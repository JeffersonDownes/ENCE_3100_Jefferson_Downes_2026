import com.cburch.logisim.file.*;
import com.cburch.logisim.circuit.*;
import com.cburch.logisim.comp.*;
import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.std.wiring.Pin;
import com.cburch.logisim.proj.Project;
import com.cburch.logisim.tools.*;
import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

/** Uses the installed Logisim simulator; no independent circuit emulation. */
public class CircuitCheck {
  static String attr(Component c, String key) {
    var a=c.getAttributeSet(); var k=a.getAttribute(key);
    return k==null ? "" : String.valueOf(a.getValue(k));
  }
  static void dump(Component c) {
    System.out.print(c.getFactory().getName()+" "+c.getLocation()+" ");
    for (var a:c.getAttributeSet().getAttributes())
      System.out.print(a.getName()+"="+c.getAttributeSet().getValue(a)+"; ");
    System.out.println();
    int i=0;
    for (var e:c.getEnds()) System.out.println("  port "+(i++)+" "+e.getLocation()+" width="+e.getWidth()+" type="+e.getType());
  }
  static Value tunnelValue(CircuitState state,String label) {
    for(var c:state.getCircuit().getNonWires())
      if(c.getFactory().getName().equals("Tunnel") && attr(c,"label").equals(label))return state.getValue(c.getLocation());
    return null;
  }
  static void checkIndicators(CircuitState state) throws Exception {
    for(var c:state.getCircuit().getNonWires()) {
      var label=attr(c,"label");
      if(c.getFactory().getName().equals("7-Segment Display")) {
        Value expected=tunnelValue(state,label+"_SEG");
        if(expected==null && state.getCircuit().getName().equals("Part_II")) {
          String prefix=c.getLocation().getY()<300?"d":"s";long mask=0;
          for(int i=0;i<7;i++) {var v=tunnelValue(state,prefix+i);if(!v.isFullyDefined())throw new Exception("Undefined original display signal");mask|=v.toLongValue()<<i;}
          expected=Value.createKnown(BitWidth.create(8),mask);
        }
        if(expected!=null && expected.isFullyDefined())for(int i=0;i<8;i++) {
          Value actual=state.getValue(c.getEnd(i).getLocation());
          if(!actual.isFullyDefined() || actual.toLongValue()!=((expected.toLongValue()>>i)&1))throw new Exception(state.getCircuit().getName()+" display "+label+" segment "+i+" wiring mismatch: "+actual);
        }
      }
      if(c.getFactory().getName().equals("LED") && label.matches("LED[RG][0-9]+")) {
        String prefix=label.substring(0,4);int bit=Integer.parseInt(label.substring(4));
        Value bus=tunnelValue(state,prefix);
        if(label.equals("LEDG8")){bus=tunnelValue(state,"ERROR");bit=0;}
        if(bus!=null && bus.isFullyDefined()) {
          Value actual=state.getValue(c.getEnd(0).getLocation());
          if(!actual.isFullyDefined() || actual.toLongValue()!=((bus.toLongValue()>>bit)&1))throw new Exception(label+" wiring mismatch");
        }
      }
    }
    for(var sub:state.getSubstates())checkIndicators(sub);
  }
  public static void main(String[] args) throws Exception {
    try { run(args); } catch(Throwable ex) { ex.printStackTrace(); System.exit(1); }
  }
  public static void run(String[] args) throws Exception {
    java.util.logging.Logger.getLogger("java.util.prefs").setLevel(java.util.logging.Level.OFF);
    var loader=new Loader(null);
    var file=loader.openLogisimFile(new File(args[0]));
    if(args[1].equals("catalog")) {
      var names=Set.of("Adder","Subtractor","Comparator","Multiplexer","Splitter","7-Segment Display","LED","NOT Gate","XOR Gate");
      for(var lib:file.getLibraries()) for(var t:lib.getTools())
        if(t instanceof AddTool at && names.contains(at.getFactory().getName()))
          dump(at.getFactory().createComponent(Location.create(400,400,true),at.getFactory().createAttributeSet()));
      System.exit(0);
    }
    var circuit=file.getCircuit(args[2]);
    if(args[1].equals("inspect")) {
      for(var c:circuit.getNonWires()) if(!c.getFactory().getName().equals("Tunnel")) dump(c);
      System.exit(0);
    }
    var project=new Project(file);
    var state=CircuitState.createRootState(project,circuit,Thread.currentThread());
    Map<String,Component> pins=new HashMap<>();
    for(var c:circuit.getNonWires()) if(c.getFactory() instanceof Pin) pins.put(attr(c,"label"),c);
    if(args[1].equals("test")) {
      var rows=Files.readAllLines(Path.of(args[3]));
      var headers=rows.get(0).split(","); int count=0, failures=0;
      for(int row=1;row<rows.size();row++) {
        if(rows.get(row).isBlank())continue;
        var vals=rows.get(row).split(",");
        for(int i=0;i<headers.length;i++) {
          var c=pins.get(headers[i]);
          if(c!=null && Pin.FACTORY.isInputPin(Instance.getInstanceFor(c))) {
            Pin.FACTORY.driveInputPin(state.getInstanceState(c),Value.createKnown(c.getEnd(0).getWidth(),Long.decode(vals[i])));
            state.markComponentAsDirty(c);
          }
        }
        state.getPropagator().propagate();
        if(state.getPropagator().isOscillating())throw new Exception("Oscillation");
        checkIndicators(state);
        if(circuit.getWidthIncompatibilityData()!=null && !circuit.getWidthIncompatibilityData().isEmpty())throw new Exception("Width mismatch: "+circuit.getWidthIncompatibilityData());
        for(int i=0;i<headers.length;i++) {
          var c=pins.get(headers[i]);
          if(c!=null && Pin.FACTORY.isInputPin(Instance.getInstanceFor(c)))continue;
          Value v;
          if(c!=null) v=state.getValue(c.getLocation());
          else if(headers[i].startsWith("T:")) {
            String name=headers[i].substring(2);
            var t=circuit.getNonWires().stream().filter(x->x.getFactory().getName().equals("Tunnel") && attr(x,"label").equals(name)).findFirst().orElseThrow();
            v=state.getValue(t.getLocation());
          } else throw new Exception("Unknown output "+headers[i]);
          if(vals[i].equals("*"))continue;
          if(!v.isFullyDefined() || v.toLongValue()!=Long.decode(vals[i])) {
            failures++;
            if(failures<=10)System.out.println("FAIL "+circuit.getName()+" row "+row+" ["+rows.get(row)+"] "+headers[i]+" expected="+vals[i]+" actual="+v);
          }
        }
        count++;
      }
      if(failures>0)throw new Exception(failures+" mismatches in "+count+" vectors");
      System.out.println("PASS "+circuit.getName()+": "+count+" vectors");
    } else if(args[1].equals("render")) {
      for(int i=4;i<args.length;i++) {
        var kv=args[i].split("="); var c=pins.get(kv[0]);
        Pin.FACTORY.driveInputPin(state.getInstanceState(c),Value.createKnown(c.getEnd(0).getWidth(),Long.decode(kv[1])));
        state.markComponentAsDirty(c);
      }
      state.getPropagator().propagate();
      var probe=new BufferedImage(10,10,BufferedImage.TYPE_INT_RGB).createGraphics();
      var b=circuit.getBounds(probe); probe.dispose();
      var img=new BufferedImage(b.getWidth()+80,b.getHeight()+80,BufferedImage.TYPE_INT_RGB);
      var g=img.createGraphics();g.setColor(java.awt.Color.WHITE);g.fillRect(0,0,img.getWidth(),img.getHeight());
      g.translate(40-b.getX(),40-b.getY());
      g.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING,java.awt.RenderingHints.VALUE_ANTIALIAS_ON);
      var ctx=new ComponentDrawContext(new javax.swing.JPanel(),circuit,state,g,g);
      ctx.setShowState(true);circuit.draw(ctx,Collections.emptySet());g.dispose();
      ImageIO.write(img,"png",new File(args[3]));
      System.out.println("RENDER "+circuit.getName()+" "+img.getWidth()+"x"+img.getHeight());
    }
    System.exit(0);
  }
}

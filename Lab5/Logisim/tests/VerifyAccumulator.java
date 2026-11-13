import com.cburch.logisim.file.*;
import com.cburch.logisim.proj.*;
import com.cburch.logisim.circuit.*;
import com.cburch.logisim.comp.*;
import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.std.wiring.Pin;
import java.io.*;
import java.util.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
class VerifyAccumulator {
 static CircuitState s; static Map<String,Component> pins=new HashMap<>(); static int checks=0;
 static void drive(String n,int v){var c=pins.get(n);((Pin)c.getFactory()).driveInputPin(s.getInstanceState(c),Value.createKnown(c.getEnd(0).getWidth(),v));s.markComponentAsDirty(c);s.getPropagator().propagate();if(s.getPropagator().isOscillating())throw new AssertionError("Oscillation");}
 static void expect(String n,int v){var c=pins.get(n);var a=((Pin)c.getFactory()).getValue(s.getInstanceState(c));if(!a.isFullyDefined()||a.toLongValue()!=v)throw new AssertionError(n+" expected "+v+" got "+a);checks++;}
 static void check(int a,int sum,int carry){expect("A_stored",a);expect("S",sum);expect("Overflow",carry);}
 public static void main(String[] args)throws Exception{
 var f=new Loader(null).openLogisimFile(new File(args[0]));var p=new Project(f);var c=f.getMainCircuit();s=CircuitState.createRootState(p,c,Thread.currentThread());
 for(var co:c.getNonWires())if(co.getFactory() instanceof Pin)pins.put(co.getAttributeSet().getValue(StdAttr.LABEL),co);
 drive("Clock",0);drive("Reset_n",0);drive("A",5);check(0,0,0);drive("Reset_n",1);check(0,0,0);
 drive("Clock",1);check(5,0,0);drive("A",9);check(5,0,0);drive("Clock",0);check(5,0,0);drive("Clock",1);check(9,5,0);
 drive("Clock",0);drive("Clock",1);check(9,14,0);drive("Reset_n",0);check(0,0,0);
 drive("Clock",0);drive("A",250);drive("Reset_n",1);drive("Clock",1);check(250,0,0);
 drive("Clock",0);drive("A",10);drive("Clock",1);check(10,250,0);
 drive("Clock",0);drive("A",0);drive("Clock",1);check(0,4,1);drive("Clock",0);check(0,4,1);drive("Clock",1);check(0,4,0);
 Random r=new Random(5);int oldA=0,sum=4,carry=0;
 for(int i=0;i<1000;i++){int a=r.nextInt(256);drive("A",a);check(oldA,sum,carry);drive("Clock",0);check(oldA,sum,carry);drive("Clock",1);int total=oldA+sum;oldA=a;sum=total&255;carry=total>>>8;check(oldA,sum,carry);if(i%79==0){drive("Reset_n",0);oldA=sum=carry=0;check(0,0,0);drive("Reset_n",1);}}
 if(c.getWidthIncompatibilityData()!=null && !c.getWidthIncompatibilityData().isEmpty())throw new AssertionError("Width mismatch");
 drive("Reset_n",0);drive("Clock",0);drive("A",0);drive("Reset_n",1);check(0,0,0);
 var im=new BufferedImage(1150,740,BufferedImage.TYPE_INT_RGB);var g=im.createGraphics();g.setColor(java.awt.Color.WHITE);g.fillRect(0,0,1150,740);g.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING,java.awt.RenderingHints.VALUE_ANTIALIAS_ON);var ctx=new ComponentDrawContext(null,c,s,g,g);ctx.setShowState(true);c.draw(ctx,null);ImageIO.write(im,"png",new File(args[1]));g.dispose();
 System.out.println("PASS: "+checks+" assertions; 1000 randomized rising edges; asynchronous reset, input latency, falling-edge hold, carry and width checks. Rendered with Logisim engine.");System.exit(0);
 }
}




"""Build editable Logisim 4.1 schematics from the preserved Part II project."""
from pathlib import Path
import xml.etree.ElementTree as E
from copy import deepcopy
import csv

ROOT=Path(__file__).resolve().parents[1]
tree=E.parse(ROOT/'Lab_2_Part_2_Solutions.circ'); project=tree.getroot()
FONT='SansSerif plain 12'
SEG=[0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f]
def a(el,k,v): E.SubElement(el,'a',name=k,val=str(v).lower() if isinstance(v,bool) else str(v))
def comp(c,name,x,y,lib=None,**attrs):
    d={'name':name,'loc':f'({x},{y})'}
    if lib is not None:d['lib']=str(lib)
    e=E.SubElement(c,'comp',d)
    for k,v in attrs.items():a(e,k,v)
    return e
def wire(c,p,q):
    if p!=q:E.SubElement(c,'wire',{'from':f'({p[0]},{p[1]})','to':f'({q[0]},{q[1]})'})
def text(c,x,y,s,size=16):comp(c,'Text',x,y,9,text=s,font=f'SansSerif {"bold" if size>14 else "plain"} {size}',halign='left')
def tunnel(c,x,y,net,w=1,facing='west'):comp(c,'Tunnel',x,y,0,label=net,width=w,facing=facing,labelfont=FONT)
def endpoint(c,p,net,w=1,side='in',length=40):
    x,y=p; q=(x-length,y) if side=='in' else (x+length,y)
    wire(c,p,q);tunnel(c,*q,net,w,'east' if side=='in' else 'west')
def pin(c,x,y,label,w=1,out=False,net=None):
    comp(c,'Pin',x,y,0,label=label,width=w,type='output' if out else 'input',facing='west' if out else 'east',labelloc='east' if out else 'west',labelfont=FONT,appearance='classic')
    if net:endpoint(c,(x,y),net,w,'in' if out else 'out')
def const(c,x,y,v,w=1):comp(c,'Constant',x,y,0,value=hex(v),width=w)
def circuit(name,title,subtitle):
    c=E.SubElement(project,'circuit',name=name)
    for k,v in [('appearance','logisim_evolution'),('circuit',name),('circuitnamedboxfixedsize',True)]:a(c,k,v)
    text(c,70,40,title,22);text(c,70,70,subtitle,13)
    return c
def split(c,x,y,net,w,bits,spacing=2):
    comp(c,'Splitter',x,y,0,fanout=w,incoming=w,facing='east',appear='left',spacing=spacing)
    endpoint(c,(x,y),net,w)
    for i,n in enumerate(bits):
        if n is not None:endpoint(c,(x+20,y-10-(w-1-i)*10*spacing),n,1,'out',30)
def group(c,x,y,net,w,groups):
    # groups: ordered (net, number of bits), low bits first.
    e=comp(c,'Splitter',x,y,0,fanout=len(groups),incoming=w,facing='east',appear='left',spacing=3)
    idx=0
    for j,(_,n) in enumerate(groups):
        for _ in range(n):a(e,f'bit{idx}',j);idx+=1
    endpoint(c,(x,y),net,w)
    for i,(n,b) in enumerate(groups):endpoint(c,(x+20,y-10-(len(groups)-1-i)*30),n,b,'out',40)
def gate(c,kind,x,y,ins,out):
    if kind=='NOT Gate':
        comp(c,kind,x,y,1,size=30);endpoint(c,(x-30,y),ins[0]);endpoint(c,(x,y),out,side='out');return
    comp(c,kind,x,y,1,size=30,inputs=len(ins))
    offsets={2:[-10,10],3:[-10,0,10],4:[-20,-10,10,20]}[len(ins)]
    for n,dy in zip(ins,offsets):endpoint(c,(x-(40 if kind=='XOR Gate' else 30),y+dy),n,length=50)
    endpoint(c,(x,y),out,side='out')
def sub(c,name,x,y,ins,outs,label=None):
    comp(c,name,x,y,label=label or '',labelfont=FONT)
    for i,(net,w) in enumerate(ins):endpoint(c,(x-220,y+20*i),net,w)
    for i,(net,w) in enumerate(outs):
        if net:endpoint(c,(x,y+20*i),net,w,'out')
def mux(c,x,y,n0,n1,sel,out,w=4):
    comp(c,'Multiplexer',x,y,2,width=w,select=1,enable=False)
    endpoint(c,(x-30,y-10),n0,w);endpoint(c,(x-30,y+10),n1,w)
    wire(c,(x-20,y+20),(x-20,y+50));tunnel(c,x-20,y+50,sel,1,'north')
    endpoint(c,(x,y),out,w,'out')
def arithmetic(c,kind,x,y,n0,n1,out,w=5,carry='ZERO',cout=None):
    comp(c,kind,x,y,3,width=w)
    endpoint(c,(x-40,y-10),n0,w);endpoint(c,(x-40,y+10),n1,w)
    wire(c,(x-20,y-20),(x-20,y-50));tunnel(c,x-20,y-50,carry,1,'south')
    endpoint(c,(x,y),out,w,'out')
    if cout:wire(c,(x-20,y+20),(x-20,y+50));tunnel(c,x-20,y+50,cout,1,'north')
def compare(c,x,y,n0,n1,gt,w=5):
    comp(c,'Comparator',x,y,3,width=w,mode='unsigned')
    endpoint(c,(x-40,y-10),n0,w);endpoint(c,(x-40,y+10),n1,w)
    endpoint(c,(x,y-10),gt,1,'out')
def zero(c,x=160,y=650):const(c,x,y,0);endpoint(c,(x,y),'ZERO',side='out')
def display(c,x,y,net,label):
    # One native 7-segment display, with short tunnels for every segment.
    comp(c,'7-Segment Display',x,y,6,label=label,labelvisible=True,labelloc='east',labelfont='SansSerif bold 16',decimalPoint=True)
    offsets=[(20,0),(30,0),(20,60),(10,60),(0,60),(10,0),(0,0),(30,60)]
    # Pin rows fan out above/below without intersecting the symbol.
    for i,(dx,dy) in enumerate(offsets):
        xx=x+dx; yy=y+dy; j=dx//10
        outy=y-20-10*j if dy==0 else y+90+10*j
        tx=x-70+60*j;ty=y-60 if dy==0 else y+150
        wire(c,(xx,yy),(xx,outy));wire(c,(xx,outy),(tx,outy));wire(c,(tx,outy),(tx,ty))
        tunnel(c,tx,ty,f'{label.replace("HEX","H")}{i}',1,'south' if dy==0 else 'north')
    split(c,x-190,y+130,net,8,[f'{label.replace("HEX","H")}{i}' for i in range(8)],spacing=2)
def display_row(c,x,y,digits):
    # Each column has its own BCD decoder and seven-segment display.
    for i,(net,label) in enumerate(digits):
        xx=x+i*400
        text(c,xx-210,y-40,f'{label}  |  {net}',16)
        sub(c,'BCD_Display',xx,y,[(net,4)],[(label+'_SEG',8)])
        display(c,xx-50,y+170,label+'_SEG',label)
def led_bank(c,x,y,net,w,prefix,color='#00b000'):
    sy=y+20*w-10
    comp(c,'Splitter',x,sy,0,fanout=w,incoming=w,facing='east',appear='left',spacing=2)
    endpoint(c,(x,sy),net,w)
    for i in range(w):
        yy=y+20*i
        comp(c,'LED',x+190,yy,6,label=f'{prefix}{i}',labelvisible=True,labelfont=FONT,color=color)
        wire(c,(x+20,yy),(x+190,yy))

def remove_tunnels(c,net):
    for e in list(c.findall('comp')):
        if e.get('name')=='Tunnel' and any(x.get('name')=='label' and x.get('val')==net for x in e.findall('a')):c.remove(e)

# Repair the original decoder's missing digit-7 term in segment f (bit 5).
decoder=next(c for c in project.findall('circuit') if c.get('name')=='Seg7_Decoder')
or_f=next(e for e in decoder.findall('comp') if e.get('loc')=='(440,420)')
a(or_f,'inputs',3)
wire(decoder,(130,150),(650,150));tunnel(decoder,650,150,'fix_v1')
wire(decoder,(130,180),(620,180));tunnel(decoder,620,180,'fix_v0')
gate(decoder,'AND Gate',850,420,['fix_v1','fix_v0'],'fix_f7')
remove_tunnels(decoder,'fix_f7')
wire(decoder,(850,420),(850,470));wire(decoder,(400,470),(850,470));wire(decoder,(400,420),(400,470));wire(decoder,(400,420),(410,420))
text(decoder,690,340,'Segment f correction',16)
text(decoder,690,365,'Add v1 AND v0: turns f off for digit 7.',13)

part2=next(c for c in project.findall('circuit') if c.get('name')=='main')
part2.set('name','Part_II')
next(e for e in part2.findall('a') if e.get('name')=='circuit').set('val','Part_II')
text(part2,100,35,'PART II  |  Four-bit binary to decimal',22)
text(part2,100,65,'Poke v3..v0 to try 0 through 15. Repaired decoder digit 7 and tied m3 mux input 1 to zero.',13)
const(part2,520,360,0);wire(part2,(520,360),(560,360))
for xx,yy in [(1340,240),(1350,630)]:
    wire(part2,(xx,yy),(xx+70,yy));const(part2,xx+70,yy,0)
project.find('main').set('name','Part_II')

c=circuit('BCD_Display','BCD to seven-segment display driver','Reuses the gate-level decoder. SEG[6:0] = g f e d c b a; SEG[7] = decimal point (off).')
pin(c,160,130,'BCD',4,net='BCD');pin(c,1000,130,'SEG',8,True,'SEG')
split(c,260,340,'BCD',4,['b0','b1','b2','b3'])
sub(c,'Seg7_Decoder',650,210,[(f'b{i}',1) for i in [3,2,1,0]],[('ACTIVE_LOW',8)])
comp(c,'NOT Gate',870,210,1,width=8,size=30)
endpoint(c,(840,210),'ACTIVE_LOW',8);endpoint(c,(870,210),'SEG',8,'out')
remove_tunnels(c,'ACTIVE_LOW');wire(c,(650,210),(840,210))
text(c,730,270,'Invert for Logisim active-high LEDs.',13)

c=circuit('Full_Adder','FULL ADDER  |  Figure 2a','s = a XOR b XOR cin; cout = (a XOR b) ? cin : b. Two XOR gates and one 2:1 mux.')
for i,n in enumerate(['a','b','cin']):pin(c,150,130+40*i,n,net=n)
pin(c,940,130,'s',out=True,net='s');pin(c,940,170,'cout',out=True,net='cout')
gate(c,'XOR Gate',440,280,['a','b'],'p')
gate(c,'XOR Gate',740,230,['p','cin'],'s')
mux(c,740,400,'b','cin','p','cout',1)
remove_tunnels(c,'p')
wire(c,(440,280),(520,280));wire(c,(520,220),(520,450));wire(c,(520,220),(700,220));wire(c,(520,450),(720,450))
text(c,600,510,'Select 0: propagate b. Select 1: propagate cin.',13)

c=circuit('Ripple_Adder_4','FOUR-BIT RIPPLE-CARRY ADDER','Four instances of Full_Adder. The carry propagates from bit 0 (left) to bit 3 (right).')
for i,(n,w) in enumerate([('A',4),('B',4),('cin',1)]):pin(c,160,130+40*i,n,w,net=n)
pin(c,1780,130,'S',4,True,'S');pin(c,1780,170,'cout',1,True,'cout')
split(c,330,240,'A',4,[f'a{i}' for i in range(4)])
split(c,640,240,'B',4,[f'b{i}' for i in range(4)])
for i in range(4):
    sub(c,'Full_Adder',430+400*i,370,[(f'a{i}',1),(f'b{i}',1),('cin' if i==0 else f'c{i}',1)],[(f's{i}',1),('cout' if i==3 else f'c{i+1}',1)],f'FA{i}')
for i in range(3):
    remove_tunnels(c,f'c{i+1}');xx=430+400*i
    wire(c,(xx,390),(xx+80,390));wire(c,(xx+80,390),(xx+80,410));wire(c,(xx+80,410),(xx+180,410))
split(c,1500,630,'S',4,[f's{i}' for i in range(4)])
text(c,180,700,'Open Full_Adder to inspect its XOR / mux implementation.',13)

c=circuit('BCD_Adder_1','ONE-DIGIT BCD ADDER','A + B + cin = 0..19. Add 6 to the raw low nibble when decimal carry k is asserted.')
for i,(n,w) in enumerate([('A',4),('B',4),('cin',1)]):pin(c,160,130+40*i,n,w,net=n)
for i,(n,w) in enumerate([('S0',4),('S1',1),('RAW',4),('C4',1),('ERROR',1)]):pin(c,1350,130+40*i,n,w,True,n)
sub(c,'Ripple_Adder_4',470,290,[('A',4),('B',4),('cin',1)],[('RAW',4),('C4',1)],'Binary sum')
split(c,350,550,'RAW',4,[f'r{i}' for i in range(4)])
gate(c,'OR Gate',620,440,['r2','r1'],'r21')
gate(c,'AND Gate',830,440,['r3','r21'],'above9')
gate(c,'OR Gate',1060,440,['C4','above9'],'S1')
split(c,700,680,'CORRECTION',4,['ZERO','S1','S1','ZERO'])
zero(c,160,670)
sub(c,'Ripple_Adder_4',1140,630,[('RAW',4),('CORRECTION',4),('ZERO',1)],[('S0',4),(None,1)],'BCD correction')
split(c,300,880,'A',4,[f'A{i}' for i in range(4)])
split(c,300,1040,'B',4,[f'B{i}' for i in range(4)])
sub(c,'myComparator',870,790,[(f'A{i}',1) for i in [3,2,1,0]],[('badA',1)],'A > 9')
sub(c,'myComparator',870,950,[(f'B{i}',1) for i in [3,2,1,0]],[('badB',1)],'B > 9')
gate(c,'OR Gate',1160,870,['badA','badB'],'ERROR')
text(c,180,1120,'S1 = C4 OR (r3 AND (r2 OR r1)). Invalid BCD inputs assert ERROR; decimal sum is then unspecified.',13)

c=circuit('BCD_Adder_2','TWO-DIGIT BCD ADDER  |  Part V core','Two instances of the Part IV adder. Decimal carry from the units stage feeds the tens stage.')
for i,n in enumerate(['A1','A0','B1','B0']):pin(c,160,130+40*i,n,4,net=n)
for i,(n,w) in enumerate([('S0',4),('S1',4),('S2',4),('ERROR',1)]):pin(c,1120,130+40*i,n,w,True,n)
zero(c,170,630)
sub(c,'BCD_Adder_1',470,390,[('A0',4),('B0',4),('ZERO',1)],[('S0',4),('carry1',1),(None,4),(None,1),('e0',1)],'Units digit')
sub(c,'BCD_Adder_1',950,390,[('A1',4),('B1',4),('carry1',1)],[('S1',4),('carry2',1),(None,4),(None,1),('e1',1)],'Tens digit')
split(c,750,690,'S2',4,['carry2','ZERO','ZERO','ZERO'])
gate(c,'OR Gate',1040,660,['e0','e1'],'ERROR')

c=circuit('Algorithm_Digit','ALGORITHMIC DECIMAL DIGIT  |  Part VI stage','T = A + B + cin; carry = T > 9; Z = carry ? 10 : 0; S = T - Z.')
for i,(n,w) in enumerate([('A',4),('B',4),('cin',1)]):pin(c,150,130+40*i,n,w,net=n)
pin(c,1220,130,'S',4,True,'S');pin(c,1220,170,'carry',1,True,'carry')
zero(c,150,720)
group(c,300,360,'A5',5,[('A',4),('ZERO',1)])
group(c,300,510,'B5',5,[('B',4),('ZERO',1)])
arithmetic(c,'Adder',550,290,'A5','B5','T',5,'cin')
const(c,490,520,9,5);endpoint(c,(490,520),'NINE',5,'out')
compare(c,760,400,'T','NINE','carry',5)
const(c,660,640,0,5);endpoint(c,(660,640),'ZERO5',5,'out')
const(c,660,690,10,5);endpoint(c,(660,690),'TEN',5,'out')
mux(c,910,600,'ZERO5','TEN','carry','Z',5)
arithmetic(c,'Subtractor',1060,290,'T','Z','S5',5)
group(c,1030,820,'S5',5,[('S',4),('unused',1)])
text(c,80,890,'Five-bit arithmetic preserves the carry at 16..19. All comparators use unsigned mode.',13)

c=circuit('Algorithm_BCD_2','ALGORITHMIC TWO-DIGIT BCD ADDER','Part VI visual counterpart: two comparator / mux / subtractor stages, with decimal carry between them.')
for i,n in enumerate(['A1','A0','B1','B0']):pin(c,160,130+40*i,n,4,net=n)
for i,n in enumerate(['S0','S1','S2']):pin(c,1110,130+40*i,n,4,True,n)
zero(c,170,630)
sub(c,'Algorithm_Digit',470,390,[('A0',4),('B0',4),('ZERO',1)],[('S0',4),('carry1',1)],'Units: T0 / Z0')
sub(c,'Algorithm_Digit',950,390,[('A1',4),('B1',4),('carry1',1)],[('S1',4),('carry2',1)],'Tens: T1 / Z1')
split(c,760,680,'S2',4,['carry2','ZERO','ZERO','ZERO'])

c=circuit('Subtract_10_Stage','CONDITIONAL SUBTRACT-10 STAGE','If V >= 10: R = V - 10 and hit = 1; otherwise R = V and hit = 0. Six-bit unsigned arithmetic.')
pin(c,140,130,'V',6,net='V');pin(c,1050,130,'R',6,True,'R');pin(c,1050,170,'hit',1,True,'hit')
zero(c,150,600)
const(c,270,260,9,6);endpoint(c,(270,260),'NINE',6,'out')
const(c,270,490,10,6);endpoint(c,(270,490),'TEN',6,'out')
compare(c,530,280,'V','NINE','hit',6)
arithmetic(c,'Subtractor',530,440,'V','TEN','MINUS10',6)
mux(c,840,390,'V','MINUS10','hit','R',6)

c=circuit('Binary6_BCD','SIX-BIT BINARY TO BCD  |  Part VII core','Six conditional subtract-10 stages produce a remainder below 10. The number of successful stages is the tens digit.')
pin(c,160,130,'V',6,net='V');pin(c,1280,130,'D0',4,True,'D0');pin(c,1280,170,'D1',4,True,'D1')
zero(c,160,830)
for i in range(6):
    xx=420+(i%3)*430;yy=300+(i//3)*220
    sub(c,'Subtract_10_Stage',xx,yy,[('V' if i==0 else f'R{i}',6)],[(f'R{i+1}',6),(f'h{i+1}',1)],f'Stage {i+1}')
group(c,340,810,'R6',6,[('D0',4),('discard',2)])
for i in range(6):
    xx=200+(i%3)*420;yy=1030+(i//3)*210
    split(c,xx,yy,f'H{i+1}',4,[f'h{i+1}','ZERO','ZERO','ZERO'])
const(c,180,1320,0,4);endpoint(c,(180,1320),'COUNT0',4,'out')
for i in range(6):
    xx=360+(i%3)*420; yy=1430+(i//3)*180
    arithmetic(c,'Adder',xx,yy,f'COUNT{i}',f'H{i+1}','D1' if i==5 else f'COUNT{i+1}',4)
text(c,80,1730,'Input range: 000000 (00) through 111111 (63). All six hit bits are counted; no ROM or lookup table.',13)

# User-facing lab circuits.
c=circuit('Part_I','PART I  |  Four independent decimal displays','Each group of four switches drives its matching display. Digits 0..9 are defined; inputs 10..15 are don\'t-cares.')
for i,hi in enumerate([15,11,7,3]):pin(c,180+330*i,150,f'SW{hi}_{hi-3}',4,net=f'D{3-i}')
display_row(c,340,280,[(f'D{i}',f'HEX{i}') for i in [3,2,1,0]])

c=circuit('Part_III','PART III  |  Four-bit ripple-carry adder','SW7..4 = A, SW3..0 = B, SW8 = cin. Red LEDs mirror inputs; green LEDs show cout and S.')
for i,(n,w,net) in enumerate([('SW7_4',4,'A'),('SW3_0',4,'B'),('SW8',1,'cin')]):pin(c,160,140+40*i,n,w,net=net)
sub(c,'Ripple_Adder_4',660,300,[('A',4),('B',4),('cin',1)],[('S',4),('cout',1)])
pin(c,1040,140,'S',4,True,'S');pin(c,1040,180,'cout',1,True,'cout')
group(c,250,530,'LEDR',9,[('B',4),('A',4),('cin',1)])
group(c,680,530,'LEDG',5,[('S',4),('cout',1)])
led_bank(c,230,650,'LEDR',9,'LEDR','#f00000');led_bank(c,760,650,'LEDG',5,'LEDG')

c=circuit('Part_IV','PART IV  |  One-digit BCD addition','SW7..4 = A, SW3..0 = B, SW8 = cin. HEX6 + HEX4 + cin = HEX1 HEX0. LEDG8 flags invalid BCD input.')
for i,(n,w,net) in enumerate([('SW7_4',4,'A'),('SW3_0',4,'B'),('SW8',1,'cin')]):pin(c,160,140+40*i,n,w,net=net)
sub(c,'BCD_Adder_1',650,170,[('A',4),('B',4),('cin',1)],[('S0',4),('carry',1),('RAW',4),('C4',1),('ERROR',1)])
zero(c,950,340)
split(c,970,270,'S1',4,['carry','ZERO','ZERO','ZERO'])
for i,(n,w) in enumerate([('S0',4),('S1',4),('ERROR',1)]):pin(c,1320,140+40*i,n,w,True,n)
display_row(c,330,420,[('A','HEX6'),('B','HEX4'),('S1','HEX1'),('S0','HEX0')])
group(c,210,910,'LEDR',9,[('B',4),('A',4),('cin',1)])
group(c,600,910,'LEDG',5,[('RAW',4),('C4',1)])
led_bank(c,240,1020,'LEDR',9,'LEDR','#f00000');led_bank(c,730,1020,'LEDG',5,'LEDG')
comp(c,'LED',1210,950,6,label='LEDG8',labelvisible=True,color='#00b000',labelfont=FONT)
endpoint(c,(1210,950),'ERROR')
text(c,1150,990,'Invalid BCD input',13)
text(c,1040,1030,'Valid digits: 0..9',13);text(c,1040,1060,'Maximum sum: 9 + 9 + 1 = 19',13)

for name,core,desc in [('Part_V','BCD_Adder_2','Two cascaded Part IV BCD adders.'),('Part_VI','Algorithm_BCD_2','Two arithmetic / comparator / mux stages matching the PDF pseudo-code.')]:
    c=circuit(name,f'PART {name.split("_")[1]}  |  Two-digit BCD addition',desc+'  Inputs are packed BCD: 0x99 means decimal 99.')
    pin(c,180,140,'SW15_8',8,net='A');pin(c,180,180,'SW7_0',8,net='B')
    group(c,340,300,'A',8,[('A0',4),('A1',4)])
    group(c,650,300,'B',8,[('B0',4),('B1',4)])
    outs=[('S0',4),('S1',4),('S2',4)]+([('ERROR',1)] if name=='Part_V' else [])
    sub(c,core,1030,150,[(n,4) for n in ['A1','A0','B1','B0']],outs)
    for i,(n,w) in enumerate(outs):pin(c,1330,140+40*i,n,w,True,n)
    display_row(c,330,440,[('A1','HEX7'),('A0','HEX6'),('B1','HEX5'),('B0','HEX4')])
    display_row(c,670,920,[('S2','HEX2'),('S1','HEX1'),('S0','HEX0')])
    text(c,80,880,'SUM  |  Hundreds, tens, units',20)
    text(c,80,1370,'Example: SW15_8 = 1001 1001 and SW7_0 = 1001 1001 displays 99 + 99 = 198.',13)

c=circuit('Part_VII','PART VII  |  Six-bit binary to two decimal digits','Poke SW5..0 to try every value from 0 to 63. HEX1 is tens and HEX0 is units.')
pin(c,180,140,'SW5_0',6,net='V')
sub(c,'Binary6_BCD',630,200,[('V',6)],[('D0',4),('D1',4)])
pin(c,1020,140,'D0',4,True,'D0');pin(c,1020,180,'D1',4,True,'D1')
display_row(c,380,400,[('D1','HEX1'),('D0','HEX0')])

# Present lab parts first, then reusable implementation circuits.
circuits=project.findall('circuit')
for cc in circuits:project.remove(cc)
order=['Part_I','Part_II','Part_III','Part_IV','Part_V','Part_VI','Part_VII','Full_Adder','Ripple_Adder_4','BCD_Adder_1','BCD_Adder_2','Algorithm_Digit','Algorithm_BCD_2','Binary6_BCD','Subtract_10_Stage','BCD_Display','Seg7_Decoder','myComparator','CircuitA','CircuitB']
for name in order:project.append(next(cc for cc in circuits if cc.get('name')==name))
E.indent(tree,space='  ')
tree.write(ROOT/'Lab_2_Solutions.circ',encoding='UTF-8',xml_declaration=True)

def vectors(name,headers,rows):
    with (ROOT/'tests'/f'{name}.csv').open('w',newline='') as f:
        w=csv.writer(f);w.writerow(headers);w.writerows(rows)
vectors('full_adder',['a','b','cin','s','cout'],((a,b,k,(a+b+k)%2,(a+b+k)//2) for a in range(2) for b in range(2) for k in range(2)))
vectors('ripple',['A','B','cin','S','cout'],((a,b,k,(a+b+k)%16,(a+b+k)//16) for a in range(16) for b in range(16) for k in range(2)))
vectors('bcd1',['A','B','cin','S0','S1','RAW','C4','ERROR'],((a,b,k,(a+b+k)%10 if max(a,b)<10 else '*',(a+b+k)//10 if max(a,b)<10 else '*',(a+b+k)%16,(a+b+k)//16,int(max(a,b)>9)) for a in range(16) for b in range(16) for k in range(2)))
vectors('bcd2',['A1','A0','B1','B0','S0','S1','S2','ERROR'],((a//10,a%10,b//10,b%10,(a+b)%10,((a+b)//10)%10,(a+b)//100,0) for a in range(100) for b in range(100)))
vectors('algorithm_digit',['A','B','cin','S','carry'],((a,b,k,(a+b+k)%10,(a+b+k)//10) for a in range(10) for b in range(10) for k in range(2)))
vectors('algorithm2',['A1','A0','B1','B0','S0','S1','S2'],((a//10,a%10,b//10,b%10,(a+b)%10,((a+b)//10)%10,(a+b)//100) for a in range(100) for b in range(100)))
vectors('binary6',['V','D0','D1'],((v,v%10,v//10) for v in range(64)))
vectors('subtract10',['V','R','hit'],((v,v-10 if v>9 else v,int(v>9)) for v in range(64)))
vectors('display',['BCD','SEG'],enumerate(SEG))
vectors('part1',['SW15_12','SW11_8','SW7_4','SW3_0','T:HEX3_SEG','T:HEX2_SEG','T:HEX1_SEG','T:HEX0_SEG'],((a,b,c,d,SEG[a],SEG[b],SEG[c],SEG[d]) for a in range(10) for b in range(10) for c in range(10) for d in range(10)))
vectors('part3',['SW7_4','SW3_0','SW8','S','cout','T:LEDR','T:LEDG'],((a,b,k,(a+b+k)%16,(a+b+k)//16,(k<<8)|(a<<4)|b,a+b+k) for a in range(16) for b in range(16) for k in range(2)))
vectors('part4',['SW7_4','SW3_0','SW8','S0','S1','ERROR','T:LEDR','T:LEDG','T:HEX6_SEG','T:HEX4_SEG','T:HEX1_SEG','T:HEX0_SEG'],((a,b,k,(a+b+k)%10 if max(a,b)<10 else '*',(a+b+k)//10 if max(a,b)<10 else '*',int(max(a,b)>9),(k<<8)|(a<<4)|b,a+b+k,SEG[a] if a<10 else '*',SEG[b] if b<10 else '*',SEG[(a+b+k)//10] if max(a,b)<10 else '*',SEG[(a+b+k)%10] if max(a,b)<10 else '*') for a in range(16) for b in range(16) for k in range(2)))
vectors('part56',['SW15_8','SW7_0','S0','S1','S2','T:HEX7_SEG','T:HEX6_SEG','T:HEX5_SEG','T:HEX4_SEG','T:HEX2_SEG','T:HEX1_SEG','T:HEX0_SEG'],(((a//10)*16+a%10,(b//10)*16+b%10,(a+b)%10,((a+b)//10)%10,(a+b)//100,SEG[a//10],SEG[a%10],SEG[b//10],SEG[b%10],SEG[(a+b)//100],SEG[((a+b)//10)%10],SEG[(a+b)%10]) for a in range(100) for b in range(100)))
vectors('part7',['SW5_0','D0','D1','T:HEX1_SEG','T:HEX0_SEG'],((v,v%10,v//10,SEG[v//10],SEG[v%10]) for v in range(64)))
print(f'Wrote {len(order)} circuits and exhaustive test vectors.')

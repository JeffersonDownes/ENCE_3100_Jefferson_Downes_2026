"""Render native schematics with representative inputs using Logisim's painter."""
from pathlib import Path
import subprocess
import concurrent.futures
import xml.etree.ElementTree as E
import sys
ROOT=Path(__file__).resolve().parents[1]
JAVA=Path.home()/'.jdks/openjdk-27/bin/java.exe'
CP=str(ROOT/'tools')+';C:/Program Files/logisim-evolution/app/logisim-evolution-4.1.0-all.jar'
samples={'Part_I':['SW15_12=1','SW11_8=2','SW7_4=3','SW3_0=7'],'Part_II':['v3=1','v2=0','v1=1','v0=1'],'Part_III':['SW7_4=15','SW3_0=1','SW8=1'],'Part_IV':['SW7_4=9','SW3_0=9','SW8=1'],'Part_V':['SW15_8=0x99','SW7_0=0x99'],'Part_VI':['SW15_8=0x99','SW7_0=0x99'],'Part_VII':['SW5_0=63'],'BCD_Adder_1':['A=9','B=9','cin=1'],'BCD_Adder_2':['A1=9','A0=9','B1=9','B0=9'],'Algorithm_Digit':['A=9','B=9','cin=1'],'Algorithm_BCD_2':['A1=9','A0=9','B1=9','B0=9'],'Binary6_BCD':['V=63'],'Subtract_10_Stage':['V=63'],'Ripple_Adder_4':['A=15','B=1','cin=1'],'Full_Adder':['a=1','b=1','cin=1'],'BCD_Display':['BCD=7']}
samples['Part_II']=[]  # Show the preserved input-pin style in its initial state.
names=sys.argv[1:] or [c.get('name') for c in E.parse(ROOT/'Lab_2_Solutions.circ').findall('circuit')]
def run(name):
    result=subprocess.run([str(JAVA),'-Djava.awt.headless=true','-cp',CP,'CircuitCheck',str(ROOT/'Lab_2_Solutions.circ'),'render',name,str(ROOT/'previews'/f'{name}.png')]+samples.get(name,[]),capture_output=True,text=True,timeout=120)
    if result.returncode:raise RuntimeError(result.stderr)
    return result.stdout
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
    for r in pool.map(run,names):print(r,flush=True)

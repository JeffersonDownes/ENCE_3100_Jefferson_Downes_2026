"""Compile the Java harness, then check the saved file in Logisim's simulator."""
from pathlib import Path
import subprocess
import concurrent.futures
import sys
ROOT=Path(__file__).resolve().parents[1]
JDK=Path.home()/'.jdks/openjdk-27/bin'
JAR=Path('C:/Program Files/logisim-evolution/app/logisim-evolution-4.1.0-all.jar')
CP=str(ROOT/'tools')+';'+str(JAR)
CASES=[('Seg7_Decoder','decoder'),('Part_II','part2'),('Full_Adder','full_adder'),('Ripple_Adder_4','ripple'),('BCD_Adder_1','bcd1'),('BCD_Adder_2','bcd2'),('Algorithm_Digit','algorithm_digit'),('Algorithm_BCD_2','algorithm2'),('Subtract_10_Stage','subtract10'),('Binary6_BCD','binary6'),('BCD_Display','display'),('Part_I','part1'),('Part_III','part3'),('Part_IV','part4'),('Part_V','part56'),('Part_VI','part56'),('Part_VII','part7')]
subprocess.run([str(JDK/'javac.exe'),'-cp',str(JAR),str(ROOT/'tools/CircuitCheck.java')],check=True)
def run(case):
    c,v=case
    result=subprocess.run([str(JDK/'java.exe'),'-Djava.awt.headless=true','-cp',CP,'CircuitCheck',str(ROOT/'Lab_2_Solutions.circ'),'test',c,str(ROOT/'tests'/f'{v}.csv')],capture_output=True,text=True,timeout=240)
    return c,result.returncode,result.stdout+result.stderr
selected=[c for c in CASES if not sys.argv[1:] or c[0] in sys.argv[1:]]
results=[]
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
    for future in concurrent.futures.as_completed([pool.submit(run,c) for c in selected]):
        result=future.result();results.append(result);print(result[2],flush=True)
if len(selected)==len(CASES):
    (ROOT/'tests/verification.txt').write_text('Logisim Evolution 4.1.0 simulation results\n'+''.join(r[2] for r in sorted(results)),encoding='utf-8')
sys.exit(int(any(r[1] for r in results)))

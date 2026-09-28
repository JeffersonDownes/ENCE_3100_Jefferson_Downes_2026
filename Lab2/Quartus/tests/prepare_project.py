"""One-time cleanup of the existing DE10-Lite assignments; keep actual pin locations."""
from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[1]
main=ROOT/'main.v'
text=main.read_text(encoding='utf-8-sig')
text=re.sub(r'/\* BEGIN PART ([IVX]+)\n',r'/*\n    // BEGIN PART \1\n',text)
text=re.sub(r'^END PART ([IVX]+) \*/',r'    // END PART \1\n*/',text,flags=re.M)
main.write_text(text,encoding='utf-8')
qsf=ROOT/'main.qsf'
old=qsf.read_text()
ports={'MAX10_CLK1_50'}
for base,n in [('SW',10),('KEY',2),('LEDR',10)]+[(f'HEX{i}',8) for i in range(6)]:
    ports.update(f'{base}[{i}]' for i in range(n))
lines=[]
for line in old.splitlines():
    if line.startswith('set_global_assignment'):
        if any(s in line for s in ['-name VERILOG_FILE','-name SDC_FILE','-entity DE10_LITE_Golden_Top']):continue
        lines.append(line)
    elif line.startswith('set_location_assignment') or ('set_instance_assignment -name IO_STANDARD' in line):
        m=re.search(r'-to (\S+)',line)
        if m and m[1] in ports:
            lines.append(line.replace(' -entity DE10_LITE_Golden_Top',''))
    elif line.startswith('set_instance_assignment -name PARTITION_HIERARCHY') and '-entity' not in line:
        lines.append(line)
files=['main.v','Seg7_Decoder.v','mux_2_1.v','CircuitA.v','CircuitB.v','Binary4_BCD.v','Full_Adder.v','Ripple_Adder_4.v','BCD_Adder_1.v','BCD_Adder_2.v','BCD_Adder_Algorithm.v','Binary6_BCD.v','Switch_Registers.v']
header='# Lab 2 - existing DE10-Lite 10M50DAF484C7G pin assignments.\n# Removed stale files and ports that are not in the main module.\n'
qsf.write_text(header+'\n'.join(lines)+'\n\n'+'\n'.join('set_global_assignment -name VERILOG_FILE '+f for f in files)+'\nset_global_assignment -name SDC_FILE main.sdc\n')
assigned={re.search(r'-to (\S+)',s)[1] for s in lines if s.startswith('set_location_assignment')}
assert assigned==ports,(ports-assigned,assigned-ports)
print(f'Preserved all {len(ports)} used pin assignments; registered {len(files)} source files.')

"""Activate main.v's commented sections in temporary copies and simulate all parts."""
from pathlib import Path
import re
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[1]
BUILD=ROOT/'tests/build'
TOOLS=Path('C:/altera_lite/25.1std/questa_fse/win64')
PARTS=['I','II','III','IV','V']
BUILD.mkdir(parents=True,exist_ok=True)
source=(ROOT/'main.v').read_text(encoding='utf-8-sig')
sources=[ROOT/p for p in re.findall(r'^set_global_assignment -name VERILOG_FILE (.+)$',(ROOT/'main.qsf').read_text(),re.M) if p!='main.v']
def variant(part,rename=True):
    text=source
    if part!='idle':
        text=re.sub(r'    // BEGIN IDLE.*?    // END IDLE', '    // IDLE disabled for test.',text,flags=re.S)
        pattern=r'/\*\s*// BEGIN PART '+part+r'\n(.*?)// END PART '+part+r'\s*\*/'
        text,n=re.subn(pattern,lambda m:m[1],text,flags=re.S)
        assert n==1,(part,n)
    if rename:text=text.replace('module main(',f'module main_{"idle" if part=="idle" else "part_"+part}(')
    return text
variants=[]
for part in ['idle']+PARTS:
    p=BUILD/f'main_{part}.v';p.write_text(variant(part));variants.append(p)
def run(exe,args,log):
    r=subprocess.run([str(TOOLS/exe)]+list(map(str,args)),cwd=BUILD,capture_output=True,text=True,timeout=180)
    out=r.stdout+r.stderr;(ROOT/'tests'/log).write_text(out,encoding='utf-8')
    if r.returncode or re.search(r'\*\* (Error|Fatal):',out):
        print(out);raise SystemExit(r.returncode or 1)
    return out
if not (BUILD/'work').exists():run('vlib.exe',['work'],'vlib.log')
run('vlog.exe',['-sv','-work','work']+sources+variants+[ROOT/'tests/lab2_tb.sv'],'compile.log')
out=run('vsim.exe',['-c','-work','work','work.lab2_tb','-do','onerror {quit -code 1 -f}; onbreak {quit -code 1 -f}; run -all; quit -code 0 -f'],'simulation.log')
print('\n'.join(line for line in out.splitlines() if 'PASS' in line))
if 'ALL PASS:' not in out:raise SystemExit('Simulation did not finish successfully.')
(ROOT/'tests/verification.txt').write_text('Questa Altera Starter FPGA Edition 2025.2\n'+ '\n'.join(line.removeprefix('# ') for line in out.splitlines() if 'PASS' in line)+'\n',encoding='utf-8')

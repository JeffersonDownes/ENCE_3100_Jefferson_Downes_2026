"""Synthesize temporary copies of each main.v section with the installed Quartus."""
from pathlib import Path
import re, subprocess, sys
ROOT=Path(__file__).resolve().parents[1]
BUILD=ROOT/'tests/build/synthesis'
MAP=Path('C:/altera_lite/25.1std/quartus/bin64/quartus_map.exe')
source=(ROOT/'main.v').read_text()
qsf=(ROOT/'main.qsf').read_text()
parts=sys.argv[1:] or ['I','II','III','IV','V']
results=[]
for part in parts:
    folder=BUILD/f'part_{part}';folder.mkdir(parents=True,exist_ok=True)
    text=re.sub(r'    // BEGIN IDLE.*?    // END IDLE','    // IDLE disabled for synthesis.',source,flags=re.S)
    pattern=r'/\*\s*// BEGIN PART '+part+r'\n(.*?)// END PART '+part+r'\s*\*/'
    text,n=re.subn(pattern,lambda m:m[1],text,flags=re.S);assert n==1
    (folder/'main.v').write_text(text)
    config=qsf
    config=re.sub(r'^set_global_assignment -name VERILOG_FILE (.+)$',lambda m:'set_global_assignment -name VERILOG_FILE "'+(str(folder/'main.v') if m[1]=='main.v' else str(ROOT/m[1])).replace('\\','/')+'"',config,flags=re.M)
    config=config.replace('SDC_FILE main.sdc','SDC_FILE "'+str(ROOT/'main.sdc').replace('\\','/')+'"')
    config+='set_global_assignment -name NUM_PARALLEL_PROCESSORS 2\n'
    (folder/'main.qsf').write_text(config)
    (folder/'main.qpf').write_text('QUARTUS_VERSION = "25.1"\nPROJECT_REVISION = "main"\n')
    r=subprocess.run([str(MAP),'main'],cwd=folder,capture_output=True,text=True,timeout=240)
    output=r.stdout+r.stderr
    (ROOT/'tests'/f'synthesis_part_{part}.log').write_text(output)
    errors=[s for s in output.splitlines() if s.startswith('Error')]
    if r.returncode or errors:
        print(output,flush=True);raise SystemExit(r.returncode or 1)
    result=f'PASS Part {part}: Quartus Analysis & Synthesis'
    results.append(result);print(result,flush=True)
    warnings=[s for s in output.splitlines() if s.startswith('Warning')]
    for s in warnings:print(s,flush=True)
(ROOT/'tests/synthesis_results.txt').write_text('\n'.join(results)+'\n')

param(
	[string]$ToolsRoot = 'C:\altera_lite\25.1std'
)

$ErrorActionPreference = 'Stop'
$generatedPath = Join-Path $PSScriptRoot 'generated'
New-Item -ItemType Directory -Path $generatedPath -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'accumulator_a_synthesis.qpf') -Destination $generatedPath
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'accumulator_a_synthesis.qsf') -Destination $generatedPath
Push-Location $generatedPath
try {
	& "$ToolsRoot\quartus\bin64\quartus_map.exe" accumulator_a_synthesis
	if ($LASTEXITCODE -ne 0) { throw 'Accumulator A Analysis & Synthesis failed.' }
	& "$ToolsRoot\questa_fse\win64\vsim.exe" -c -onfinish stop -l accumulator_a_simulation.log -do 'do ../accumulator_a.do'
	if ($LASTEXITCODE -ne 0) { throw 'Accumulator A simulation failed.' }
	if (-not (Select-String -LiteralPath 'accumulator_a_simulation.log' -Pattern 'PASS: Accumulator A' -Quiet)) {
		throw 'Simulation did not reach its passing result.'
	}
}
finally {
	Pop-Location
}

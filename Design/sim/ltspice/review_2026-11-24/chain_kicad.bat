@echo off
rem ERC and DRC with schematic parity on a COPY of ..\..\..\kicad (the original project is not opened)
cd /d "%~dp0"
if not exist kicad_checks mkdir kicad_checks
robocopy "..\..\..\kicad" "kicad_copy" /E /XD .history /NFL /NDL /NJH /NJS /NP > nul
"%KC%" version > kicad_checks\kicad_version.txt 2>&1
"%KC%" sch erc --severity-all --units mm -o kicad_checks\erc.rpt kicad_copy\NoCountryforRipple_Buck.kicad_sch > kicad_checks\erc_stdout.txt 2>&1
"%KC%" sch erc --severity-all --format json -o kicad_checks\erc.json kicad_copy\NoCountryforRipple_Buck.kicad_sch >> kicad_checks\erc_stdout.txt 2>&1
"%KC%" pcb drc --schematic-parity --severity-all --units mm -o kicad_checks\drc.rpt kicad_copy\NoCountryforRipple_Buck.kicad_pcb > kicad_checks\drc_stdout.txt 2>&1
"%KC%" pcb drc --schematic-parity --severity-all --format json -o kicad_checks\drc.json kicad_copy\NoCountryforRipple_Buck.kicad_pcb >> kicad_checks\drc_stdout.txt 2>&1
echo done> done_kicad.txt

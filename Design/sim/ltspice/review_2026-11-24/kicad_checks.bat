@echo off
rem KiCad 10 ERC + DRC with schematic parity on a COPY of ..\..\..\kicad (the original project is never opened).
cd /d "%~dp0"
set "KC="
for %%P in ("D:\Program Files\KiCad\10.0\bin\kicad-cli.exe" "%ProgramFiles%\KiCad\10.0\bin\kicad-cli.exe" "%ProgramFiles%\KiCad\10\bin\kicad-cli.exe" "%LOCALAPPDATA%\Programs\KiCad\10.0\bin\kicad-cli.exe") do if not defined KC if exist "%%~P" set "KC=%%~P"
if not defined KC (echo kicad-cli not found> kicad_checks_status.txt & exit /b 1)
echo kicad-cli=%KC%> kicad_checks_status.txt
call chain_kicad.bat

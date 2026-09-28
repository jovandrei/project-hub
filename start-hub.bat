@echo off
setlocal
set "PY=python"
where py >nul 2>nul
if %errorlevel%==0 set "PY=py -3"
cd /d "%~dp0"
echo project-hub at http://127.0.0.1:8760 - close this window or Control-C to stop.
%PY% hub.py %*
pause

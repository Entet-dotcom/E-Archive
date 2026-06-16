@echo off
cd /d "%~dp0"
echo Checking http://127.0.0.1:8080/api/health ...
curl -s http://127.0.0.1:8080/api/health
if errorlevel 1 (
  echo.
  echo API is NOT running. Start it with run_server.bat or double-click START_API.bat in the project folder.
) else (
  echo.
  echo API is running.
)
echo.
pause

@echo off
REM Starts API from project root (uses server\run_server.bat).
cd /d "%~dp0server"
if not exist "bin\server.dart" (
  echo ERROR: Could not find server\bin\server.dart
  pause
  exit /b 1
)
call run_server.bat

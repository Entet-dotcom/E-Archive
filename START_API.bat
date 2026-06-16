@echo off
REM Double-click this file from the E-Archive folder (same place as start_app.bat).
cd /d "%~dp0server"
if not exist "bin\server.dart" (
  echo ERROR: server folder not found. Run this from the E-Archive project root.
  pause
  exit /b 1
)
call run_server.bat

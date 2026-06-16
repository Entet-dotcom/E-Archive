@echo off

echo Stopping process on port 8080 (E-Archive API)...

for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8080" ^| findstr "LISTENING"') do (

  echo Killing PID %%a

  taskkill /F /PID %%a 2>nul

)
taskkill /F /IM dart.exe 2>nul
timeout /t 1 /nobreak >nul
echo Done. You can run run_server.bat again.

if /I not "%~1"=="nopause" pause


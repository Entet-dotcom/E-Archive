@echo off
cd /d "%~dp0"

echo [1/2] Starting E-Archive API on port 8080...
start "E-Archive API" cmd /k "%~dp0server\run_server.bat"

echo Waiting for API to start...
timeout /t 4 /nobreak >nul

echo [2/2] Starting Flutter app...
flutter run -d windows

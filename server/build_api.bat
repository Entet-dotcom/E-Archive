@echo off
cd /d "%~dp0"
echo Building API CLI bundle...
dart pub get
if errorlevel 1 exit /b 1
dart build cli -t bin/server.dart -o build/api_release
if errorlevel 1 exit /b 1
echo.
echo Output: %CD%\build\api_release\bundle\
echo   bin\server.exe
echo   lib\sqlite3.dll
pause

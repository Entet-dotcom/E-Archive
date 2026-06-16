@echo off
cd /d "%~dp0"
echo ============================================
echo   E-Archive API  (keep this window OPEN)
echo   SQLite: %CD%\e_archive.sqlite
echo   URL:    http://127.0.0.1:8080
echo ============================================
echo If port 8080 is busy, run stop_server.bat first.
echo.

call "%~dp0stop_server.bat" nopause

call "%~dp0clean_native_assets.bat"

dart pub get

if errorlevel 1 exit /b 1

dart run bin/server.dart

pause


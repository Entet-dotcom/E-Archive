@echo off
REM CMD-only cleanup for Dart native sqlite3.dll (use this from .bat, not PowerShell rmdir).
cd /d "%~dp0"
if exist ".dart_tool\lib\sqlite3.dll" del /f /q ".dart_tool\lib\sqlite3.dll" 2>nul
if exist ".dart_tool\lib" rmdir /s /q ".dart_tool\lib" 2>nul
exit /b 0

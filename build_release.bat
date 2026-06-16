@echo off
setlocal
cd /d "%~dp0"

echo ============================================
echo   E-Archive release build (Windows)
echo ============================================
echo.

echo [1/3] Building API executable (no Dart needed at runtime)...
cd server
call dart pub get
if errorlevel 1 exit /b 1
call dart build cli -t bin/server.dart -o build/api_release
if errorlevel 1 exit /b 1
cd ..

if not exist "server\build\api_release\bundle\bin\server.exe" (
  echo ERROR: server\build\api_release\bundle\bin\server.exe was not created.
  exit /b 1
)
if not exist "server\build\api_release\bundle\lib\sqlite3.dll" (
  echo ERROR: server\build\api_release\bundle\lib\sqlite3.dll was not created.
  exit /b 1
)

echo.
echo [2/3] Building Flutter Windows release...
call flutter build windows --release
if errorlevel 1 exit /b 1

echo.
echo [3/3] Packaging API next to the app...
set "RELEASE=build\windows\x64\runner\Release"
set "API_SRC=server\build\api_release\bundle"

if not exist "%RELEASE%\e_archive.exe" (
  echo ERROR: %RELEASE%\e_archive.exe not found.
  exit /b 1
)

if exist "%RELEASE%\api" rmdir /s /q "%RELEASE%\api"
if exist "%RELEASE%\api_release" rmdir /s /q "%RELEASE%\api_release"

xcopy /E /I /Y "%API_SRC%" "%RELEASE%\api" >nul
if errorlevel 1 (
  echo ERROR: Failed to copy API bundle into %RELEASE%\api
  exit /b 1
)

copy /Y "%RELEASE%\api\lib\sqlite3.dll" "%RELEASE%\api\bin\sqlite3.dll" >nul

if exist "server\e_archive.sqlite" (
  echo Copying existing database into release folder...
  copy /Y "server\e_archive.sqlite" "%RELEASE%\e_archive.sqlite" >nul
)
if exist "%RELEASE%\api\e_archive.sqlite" del /q "%RELEASE%\api\e_archive.sqlite"

if not exist "%RELEASE%\uploads" mkdir "%RELEASE%\uploads"
if exist "server\uploads" (
  xcopy /E /I /Y "server\uploads\*" "%RELEASE%\uploads\" >nul
)

if not exist "%RELEASE%\api\bin\server.exe" (
  echo ERROR: %RELEASE%\api\bin\server.exe is missing after packaging.
  exit /b 1
)

echo.
echo ============================================
echo   Done
echo ============================================
echo.
echo Run the app from:
echo   %RELEASE%\e_archive.exe
echo.
echo To install on another PC, copy the ENTIRE Release folder:
echo   %RELEASE%
echo   (e_archive.exe, flutter_windows.dll, data\, api\, uploads\, e_archive.sqlite)
echo.
echo The API starts automatically (api\bin\server.exe).
echo Data file: %RELEASE%\e_archive.sqlite
echo.
pause

@echo off
setlocal
cd /d "%~dp0"

echo Packaging API into the release folder...
echo.

if not exist "server\build\api_release\bundle\bin\server.exe" (
  echo API not built yet. Building...
  cd server
  call dart pub get
  if errorlevel 1 exit /b 1
  call dart build cli -t bin/server.dart -o build/api_release
  if errorlevel 1 exit /b 1
  cd ..
)

set "RELEASE=build\windows\x64\runner\Release"
set "API_SRC=server\build\api_release\bundle"

if not exist "%RELEASE%\e_archive.exe" (
  echo ERROR: Build the app first: flutter build windows --release
  echo        or run build_release.bat
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
echo OK: %RELEASE%\api\bin\server.exe is ready.
echo Copy the entire Release folder to other PCs:
echo   %RELEASE%
echo Run: %RELEASE%\e_archive.exe
echo.
pause

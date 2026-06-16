# Run from server folder:  .\run_server.ps1
# (In PowerShell, do NOT use "rmdir /s /q" — that is CMD syntax and will not delete .dart_tool\lib.)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

Write-Host 'Stopping API on port 8080 and any Dart processes (unlocks sqlite3.dll)...'
try {
    $lines = netstat -ano | Select-String ':8080\s+.*LISTENING'
    foreach ($line in $lines) {
        $procId = ($line -split '\s+')[-1]
        if ($procId -match '^\d+$') {
            Write-Host "  Stopping PID $procId"
            Stop-Process -Id ([int]$procId) -Force -ErrorAction SilentlyContinue
        }
    }
    Get-Process -Name dart -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
} catch {
    Write-Warning "Could not stop processes: $_"
}

$libDir = Join-Path $PSScriptRoot '.dart_tool\lib'
if (Test-Path $libDir) {
    Write-Host 'Removing .dart_tool\lib (fixes sqlite3.dll errno 183)...'
    Remove-Item -LiteralPath $libDir -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $libDir) {
        Write-Error @"
Could not delete $libDir
Close any E-Archive API window, then run:  .\stop_server.bat
Then run this script again.
"@
    }
}

Write-Host 'Starting E-Archive API...'
dart pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
dart run bin/server.dart

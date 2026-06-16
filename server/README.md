# E-Archive API (Dart + SQLite)

## Automated file organization

Complete uploads are stored under `uploads/` using this hierarchy:

`{schoolYear}/{college}/{program}/{studentCategory}/{studentNo}_{lastName}/{documentType}.ext`

Incomplete uploads (no received date on the student form) go to `uploads/Pending Documents/`.

## Start the server

| How | Command |
|-----|---------|
| **Easiest (CMD)** | Double-click `run_server.bat` |
| **PowerShell** | `cd server` then `.\run_server.ps1` |
| **From project root** | Double-click `run_api_server.bat` or `dart run bin/server.dart` |
| **Inside server/** | `dart run bin/server.dart` (after `cd server`) |

From the project root, `dart run bin/server.dart` forwards to `server/bin/server.dart`.

If you run `dart run bin/server.dart` **inside** `server/`, use that folder’s copy directly (no launcher).

## sqlite3.dll error (errno 183)

Dart copies `sqlite3.dll` into `.dart_tool\lib\`. If that file already exists, `dart run` fails on Windows.

### PowerShell (Cursor terminal)

`rmdir /s /q` does **not** work in PowerShell. Use one of these:

```powershell
cd server
.\run_server.ps1
```

Or clean manually, then run:

```powershell
cd server
Remove-Item -Recurse -Force .dart_tool\lib -ErrorAction SilentlyContinue
dart run bin/server.dart
```

### CMD

```bat
cd server
clean_native_assets.bat
dart run bin/server.dart
```

Or use `run_server.bat` (stops port 8080, cleans, then runs).

If delete fails, another process is locking the DLL — run `stop_server.bat`, close any API window, then retry.

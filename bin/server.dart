import 'dart:io';

/// Starts the API from [server/]. Safe to run from the E-Archive project root:
/// `dart run bin/server.dart`
Future<void> main(List<String> args) async {
  final root = Directory.current;
  final serverDir = Directory('${root.path}${Platform.pathSeparator}server');
  final entry = File(
    '${serverDir.path}${Platform.pathSeparator}bin'
    '${Platform.pathSeparator}server.dart',
  );

  if (!entry.existsSync()) {
    stderr.writeln('Could not find server/bin/server.dart');
    stderr.writeln('Expected: ${entry.path}');
    stderr.writeln(
      'Run this from the E-Archive folder (the one that contains server/).',
    );
    exit(1);
  }

  final cleanError = _cleanSqliteNativeAssets(serverDir);
  if (cleanError != null) {
    stderr.writeln(cleanError);
    exit(1);
  }

  final process = await Process.start(
    Platform.executable,
    ['run', 'bin/server.dart', ...args],
    workingDirectory: serverDir.path,
    mode: ProcessStartMode.inheritStdio,
  );

  exit(await process.exitCode);
}

/// Removes locked/cached sqlite3.dll (Windows errno 183) before `dart run`.
String? _cleanSqliteNativeAssets(Directory serverDir) {
  final libDir = Directory(
    '${serverDir.path}${Platform.pathSeparator}.dart_tool'
    '${Platform.pathSeparator}lib',
  );
  final dll = File('${libDir.path}${Platform.pathSeparator}sqlite3.dll');

  try {
    if (dll.existsSync()) {
      dll.deleteSync();
    }
    if (libDir.existsSync()) {
      libDir.deleteSync(recursive: true);
    }
    return null;
  } catch (e) {
    return '''
Could not clear ${libDir.path}
$e

Another API or Dart process may be using sqlite3.dll.
  1. Close any E-Archive API terminal window
  2. Run:  server\\stop_server.bat
  3. Retry:  dart run bin/server.dart

Or double-click START_API.bat (cleans and starts automatically).''';
  }
}

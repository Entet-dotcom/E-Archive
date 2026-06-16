import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../config/api_config.dart';

/// Starts the local E-Archive API on desktop when needed.
///
/// Release: runs bundled `api/bin/server.exe` next to the app (no Dart SDK required).
/// Development: runs `dart run bin/server.dart` in the server folder.
class ApiServerLauncher {
  ApiServerLauncher._();

  static const _bundledExeNames = ['server.exe', 'e_archive_api.exe'];

  /// Optional status updates for the splash screen (e.g. "Waiting for API… 5s").
  static void Function(String message)? onStatus;

  /// Returns true if the API responds to `/api/health`.
  static Future<bool> isHealthy() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/health'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Ensures the API is reachable; starts it when possible.
  static Future<void> ensureRunning({
    void Function(String message)? onStatus,
  }) async {
    ApiServerLauncher.onStatus = onStatus;
    try {
      if (kIsWeb) return;
      if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
        return;
      }
      _status('Checking API…');
      if (await isHealthy()) return;

      final bundled = _findBundledApi();
      if (bundled != null) {
        await _startBundled(bundled);
        return;
      }

      final root = _findProjectRoot();
      if (root == null) {
        throw StateError(_missingLayoutMessage());
      }

      await _startWithDart(root);
    } finally {
      ApiServerLauncher.onStatus = null;
    }
  }

  static void _status(String message) {
    onStatus?.call(message);
  }

  static Future<void> _startBundled(_BundledApi api) async {
    _status('Starting API server…');
    final env = _environmentForDataDir(
      api.dataDirectory,
      nativeLibDirs: api.nativeLibDirs,
    );

    try {
      await Process.start(
        api.exePath,
        const [],
        workingDirectory: api.dataDirectory,
        environment: env,
        mode: ProcessStartMode.detached,
      );
    } on ProcessException catch (e) {
      throw StateError(
        'Could not start the bundled API at ${api.exePath}.\n$e',
      );
    }

    await _waitForHealthy();
  }

  static Future<void> _startWithDart(String projectRoot) async {
    final serverDir = p.join(projectRoot, 'server');
    _cleanSqliteNativeAssets(serverDir);

    final dart = await _resolveDartExecutable();
    if (dart == null) {
      throw StateError(_missingDartMessage());
    }

    _status('Starting API server…');
    final env = _environmentForDataDir(serverDir);

    try {
      await Process.start(
        dart,
        ['run', 'bin/server.dart'],
        workingDirectory: serverDir,
        environment: env,
        mode: ProcessStartMode.detached,
      );
    } on ProcessException catch (e) {
      throw StateError(
        'Could not start the API with Dart.\n'
        'Command: $dart run bin/server.dart\n'
        '$e\n\n'
        '${_missingDartMessage()}',
      );
    }

    await _waitForHealthy();
  }

  static Future<void> _waitForHealthy() async {
    const attempts = 40;
    for (var i = 0; i < attempts; i++) {
      if (i > 0 && i % 4 == 0) {
        final seconds = (i * 500) ~/ 1000;
        _status('Waiting for API… ${seconds}s');
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (await isHealthy()) {
        _status('API ready');
        return;
      }
    }

    final dbHint = _resolveDatabasePath(_appDirectory());
    throw StateError(
      'The API did not respond at ${ApiConfig.baseUrl} within 20 seconds.\n\n'
      'Database: $dbHint\n\n'
      'Try:\n'
      '1. Run package_api.bat (copies api + database into Release)\n'
      '2. Or double-click run_api_server.bat and click Retry\n'
      '3. Check port 8080 is free (server\\stop_server.bat)',
    );
  }

  static Map<String, String> _environmentForDataDir(
    String dataDir, {
    List<String> nativeLibDirs = const [],
  }) {
    final env = Map<String, String>.from(Platform.environment);
    env['E_ARCHIVE_DB_PATH'] = _resolveDatabasePath(dataDir);

    if (Platform.isWindows && nativeLibDirs.isNotEmpty) {
      final pathKey = 'PATH';
      final existing = env[pathKey] ?? '';
      final extra = nativeLibDirs
          .where((dir) => Directory(dir).existsSync())
          .join(';');
      if (extra.isNotEmpty) {
        env[pathKey] = existing.isEmpty ? extra : '$extra;$existing';
      }
    }

    return env;
  }

  /// Picks an existing SQLite file or defaults to [dataDir]/e_archive.sqlite.
  static String _resolveDatabasePath(String dataDir) {
    final candidates = <String>[
      p.join(dataDir, 'e_archive.sqlite'),
    ];

    var dir = Directory(dataDir);
    for (var depth = 0; depth < 12; depth++) {
      candidates.add(p.join(dir.path, 'server', 'e_archive.sqlite'));
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }

    for (final path in candidates) {
      if (File(path).existsSync()) {
        return p.normalize(path);
      }
    }

    return p.normalize(p.join(dataDir, 'e_archive.sqlite'));
  }

  static String _appDirectory() {
    return File(Platform.resolvedExecutable).parent.path;
  }

  static final _bundledExeRelativeDirs = [
    p.join('api', 'bin'),
    p.join('api_release', 'bundle', 'bin'),
  ];

  static _BundledApi? _findBundledApi() {
    final searchRoots = <String>{};

    var dir = File(Platform.resolvedExecutable).parent;
    for (var i = 0; i < 8; i++) {
      searchRoots.add(dir.path);
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    searchRoots.add(Directory.current.path);

    for (final root in searchRoots) {
      for (final binDir in _bundledExeRelativeDirs) {
        for (final name in _bundledExeNames) {
          final exe = p.join(root, binDir, name);
          if (!File(exe).existsSync()) continue;

          final bundleRoot = p.normalize(p.join(root, p.dirname(binDir)));
          final nativeLibDirs = <String>[
            p.join(bundleRoot, 'lib'),
            p.dirname(exe),
          ];

          return _BundledApi(
            exePath: p.normalize(exe),
            dataDirectory: p.normalize(root),
            nativeLibDirs: nativeLibDirs,
          );
        }
      }
    }
    return null;
  }

  static Future<String?> _resolveDartExecutable() async {
    for (final candidate in _dartSdkCandidates()) {
      if (_isRunnableExecutable(candidate)) return candidate;
    }
    return null;
  }

  static List<String> _dartSdkCandidates() {
    final candidates = <String>[];

    void addFlutterRoot(String root) {
      candidates.add(
        p.join(
          root,
          'bin',
          'cache',
          'dart-sdk',
          'bin',
          Platform.isWindows ? 'dart.exe' : 'dart',
        ),
      );
    }

    final fromEnv = Platform.environment['DART'];
    if (fromEnv != null && fromEnv.isNotEmpty) {
      candidates.add(fromEnv);
    }

    final flutterRoot = Platform.environment['FLUTTER_ROOT'];
    if (flutterRoot != null && flutterRoot.isNotEmpty) {
      addFlutterRoot(flutterRoot);
    }

    if (Platform.isWindows) {
      for (final root in [
        r'C:\flutter',
        r'C:\src\flutter',
        r'C:\dev\flutter',
      ]) {
        addFlutterRoot(root);
      }

      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null) {
        for (final flutterDir in ['flutter', 'Flutter']) {
          addFlutterRoot(p.join(localAppData, flutterDir));
        }
      }
    }

    return candidates;
  }

  static bool _isRunnableExecutable(String path) {
    final file = File(path);
    if (!file.existsSync()) return false;
    if (Platform.isWindows) {
      return path.toLowerCase().endsWith('.exe');
    }
    return true;
  }

  static String? _findProjectRoot() {
    final starts = <String>{
      Directory.current.path,
      File(Platform.resolvedExecutable).parent.path,
    };

    for (final start in starts) {
      var dir = Directory(start);
      for (var depth = 0; depth < 14; depth++) {
        final serverEntry = p.join(dir.path, 'server', 'bin', 'server.dart');
        if (File(serverEntry).existsSync()) {
          return dir.path;
        }
        final parent = dir.parent;
        if (parent.path == dir.path) break;
        dir = parent;
      }
    }
    return null;
  }

  static String _missingLayoutMessage() {
    return 'Could not find the E-Archive API.\n\n'
        'For a release build, run build_release.bat or package_api.bat, then open:\n'
        '  build\\windows\\x64\\runner\\Release\\e_archive.exe\n\n'
        'That folder must contain api\\bin\\server.exe next to e_archive.exe.';
  }

  static String _missingDartMessage() {
    return 'Dart was not found on this PC (release builds do not need Dart if '
        'api\\bin\\server.exe is bundled).\n\n'
        'Run package_api.bat or build_release.bat from the E-Archive project folder.';
  }

  static void _cleanSqliteNativeAssets(String serverDir) {
    final libDir = Directory(p.join(serverDir, '.dart_tool', 'lib'));
    final dll = File(p.join(libDir.path, 'sqlite3.dll'));

    try {
      if (dll.existsSync()) dll.deleteSync();
      if (libDir.existsSync()) libDir.deleteSync(recursive: true);
    } catch (_) {}
  }
}

class _BundledApi {
  const _BundledApi({
    required this.exePath,
    required this.dataDirectory,
    required this.nativeLibDirs,
  });

  final String exePath;
  final String dataDirectory;
  final List<String> nativeLibDirs;
}

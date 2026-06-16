import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:e_archive_server/api_handlers.dart';
import 'package:e_archive_server/config.dart';
import 'package:e_archive_server/sqlite_store.dart';

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final baseUrl =
      'http://${ServerConfig.apiHost}:${ServerConfig.apiPort}';

  if (await _isOurApiAlreadyRunning(baseUrl)) {
    stdout.writeln('E-Archive API is already running at $baseUrl');
    stdout.writeln('Use the app as-is, or stop that process before starting again.');
    return;
  }

  final uploadsDir = Directory(
    '${Directory.current.path}${Platform.pathSeparator}uploads',
  );

  final store = SqliteStore();
  try {
    await store.open(uploadsDir);
  } catch (e) {
    stderr.writeln('Failed to open SQLite database (${ServerConfig.dbPath}): $e');
    stderr.writeln('Check file permissions or set E_ARCHIVE_DB_PATH to a writable folder.');
    exit(1);
  }

  final apiHandler = createApiHandler(store, uploadsDir);
  final uploadsHandler = createUploadsHandler(uploadsDir);
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler((Request request) {
        final path = request.requestedUri.path;
        if (path.startsWith('/uploads/')) {
          return uploadsHandler(request);
        }
        return apiHandler(request);
      });

  try {
    await shelf_io.serve(
      handler,
      ServerConfig.apiHost,
      ServerConfig.apiPort,
    );
  } on SocketException catch (e) {
    if (e.osError?.errorCode == 10048) {
      stderr.writeln(
        'Port ${ServerConfig.apiPort} is already in use on ${ServerConfig.apiHost}.',
      );
      stderr.writeln('');
      stderr.writeln('Fix: close the other program using that port, then retry.');
      stderr.writeln('  1. Find PID:  netstat -ano | findstr :${ServerConfig.apiPort}');
      stderr.writeln('  2. Stop it:   taskkill /F /PID <pid>');
      stderr.writeln('');
      stderr.writeln('Or run stop_server.bat from the server folder.');
    } else {
      stderr.writeln('Could not start server: $e');
    }
    exit(1);
  }

  stdout.writeln('E-Archive API running at $baseUrl');
  stdout.writeln('Database (SQLite): ${ServerConfig.resolvedDbPath}');
}

Future<bool> _isOurApiAlreadyRunning(String baseUrl) async {
  final client = HttpClient();
  try {
    final request = await client
        .getUrl(Uri.parse('$baseUrl/api/health'))
        .timeout(const Duration(seconds: 2));
    final response = await request.close().timeout(const Duration(seconds: 2));
    if (response.statusCode != 200) return false;
    final body = await response.transform(utf8.decoder).join();
    return body.contains('"status":"ok"') || body.contains('"status": "ok"');
  } catch (_) {
    return false;
  } finally {
    client.close(force: true);
  }
}

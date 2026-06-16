import 'dart:io';

import 'package:path/path.dart' as p;

/// API and SQLite file location.
///
/// Override the database file with:
/// `set E_ARCHIVE_DB_PATH=C:\path\to\e_archive.sqlite`
class ServerConfig {
  static const apiHost = '127.0.0.1';
  static const apiPort = 8080;

  /// File name or path for the SQLite database (relative paths are under cwd).
  static String get dbPath {
    final fromEnv = Platform.environment['E_ARCHIVE_DB_PATH'];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      return fromEnv.trim();
    }
    return 'e_archive.sqlite';
  }

  /// Absolute path to the SQLite database file.
  static String get resolvedDbPath {
    if (p.isAbsolute(dbPath)) {
      return dbPath;
    }
    return p.join(Directory.current.path, dbPath);
  }
}

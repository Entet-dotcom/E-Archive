import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqflite.dart';

import 'config.dart';

class SqliteStore {
  Database? _db;
  late final Directory uploadsDir;

  Future<void> open(Directory uploadsDirectory) async {
    uploadsDir = uploadsDirectory;
    await uploadsDir.create(recursive: true);

    final path = ServerConfig.resolvedDbPath;
    await Directory(p.dirname(path)).create(recursive: true);

    _db = await openDatabase(
      path,
      version: 9,
      onOpen: (db) async {
        await _ensureSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateToV2(db);
        }
        if (oldVersion < 3) {
          await _migrateToV3(db);
        }
        if (oldVersion < 4) {
          await _migrateToV4(db);
        }
        if (oldVersion < 5) {
          await _migrateToV5(db);
        }
        if (oldVersion < 6) {
          await _migrateToV6(db);
        }
        if (oldVersion < 7) {
          await _migrateToV7(db);
        }
        if (oldVersion < 8) {
          await _migrateToV8(db);
        }
        if (oldVersion < 9) {
          await _migrateToV9(db);
        }
        await _ensureSchema(db);
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Database get db {
    final d = _db;
    if (d == null) {
      throw StateError('SQLite database is not open');
    }
    return d;
  }

  Future<void> _ensureSchema(Database d) async {
    await d.execute('''
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_no TEXT NOT NULL UNIQUE,
        full_name TEXT NOT NULL,
        course TEXT NOT NULL,
        year INTEGER NOT NULL DEFAULT 1,
        status TEXT NOT NULL DEFAULT 'graduated',
        email TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        student TEXT NOT NULL DEFAULT '',
        image_path TEXT NOT NULL,
        mime_type TEXT NOT NULL DEFAULT 'image',
        size_bytes INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        college_id INTEGER,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (college_id) REFERENCES colleges(id)
      )
    ''');

    await _addColumnIfNotExists(d, 'courses', 'college_id', 'INTEGER');
    await _addColumnIfNotExists(d, 'courses', 'code', 'TEXT');

    await _addColumnIfNotExists(d, 'documents', 'document_type', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'school_year', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'program', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'student_no', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'storage_path', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'college', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'student_category', 'TEXT');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS colleges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await _dropColumnIfExists(d, 'colleges', 'code');

    await _seedDefaultCourses(d);
    await _seedDefaultColleges(d);

    await _addColumnIfNotExists(d, 'documents', 'content_hash', 'TEXT');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS retention_policies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_type TEXT NOT NULL UNIQUE,
        retention_years INTEGER NOT NULL DEFAULT 7,
        legal_basis TEXT NOT NULL DEFAULT '',
        iso_reference TEXT NOT NULL DEFAULT 'ISO 15489-1:2016',
        description TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS access_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL,
        resource TEXT NOT NULL,
        action TEXT NOT NULL,
        allowed INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        UNIQUE(role, resource, action)
      )
    ''');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        actor TEXT NOT NULL,
        action TEXT NOT NULL,
        resource_type TEXT NOT NULL DEFAULT '',
        resource_id TEXT NOT NULL DEFAULT '',
        details TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS backup_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL UNIQUE,
        backup_path TEXT NOT NULL,
        size_bytes INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'completed',
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS disposal_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_id INTEGER NOT NULL UNIQUE,
        status TEXT NOT NULL DEFAULT 'pending',
        reason TEXT NOT NULL DEFAULT '',
        recommended_date TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (document_id) REFERENCES documents(id)
      )
    ''');

    await _seedComplianceDefaults(d);
    await _seedComplianceDemoData(d);

    await _dropColumnIfExists(d, 'documents', 'extracted_text');
  }

  Future<void> _migrateToV9(Database d) async {
    await _seedComplianceDemoData(d);
  }

  /// Sample records for compliance modules (retention, duplicates, disposal, etc.).
  Future<void> _seedComplianceDemoData(Database d) async {
    final demoCheck = await d.rawQuery(
      "SELECT COUNT(*) AS cnt FROM students WHERE student_no LIKE 'DEMO-%'",
    );
    final demoCount = demoCheck.first['cnt'];
    if (demoCount is num && demoCount > 0) return;

    var courseName = 'Secondary Education';
    final courseRows = await d.rawQuery(
      'SELECT name FROM courses ORDER BY id ASC LIMIT 1',
    );
    if (courseRows.isNotEmpty) {
      courseName = (courseRows.first['name'] ?? courseName).toString();
    }

    final collegeRows = await d.rawQuery(
      'SELECT name FROM colleges ORDER BY id ASC LIMIT 1',
    );
    final collegeName = collegeRows.isEmpty
        ? 'EDUC - College of Education (COEd)'
        : (collegeRows.first['name'] ?? '').toString();

    await d.rawInsert(
      '''
      INSERT INTO students (student_no, full_name, course, year, status, email, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        'DEMO-2024-001',
        'Maria Clara Santos',
        courseName,
        4,
        'graduated',
        'maria.santos@jrmsu.edu.ph',
        '2024-03-15 08:00:00',
      ],
    );

    await d.rawInsert(
      '''
      INSERT INTO students (student_no, full_name, course, year, status, email, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        'DEMO-2023-014',
        'Juan Miguel Reyes',
        courseName,
        4,
        'graduated',
        'juan.reyes@jrmsu.edu.ph',
        '2023-05-20 09:30:00',
      ],
    );

    const duplicateHash =
        'a3f5c8d9e2b147608915263748596a0b1c2d3e4f5678901234567890abcd';

    Future<int> insertDemoDoc({
      required String title,
      required String student,
      required String studentNo,
      required String documentType,
      required String createdAt,
      required String contentHash,
      int sizeBytes = 245760,
    }) async {
      return d.rawInsert(
        '''
        INSERT INTO documents
          (title, student, image_path, mime_type, size_bytes,
           document_type, school_year, program, student_no, storage_path,
           college, student_category, content_hash, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          title,
          student,
          '/uploads/demo/$studentNo/${documentType.replaceAll(' ', '_')}.pdf',
          'application/pdf',
          sizeBytes,
          documentType,
          '2023-2024',
          'BSED',
          studentNo,
          'demo/$studentNo/${documentType.replaceAll(' ', '_')}.pdf',
          collegeName,
          'Graduated',
          contentHash,
          createdAt,
        ],
      );
    }

    final expiredTranscript = await insertDemoDoc(
      title: 'Transcript of Records — Maria Santos',
      student: 'Maria Clara Santos',
      studentNo: 'DEMO-2024-001',
      documentType: 'Transcript of Records',
      createdAt: '2014-06-10 10:00:00',
      contentHash: 'hash_transcript_maria_001',
    );
    await insertDemoDoc(
      title: 'Form 137 — Juan Reyes',
      student: 'Juan Miguel Reyes',
      studentNo: 'DEMO-2023-014',
      documentType: 'Form 137',
      createdAt: '2013-01-20 11:00:00',
      contentHash: 'hash_form137_juan_001',
    );
    await insertDemoDoc(
      title: 'Certificate — Maria Santos',
      student: 'Maria Clara Santos',
      studentNo: 'DEMO-2024-001',
      documentType: 'Certificate',
      createdAt: '2019-07-01 14:00:00',
      contentHash: 'hash_cert_maria_001',
    );
    await insertDemoDoc(
      title: 'Misc Registrar Form — Juan Reyes',
      student: 'Juan Miguel Reyes',
      studentNo: 'DEMO-2023-014',
      documentType: 'Other',
      createdAt: '2019-08-15 09:00:00',
      contentHash: 'hash_other_juan_001',
    );
    await insertDemoDoc(
      title: 'Diploma — Maria Santos',
      student: 'Maria Clara Santos',
      studentNo: 'DEMO-2024-001',
      documentType: 'Diploma',
      createdAt: '2024-04-01 16:00:00',
      contentHash: 'hash_diploma_maria_001',
    );
    await insertDemoDoc(
      title: 'Transcript Copy A — Maria Santos',
      student: 'Maria Clara Santos',
      studentNo: 'DEMO-2024-001',
      documentType: 'Transcript of Records',
      createdAt: '2022-03-10 10:00:00',
      contentHash: duplicateHash,
    );
    await insertDemoDoc(
      title: 'Transcript Copy B — Maria Santos (duplicate upload)',
      student: 'Maria Clara Santos',
      studentNo: 'DEMO-2024-001',
      documentType: 'Transcript of Records',
      createdAt: '2023-06-18 10:00:00',
      contentHash: duplicateHash,
    );

    const auditEntries = [
      ['admin@gmail.com', 'document_uploaded', 'document', 'demo', 'Uploaded demo transcript'],
      ['staff@gmail.com', 'student_created', 'student', 'DEMO-2024-001', 'Registered Maria Santos'],
      ['admin@gmail.com', 'backup_created', 'backup', 'demo_backup_20250601', 'Scheduled weekly backup'],
      ['admin@gmail.com', 'disposal_approved', 'document', 'demo', 'Approved expired transcript disposal'],
      ['staff@gmail.com', 'document_uploaded', 'document', 'demo', 'Uploaded Form 137 scan'],
    ];
    for (final entry in auditEntries) {
      await d.rawInsert(
        '''
        INSERT INTO audit_logs (actor, action, resource_type, resource_id, details, created_at)
        VALUES (?, ?, ?, ?, ?, datetime('now', ?))
        ''',
        [...entry, '-${auditEntries.indexOf(entry)} days'],
      );
    }

    await d.rawInsert(
      '''
      INSERT INTO backup_records (label, backup_path, size_bytes, status, created_at)
      VALUES (?, ?, ?, ?, ?)
      ''',
      [
        'demo_backup_20250601',
        'backups/demo_backup_20250601',
        15728640,
        'completed',
        '2025-06-01 02:00:00',
      ],
    );
    await d.rawInsert(
      '''
      INSERT INTO backup_records (label, backup_path, size_bytes, status, created_at)
      VALUES (?, ?, ?, ?, ?)
      ''',
      [
        'demo_backup_20250515',
        'backups/demo_backup_20250515',
        14680064,
        'completed',
        '2025-05-15 02:00:00',
      ],
    );

    await d.rawInsert(
      '''
      INSERT INTO disposal_queue (document_id, status, reason, recommended_date, created_at)
      VALUES (?, ?, ?, ?, ?)
      ''',
      [
        expiredTranscript,
        'pending',
        'Retention period exceeded (10 years)',
        '2024-06-10',
        '2025-06-01 08:00:00',
      ],
    );
  }

  Future<void> _migrateToV8(Database d) async {
    await _addColumnIfNotExists(d, 'documents', 'content_hash', 'TEXT');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS retention_policies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_type TEXT NOT NULL UNIQUE,
        retention_years INTEGER NOT NULL DEFAULT 7,
        legal_basis TEXT NOT NULL DEFAULT '',
        iso_reference TEXT NOT NULL DEFAULT 'ISO 15489-1:2016',
        description TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS access_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL,
        resource TEXT NOT NULL,
        action TEXT NOT NULL,
        allowed INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        UNIQUE(role, resource, action)
      )
    ''');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        actor TEXT NOT NULL,
        action TEXT NOT NULL,
        resource_type TEXT NOT NULL DEFAULT '',
        resource_id TEXT NOT NULL DEFAULT '',
        details TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS backup_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL UNIQUE,
        backup_path TEXT NOT NULL,
        size_bytes INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'completed',
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS disposal_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_id INTEGER NOT NULL UNIQUE,
        status TEXT NOT NULL DEFAULT 'pending',
        reason TEXT NOT NULL DEFAULT '',
        recommended_date TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (document_id) REFERENCES documents(id)
      )
    ''');

    await _seedComplianceDefaults(d);
  }

  Future<void> _seedComplianceDefaults(Database d) async {
    final policyCount =
        await d.rawQuery('SELECT COUNT(*) AS cnt FROM retention_policies');
    final policyTotal = policyCount.first['cnt'];
    if (policyTotal is num && policyTotal == 0) {
      const policies = [
        ['Form 137', 10, 'DepEd Order + RA 9470', 'ISO 15489-1:2016', 'Permanent academic record'],
        ['Transcript of Records', 10, 'CHED + RA 9470', 'ISO 15489-1:2016', 'Official academic transcript'],
        ['Diploma', 10, 'RA 9470', 'ISO 15489-1:2016', 'Graduation credential'],
        ['Certificate', 7, 'RA 9470', 'ISO 15489-1:2016', 'Supplementary certificate'],
        ['Other', 7, 'RA 9470 + RA 10173', 'ISO 15489-1:2016', 'General registrar document'],
      ];
      for (final row in policies) {
        await d.rawInsert(
          '''
          INSERT OR IGNORE INTO retention_policies
            (document_type, retention_years, legal_basis, iso_reference, description)
          VALUES (?, ?, ?, ?, ?)
          ''',
          row,
        );
      }
    }

    final ruleCount =
        await d.rawQuery('SELECT COUNT(*) AS cnt FROM access_rules');
    final ruleTotal = ruleCount.first['cnt'];
    if (ruleTotal is num && ruleTotal == 0) {
      const rules = [
        ['admin', 'documents', 'delete', 1],
        ['admin', 'documents', 'upload', 1],
        ['admin', 'students', 'delete', 1],
        ['admin', 'compliance', 'manage', 1],
        ['admin', 'backup', 'restore', 1],
        ['staff', 'documents', 'upload', 1],
        ['staff', 'documents', 'delete', 0],
        ['staff', 'students', 'delete', 0],
        ['staff', 'compliance', 'manage', 0],
        ['staff', 'backup', 'restore', 0],
      ];
      for (final row in rules) {
        await d.rawInsert(
          '''
          INSERT OR IGNORE INTO access_rules (role, resource, action, allowed)
          VALUES (?, ?, ?, ?)
          ''',
          row,
        );
      }
    }
  }

  Future<void> _migrateToV4(Database d) async {
    const renames = <String, String>{
      'CCS': 'CCS - College of Computer Studies',
      'EDUC': 'EDUC - College of Education (COEd)',
      'CRIM': 'CRIM - College of Criminal Justice Education (CCJE)',
      'CAF': 'CAF - College of Agriculture and Forestry',
      'Engineering': 'Engineering - College of Engineering',
      'BSBA': 'BSBA - College of Business Administration and Hospitality Management',
    };
    for (final entry in renames.entries) {
      await d.rawUpdate(
        'UPDATE colleges SET name = ? WHERE name = ?',
        [entry.value, entry.key],
      );
    }
  }

  Future<void> _migrateToV6(Database d) async {
    await _addColumnIfNotExists(d, 'documents', 'college', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'student_category', 'TEXT');
  }

  /// Removes legacy placeholder program names from the courses table.
  Future<void> _migrateToV7(Database d) async {
    await d.rawDelete(
      "DELETE FROM courses WHERE name IN ('Information Technology', 'Business Administration')",
    );
  }

  Future<void> _migrateToV5(Database d) async {
    const cafName = 'CAF - College of Agriculture and Forestry';
    const forestryNames = ['Forestry', 'Forestry - College of Forestry'];

    int? cafId;
    final cafRows = await d.rawQuery(
      "SELECT id FROM colleges WHERE name = ? OR name = 'CAF' LIMIT 1",
      [cafName],
    );
    if (cafRows.isNotEmpty) {
      cafId = cafRows.first['id'] as int?;
    }

    for (final forestryName in forestryNames) {
      final forestryRows = await d.rawQuery(
        'SELECT id FROM colleges WHERE name = ? LIMIT 1',
        [forestryName],
      );
      if (forestryRows.isEmpty) continue;
      final forestryId = forestryRows.first['id'] as int?;
      if (forestryId == null) continue;

      if (cafId == null) {
        await d.rawUpdate(
          'UPDATE colleges SET name = ? WHERE id = ?',
          [cafName, forestryId],
        );
        cafId = forestryId;
        continue;
      }

      if (forestryId != cafId) {
        await d.rawUpdate(
          'UPDATE courses SET college_id = ? WHERE college_id = ?',
          [cafId, forestryId],
        );
        await d.rawDelete('DELETE FROM colleges WHERE id = ?', [forestryId]);
      }
    }
  }

  Future<void> _migrateToV3(Database d) async {
    await _addColumnIfNotExists(d, 'courses', 'code', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'document_type', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'school_year', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'program', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'student_no', 'TEXT');
    await _addColumnIfNotExists(d, 'documents', 'storage_path', 'TEXT');

    await d.rawUpdate(
      "UPDATE courses SET code = 'BSED' WHERE name = 'Secondary Education' AND (code IS NULL OR code = '')",
    );
  }

  Future<void> _migrateToV2(Database d) async {
    await _addColumnIfNotExists(d, 'courses', 'college_id', 'INTEGER');

    final colleges = await d.rawQuery(
      'SELECT id FROM colleges ORDER BY id ASC LIMIT 1',
    );
    if (colleges.isEmpty) return;
    final firstCollegeId = colleges.first['id'];
    await d.rawUpdate(
      'UPDATE courses SET college_id = ? WHERE college_id IS NULL',
      [firstCollegeId],
    );
  }

  Future<void> _addColumnIfNotExists(
    Database d,
    String table,
    String column,
    String type,
  ) async {
    final rows = await d.rawQuery('PRAGMA table_info($table)');
    final hasColumn = rows.any((r) => r['name'] == column);
    if (hasColumn) return;
    await d.execute('ALTER TABLE $table ADD COLUMN $column $type');
  }

  Future<void> _seedDefaultCourses(Database d) async {
    final count = await d.rawQuery('SELECT COUNT(*) AS cnt FROM courses');
    if (count.isEmpty) return;
    final total = count.first['cnt'];
    if (total is num && total > 0) return;

    final colleges = await d.rawQuery(
      'SELECT id, name FROM colleges ORDER BY id ASC',
    );
    if (colleges.isEmpty) return;

    int? collegeIdFor(String abbrev) {
      final key = abbrev.toUpperCase();
      for (final row in colleges) {
        final name = (row['name'] ?? '').toString();
        final upper = name.toUpperCase();
        if (upper == key || upper.startsWith('$key -')) {
          return row['id'] as int?;
        }
      }
      return colleges.first['id'] as int?;
    }

    final defaults = <(String name, String code, String collegeAbbrev)>[
      ('Secondary Education', 'BSED', 'EDUC'),
    ];
    for (final entry in defaults) {
      final collegeId = collegeIdFor(entry.$3);
      await d.rawInsert(
        'INSERT INTO courses (name, code, college_id) VALUES (?, ?, ?)',
        [entry.$1, entry.$2, collegeId],
      );
    }
  }

  Future<void> _seedDefaultColleges(Database d) async {
    final count = await d.rawQuery('SELECT COUNT(*) AS cnt FROM colleges');
    if (count.isEmpty) return;
    final total = count.first['cnt'];
    if (total is num && total > 0) return;

    const defaults = [
      ['CCS - College of Computer Studies', 1],
      ['EDUC - College of Education (COEd)', 1],
      ['CRIM - College of Criminal Justice Education (CCJE)', 1],
      ['CAF - College of Agriculture and Forestry', 1],
      ['Engineering - College of Engineering', 1],
      [
        'BSBA - College of Business Administration and Hospitality Management',
        1,
      ],
    ];
    for (final row in defaults) {
      await d.rawInsert(
        'INSERT INTO colleges (name, is_active) VALUES (?, ?)',
        row,
      );
    }
  }

  Future<void> _dropColumnIfExists(
    Database d,
    String table,
    String column,
  ) async {
    final rows = await d.rawQuery('PRAGMA table_info($table)');
    final hasColumn = rows.any((r) => r['name'] == column);
    if (!hasColumn) return;
    try {
      await d.execute('ALTER TABLE $table DROP COLUMN $column');
    } catch (_) {
      // Older SQLite without DROP COLUMN: ignore.
    }
  }

  Future<List<Map<String, Object?>>> fetchCourses({int? collegeId}) async {
    final results = collegeId != null
        ? await db.rawQuery(
            'SELECT * FROM courses WHERE college_id = ? ORDER BY name ASC',
            [collegeId],
          )
        : await db.rawQuery(
            'SELECT * FROM courses ORDER BY name ASC',
          );
    return results.map(_rowToMap).toList();
  }

  Future<Map<String, Object?>> insertCourse({
    required String name,
    int? collegeId,
    String? code,
  }) async {
    final id = await db.rawInsert(
      '''
      INSERT INTO courses (name, college_id, code)
      VALUES (?, ?, ?)
      ''',
      [name, collegeId, code?.trim()],
    );

    return (await _courseById(id))!;
  }

  Future<Map<String, Object?>?> updateCourse({
    required int id,
    required String name,
    int? collegeId,
    String? code,
  }) async {
    if (collegeId != null) {
      await db.rawUpdate(
        '''
        UPDATE courses
        SET name = ?, college_id = ?, code = ?
        WHERE id = ?
        ''',
        [name, collegeId, code?.trim(), id],
      );
    } else {
      await db.rawUpdate(
        '''
        UPDATE courses
        SET name = ?, code = ?
        WHERE id = ?
        ''',
        [name, code?.trim(), id],
      );
    }
    return _courseById(id);
  }

  Future<bool> deleteCourse(int id) async {
    final n = await db.rawDelete(
      'DELETE FROM courses WHERE id = ?',
      [id],
    );
    return n > 0;
  }

  Future<List<Map<String, Object?>>> fetchColleges() async {
    final results = await db.rawQuery(
      'SELECT * FROM colleges ORDER BY name ASC',
    );
    return results.map(_rowToMap).toList();
  }

  Future<Map<String, Object?>> insertCollege({
    required String name,
    bool isActive = true,
  }) async {
    final id = await db.rawInsert(
      '''
      INSERT INTO colleges (name, is_active)
      VALUES (?, ?)
      ''',
      [name, isActive ? 1 : 0],
    );

    return (await _collegeById(id))!;
  }

  Future<Map<String, Object?>?> updateCollege({
    required int id,
    required String name,
    bool isActive = true,
  }) async {
    await db.rawUpdate(
      '''
      UPDATE colleges
      SET name = ?, is_active = ?
      WHERE id = ?
      ''',
      [name, isActive ? 1 : 0, id],
    );
    return _collegeById(id);
  }

  Future<bool> deleteCollege(int id) async {
    await db.rawDelete(
      'DELETE FROM courses WHERE college_id = ?',
      [id],
    );
    final n = await db.rawDelete(
      'DELETE FROM colleges WHERE id = ?',
      [id],
    );
    return n > 0;
  }

  Future<List<Map<String, Object?>>> fetchStudents({
    int? courseId,
    String? courseName,
  }) async {
    String? filterCourse = courseName?.trim();
    if ((filterCourse == null || filterCourse.isEmpty) && courseId != null) {
      final course = await _courseById(courseId);
      filterCourse = (course?['name'] ?? '').toString().trim();
    }

    final results = filterCourse != null && filterCourse.isNotEmpty
        ? await db.rawQuery(
            '''
            SELECT * FROM students
            WHERE course = ?
            ORDER BY created_at DESC
            ''',
            [filterCourse],
          )
        : await db.rawQuery(
            'SELECT * FROM students ORDER BY created_at DESC',
          );
    return results.map(_rowToMap).toList();
  }

  Future<Map<String, Object?>> insertStudent({
    required String studentNo,
    required String fullName,
    required String course,
    required int year,
    required String status,
    String email = '',
  }) async {
    final id = await db.rawInsert(
      '''
      INSERT INTO students (student_no, full_name, course, year, status, email)
      VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [studentNo, fullName, course, year, status, email],
    );

    return (await _studentById(id))!;
  }

  Future<bool> deleteStudent(int id) async {
    final student = await _studentById(id);
    if (student == null) return false;

    final studentNo = (student['student_no'] ?? '').toString().trim();
    final fullName = (student['full_name'] ?? '').toString().trim();

    final docRows = studentNo.isNotEmpty
        ? await db.rawQuery(
            '''
            SELECT id FROM documents
            WHERE student_no = ?
               OR LOWER(TRIM(student)) = LOWER(?)
            ''',
            [studentNo, fullName],
          )
        : await db.rawQuery(
            '''
            SELECT id FROM documents
            WHERE LOWER(TRIM(student)) = LOWER(?)
            ''',
            [fullName],
          );

    for (final row in docRows) {
      final docId = row['id'];
      if (docId is int) {
        await deleteDocument(docId);
      }
    }

    final n = await db.rawDelete(
      'DELETE FROM students WHERE id = ?',
      [id],
    );
    return n > 0;
  }

  Future<List<Map<String, Object?>>> fetchDocuments() async {
    final results = await db.rawQuery(
      'SELECT * FROM documents ORDER BY created_at DESC',
    );
    return results.map(_rowToMap).toList();
  }

  Future<Map<String, Object?>> insertDocument({
    required String title,
    required String student,
    required String imagePath,
    required String mimeType,
    required int sizeBytes,
    String documentType = '',
    String schoolYear = '',
    String program = '',
    String studentNo = '',
    String storagePath = '',
    String college = '',
    String studentCategory = '',
    String contentHash = '',
  }) async {
    final id = await db.rawInsert(
      '''
      INSERT INTO documents
        (title, student, image_path, mime_type, size_bytes,
         document_type, school_year, program, student_no, storage_path,
         college, student_category, content_hash)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        title,
        student,
        imagePath,
        mimeType,
        sizeBytes,
        documentType,
        schoolYear,
        program,
        studentNo,
        storagePath,
        college,
        studentCategory,
        contentHash,
      ],
    );

    return (await _documentById(id))!;
  }

  Future<Map<String, Object?>?> findDocumentByHash(String hash) async {
    final results = await db.rawQuery(
      'SELECT * FROM documents WHERE content_hash = ? LIMIT 1',
      [hash],
    );
    if (results.isEmpty) return null;
    return _rowToMap(results.first);
  }

  Future<List<Map<String, Object?>>> fetchRetentionPolicies() async {
    final results = await db.rawQuery(
      'SELECT * FROM retention_policies ORDER BY document_type ASC',
    );
    return results.map(_rowToMap).toList();
  }

  Future<List<Map<String, Object?>>> fetchAccessRules() async {
    final results = await db.rawQuery(
      'SELECT * FROM access_rules ORDER BY role ASC, resource ASC',
    );
    return results.map(_rowToMap).toList();
  }

  Future<List<Map<String, Object?>>> fetchAuditLogs({int limit = 100}) async {
    final results = await db.rawQuery(
      'SELECT * FROM audit_logs ORDER BY created_at DESC LIMIT ?',
      [limit],
    );
    return results.map(_rowToMap).toList();
  }

  Future<Map<String, Object?>> insertAuditLog({
    required String actor,
    required String action,
    String resourceType = '',
    String resourceId = '',
    String details = '',
  }) async {
    final id = await db.rawInsert(
      '''
      INSERT INTO audit_logs (actor, action, resource_type, resource_id, details)
      VALUES (?, ?, ?, ?, ?)
      ''',
      [actor, action, resourceType, resourceId, details],
    );
    final results = await db.rawQuery(
      'SELECT * FROM audit_logs WHERE id = ? LIMIT 1',
      [id],
    );
    return _rowToMap(results.first);
  }

  Future<List<Map<String, Object?>>> fetchBackupRecords() async {
    final results = await db.rawQuery(
      'SELECT * FROM backup_records ORDER BY created_at DESC',
    );
    return results.map(_rowToMap).toList();
  }

  Future<Map<String, Object?>> insertBackupRecord({
    required String label,
    required String backupPath,
    required int sizeBytes,
    String status = 'completed',
  }) async {
    final id = await db.rawInsert(
      '''
      INSERT INTO backup_records (label, backup_path, size_bytes, status)
      VALUES (?, ?, ?, ?)
      ''',
      [label, backupPath, sizeBytes, status],
    );
    final results = await db.rawQuery(
      'SELECT * FROM backup_records WHERE id = ? LIMIT 1',
      [id],
    );
    return _rowToMap(results.first);
  }

  Future<List<Map<String, Object?>>> fetchDisposalQueue() async {
    final results = await db.rawQuery(
      'SELECT * FROM disposal_queue ORDER BY created_at DESC',
    );
    return results.map(_rowToMap).toList();
  }

  Future<Map<String, Object?>> upsertDisposalQueue({
    required int documentId,
    required String status,
    required String reason,
    String recommendedDate = '',
  }) async {
    await db.rawInsert(
      '''
      INSERT INTO disposal_queue (document_id, status, reason, recommended_date)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(document_id) DO UPDATE SET
        status = excluded.status,
        reason = excluded.reason,
        recommended_date = excluded.recommended_date
      ''',
      [documentId, status, reason, recommendedDate],
    );
    final results = await db.rawQuery(
      'SELECT * FROM disposal_queue WHERE document_id = ? LIMIT 1',
      [documentId],
    );
    return _rowToMap(results.first);
  }

  Future<bool> deleteDocument(int id) async {
    final rows = await db.rawQuery(
      'SELECT image_path FROM documents WHERE id = ? LIMIT 1',
      [id],
    );
    if (rows.isEmpty) return false;

    final imagePath = (rows.first['image_path'] as String?)?.trim() ?? '';
    _deleteUploadIfLocal(imagePath);

    final n = await db.rawDelete(
      'DELETE FROM documents WHERE id = ?',
      [id],
    );
    return n > 0;
  }

  void _deleteUploadIfLocal(String imagePath) {
    if (!imagePath.startsWith('/uploads/')) return;
    final relative = imagePath
        .replaceFirst('/uploads/', '')
        .replaceAll('/', Platform.pathSeparator);
    final file = File(
      '${uploadsDir.path}${Platform.pathSeparator}$relative',
    );
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  Future<String?> programCodeForCourse(String courseName) async {
    final name = courseName.trim();
    if (name.isEmpty) return null;
    final rows = await db.rawQuery(
      'SELECT code FROM courses WHERE name = ? LIMIT 1',
      [name],
    );
    if (rows.isEmpty) return null;
    final code = (rows.first['code'] ?? '').toString().trim();
    return code.isEmpty ? null : code;
  }

  Future<String?> collegeNameForCourse(String courseName) async {
    final name = courseName.trim();
    if (name.isEmpty) return null;
    final rows = await db.rawQuery(
      '''
      SELECT c.name AS college_name
      FROM courses co
      INNER JOIN colleges c ON c.id = co.college_id
      WHERE co.name = ?
      LIMIT 1
      ''',
      [name],
    );
    if (rows.isEmpty) return null;
    final college = (rows.first['college_name'] ?? '').toString().trim();
    return college.isEmpty ? null : college;
  }

  Future<Map<String, Object?>?> _courseById(int id) async {
    final results = await db.rawQuery(
      'SELECT * FROM courses WHERE id = ? LIMIT 1',
      [id],
    );
    if (results.isEmpty) return null;
    return _rowToMap(results.first);
  }

  Future<Map<String, Object?>?> _collegeById(int id) async {
    final results = await db.rawQuery(
      'SELECT * FROM colleges WHERE id = ? LIMIT 1',
      [id],
    );
    if (results.isEmpty) return null;
    return _rowToMap(results.first);
  }

  Future<Map<String, Object?>?> _studentById(int id) async {
    final results = await db.rawQuery(
      'SELECT * FROM students WHERE id = ? LIMIT 1',
      [id],
    );
    if (results.isEmpty) return null;
    return _rowToMap(results.first);
  }

  Future<Map<String, Object?>?> _documentById(int id) async {
    final results = await db.rawQuery(
      'SELECT * FROM documents WHERE id = ? LIMIT 1',
      [id],
    );
    if (results.isEmpty) return null;
    return _rowToMap(results.first);
  }

  Map<String, Object?> _rowToMap(Map<String, Object?> row) {
    final map = <String, Object?>{};
    for (final entry in row.entries) {
      final name = entry.key;
      final value = entry.value;
      if (value is DateTime) {
        map[name] = value.toUtc().toIso8601String();
      } else if (name == 'created_at' && value is String) {
        final parsed = DateTime.tryParse(value.replaceFirst(' ', 'T'));
        map[name] = parsed != null
            ? parsed.toUtc().toIso8601String()
            : value;
      } else {
        map[name] = value;
      }
    }
    return map;
  }
}

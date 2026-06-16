import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqflite_common/sqflite.dart';

import 'config.dart';
import 'compliance_service.dart';
import 'document_classifier.dart';
import 'sqlite_store.dart';

bool _isUniqueConstraintError(Object e) {
  return e is DatabaseException && e.isUniqueConstraintError();
}

Handler createApiHandler(SqliteStore store, Directory uploadsDir) {
  final router = Router();
  final compliance = ComplianceService(store);

  String userRole(Request request) {
    return (request.headers['x-user-role'] ??
            request.headers['X-User-Role'] ??
            'admin')
        .toLowerCase();
  }

  String userActor(Request request) {
    return request.headers['x-user-name'] ??
        request.headers['X-User-Name'] ??
        'system';
  }

  Future<bool> checkAccess(
    Request request, {
    required String resource,
    required String action,
  }) async {
    final rules = await store.fetchAccessRules();
    return compliance.isAccessAllowed(
      role: userRole(request),
      resource: resource,
      action: action,
      rules: rules,
    );
  }

  Future<void> audit(
    Request request, {
    required String action,
    String resourceType = '',
    String resourceId = '',
    String details = '',
  }) async {
    await compliance.logAudit(
      actor: userActor(request),
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      details: details,
    );
  }

  String publicBaseUrl(Request request) {
    final host = request.requestedUri.host;
    final port = ServerConfig.apiPort;
    return 'http://$host:$port';
  }

  Response jsonResponse(Object body, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  Response errorResponse(String message, {int statusCode = 500}) {
    return jsonResponse({'error': message}, statusCode: statusCode);
  }

  router.get('/api/health', (Request request) {
    return jsonResponse({
      'status': 'ok',
      'database': 'sqlite',
      'database_path': ServerConfig.resolvedDbPath,
    });
  });

  router.get('/api/students', (Request request) async {
    try {
      final courseIdParam = request.url.queryParameters['course_id'];
      final courseName = request.url.queryParameters['course']?.trim();
      final courseId =
          courseIdParam != null ? int.tryParse(courseIdParam) : null;
      final rows = await store.fetchStudents(
        courseId: courseId,
        courseName: courseName,
      );
      return jsonResponse(rows);
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.post('/api/students', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final row = await store.insertStudent(
        studentNo: '${data['student_no'] ?? ''}'.trim(),
        fullName: '${data['full_name'] ?? ''}'.trim(),
        course: '${data['course'] ?? ''}'.trim(),
        year: int.tryParse('${data['year'] ?? 1}') ?? 1,
        status: 'graduated',
        email: '${data['email'] ?? ''}'.trim(),
      );
      await audit(
        request,
        action: 'student_created',
        resourceType: 'student',
        resourceId: '${row['id']}',
        details: row['full_name']?.toString() ?? '',
      );
      return jsonResponse(row, statusCode: 201);
    } catch (e) {
      if (_isUniqueConstraintError(e)) {
        return errorResponse('Student number already exists.', statusCode: 409);
      }
      return errorResponse('$e');
    }
  });

  router.delete('/api/students/<id>', (Request request, String id) async {
    try {
      final studentId = int.tryParse(id);
      if (studentId == null) {
        return errorResponse('Invalid student id', statusCode: 400);
      }
      if (!await checkAccess(request, resource: 'students', action: 'delete')) {
        return errorResponse('Access denied by rule-based policy.', statusCode: 403);
      }
      final ok = await store.deleteStudent(studentId);
      if (!ok) {
        return errorResponse('Student not found', statusCode: 404);
      }
      await audit(
        request,
        action: 'student_deleted',
        resourceType: 'student',
        resourceId: id,
      );
      return jsonResponse({'deleted': true});
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/courses', (Request request) async {
    try {
      final collegeIdParam = request.url.queryParameters['college_id'];
      final collegeId =
          collegeIdParam != null ? int.tryParse(collegeIdParam) : null;
      final rows = await store.fetchCourses(collegeId: collegeId);
      return jsonResponse(rows);
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.post('/api/courses', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final name = '${data['name'] ?? ''}'.trim();
      if (name.isEmpty) {
        return errorResponse('Name is required.', statusCode: 400);
      }
      final collegeIdRaw = data['college_id'];
      final collegeId = collegeIdRaw == null
          ? null
          : int.tryParse('$collegeIdRaw');
      if (collegeId == null) {
        return errorResponse(
          'college_id is required. Add programs from a college.',
          statusCode: 400,
        );
      }
      final row = await store.insertCourse(
        name: name,
        collegeId: collegeId,
      );
      return jsonResponse(row, statusCode: 201);
    } catch (e) {
      if (_isUniqueConstraintError(e)) {
        return errorResponse('Program name already exists.', statusCode: 409);
      }
      return errorResponse('$e');
    }
  });

  router.put('/api/courses/<id>', (Request request, String id) async {
    try {
      final courseId = int.tryParse(id);
      if (courseId == null) {
        return errorResponse('Invalid program id', statusCode: 400);
      }
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final name = '${data['name'] ?? ''}'.trim();
      if (name.isEmpty) {
        return errorResponse('Name is required.', statusCode: 400);
      }
      final collegeIdRaw = data['college_id'];
      final collegeId = collegeIdRaw == null
          ? null
          : int.tryParse('$collegeIdRaw');
      final row = await store.updateCourse(
        id: courseId,
        name: name,
        collegeId: collegeId,
      );
      if (row == null) {
        return errorResponse('Program not found', statusCode: 404);
      }
      return jsonResponse(row);
    } catch (e) {
      if (_isUniqueConstraintError(e)) {
        return errorResponse('Program name already exists.', statusCode: 409);
      }
      return errorResponse('$e');
    }
  });

  router.delete('/api/courses/<id>', (Request request, String id) async {
    try {
      final courseId = int.tryParse(id);
      if (courseId == null) {
        return errorResponse('Invalid program id', statusCode: 400);
      }
      final ok = await store.deleteCourse(courseId);
      if (!ok) {
        return errorResponse('Program not found', statusCode: 404);
      }
      return jsonResponse({'deleted': true});
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/colleges', (Request request) async {
    try {
      final rows = await store.fetchColleges();
      return jsonResponse(rows);
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.post('/api/colleges', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final name = '${data['name'] ?? ''}'.trim();
      if (name.isEmpty) {
        return errorResponse('Name is required.', statusCode: 400);
      }
      final row = await store.insertCollege(name: name);
      return jsonResponse(row, statusCode: 201);
    } catch (e) {
      if (_isUniqueConstraintError(e)) {
        return errorResponse('College name already exists.', statusCode: 409);
      }
      return errorResponse('$e');
    }
  });

  router.put('/api/colleges/<id>', (Request request, String id) async {
    try {
      final collegeId = int.tryParse(id);
      if (collegeId == null) {
        return errorResponse('Invalid college id', statusCode: 400);
      }
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final name = '${data['name'] ?? ''}'.trim();
      if (name.isEmpty) {
        return errorResponse('Name is required.', statusCode: 400);
      }
      final row = await store.updateCollege(
        id: collegeId,
        name: name,
      );
      if (row == null) {
        return errorResponse('College not found', statusCode: 404);
      }
      return jsonResponse(row);
    } catch (e) {
      if (_isUniqueConstraintError(e)) {
        return errorResponse('College name already exists.', statusCode: 409);
      }
      return errorResponse('$e');
    }
  });

  router.delete('/api/colleges/<id>', (Request request, String id) async {
    try {
      final collegeId = int.tryParse(id);
      if (collegeId == null) {
        return errorResponse('Invalid college id', statusCode: 400);
      }
      final ok = await store.deleteCollege(collegeId);
      if (!ok) {
        return errorResponse('College not found', statusCode: 404);
      }
      return jsonResponse({'deleted': true});
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/documents', (Request request) async {
    try {
      final rows = await store.fetchDocuments();
      final base = publicBaseUrl(request);
      final withUrls = rows.map((row) {
        final path = (row['image_path'] ?? '').toString();
        if (path.startsWith('/uploads/')) {
          return {...row, 'image_path': '$base$path'};
        }
        return row;
      }).toList();
      return jsonResponse(withUrls);
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.post('/api/documents', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final base64 = (data['image_base64'] ?? '').toString();
      if (base64.isEmpty) {
        return errorResponse('image_base64 is required', statusCode: 400);
      }

      final bytes = base64Decode(base64);
      final contentHash = ComplianceService.hashBytes(bytes);
      final duplicate = await compliance.findDuplicateByHash(contentHash);

      final originalName =
          (data['file_name'] ?? 'upload.bin').toString().trim();
      final safeName = _safeFileName(originalName);

      final studentName = '${data['student'] ?? ''}'.trim();
      final studentNo = '${data['student_no'] ?? ''}'.trim();
      final courseName = '${data['course'] ?? ''}'.trim();
      var program = '${data['program'] ?? ''}'.trim();
      if (program.isEmpty && courseName.isNotEmpty) {
        program =
            (await store.programCodeForCourse(courseName)) ?? courseName;
      }
      final schoolYear = '${data['school_year'] ?? ''}'.trim();
      final documentType = '${data['document_type'] ?? ''}'.trim();
      final isComplete = data['is_complete'] == true ||
          data['is_complete']?.toString() == 'true';

      var college = '${data['college'] ?? ''}'.trim();
      if (college.isEmpty && courseName.isNotEmpty) {
        college = (await store.collegeNameForCourse(courseName)) ?? '';
      }

      var studentCategory = '${data['student_category'] ?? ''}'.trim();
      if (studentCategory.isEmpty) {
        studentCategory = '${data['status'] ?? ''}'.trim();
      }
      if (studentCategory.isEmpty) {
        studentCategory = 'Graduated';
      }

      final relativePath = DocumentClassifier.buildRelativePath(
        schoolYear: schoolYear.isEmpty ? 'Unknown' : schoolYear,
        college: college.isEmpty ? 'General' : college,
        program: program.isEmpty ? 'General' : program,
        studentCategory: studentCategory,
        studentNo: studentNo,
        studentName: studentName,
        documentType: documentType.isEmpty ? 'Other' : documentType,
        fileName: safeName,
        isComplete: isComplete,
      );

      final file = File(
        '${uploadsDir.path}${Platform.pathSeparator}$relativePath',
      );
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);

      final imagePath = DocumentClassifier.toUrlPath(relativePath);
      final normalizedCategory =
          DocumentClassifier.normalizeCategory(studentCategory);

      final row = await store.insertDocument(
        title: '${data['title'] ?? 'Untitled'}'.trim(),
        student: studentName,
        imagePath: imagePath,
        mimeType: '${data['mime_type'] ?? 'image'}'.trim(),
        sizeBytes: bytes.length,
        documentType: documentType,
        schoolYear: schoolYear,
        program: program,
        studentNo: studentNo,
        storagePath: relativePath.replaceAll(Platform.pathSeparator, '/'),
        college: college.isEmpty ? 'General' : college,
        studentCategory: normalizedCategory,
        contentHash: contentHash,
      );

      await audit(
        request,
        action: 'document_uploaded',
        resourceType: 'document',
        resourceId: '${row['id']}',
        details: row['title']?.toString() ?? '',
      );

      final base = publicBaseUrl(request);
      return jsonResponse({
        ...row,
        'image_path': '$base$imagePath',
        'duplicate_detected': duplicate != null,
        'duplicate_of': duplicate?['id'],
      }, statusCode: 201);
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.delete('/api/documents/<id>', (Request request, String id) async {
    try {
      final docId = int.tryParse(id);
      if (docId == null) {
        return errorResponse('Invalid document id', statusCode: 400);
      }
      if (!await checkAccess(request, resource: 'documents', action: 'delete')) {
        return errorResponse('Access denied by rule-based policy.', statusCode: 403);
      }
      final ok = await store.deleteDocument(docId);
      if (!ok) {
        return errorResponse('Document not found', statusCode: 404);
      }
      await audit(
        request,
        action: 'document_deleted',
        resourceType: 'document',
        resourceId: id,
      );
      return jsonResponse({'deleted': true});
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/compliance/overview', (Request request) async {
    try {
      return jsonResponse(await compliance.fetchOverview());
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/compliance/retention', (Request request) async {
    try {
      return jsonResponse(await compliance.fetchRetentionMonitoring());
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/compliance/retention/policies', (Request request) async {
    try {
      return jsonResponse(await compliance.fetchRetentionPolicies());
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/compliance/access-rules', (Request request) async {
    try {
      return jsonResponse(await compliance.fetchAccessRules());
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/compliance/duplicates', (Request request) async {
    try {
      return jsonResponse(await compliance.fetchDuplicates());
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/compliance/analytics', (Request request) async {
    try {
      return jsonResponse(await compliance.fetchDecisionAnalytics());
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.post('/api/compliance/backup', (Request request) async {
    try {
      if (!await checkAccess(request, resource: 'compliance', action: 'manage')) {
        return errorResponse('Access denied by rule-based policy.', statusCode: 403);
      }
      final result = await compliance.createBackup();
      return jsonResponse(result, statusCode: 201);
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/compliance/backups', (Request request) async {
    try {
      return jsonResponse(await compliance.fetchBackups());
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.post('/api/compliance/restore', (Request request) async {
    try {
      if (!await checkAccess(request, resource: 'backup', action: 'restore')) {
        return errorResponse('Access denied by rule-based policy.', statusCode: 403);
      }
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final label = '${data['label'] ?? ''}'.trim();
      if (label.isEmpty) {
        return errorResponse('label is required', statusCode: 400);
      }
      final result = await compliance.restoreBackup(label);
      return jsonResponse(result);
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/compliance/privacy', (Request request) async {
    try {
      return jsonResponse(await compliance.fetchPrivacyCompliance());
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/compliance/disposal', (Request request) async {
    try {
      return jsonResponse(await compliance.fetchDisposalRecommendations());
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.post('/api/compliance/disposal/<id>/approve', (
    Request request,
    String id,
  ) async {
    try {
      if (!await checkAccess(request, resource: 'compliance', action: 'manage')) {
        return errorResponse('Access denied by rule-based policy.', statusCode: 403);
      }
      final docId = int.tryParse(id);
      if (docId == null) {
        return errorResponse('Invalid document id', statusCode: 400);
      }
      final row = await compliance.approveDisposal(docId);
      return jsonResponse(row);
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/compliance/iso', (Request request) async {
    try {
      return jsonResponse(await compliance.fetchIsoCompliance());
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.get('/api/audit-logs', (Request request) async {
    try {
      final limitParam = request.url.queryParameters['limit'];
      final limit = int.tryParse(limitParam ?? '') ?? 100;
      return jsonResponse(await compliance.fetchAuditLogs(limit: limit));
    } catch (e) {
      return errorResponse('$e');
    }
  });

  router.post('/api/audit-logs', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final row = await compliance.logAudit(
        actor: '${data['actor'] ?? userActor(request)}'.trim(),
        action: '${data['action'] ?? ''}'.trim(),
        resourceType: '${data['resource_type'] ?? ''}'.trim(),
        resourceId: '${data['resource_id'] ?? ''}'.trim(),
        details: '${data['details'] ?? ''}'.trim(),
      );
      return jsonResponse(row, statusCode: 201);
    } catch (e) {
      return errorResponse('$e');
    }
  });

  return router.call;
}

/// Serves nested files under `/uploads/...` (rule-based folder layout).
Handler createUploadsHandler(Directory uploadsDir) {
  return (Request request) {
    final urlPath = request.requestedUri.path;
    if (!urlPath.startsWith('/uploads/')) {
      return Response.notFound('Not found');
    }

    final relative = urlPath
        .replaceFirst('/uploads/', '')
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .map(_safeFileName)
        .join(Platform.pathSeparator);

    if (relative.isEmpty || relative.contains('..')) {
      return Response.notFound('File not found');
    }

    final file = File(
      p.join(uploadsDir.absolute.path, relative),
    );
    final uploadsRoot = p.normalize(uploadsDir.absolute.path);
    final filePath = p.normalize(file.absolute.path);
    if (!p.isWithin(uploadsRoot, filePath)) {
      return Response.forbidden('Invalid path');
    }
    if (!file.existsSync()) {
      return Response.notFound('File not found');
    }

    return Response.ok(
      file.openRead(),
      headers: {'content-type': _guessContentType(file.path)},
    );
  };
}

String _safeFileName(String name) {
  final base = name.split(Platform.pathSeparator).last;
  return base.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
}

String _guessContentType(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.pdf')) return 'application/pdf';
  return 'application/octet-stream';
}

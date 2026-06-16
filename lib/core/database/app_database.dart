import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../config/api_config.dart';
import 'api_unavailable_exception.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  String userRole = 'admin';
  String userName = 'system';

  Map<String, String> get _sessionHeaders => {
        'content-type': 'application/json',
        'x-user-role': userRole,
        'x-user-name': userName,
      };

  static Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<void> ensureInitialized() async {
    try {
      final response = await http
          .get(_uri('/api/health'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw ApiUnavailableException(
          'API returned status ${response.statusCode}. '
          'Check that the Dart server is running (run_api_server.bat or server\\run_server.bat).',
        );
      }
    } on SocketException {
      throw ApiUnavailableException();
    } on http.ClientException {
      throw ApiUnavailableException();
    } on ApiUnavailableException {
      rethrow;
    }
  }

  Future<List<Map<String, Object?>>> fetchStudents({
    int? courseId,
    String? course,
  }) async {
    var path = '/api/students';
    final queryParts = <String>[];
    if (courseId != null) {
      queryParts.add('course_id=$courseId');
    } else if (course != null && course.trim().isNotEmpty) {
      queryParts.add('course=${Uri.encodeComponent(course.trim())}');
    }
    if (queryParts.isNotEmpty) {
      path = '$path?${queryParts.join('&')}';
    }
    final response = await http.get(_uri(path));
    _ensureOk(response);
    return _decodeList(response.body);
  }

  Future<Map<String, Object?>> insertStudent({
    required String studentNo,
    required String fullName,
    required String course,
    required int year,
    required String status,
    String email = '',
  }) async {
    final response = await http.post(
      _uri('/api/students'),
      headers: _sessionHeaders,
      body: jsonEncode({
        'student_no': studentNo,
        'full_name': fullName,
        'course': course,
        'year': year,
        'status': status,
        'email': email,
      }),
    );
    _ensureOk(response, expected: {200, 201});
    return _decodeMap(response.body);
  }

  Future<bool> deleteStudent(int id) async {
    final response = await http.delete(
      _uri('/api/students/$id'),
      headers: _sessionHeaders,
    );
    if (response.statusCode == 404) return false;
    _ensureOk(response);
    return true;
  }

  Future<List<Map<String, Object?>>> fetchCourses({int? collegeId}) async {
    final uri = collegeId != null
        ? _uri('/api/courses?college_id=$collegeId')
        : _uri('/api/courses');
    final response = await http.get(uri);
    _ensureOk(response);
    return _decodeList(response.body);
  }

  Future<Map<String, Object?>> insertCourse({
    required String name,
    int? collegeId,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (collegeId != null) {
      body['college_id'] = collegeId;
    }
    final response = await http.post(
      _uri('/api/courses'),
      headers: _sessionHeaders,
      body: jsonEncode(body),
    );
    _ensureOk(response, expected: {200, 201});
    return _decodeMap(response.body);
  }

  Future<Map<String, Object?>> updateCourse({
    required int id,
    required String name,
    int? collegeId,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (collegeId != null) {
      body['college_id'] = collegeId;
    }
    final response = await http.put(
      _uri('/api/courses/$id'),
      headers: _sessionHeaders,
      body: jsonEncode(body),
    );
    _ensureOk(response);
    return _decodeMap(response.body);
  }

  Future<bool> deleteCourse(int id) async {
    final response = await http.delete(_uri('/api/courses/$id'));
    if (response.statusCode == 404) return false;
    _ensureOk(response);
    return true;
  }

  Future<List<Map<String, Object?>>> fetchColleges() async {
    final response = await http.get(_uri('/api/colleges'));
    _ensureOk(response);
    return _decodeList(response.body);
  }

  Future<Map<String, Object?>> insertCollege({
    required String name,
  }) async {
    final response = await http.post(
      _uri('/api/colleges'),
      headers: _sessionHeaders,
      body: jsonEncode({
        'name': name,
      }),
    );
    _ensureOk(response, expected: {200, 201});
    return _decodeMap(response.body);
  }

  Future<Map<String, Object?>> updateCollege({
    required int id,
    required String name,
  }) async {
    final response = await http.put(
      _uri('/api/colleges/$id'),
      headers: _sessionHeaders,
      body: jsonEncode({
        'name': name,
      }),
    );
    _ensureOk(response);
    return _decodeMap(response.body);
  }

  Future<bool> deleteCollege(int id) async {
    final response = await http.delete(_uri('/api/colleges/$id'));
    if (response.statusCode == 404) return false;
    _ensureOk(response);
    return true;
  }

  Future<List<Map<String, Object?>>> fetchDocuments() async {
    final response = await http.get(_uri('/api/documents'));
    _ensureOk(response);
    return _decodeList(response.body);
  }

  Future<Map<String, Object?>> insertDocument({
    required String title,
    required String student,
    required String sourceImagePath,
    String mimeType = 'image',
    String studentNo = '',
    String course = '',
    String program = '',
    String schoolYear = '',
    String documentType = '',
    bool isComplete = true,
    String college = '',
    String studentCategory = '',
  }) async {
    final source = File(sourceImagePath);
    if (!await source.exists()) {
      throw StateError('Image file not found: $sourceImagePath');
    }

    final bytes = await source.readAsBytes();
    final response = await http.post(
      _uri('/api/documents'),
      headers: _sessionHeaders,
      body: jsonEncode({
        'title': title,
        'student': student,
        'mime_type': mimeType,
        'file_name': p.basename(sourceImagePath),
        'image_base64': base64Encode(bytes),
        'student_no': studentNo,
        'course': course,
        'program': program,
        'school_year': schoolYear,
        'document_type': documentType,
        'is_complete': isComplete,
        'college': college,
        'student_category': studentCategory,
      }),
    );
    _ensureOk(response, expected: {200, 201});
    return _decodeMap(response.body);
  }

  Future<bool> deleteDocument(int id, {bool deleteFile = true}) async {
    final response = await http.delete(
      _uri('/api/documents/$id'),
      headers: _sessionHeaders,
    );
    if (response.statusCode == 404) return false;
    _ensureOk(response);
    return true;
  }

  Future<Map<String, Object?>> fetchComplianceOverview() async {
    final response = await http.get(_uri('/api/compliance/overview'));
    _ensureOk(response);
    return _decodeMap(response.body);
  }

  Future<List<Map<String, Object?>>> fetchRetentionMonitoring() async {
    final response = await http.get(_uri('/api/compliance/retention'));
    _ensureOk(response);
    return _decodeList(response.body);
  }

  Future<List<Map<String, Object?>>> fetchRetentionPolicies() async {
    final response = await http.get(_uri('/api/compliance/retention/policies'));
    _ensureOk(response);
    return _decodeList(response.body);
  }

  Future<List<Map<String, Object?>>> fetchAccessRules() async {
    final response = await http.get(_uri('/api/compliance/access-rules'));
    _ensureOk(response);
    return _decodeList(response.body);
  }

  Future<List<Map<String, Object?>>> fetchDuplicateGroups() async {
    final response = await http.get(_uri('/api/compliance/duplicates'));
    _ensureOk(response);
    return _decodeList(response.body);
  }

  Future<Map<String, Object?>> fetchComplianceAnalytics() async {
    final response = await http.get(_uri('/api/compliance/analytics'));
    _ensureOk(response);
    return _decodeMap(response.body);
  }

  Future<Map<String, Object?>> createBackup() async {
    final response = await http.post(
      _uri('/api/compliance/backup'),
      headers: _sessionHeaders,
    );
    _ensureOk(response, expected: {200, 201});
    return _decodeMap(response.body);
  }

  Future<List<Map<String, Object?>>> fetchBackups() async {
    final response = await http.get(_uri('/api/compliance/backups'));
    _ensureOk(response);
    return _decodeList(response.body);
  }

  Future<Map<String, Object?>> restoreBackup(String label) async {
    final response = await http.post(
      _uri('/api/compliance/restore'),
      headers: _sessionHeaders,
      body: jsonEncode({'label': label}),
    );
    _ensureOk(response);
    return _decodeMap(response.body);
  }

  Future<Map<String, Object?>> fetchPrivacyCompliance() async {
    final response = await http.get(_uri('/api/compliance/privacy'));
    _ensureOk(response);
    return _decodeMap(response.body);
  }

  Future<List<Map<String, Object?>>> fetchDisposalRecommendations() async {
    final response = await http.get(_uri('/api/compliance/disposal'));
    _ensureOk(response);
    return _decodeList(response.body);
  }

  Future<Map<String, Object?>> approveDisposal(int documentId) async {
    final response = await http.post(
      _uri('/api/compliance/disposal/$documentId/approve'),
      headers: _sessionHeaders,
    );
    _ensureOk(response);
    return _decodeMap(response.body);
  }

  Future<Map<String, Object?>> fetchIsoCompliance() async {
    final response = await http.get(_uri('/api/compliance/iso'));
    _ensureOk(response);
    return _decodeMap(response.body);
  }

  Future<List<Map<String, Object?>>> fetchAuditLogs({int limit = 100}) async {
    final response = await http.get(_uri('/api/audit-logs?limit=$limit'));
    _ensureOk(response);
    return _decodeList(response.body);
  }

  void _ensureOk(http.Response response, {Set<int>? expected}) {
    final allowed = expected ?? {200};
    if (allowed.contains(response.statusCode)) return;

    String message = 'Request failed (${response.statusCode})';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final error = body['error']?.toString();
      if (error != null && error.isNotEmpty) {
        message = error;
      }
    } catch (_) {}

    throw StateError(message);
  }

  List<Map<String, Object?>> _decodeList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) {
      throw StateError('Expected a JSON array from API');
    }
    return decoded
        .map((item) => Map<String, Object?>.from(item as Map))
        .toList();
  }

  Map<String, Object?> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw StateError('Expected a JSON object from API');
    }
    return Map<String, Object?>.from(decoded);
  }
}

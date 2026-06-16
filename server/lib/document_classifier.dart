import 'dart:io';

import 'package:path/path.dart' as p;

/// Rule-based folder layout for registrar uploads (automated file organization).
///
/// Complete documents:
///   {schoolYear}/{college}/{program}/{studentCategory}/{studentNo}_{lastName}/{documentFileName}
///
/// Incomplete documents:
///   Pending Documents/{originalFileName}
class DocumentClassifier {
  static String buildRelativePath({
    required String schoolYear,
    required String college,
    required String program,
    required String studentCategory,
    required String studentNo,
    required String studentName,
    required String documentType,
    required String fileName,
    required bool isComplete,
  }) {
    final safeFile = _safeFileName(fileName);

    if (!isComplete) {
      return 'Pending Documents${Platform.pathSeparator}$safeFile';
    }

    final year = _safeSegment(schoolYear);
    final collegeSeg = _safeSegment(college);
    final prog = _safeSegment(program);
    final category = _safeSegment(normalizeCategory(studentCategory));
    final studentFolder = _studentFolder(studentNo, studentName);
    final typeFile = _fileNameForType(documentType, safeFile);

    return '$year${Platform.pathSeparator}$collegeSeg'
        '${Platform.pathSeparator}$prog'
        '${Platform.pathSeparator}$category'
        '${Platform.pathSeparator}$studentFolder'
        '${Platform.pathSeparator}$typeFile';
  }

  /// Title-cases a student category label for folder names (e.g. `graduated` → `Graduated`).
  static String normalizeCategory(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'General';
    return trimmed
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
          if (part.length == 1) return part.toUpperCase();
          return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  static String toUrlPath(String relativePath) {
    return '/uploads/${relativePath.replaceAll(Platform.pathSeparator, '/')}';
  }

  static String _studentFolder(String studentNo, String studentName) {
    final no = _safeSegment(studentNo);
    final last = _lastName(studentName);
    if (no.isEmpty && last.isEmpty) return 'unknown';
    if (last.isEmpty) return no;
    if (no.isEmpty) return last;
    return '${no}_$last';
  }

  static String _lastName(String fullName) {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    return _safeSegment(parts.last);
  }

  static String _fileNameForType(String documentType, String originalSafe) {
    final ext = p.extension(originalSafe);
    final normalized =
        documentType.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (normalized.isEmpty) return originalSafe;
    return '$normalized${ext.isEmpty ? '' : ext}';
  }

  static String _safeSegment(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'unknown';
    return trimmed.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  static String _safeFileName(String name) {
    final base = name.split(Platform.pathSeparator).last;
    return base.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }
}

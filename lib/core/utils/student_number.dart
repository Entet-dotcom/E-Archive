/// Student ID format: `{PROGRAM}-{YY}-A-{SERIAL}` (e.g. KC-22-A-00000).
class StudentNumber {
  StudentNumber._();

  static const int serialDigits = 5;
  static const int minSerial = 0;
  static const String segmentLetter = 'A';
  static const String example = 'KC-22-A-00000';

  static final RegExp _formatPattern = RegExp(
    r'^([A-Z0-9]+)-(\d{2})-A-(\d{5})$',
    caseSensitive: false,
  );

  static final RegExp _serialSuffixPattern = RegExp(r'-(\d{5})$');

  /// Two-digit year from a school year like `2022-2023` → `22`.
  static String yearSuffix(String schoolYear) {
    final trimmed = schoolYear.trim();
    if (trimmed.isEmpty) {
      return _currentYearSuffix();
    }
    final start = trimmed.split('-').first.trim();
    final year = int.tryParse(start);
    if (year != null && year >= 100) {
      return (year % 100).toString().padLeft(2, '0');
    }
    final match = RegExp(r'^(\d{4})').firstMatch(trimmed);
    if (match != null) {
      final y = int.tryParse(match.group(1)!);
      if (y != null) return (y % 100).toString().padLeft(2, '0');
    }
    return _currentYearSuffix();
  }

  static String _currentYearSuffix() {
    return (DateTime.now().year % 100).toString().padLeft(2, '0');
  }

  /// Resolves a program code from a course name, e.g. `(BEEd)` → `BEED`.
  static String programCodeFromName(String programName) {
    final trimmed = programName.trim();
    if (trimmed.isEmpty) return 'KC';

    final paren = RegExp(r'\(([^)]+)\)\s*$').firstMatch(trimmed);
    if (paren != null) {
      final code = paren.group(1)!.trim();
      if (code.isNotEmpty) return code.toUpperCase();
    }

    final bsIn = RegExp(
      r'^bachelor\s+of\s+science\s+in\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(trimmed.replaceAll(RegExp(r'\([^)]*\)'), '').trim());
    if (bsIn != null) {
      final restWords = bsIn
          .group(1)!
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      if (restWords.isNotEmpty) {
        return 'BS${restWords.map((w) => w[0].toUpperCase()).join()}';
      }
    }

    final words = trimmed
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'KC';

    final skip = {'of', 'in', 'and', 'the', 'major'};
    final letters = <String>[];
    for (final word in words) {
      final lower = word.toLowerCase();
      if (skip.contains(lower)) continue;
      if (lower == 'bachelor' || lower == 'science') continue;
      letters.add(word[0].toUpperCase());
      if (letters.length >= 2) break;
    }
    if (letters.isEmpty) return 'KC';
    return letters.join();
  }

  static String resolveProgramCode({
    required String programName,
    String? courseCode,
  }) {
    final fromApi = courseCode?.trim();
    if (fromApi != null && fromApi.isNotEmpty) {
      return fromApi.toUpperCase();
    }
    return programCodeFromName(programName);
  }

  static String prefix(String programCode, String schoolYear) {
    final code =
        programCode.trim().isEmpty ? 'KC' : programCode.trim().toUpperCase();
    return '$code-${yearSuffix(schoolYear)}-$segmentLetter';
  }

  static String format({
    required String programCode,
    required String schoolYear,
    required int serial,
  }) {
    final clamped = serial.clamp(minSerial, 99999);
    final serialText = clamped.toString().padLeft(serialDigits, '0');
    return '${prefix(programCode, schoolYear)}-$serialText';
  }

  static int? parseSerial(String studentNo) {
    final trimmed = studentNo.trim().toUpperCase();
    final match = _formatPattern.firstMatch(trimmed);
    if (match != null) {
      return int.tryParse(match.group(3)!);
    }
    final suffix = _serialSuffixPattern.firstMatch(trimmed);
    if (suffix != null) {
      return int.tryParse(suffix.group(1)!);
    }
    final parts = trimmed.split('-');
    if (parts.length >= 2) {
      return int.tryParse(parts.last);
    }
    return null;
  }

  static bool matchesPrefix(String studentNo, String prefixValue) {
    return studentNo.trim().toUpperCase().startsWith(
          '${prefixValue.trim().toUpperCase()}-',
        );
  }

  static int maxSerialForPrefix(
    Iterable<String> studentNumbers,
    String prefixValue,
  ) {
    final normalizedPrefix = prefixValue.trim().toUpperCase();
    var max = minSerial - 1;
    for (final raw in studentNumbers) {
      final no = raw.trim().toUpperCase();
      if (!matchesPrefix(no, normalizedPrefix)) continue;
      final serial = parseSerial(no);
      if (serial != null && serial > max) max = serial;
    }
    return max;
  }

  /// Next ID for the program/year group; first ID uses serial [minSerial] (00000).
  static String next({
    required Iterable<String> existingStudentNumbers,
    required String programCode,
    required String schoolYear,
  }) {
    final groupPrefix = prefix(programCode, schoolYear);
    final maxSerial = maxSerialForPrefix(existingStudentNumbers, groupPrefix);
    final nextSerial = maxSerial < minSerial ? minSerial : maxSerial + 1;
    return format(
      programCode: programCode,
      schoolYear: schoolYear,
      serial: nextSerial,
    );
  }
}

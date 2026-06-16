part of '../../dashboard_shell_page.dart';

class _AnalyticsData {
  const _AnalyticsData({
    required this.students,
    required this.courses,
    required this.documents,
    required this.byCourse,
    required this.bySchoolYear,
    required this.availableYears,
    required this.byCourseByYear,
    required this.graduatesByYear,
  });

  final int students;
  final int courses;
  final int documents;
  final List<_CourseCount> byCourse;
  final List<_YearCount> bySchoolYear;
  final List<String> availableYears;

  /// Program breakdown per school year (for year drill-down charts).
  final Map<String, List<_CourseCount>> byCourseByYear;

  /// Graduates grouped by school year (for year drill-down lists).
  final Map<String, List<_AnalyticsGraduate>> graduatesByYear;

  /// Metrics scoped to a single school year (stats row and insight cards).
  _AnalyticsData forSchoolYear(
    String year,
    List<_CourseCount> coursesForYear,
  ) {
    var graduateCount = 0;
    for (final entry in bySchoolYear) {
      if (entry.year == year) {
        graduateCount = entry.students;
        break;
      }
    }

    return _AnalyticsData(
      students: graduateCount,
      courses: coursesForYear.length,
      documents: 0,
      byCourse: coursesForYear,
      bySchoolYear: bySchoolYear.where((e) => e.year == year).toList(),
      availableYears: availableYears,
      byCourseByYear: byCourseByYear,
      graduatesByYear: graduatesByYear,
    );
  }
}

class _AnalyticsGraduate {
  const _AnalyticsGraduate({
    required this.studentNo,
    required this.fullName,
    required this.course,
    required this.programLabel,
    required this.schoolYear,
  });

  final String studentNo;
  final String fullName;
  final String course;
  final String programLabel;
  final String schoolYear;
}

String _graduateInitials(String fullName) {
  final parts =
      fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final word = parts.first;
    return word.length >= 2
        ? word.substring(0, 2).toUpperCase()
        : word.toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

Color _accentForProgram(String program, List<Color> palette) {
  if (palette.isEmpty) return const Color(0xFF3B82F6);
  final key = program.trim().isEmpty ? 'default' : program.trim();
  return palette[key.hashCode.abs() % palette.length];
}

class _CourseCount {
  const _CourseCount({
    required this.name,
    required this.code,
    required this.count,
  });

  /// Full program name (e.g. from student records).
  final String name;

  /// Short chart label (e.g. BSCS, BSHM).
  final String code;
  final int count;
}

class _YearCount {
  const _YearCount({
    required this.year,
    required this.students,
    required this.documents,
  });

  final String year;
  final int students;
  final int documents;
}

int _chartMax(Iterable<int> values) {
  if (values.isEmpty) return 1;
  final maxValue = values.reduce(math.max);
  if (maxValue <= 0) return 1;

  // Tight axis for small counts so bars fill the plot vertically.
  if (maxValue <= 5) return maxValue + 1;

  final withHeadroom = (maxValue * 1.12).ceil();
  if (withHeadroom <= 10) return ((withHeadroom + 1) ~/ 2) * 2;
  if (withHeadroom <= 50) return ((withHeadroom + 4) ~/ 5) * 5;
  return ((withHeadroom + 9) ~/ 10) * 10;
}

/// Grid divisions for bar charts (fewer lines when the axis is small).
int _chartGridSteps(int maxY) {
  if (maxY <= 5) return maxY;
  if (maxY <= 10) return 5;
  return 4;
}

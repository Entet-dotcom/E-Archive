part of '../../dashboard_shell_page.dart';

class _AdminDashStatMetric {
  const _AdminDashStatMetric({
    required this.title,
    required this.icon,
    required this.accent,
    required this.valueOf,
    required this.hintOf,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final String Function(_DashboardBaseData) valueOf;
  final String Function(_DashboardBaseData) hintOf;
}

List<_AdminDashStatMetric> _adminDashStatMetrics() => const [
      _AdminDashStatMetric(
        title: 'Students',
        icon: Icons.groups_outlined,
        accent: Color(0xFF2563EB),
        valueOf: _studentsValue,
        hintOf: _studentsHint,
      ),
      _AdminDashStatMetric(
        title: 'Documents',
        icon: Icons.archive_outlined,
        accent: Color(0xFF059669),
        valueOf: _documentsValue,
        hintOf: _documentsHint,
      ),
      _AdminDashStatMetric(
        title: 'Programs',
        icon: Icons.menu_book_outlined,
        accent: Color(0xFF0891B2),
        valueOf: _programsValue,
        hintOf: _programsHint,
      ),
      _AdminDashStatMetric(
        title: 'Colleges',
        icon: Icons.account_balance_outlined,
        accent: Color(0xFF7C3AED),
        valueOf: _collegesValue,
        hintOf: _collegesHint,
      ),
    ];

String _studentsValue(_DashboardBaseData data) => '${data.studentsCount}';
String _studentsHint(_DashboardBaseData data) =>
    data.studentsWithoutDocs > 0
        ? '${data.studentsWithoutDocs} without docs'
        : 'archived profiles';

String _documentsValue(_DashboardBaseData data) => '${data.documentsCount}';
String _documentsHint(_DashboardBaseData data) => 'stored in archive';

String _programsValue(_DashboardBaseData data) => '${data.coursesCount}';
String _programsHint(_DashboardBaseData data) => 'program offerings';

String _collegesValue(_DashboardBaseData data) => '${data.collegesCount}';
String _collegesHint(_DashboardBaseData data) => 'institutions';

class _AdminDashQuickAction {
  const _AdminDashQuickAction({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

const _adminDashQuickActions = [
  _AdminDashQuickAction(
    id: 'students',
    label: 'Students',
    icon: Icons.school_outlined,
  ),
  _AdminDashQuickAction(
    id: 'archived_documents',
    label: 'Documents',
    icon: Icons.folder_outlined,
  ),
  _AdminDashQuickAction(
    id: 'compliance_hub',
    label: 'Compliance',
    icon: Icons.verified_user_outlined,
  ),
  _AdminDashQuickAction(
    id: 'data_analytics',
    label: 'Analytics',
    icon: Icons.analytics_outlined,
  ),
  _AdminDashQuickAction(
    id: 'courses',
    label: 'Programs',
    icon: Icons.menu_book_outlined,
  ),
];

String _adminDashTopProgramLabel(_DashboardBaseData data) {
  final name = data.topProgramName;
  if (name == null || name.isEmpty) return 'No program data';
  return '$name (${data.topProgramCount})';
}

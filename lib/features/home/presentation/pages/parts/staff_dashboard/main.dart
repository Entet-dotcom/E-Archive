part of '../../dashboard_shell_page.dart';

class _StaffDashboardPage extends StatelessWidget {
  const _StaffDashboardPage({
    required this.data,
    this.includeHeader = true,
  });

  final _DashboardBaseData data;
  final bool includeHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (includeHeader)
          _DashboardTopHeader(
            accountName: data.accountName,
            searchController: data.searchController,
            onSearchChanged: data.onSearchChanged,
          ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _DashboardStatTile(
              title: 'Today Uploads',
              value: data.recentUploadsCount.toString(),
              icon: Icons.cloud_upload_outlined,
              accent: const Color(0xFF0284C7),
              hint: 'documents received',
            ),
            _DashboardStatTile(
              title: 'Students',
              value: data.studentsCount.toString(),
              icon: Icons.groups_outlined,
              accent: const Color(0xFF1D4ED8),
              hint: 'records available',
            ),
            _DashboardStatTile(
              title: 'Trash',
              value: data.documentsCount.toString(),
              icon: Icons.delete_outline,
              accent: const Color(0xFF16A34A),
              hint: 'total documents',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Card(
          title: 'Recent Uploads',
          icon: Icons.history_toggle_off_outlined,
          child: _RecentUploadsTable(rows: data.recentDocs),
        ),
      ],
    );
  }
} 
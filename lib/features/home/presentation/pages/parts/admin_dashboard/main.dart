part of '../../dashboard_shell_page.dart';

/// Admin overview: KPIs, program chart, recent uploads, and shortcuts.
class _AdminDashboardPage extends StatelessWidget {
  const _AdminDashboardPage({
    required this.data,
    this.includeHeader = true,
  });

  final _DashboardBaseData data;
  final bool includeHeader;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (includeHeader) ...[
                _DashboardTopHeader(
                  accountName: data.accountName,
                  searchController: data.searchController,
                  onSearchChanged: data.onSearchChanged,
                ),
                const SizedBox(height: _AdminDashTheme.sectionGap),
              ],
              _AdminDashboardStatsRow(data: data),
              const SizedBox(height: _AdminDashTheme.sectionGap),
              Expanded(child: _AdminDashboardBody(data: data)),
            ],
          ),
        );
      },
    );
  }
}

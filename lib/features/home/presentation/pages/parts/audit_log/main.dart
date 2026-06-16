part of '../../dashboard_shell_page.dart';

class _AuditLogPage extends StatelessWidget {
  const _AuditLogPage({required this.rows});
  final List<_AuditRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PageHeader(
          title: 'Activity Log',
          subtitle: 'Review recent actions across the system.',
        ),
        Expanded(
          child: _RecordListCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: _RecordListTheme.headerBg,
                    border: Border(
                      bottom: BorderSide(color: _RecordListTheme.border),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('Actor', style: _AuditLogPage._headerStyle),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Action',
                          style: _AuditLogPage._headerStyle,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date',
                          style: _AuditLogPage._headerStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: rows.isEmpty
                      ? const Center(
                          child: Text(
                            'No activity recorded yet.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        )
                      : ListView.separated(
                          itemCount: rows.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: _RecordListTheme.border,
                          ),
                          itemBuilder: (context, index) {
                            return _AuditLogDataRow(row: rows[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF64748B),
    letterSpacing: 0.2,
  );
}

class _AuditLogDataRow extends StatelessWidget {
  const _AuditLogDataRow({required this.row});

  final _AuditRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              row.actor,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              row.action,
              style: const TextStyle(color: Color(0xFF334155)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.date,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}

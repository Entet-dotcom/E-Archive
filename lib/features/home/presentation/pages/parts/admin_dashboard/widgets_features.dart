part of '../../dashboard_shell_page.dart';

class _AdminDashboardFeatures extends StatelessWidget {
  const _AdminDashboardFeatures({
    required this.data,
    required this.sidebar,
  });

  final _DashboardBaseData data;
  final bool sidebar;

  @override
  Widget build(BuildContext context) {
    final quickActions =
        _AdminQuickActionsPanel(onNavigate: data.onNavigate);
    final activity = _AdminActivityPanel(audit: data.recentAudit);
    final snapshot = _AdminSnapshotStrip(data: data);

    if (sidebar) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: quickActions),
          const SizedBox(height: _AdminDashTheme.featureGap),
          Expanded(child: activity),
          const SizedBox(height: _AdminDashTheme.featureGap),
          snapshot,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: quickActions),
              const SizedBox(width: _AdminDashTheme.featureGap),
              Expanded(child: activity),
            ],
          ),
        ),
        const SizedBox(height: _AdminDashTheme.featureGap),
        snapshot,
      ],
    );
  }
}

class _AdminQuickActionsPanel extends StatelessWidget {
  const _AdminQuickActionsPanel({this.onNavigate});

  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    return _AdminPanel(
      compact: true,
      expandChild: true,
      title: 'Quick Actions',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoCol = constraints.maxWidth >= 160;
          return GridView.count(
            crossAxisCount: twoCol ? 2 : 1,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: twoCol ? 2.4 : 3.6,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final action in _adminDashQuickActions)
                _AdminQuickActionTile(
                  label: action.label,
                  icon: action.icon,
                  onTap: onNavigate == null
                      ? null
                      : () => onNavigate!(action.id),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminQuickActionTile extends StatelessWidget {
  const _AdminQuickActionTile({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _AdminDashTheme.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 15, color: _AdminDashTheme.link),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _AdminDashTheme.label().copyWith(
                        color: _AdminDashTheme.textBody,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminActivityPanel extends StatelessWidget {
  const _AdminActivityPanel({required this.audit});

  final List<_AuditRow> audit;

  @override
  Widget build(BuildContext context) {
    return _AdminPanel(
      compact: true,
      expandChild: true,
      title: 'Recent Activity',
      child: audit.isEmpty
          ? Center(
              child: Text(
                'No activity yet',
                style: _AdminDashTheme.label().copyWith(
                      color: _AdminDashTheme.textHint,
                    ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: audit.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: _AdminDashTheme.featureGap - 2),
              itemBuilder: (context, index) =>
                  _AdminActivityRow(row: audit[index]),
            ),
    );
  }
}

class _AdminActivityRow extends StatelessWidget {
  const _AdminActivityRow({required this.row});

  final _AuditRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.circle, size: 6, color: _AdminDashTheme.textHint),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.action,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _AdminDashTheme.label().copyWith(
                      color: _AdminDashTheme.textBody,
                    ),
              ),
              Text(
                '${row.actor} · ${row.date}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _AdminDashTheme.caption(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminSnapshotStrip extends StatelessWidget {
  const _AdminSnapshotStrip({required this.data});

  final _DashboardBaseData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _AdminDashTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AdminDashTheme.border),
      ),
      child: Row(
        children: [
          _AdminSnapshotChip(
            icon: Icons.account_balance_outlined,
            label: '${data.collegesCount} colleges',
          ),
          const SizedBox(width: 8),
          _AdminSnapshotChip(
            icon: Icons.warning_amber_outlined,
            label: '${data.studentsWithoutDocs} no docs',
            accent: data.studentsWithoutDocs > 0
                ? _AdminDashTheme.warning
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _AdminSnapshotChip(
              icon: Icons.trending_up,
              label: _adminDashTopProgramLabel(data),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSnapshotChip extends StatelessWidget {
  const _AdminSnapshotChip({
    required this.icon,
    required this.label,
    this.accent,
  });

  final IconData icon;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? _AdminDashTheme.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _AdminDashTheme.caption().copyWith(
                  color: accent ?? const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

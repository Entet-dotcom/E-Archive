part of '../../dashboard_shell_page.dart';

/// KPI row on the admin dashboard — same cards as Compliance Hub overview.
class _AdminDashboardComplianceRow extends StatelessWidget {
  const _AdminDashboardComplianceRow({
    required this.data,
    this.onNavigate,
  });

  final _DashboardBaseData data;
  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    final compliance = data.compliance;
    if (compliance == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Compliance Overview',
                style: _AdminDashTheme.panelTitle(size: 15),
              ),
            ),
            if (onNavigate != null)
              TextButton(
                onPressed: () => onNavigate!('compliance_hub'),
                style: TextButton.styleFrom(
                  foregroundColor: _AdminDashTheme.link,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Open hub',
                  style: AppFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: _AdminDashTheme.statSpacing),
        _ComplianceOverviewMetricsRow(overview: compliance.toOverviewMap()),
      ],
    );
  }
}

class _AdminDashboardComplianceInsights extends StatelessWidget {
  const _AdminDashboardComplianceInsights({
    required this.compliance,
    this.onNavigate,
  });

  final _ComplianceDashboardData compliance;
  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    if (compliance.decisions.isEmpty) return const SizedBox.shrink();

    return _AdminPanel(
      compact: true,
      title: 'Compliance Recommendations',
      trailing: onNavigate == null
          ? null
          : TextButton(
              onPressed: () => onNavigate!('compliance_hub'),
              style: TextButton.styleFrom(
                foregroundColor: _AdminDashTheme.link,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View all',
                style: AppFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
      child: Column(
        children: [
          for (var i = 0; i < compliance.decisions.length && i < 3; i++)
            Padding(
              padding: EdgeInsets.only(top: i > 0 ? 8 : 0),
              child: _ComplianceDecisionTile(row: compliance.decisions[i]),
            ),
        ],
      ),
    );
  }
}

extension on _ComplianceDashboardData {
  Map<String, Object?> toOverviewMap() => {
        'retention_active': retentionActive,
        'retention_expired': retentionExpired,
        'duplicate_groups': duplicateGroups,
        'disposal_pending': disposalPending,
        'privacy_score': privacyScore,
        'iso_score': isoScore,
      };
}

class _ComplianceOverviewMetricsRow extends StatelessWidget {
  const _ComplianceOverviewMetricsRow({required this.overview});

  final Map<String, Object?> overview;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _AdminMetricHighlightCard(
        dimension: 'Retention',
        metricValue: '${overview['retention_active'] ?? 0}',
        metricLabel: 'active records',
        icon: Icons.inventory_2_outlined,
        accent: const Color(0xFF2563EB),
      ),
      _AdminMetricHighlightCard(
        dimension: 'Expired',
        metricValue: '${overview['retention_expired'] ?? 0}',
        metricLabel: 'need review',
        icon: Icons.warning_amber_outlined,
        accent: const Color(0xFFDC2626),
      ),
      _AdminMetricHighlightCard(
        dimension: 'Duplicates',
        metricValue: '${overview['duplicate_groups'] ?? 0}',
        metricLabel: 'SHA-256 groups',
        icon: Icons.copy_all_outlined,
        accent: const Color(0xFF9333EA),
      ),
      _AdminMetricHighlightCard(
        dimension: 'Disposal',
        metricValue: '${overview['disposal_pending'] ?? 0}',
        metricLabel: 'pending approval',
        icon: Icons.delete_sweep_outlined,
        accent: const Color(0xFFEA580C),
      ),
      _AdminMetricHighlightCard(
        dimension: 'Privacy',
        metricValue: '${overview['privacy_score'] ?? 0}%',
        metricLabel: 'RA 10173 score',
        icon: Icons.privacy_tip_outlined,
        accent: const Color(0xFF059669),
      ),
      _AdminMetricHighlightCard(
        dimension: 'ISO',
        metricValue: '${overview['iso_score'] ?? 0}%',
        metricLabel: 'standards aligned',
        icon: Icons.verified_outlined,
        accent: const Color(0xFF0891B2),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (maxWidth < _AdminDashTheme.statColumnsMedium) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: _AdminDashTheme.statSpacing),
                cards[i],
              ],
            ],
          );
        }

        if (maxWidth < 1200) {
          final cardWidth =
              (maxWidth - _AdminDashTheme.statSpacing) / 2;
          return Wrap(
            spacing: _AdminDashTheme.statSpacing,
            runSpacing: _AdminDashTheme.statSpacing,
            children: [
              for (final card in cards)
                SizedBox(width: cardWidth, child: card),
            ],
          );
        }

        final cardWidth =
            (maxWidth - (5 * _AdminDashTheme.statSpacing)) / 6;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: _AdminDashTheme.statSpacing),
              SizedBox(width: cardWidth, child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}

class _ComplianceDecisionTile extends StatelessWidget {
  const _ComplianceDecisionTile({required this.row});

  final _ComplianceDecisionRow row;

  @override
  Widget build(BuildContext context) {
    final color = row.priority == 'high'
        ? const Color(0xFFDC2626)
        : row.priority == 'medium'
            ? const Color(0xFFEA580C)
            : _AdminDashTheme.link;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _AdminDashTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AdminDashTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            row.priority == 'high'
                ? Icons.priority_high
                : Icons.lightbulb_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  style: _AdminDashTheme.label().copyWith(
                        color: _AdminDashTheme.textPrimary,
                        fontSize: 12,
                      ),
                ),
                Text(
                  row.detail,
                  style: _AdminDashTheme.caption().copyWith(
                        color: _AdminDashTheme.textMuted,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceHubPage extends StatefulWidget {
  const _ComplianceHubPage({
    required this.isAdmin,
    required this.accountName,
    required this.initialTab,
  });

  final bool isAdmin;
  final String accountName;
  final int initialTab;

  @override
  State<_ComplianceHubPage> createState() => _ComplianceHubPageState();
}

class _ComplianceHubPageState extends State<_ComplianceHubPage>
    with SingleTickerProviderStateMixin {
  final _db = AppDatabase.instance;
  late TabController _tabs;
  bool _loading = true;
  String? _error;

  Map<String, Object?> _overview = {};
  List<Map<String, Object?>> _retention = [];
  List<Map<String, Object?>> _policies = [];
  List<Map<String, Object?>> _accessRules = [];
  List<Map<String, Object?>> _duplicates = [];
  Map<String, Object?> _analytics = {};
  List<Map<String, Object?>> _backups = [];
  Map<String, Object?> _privacy = {};
  List<Map<String, Object?>> _disposal = [];
  Map<String, Object?> _iso = {};

  static const _tabLabels = [
    'Overview',
    'Retention',
    'Access Rules',
    'Duplicates',
    'Analytics',
    'Backup',
    'Privacy',
    'Disposal',
    'ISO',
  ];

  @override
  void initState() {
    super.initState();
    final tab = widget.initialTab.clamp(0, _tabLabels.length - 1);
    _tabs = TabController(length: _tabLabels.length, vsync: this, initialIndex: tab);
    _loadAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _db.fetchComplianceOverview(),
        _db.fetchRetentionMonitoring(),
        _db.fetchRetentionPolicies(),
        _db.fetchAccessRules(),
        _db.fetchDuplicateGroups(),
        _db.fetchComplianceAnalytics(),
        _db.fetchBackups(),
        _db.fetchPrivacyCompliance(),
        _db.fetchDisposalRecommendations(),
        _db.fetchIsoCompliance(),
      ]);
      if (!mounted) return;
      setState(() {
        _overview = results[0] as Map<String, Object?>;
        _retention = (results[1] as List).cast<Map<String, Object?>>();
        _policies = (results[2] as List).cast<Map<String, Object?>>();
        _accessRules = (results[3] as List).cast<Map<String, Object?>>();
        _duplicates = (results[4] as List).cast<Map<String, Object?>>();
        _analytics = results[5] as Map<String, Object?>;
        _backups = (results[6] as List).cast<Map<String, Object?>>();
        _privacy = results[7] as Map<String, Object?>;
        _disposal = (results[8] as List).cast<Map<String, Object?>>();
        _iso = results[9] as Map<String, Object?>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _runBackup() async {
    try {
      await _db.createBackup();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup created successfully.')),
      );
      await _loadAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    }
  }

  Future<void> _runRestore(String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore backup?'),
        content: Text(
          'This will replace the current database and uploads with backup "$label". Continue?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Restore')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _db.restoreBackup(label);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restored. Reload data if needed.')),
      );
      await _loadAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    }
  }

  Future<void> _approveDisposal(int docId) async {
    try {
      await _db.approveDisposal(docId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disposal approved.')),
      );
      await _loadAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PageHeader(
          title: 'Compliance & Governance',
          subtitle:
              'Retention monitoring, rule-based access, duplicates, analytics, backup, privacy (RA 10173), disposal, and ISO alignment.',
          trailing: IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadAll,
            icon: const Icon(Icons.refresh),
          ),
        ),
        if (_error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Text(
              _error!,
              style: const TextStyle(color: Color(0xFF9A3412), fontSize: 12),
            ),
          ),
        if (!_loading) ...[
          _ComplianceOverviewMetricsRow(overview: _overview),
          const SizedBox(height: _AdminDashTheme.sectionGap),
        ],
        Expanded(
          child: _AdminPanel(
            compact: true,
            expandChild: true,
            title: 'Compliance Modules',
            trailing: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TabBar(
                        controller: _tabs,
                        isScrollable: true,
                        labelColor: _AdminDashTheme.link,
                        unselectedLabelColor: _AdminDashTheme.textMuted,
                        indicatorColor: _AdminDashTheme.link,
                        labelStyle: AppFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: [for (final label in _tabLabels) Tab(text: label)],
                      ),
                      const Divider(height: 1, color: _AdminDashTheme.border),
                      Expanded(
                        child: TabBarView(
                          controller: _tabs,
                          children: [
                            _ComplianceOverviewTab(overview: _overview),
                            _RetentionTab(records: _retention, policies: _policies),
                            _AccessRulesTab(rules: _accessRules),
                            _DuplicatesTab(groups: _duplicates),
                            _ComplianceAnalyticsTab(data: _analytics),
                            _BackupTab(
                              backups: _backups,
                              isAdmin: widget.isAdmin,
                              onBackup: _runBackup,
                              onRestore: _runRestore,
                            ),
                            _PrivacyTab(data: _privacy),
                            _DisposalTab(
                              items: _disposal,
                              isAdmin: widget.isAdmin,
                              onApprove: _approveDisposal,
                            ),
                            _IsoTab(data: _iso),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _ComplianceOverviewTab extends StatelessWidget {
  const _ComplianceOverviewTab({required this.overview});
  final Map<String, Object?> overview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(4),
      children: [
        _AdminPanel(
          compact: true,
          title: 'Module status',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _ModuleStatusRow(name: 'Records retention monitoring', enabled: true),
              _ModuleStatusRow(name: 'Rule-based access control', enabled: true),
              _ModuleStatusRow(name: 'Duplicate detection (SHA-256)', enabled: true),
              _ModuleStatusRow(name: 'Analytics & decision dashboard', enabled: true),
              _ModuleStatusRow(name: 'Backup & recovery', enabled: true),
              _ModuleStatusRow(name: 'Data Privacy Act (RA 10173)', enabled: true),
              _ModuleStatusRow(name: 'Disposal recommendations', enabled: true),
              _ModuleStatusRow(name: 'ISO 15489 / 30301 / 27001 compatibility', enabled: true),
            ],
          ),
        ),
        if (overview['last_backup'] != null) ...[
          const SizedBox(height: _AdminDashTheme.panelGap),
          _AdminPanel(
            compact: true,
            title: 'Last backup',
            child: Text(
              '${overview['last_backup']}'.split('T').first,
              style: _AdminDashTheme.label().copyWith(color: _AdminDashTheme.textBody),
            ),
          ),
        ],
      ],
    );
  }
}

class _ModuleStatusRow extends StatelessWidget {
  const _ModuleStatusRow({required this.name, required this.enabled});
  final String name;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel_outlined,
            size: 16,
            color: enabled ? const Color(0xFF059669) : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: _AdminDashTheme.label().copyWith(
                    color: _AdminDashTheme.textBody,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetentionTab extends StatelessWidget {
  const _RetentionTab({required this.records, required this.policies});
  final List<Map<String, Object?>> records;
  final List<Map<String, Object?>> policies;

  Color _statusColor(String status) {
    switch (status) {
      case 'expired':
        return const Color(0xFFDC2626);
      case 'expiring_soon':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(4),
      children: [
        _AdminPanel(
          compact: true,
          title: 'Retention policies',
          child: policies.isEmpty
              ? Text('No policies configured.', style: _AdminDashTheme.label())
              : Column(
                  children: [
                    for (final p in policies)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${p['document_type']} — ${p['retention_years']} years',
                          style: _AdminDashTheme.label().copyWith(
                                color: _AdminDashTheme.textPrimary,
                                fontSize: 12,
                              ),
                        ),
                        subtitle: Text(
                          '${p['legal_basis']} · ${p['iso_reference']}',
                          style: _AdminDashTheme.caption(),
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: _AdminDashTheme.panelGap),
        _AdminPanel(
          compact: true,
          title: 'Records monitoring (${records.length})',
          child: records.isEmpty
              ? Text('No documents to monitor.', style: _AdminDashTheme.label())
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingTextStyle: _AdminDashTheme.label(),
                    dataTextStyle: _AdminDashTheme.caption().copyWith(
                          color: _AdminDashTheme.textBody,
                          fontSize: 11,
                        ),
                    columns: const [
                      DataColumn(label: Text('Document')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Days left')),
                      DataColumn(label: Text('Expiry')),
                    ],
                    rows: [
                      for (final r in records)
                        DataRow(cells: [
                          DataCell(Text('${r['title']}', overflow: TextOverflow.ellipsis)),
                          DataCell(Text('${r['document_type'] ?? 'Other'}')),
                          DataCell(Text(
                            '${r['status']}',
                            style: TextStyle(color: _statusColor('${r['status']}')),
                          )),
                          DataCell(Text('${r['days_remaining']}')),
                          DataCell(Text('${(r['expiry_date'] ?? '').toString().split('T').first}')),
                        ]),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _AccessRulesTab extends StatelessWidget {
  const _AccessRulesTab({required this.rules});
  final List<Map<String, Object?>> rules;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(4),
      children: [
        _AdminPanel(
          compact: true,
          title: 'Automatic rule-based access',
          child: rules.isEmpty
              ? Text('No access rules defined.', style: _AdminDashTheme.label())
              : DataTable(
                  headingTextStyle: _AdminDashTheme.label(),
                  dataTextStyle: _AdminDashTheme.caption().copyWith(
                        color: _AdminDashTheme.textBody,
                        fontSize: 11,
                      ),
                  columns: const [
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Resource')),
                    DataColumn(label: Text('Action')),
                    DataColumn(label: Text('Allowed')),
                  ],
                  rows: [
                    for (final r in rules)
                      DataRow(cells: [
                        DataCell(Text('${r['role']}')),
                        DataCell(Text('${r['resource']}')),
                        DataCell(Text('${r['action']}')),
                        DataCell(Text((r['allowed'] ?? 0) == 1 ? 'Yes' : 'No')),
                      ]),
                  ],
                ),
        ),
      ],
    );
  }
}

class _DuplicatesTab extends StatelessWidget {
  const _DuplicatesTab({required this.groups});
  final List<Map<String, Object?>> groups;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(4),
      children: [
        if (groups.isEmpty)
          _AdminPanel(
            compact: true,
            title: 'Duplicate detection',
            child: Text(
              'No duplicate documents detected (SHA-256 content hash).',
              style: _AdminDashTheme.label(),
            ),
          )
        else
          for (final g in groups)
            Padding(
              padding: const EdgeInsets.only(bottom: _AdminDashTheme.panelGap),
              child: _AdminPanel(
                compact: true,
                title: 'Duplicate group (${g['count']} copies)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hash: ${g['content_hash']}',
                      style: _AdminDashTheme.caption(),
                    ),
                    const SizedBox(height: 8),
                    for (final doc in (g['documents'] as List? ?? []))
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('${doc['title']}', style: _AdminDashTheme.label()),
                        subtitle: Text(
                          '${doc['student']} · ${doc['document_type'] ?? 'Other'}',
                          style: _AdminDashTheme.caption(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _ComplianceAnalyticsTab extends StatelessWidget {
  const _ComplianceAnalyticsTab({required this.data});
  final Map<String, Object?> data;

  @override
  Widget build(BuildContext context) {
    final totals = data['totals'] as Map? ?? {};
    final retention = data['retention_summary'] as Map? ?? {};
    final decisions = (data['decisions'] as List?)?.cast<Map>() ?? [];

    return ListView(
      padding: const EdgeInsets.all(4),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _AdminMetricHighlightCard(
                dimension: 'Students',
                metricValue: '${totals['students'] ?? 0}',
                metricLabel: 'data subjects',
                icon: Icons.groups_outlined,
                accent: const Color(0xFF2563EB),
              ),
              _AdminMetricHighlightCard(
                dimension: 'Documents',
                metricValue: '${totals['documents'] ?? 0}',
                metricLabel: 'archived files',
                icon: Icons.description_outlined,
                accent: const Color(0xFF9333EA),
              ),
              _AdminMetricHighlightCard(
                dimension: 'Storage',
                metricValue: '${totals['storage_mb'] ?? '0'}',
                metricLabel: 'MB used',
                icon: Icons.storage_outlined,
                accent: const Color(0xFF0891B2),
              ),
            ];
            if (constraints.maxWidth < 720) {
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: _AdminDashTheme.statSpacing),
                    cards[i],
                  ],
                ],
              );
            }
            return Row(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: _AdminDashTheme.statSpacing),
                  Expanded(child: cards[i]),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: _AdminDashTheme.panelGap),
        _AdminPanel(
          compact: true,
          title: 'Retention summary',
          child: Text(
            'Active: ${retention['active'] ?? 0} · '
            'Expiring soon: ${retention['expiring_soon'] ?? 0} · '
            'Expired: ${retention['expired'] ?? 0}',
            style: _AdminDashTheme.label().copyWith(color: _AdminDashTheme.textBody),
          ),
        ),
        const SizedBox(height: _AdminDashTheme.panelGap),
        _AdminPanel(
          compact: true,
          title: 'Decision recommendations',
          child: decisions.isEmpty
              ? Text('No recommendations.', style: _AdminDashTheme.label())
              : Column(
                  children: [
                    for (var i = 0; i < decisions.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _ComplianceDecisionTile(
                        row: _ComplianceDecisionRow(
                          priority: '${decisions[i]['priority']}',
                          title: '${decisions[i]['title']}',
                          detail: '${decisions[i]['detail']}',
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _BackupTab extends StatelessWidget {
  const _BackupTab({
    required this.backups,
    required this.isAdmin,
    required this.onBackup,
    required this.onRestore,
  });

  final List<Map<String, Object?>> backups;
  final bool isAdmin;
  final VoidCallback onBackup;
  final ValueChanged<String> onRestore;

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(4),
      children: [
        if (isAdmin)
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: onBackup,
              icon: const Icon(Icons.backup_outlined),
              label: const Text('Create backup now'),
            ),
          ),
        if (isAdmin) const SizedBox(height: _AdminDashTheme.panelGap),
        _AdminPanel(
          compact: true,
          title: 'Backup history (${backups.length})',
          child: backups.isEmpty
              ? Text(
                  'No backups yet. Create one to protect your archive.',
                  style: _AdminDashTheme.label(),
                )
              : Column(
                  children: [
                    for (final b in backups)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${b['label']}', style: _AdminDashTheme.label()),
                        subtitle: Text(
                          '${(b['created_at'] ?? '').toString().split('T').first} · '
                          '${_formatBytes((b['size_bytes'] as int?) ?? 0)}',
                          style: _AdminDashTheme.caption(),
                        ),
                        trailing: isAdmin
                            ? TextButton(
                                onPressed: () => onRestore('${b['label']}'),
                                child: const Text('Restore'),
                              )
                            : null,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _PrivacyTab extends StatelessWidget {
  const _PrivacyTab({required this.data});
  final Map<String, Object?> data;

  @override
  Widget build(BuildContext context) {
    final checks = (data['checks'] as List?)?.cast<Map>() ?? [];
    return ListView(
      padding: const EdgeInsets.all(4),
      children: [
        _AdminMetricHighlightCard(
          dimension: 'Privacy',
          metricValue: '${data['compliance_score'] ?? 0}%',
          metricLabel: 'RA 10173 compliance',
          icon: Icons.privacy_tip_outlined,
          accent: const Color(0xFF059669),
        ),
        const SizedBox(height: _AdminDashTheme.panelGap),
        _AdminPanel(
          compact: true,
          title: '${data['framework'] ?? 'RA 10173'}',
          child: Column(
            children: [
              for (final c in checks)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    c['status'] == 'compliant'
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color: c['status'] == 'compliant'
                        ? const Color(0xFF059669)
                        : const Color(0xFFEA580C),
                  ),
                  title: Text('${c['requirement']}', style: _AdminDashTheme.label()),
                  subtitle: Text(
                    '${c['detail']}\n${c['reference']}',
                    style: _AdminDashTheme.caption(),
                  ),
                  isThreeLine: true,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisposalTab extends StatelessWidget {
  const _DisposalTab({
    required this.items,
    required this.isAdmin,
    required this.onApprove,
  });

  final List<Map<String, Object?>> items;
  final bool isAdmin;
  final ValueChanged<int> onApprove;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(4),
      children: [
        _AdminPanel(
          compact: true,
          title: 'Disposal recommendations (${items.length})',
          child: items.isEmpty
              ? Text(
                  'No documents currently recommended for disposal.',
                  style: _AdminDashTheme.label(),
                )
              : Column(
                  children: [
                    for (final item in items)
                      Builder(
                        builder: (context) {
                          final doc = item['document'] as Map? ?? {};
                          final docId =
                              item['document_id'] as int? ?? doc['id'] as int?;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${doc['title'] ?? 'Document'}',
                              style: _AdminDashTheme.label(),
                            ),
                            subtitle: Text(
                              '${item['reason']} · ${doc['document_type'] ?? ''} · '
                              'Status: ${item['status'] ?? 'pending'}',
                              style: _AdminDashTheme.caption(),
                            ),
                            trailing: isAdmin &&
                                    docId != null &&
                                    item['status'] != 'approved'
                                ? TextButton(
                                    onPressed: () => onApprove(docId),
                                    child: const Text('Approve'),
                                  )
                                : null,
                          );
                        },
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _IsoTab extends StatelessWidget {
  const _IsoTab({required this.data});
  final Map<String, Object?> data;

  @override
  Widget build(BuildContext context) {
    final controls = (data['controls'] as List?)?.cast<Map>() ?? [];
    final standards = (data['standards'] as List?)?.cast<String>() ?? [];

    return ListView(
      padding: const EdgeInsets.all(4),
      children: [
        _AdminMetricHighlightCard(
          dimension: 'ISO',
          metricValue: '${data['overall_score'] ?? 0}%',
          metricLabel: 'compatibility score',
          icon: Icons.verified_outlined,
          accent: const Color(0xFF0891B2),
        ),
        const SizedBox(height: 8),
        Text(
          'Standards: ${standards.join(', ')}',
          style: _AdminDashTheme.caption().copyWith(color: _AdminDashTheme.textMuted),
        ),
        const SizedBox(height: _AdminDashTheme.panelGap),
        _AdminPanel(
          compact: true,
          title: 'Control mapping',
          child: Column(
            children: [
              for (final c in controls)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${c['control']}', style: _AdminDashTheme.label()),
                  subtitle: Text(
                    '${c['standard']} · ${c['detail']}',
                    style: _AdminDashTheme.caption(),
                  ),
                  trailing: Chip(
                    label: Text(
                      '${c['status']}'.replaceAll('_', ' '),
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: c['status'] == 'implemented'
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEF3C7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

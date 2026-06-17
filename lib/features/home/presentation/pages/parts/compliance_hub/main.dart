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

class _ComplianceHubSnapshot {
  const _ComplianceHubSnapshot({
    required this.overview,
    required this.retention,
    required this.policies,
    required this.accessRules,
    required this.duplicates,
    required this.analytics,
    required this.backups,
    required this.privacy,
    required this.disposal,
    required this.iso,
  });

  final Map<String, Object?> overview;
  final List<Map<String, Object?>> retention;
  final List<Map<String, Object?>> policies;
  final List<Map<String, Object?>> accessRules;
  final List<Map<String, Object?>> duplicates;
  final Map<String, Object?> analytics;
  final List<Map<String, Object?>> backups;
  final Map<String, Object?> privacy;
  final List<Map<String, Object?>> disposal;
  final Map<String, Object?> iso;
}

class _ComplianceTabLoading extends StatelessWidget {
  const _ComplianceTabLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 10),
          Text(
            'Loading module data…',
            style: _AdminDashTheme.label().copyWith(color: _AdminDashTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ComplianceMetricsSkeleton extends StatelessWidget {
  const _ComplianceMetricsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonPulseScope(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth < 1200
              ? (constraints.maxWidth - _AdminDashTheme.statSpacing) / 2
              : (constraints.maxWidth - (5 * _AdminDashTheme.statSpacing)) / 6;
          return Wrap(
            spacing: _AdminDashTheme.statSpacing,
            runSpacing: _AdminDashTheme.statSpacing,
            children: [
              for (var i = 0; i < 6; i++)
                SkeletonBox(
                  width: cardWidth.clamp(140, 220),
                  height: 92,
                  borderRadius: 14,
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Keeps each tab's scroll position and avoids rebuild when switching tabs.
class _KeepAliveComplianceTab extends StatefulWidget {
  const _KeepAliveComplianceTab({required this.child});

  final Widget child;

  @override
  State<_KeepAliveComplianceTab> createState() => _KeepAliveComplianceTabState();
}

class _KeepAliveComplianceTabState extends State<_KeepAliveComplianceTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _ComplianceHubPageState extends State<_ComplianceHubPage>
    with TickerProviderStateMixin {
  static _ComplianceHubSnapshot? _memoryCache;

  final _db = AppDatabase.instance;
  late TabController _tabs;
  bool _overviewLoading = true;
  bool _detailsLoading = false;
  bool _refreshing = false;
  String? _error;
  List<Widget>? _cachedTabBodies;

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

  bool get _hasDetails =>
      _retention.isNotEmpty ||
      _policies.isNotEmpty ||
      _accessRules.isNotEmpty ||
      _duplicates.isNotEmpty ||
      _analytics.isNotEmpty ||
      _backups.isNotEmpty ||
      _privacy.isNotEmpty ||
      _disposal.isNotEmpty ||
      _iso.isNotEmpty;

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
    _tabs = TabController(
      length: _tabLabels.length,
      vsync: this,
      initialIndex: tab,
      animationDuration: const Duration(milliseconds: 220),
    );
    _tabs.addListener(_onTabIndexChanged);
    final cached = _memoryCache;
    if (cached != null) {
      _applySnapshot(cached);
      _overviewLoading = false;
      _rebuildCachedTabs();
      unawaited(_refreshInBackground());
    } else {
      unawaited(_loadOverviewFirst());
    }
  }

  void _applySnapshot(_ComplianceHubSnapshot snapshot) {
    _overview = snapshot.overview;
    _retention = snapshot.retention;
    _policies = snapshot.policies;
    _accessRules = snapshot.accessRules;
    _duplicates = snapshot.duplicates;
    _analytics = snapshot.analytics;
    _backups = snapshot.backups;
    _privacy = snapshot.privacy;
    _disposal = snapshot.disposal;
    _iso = snapshot.iso;
  }

  _ComplianceHubSnapshot _createSnapshot() {
    return _ComplianceHubSnapshot(
      overview: _overview,
      retention: _retention,
      policies: _policies,
      accessRules: _accessRules,
      duplicates: _duplicates,
      analytics: _analytics,
      backups: _backups,
      privacy: _privacy,
      disposal: _disposal,
      iso: _iso,
    );
  }

  void _saveSnapshot() {
    _memoryCache = _createSnapshot();
  }

  void _onTabIndexChanged() {
    if (_tabs.indexIsChanging) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabIndexChanged);
    _tabs.dispose();
    super.dispose();
  }

  void _rebuildCachedTabs() {
    Widget tabBody(int index, Widget child) {
      if (index > 0 && !_hasDetails && _detailsLoading) {
        return const _ComplianceTabLoading();
      }
      return child;
    }

    _cachedTabBodies = [
      _KeepAliveComplianceTab(
        child: tabBody(0, _ComplianceOverviewTab(overview: _overview)),
      ),
      _KeepAliveComplianceTab(
        child: tabBody(
          1,
          _RetentionTab(records: _retention, policies: _policies),
        ),
      ),
      _KeepAliveComplianceTab(
        child: tabBody(2, _AccessRulesTab(rules: _accessRules)),
      ),
      _KeepAliveComplianceTab(
        child: tabBody(3, _DuplicatesTab(groups: _duplicates)),
      ),
      _KeepAliveComplianceTab(
        child: tabBody(4, _ComplianceAnalyticsTab(data: _analytics)),
      ),
      _KeepAliveComplianceTab(
        child: tabBody(
          5,
          _BackupTab(
            backups: _backups,
            isAdmin: widget.isAdmin,
            onBackup: _runBackup,
            onRestore: _runRestore,
          ),
        ),
      ),
      _KeepAliveComplianceTab(
        child: tabBody(6, _PrivacyTab(data: _privacy)),
      ),
      _KeepAliveComplianceTab(
        child: tabBody(
          7,
          _DisposalTab(
            items: _disposal,
            isAdmin: widget.isAdmin,
            onApprove: _approveDisposal,
          ),
        ),
      ),
      _KeepAliveComplianceTab(
        child: tabBody(8, _IsoTab(data: _iso)),
      ),
    ];
  }

  Future<void> _loadOverviewFirst() async {
    if (!mounted) return;
    setState(() {
      _overviewLoading = true;
      _error = null;
    });
    try {
      final overview = await _db.fetchComplianceOverview();
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _overviewLoading = false;
        _rebuildCachedTabs();
      });
      unawaited(_loadDetailsInBackground());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _overviewLoading = false;
      });
    }
  }

  Future<void> _loadDetailsInBackground() async {
    if (!mounted) return;
    setState(() => _detailsLoading = true);
    try {
      final results = await Future.wait([
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
        _retention = (results[0] as List).cast<Map<String, Object?>>();
        _policies = (results[1] as List).cast<Map<String, Object?>>();
        _accessRules = (results[2] as List).cast<Map<String, Object?>>();
        _duplicates = (results[3] as List).cast<Map<String, Object?>>();
        _analytics = results[4] as Map<String, Object?>;
        _backups = (results[5] as List).cast<Map<String, Object?>>();
        _privacy = results[6] as Map<String, Object?>;
        _disposal = (results[7] as List).cast<Map<String, Object?>>();
        _iso = results[8] as Map<String, Object?>;
        _detailsLoading = false;
        _rebuildCachedTabs();
      });
      _saveSnapshot();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _detailsLoading = false;
        _error ??= '$e';
      });
    }
  }

  Future<void> _refreshInBackground() async {
    if (!mounted) return;
    setState(() => _refreshing = true);
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
        _refreshing = false;
        _rebuildCachedTabs();
      });
      _saveSnapshot();
    } catch (_) {
      if (!mounted) return;
      setState(() => _refreshing = false);
    }
  }

  Future<void> _runBackup() async {
    try {
      await _db.createBackup();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup created successfully.')),
      );
      await _refreshInBackground();
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
      await _refreshInBackground();
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
      await _refreshInBackground();
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
            onPressed: (_overviewLoading || _refreshing) ? null : () {
              unawaited(_refreshInBackground());
            },
            icon: _refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
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
        if (_overviewLoading)
          const _ComplianceMetricsSkeleton()
        else ...[
          RepaintBoundary(
            child: _ComplianceOverviewMetricsRow(overview: _overview),
          ),
          const SizedBox(height: _AdminDashTheme.sectionGap),
        ],
        Expanded(
          child: _AdminPanel(
            compact: true,
            expandChild: true,
            title: 'Compliance Modules',
            trailing: _detailsLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: _tabs,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                    mouseCursor: SystemMouseCursors.click,
                    labelColor: _AdminDashTheme.link,
                    unselectedLabelColor: _AdminDashTheme.textMuted,
                    indicatorColor: _AdminDashTheme.link,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    labelStyle: AppFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: AppFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      for (final label in _tabLabels) Tab(text: label),
                    ],
                  ),
                ),
                const Divider(height: 1, color: _AdminDashTheme.border),
                Expanded(
                  child: ClipRect(
                    child: _cachedTabBodies == null
                        ? const _ComplianceTabLoading()
                        : IndexedStack(
                            index: _tabs.index,
                            sizing: StackFit.expand,
                            children: _cachedTabBodies!,
                          ),
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
      cacheExtent: 200,
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

  static Color _statusColor(String status) {
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
    return CustomScrollView(
      cacheExtent: 240,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(4),
          sliver: SliverToBoxAdapter(
            child: _AdminPanel(
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
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(4, _AdminDashTheme.panelGap, 4, 4),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Records monitoring (${records.length})',
              style: _AdminDashTheme.panelTitle(size: 13),
            ),
          ),
        ),
        if (records.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            sliver: SliverToBoxAdapter(
              child: Text(
                'No documents to monitor.',
                style: _AdminDashTheme.label(),
              ),
            ),
          ),
        if (records.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            sliver: SliverToBoxAdapter(child: _ComplianceTableHeader.retention()),
          ),
          SliverList.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[index];
              final status = '${r['status']}';
              return _ComplianceTableRow(
                cells: [
                  '${r['title']}',
                  '${r['document_type'] ?? 'Other'}',
                  status,
                  '${r['days_remaining']}',
                  '${(r['expiry_date'] ?? '').toString().split('T').first}',
                ],
                accentIndices: {2},
                accentColor: _statusColor(status),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _AccessRulesTab extends StatelessWidget {
  const _AccessRulesTab({required this.rules});
  final List<Map<String, Object?>> rules;

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(4),
        children: [
          _AdminPanel(
            compact: true,
            title: 'Automatic rule-based access',
            child: Text('No access rules defined.', style: _AdminDashTheme.label()),
          ),
        ],
      );
    }

    return CustomScrollView(
      cacheExtent: 200,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Automatic rule-based access',
              style: _AdminDashTheme.panelTitle(size: 13),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          sliver: SliverToBoxAdapter(child: _ComplianceTableHeader.accessRules()),
        ),
        SliverList.builder(
          itemCount: rules.length,
          itemBuilder: (context, index) {
            final r = rules[index];
            return _ComplianceTableRow(
              flex: const [2, 2, 2, 1],
              cells: [
                '${r['role']}',
                '${r['resource']}',
                '${r['action']}',
                (r['allowed'] ?? 0) == 1 ? 'Yes' : 'No',
              ],
            );
          },
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
      cacheExtent: 200,
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
      cacheExtent: 200,
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
      cacheExtent: 200,
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

class _ComplianceTableHeader extends StatelessWidget {
  const _ComplianceTableHeader({required this.labels, required this.flex});

  final List<String> labels;
  final List<int> flex;

  factory _ComplianceTableHeader.retention() {
    return const _ComplianceTableHeader(
      labels: ['Document', 'Type', 'Status', 'Days left', 'Expiry'],
      flex: [3, 2, 2, 1, 2],
    );
  }

  factory _ComplianceTableHeader.accessRules() {
    return const _ComplianceTableHeader(
      labels: ['Role', 'Resource', 'Action', 'Allowed'],
      flex: [2, 2, 2, 1],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: _RecordListTheme.headerBg,
        border: Border(bottom: BorderSide(color: _RecordListTheme.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              flex: flex[i],
              child: Text(
                labels[i],
                style: _AdminDashTheme.label().copyWith(fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComplianceTableRow extends StatelessWidget {
  const _ComplianceTableRow({
    required this.cells,
    this.flex = const [3, 2, 2, 1, 2],
    this.accentIndices = const {},
    this.accentColor,
  });

  final List<String> cells;
  final List<int> flex;
  final Set<int> accentIndices;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _RecordListTheme.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              flex: i < flex.length ? flex[i] : 1,
              child: Text(
                cells[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _AdminDashTheme.caption().copyWith(
                      color: accentIndices.contains(i)
                          ? accentColor ?? _AdminDashTheme.textBody
                          : _AdminDashTheme.textBody,
                      fontSize: 11,
                      fontWeight: accentIndices.contains(i)
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

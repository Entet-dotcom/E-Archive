part of '../../dashboard_shell_page.dart';

/// Settings area: add and delete colleges.
class _SettingsCollegesPage extends StatefulWidget {
  const _SettingsCollegesPage({
    required this.rows,
    required this.isLoading,
    required this.loadError,
    required this.onRefresh,
    required this.onAddCollege,
    required this.onDeleteCollege,
    this.courseCountByCollegeId,
  });

  final List<_CollegeRow> rows;
  final bool isLoading;
  final String? loadError;
  final VoidCallback onRefresh;
  final Future<String?> Function({required String name}) onAddCollege;
  final Future<String?> Function(_CollegeRow college) onDeleteCollege;
  final Map<int, int>? courseCountByCollegeId;

  @override
  State<_SettingsCollegesPage> createState() => _SettingsCollegesPageState();
}

class _SettingsCollegesPageState extends State<_SettingsCollegesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<_CollegeRow> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return widget.rows;
    return widget.rows.where((row) {
      final name = row.name.toLowerCase();
      final label = _collegeAddOptionLabel(row.name).toLowerCase();
      final display = _parseCollegeDisplayLabel(row.name);
      return name.contains(q) ||
          label.contains(q) ||
          display.code.toLowerCase().contains(q) ||
          display.fullName.toLowerCase().contains(q);
    }).toList();
  }

  bool get _hasSearchFilter => _searchController.text.trim().isNotEmpty;

  void _resetFilters() {
    setState(_searchController.clear);
  }

  Future<void> _openAddCollegeDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _CollegeFormDialog(
        onAddCollege: widget.onAddCollege,
        onUpdateCollege: ({required college, required name}) async {
          return 'Edit is not available in Settings.';
        },
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('College added to the database.')),
      );
    }
  }

  Future<void> _confirmDelete(_CollegeRow college) async {
    final confirmed = await _showCollegeDeleteDialog(
      context,
      collegeName: college.name,
    );

    if (confirmed != true || !mounted) return;

    final error = await widget.onDeleteCollege(college);
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('College deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final showEmpty = !widget.isLoading && filtered.isEmpty;
    final countLabel =
        filtered.length == 1 ? '1 college' : '${filtered.length} colleges';

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.slash): () {
          _searchFocus.requestFocus();
        },
      },
      child: Focus(
        autofocus: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PageHeader(
              breadcrumbs: ['Settings', 'Colleges'],
              title: 'Manage colleges',
              subtitle:
                  'Add or remove colleges here. Student Records uses these entries for browsing only.',
            ),
            if (widget.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(minHeight: 3),
              ),
            if (widget.loadError != null)
              _RecordLoadBanner(
                message: widget.loadError!,
                onRetry: widget.onRefresh,
              ),
            Expanded(
              child: _RecordListCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RecordListToolbar(
                      search: _RecordSearchField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: (_) => setState(() {}),
                        hintText: 'Search colleges…',
                        focusColor: _collegeTeal,
                      ),
                      trailing: [
                        if (!showEmpty)
                          _RecordCountBadge(
                            icon: Icons.account_balance_outlined,
                            label: countLabel,
                            accentColor: _collegeTeal,
                          ),
                        _RecordPrimaryButton(
                          label: 'Add college',
                          onPressed:
                              widget.isLoading ? null : _openAddCollegeDialog,
                          color: _collegeTealDark,
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: _RecordListTheme.border),
                    if (showEmpty)
                      _CollegesEmptyState(
                        canEdit: true,
                        hasSearchFilter: _hasSearchFilter,
                        onAdd: _openAddCollegeDialog,
                        onResetFilters: _resetFilters,
                        addButtonLabel: 'Add college',
                      )
                    else
                      Expanded(
                        child: _CollegesSettingsList(
                          rows: filtered,
                          courseCountByCollegeId:
                              widget.courseCountByCollegeId,
                          onDelete: _confirmDelete,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

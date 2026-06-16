part of '../../dashboard_shell_page.dart';

class _CoursesPage extends StatefulWidget {
  const _CoursesPage({
    required this.rows,
    required this.canEdit,
    this.canAdd,
    required this.isLoading,
    required this.loadError,
    required this.onRefresh,
    required this.onAddCourse,
    required this.onUpdateCourse,
    required this.onDeleteCourse,
    this.collegeName,
    this.onBack,
    this.onCourseSelected,
    this.studentCountByName,
    this.breadcrumbs,
    this.pageTitle,
    this.pageSubtitle,
  });

  final List<_CourseRow> rows;
  final bool canEdit;
  final bool? canAdd;
  final bool isLoading;
  final String? loadError;
  final VoidCallback onRefresh;
  final Future<String?> Function({required String name}) onAddCourse;
  final Future<String?> Function({
    required _CourseRow course,
    required String name,
  }) onUpdateCourse;
  final Future<String?> Function(_CourseRow course) onDeleteCourse;
  final String? collegeName;
  final VoidCallback? onBack;
  final ValueChanged<_CourseRow>? onCourseSelected;
  final Map<String, int>? studentCountByName;
  final List<String>? breadcrumbs;
  final String? pageTitle;
  final String? pageSubtitle;

  @override
  State<_CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<_CoursesPage> {
  bool get _canAdd => widget.canAdd ?? widget.canEdit;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<_CourseRow> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return widget.rows;
    return widget.rows.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  bool get _hasSearchFilter => _searchController.text.trim().isNotEmpty;

  void _resetFilters() {
    setState(_searchController.clear);
  }

  Future<void> _openCourseDialog({_CourseRow? existing}) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _CourseFormDialog(
        existing: existing,
        collegeName: widget.collegeName,
        onAddCourse: widget.onAddCourse,
        onUpdateCourse: widget.onUpdateCourse,
        onDeleteCourse:
            existing != null && widget.canEdit ? widget.onDeleteCourse : null,
      ),
    );

    if (!mounted || result == null) return;

    final message = switch (result) {
      'deleted' => 'Program deleted.',
      'updated' => 'Program updated.',
      'added' => 'Program added to the database.',
      _ => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _confirmDelete(_CourseRow course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete program?'),
        content: Text(
          'Remove ${course.name}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final error = await widget.onDeleteCourse(course);
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Program deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final showEmpty = !widget.isLoading && filtered.isEmpty;
    final countLabel =
        filtered.length == 1 ? '1 program' : '${filtered.length} programs';
    final inDrill = widget.collegeName != null;
    final breadcrumbs = widget.breadcrumbs ??
        (inDrill
            ? ['Records', widget.collegeName!, 'Programs']
            : const ['Records', 'Programs']);
    final subtitle = widget.pageSubtitle ??
        (inDrill
            ? 'Programs offered under ${widget.collegeName}. Select a program to view its students.'
            : 'View all programs and their students. To add a program, open a college under Records → Colleges.');
    final title = widget.pageTitle ?? 'Programs';

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
            _PageHeader(
              breadcrumbs: breadcrumbs,
              onBack: inDrill ? widget.onBack : null,
              backTooltip: inDrill ? 'Back to colleges' : null,
              title: title,
              subtitle: subtitle,
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
                        hintText: 'Search programs…',
                        focusColor: _courseBlue,
                      ),
                      trailing: [
                        if (!showEmpty)
                          _RecordCountBadge(
                            icon: Icons.menu_book_outlined,
                            label: countLabel,
                            accentColor: _courseBlue,
                          ),
                        if (_canAdd)
                          _RecordPrimaryButton(
                            label: 'Add program',
                            onPressed: widget.isLoading
                                ? null
                                : () => _openCourseDialog(),
                            color: _courseBlue,
                          ),
                      ],
                    ),
                    const Divider(height: 1, color: _RecordListTheme.border),
                    if (showEmpty)
                      _CollegesEmptyState(
                        canEdit: _canAdd,
                        hasSearchFilter: _hasSearchFilter,
                        onAdd: () => _openCourseDialog(),
                        onResetFilters: _resetFilters,
                        addButtonLabel: 'Add program',
                        addButtonColor: _courseBlue,
                      )
                    else
                      Expanded(
                        child: _RecordDataTable(
                          headers: const ['Name', 'Actions'],
                          actionsWidth:
                              widget.onCourseSelected != null ? 148 : 108,
                          rows: filtered.map((course) {
                            final studentCount =
                                widget.studentCountByName?[course.name] ?? 0;
                            final studentLabel = studentCount == 1
                                ? '1 student'
                                : '$studentCount students';
                            return [
                              InkWell(
                                onTap: widget.onCourseSelected != null
                                    ? () => widget.onCourseSelected!(course)
                                    : null,
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          course.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: _RecordListTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (widget.onCourseSelected != null) ...[
                                        const SizedBox(width: 12),
                                        Text(
                                          studentLabel,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: studentCount > 0
                                                ? _RecordListTheme.textPrimary
                                                : _RecordListTheme.textHint,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.chevron_right,
                                          size: 18,
                                          color: _RecordListTheme.textHint,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.onCourseSelected != null) ...[
                                    _RecordIconAction(
                                      icon: Icons.people_outline,
                                      color: _RecordListTheme.textMuted,
                                      onPressed: () =>
                                          widget.onCourseSelected!(course),
                                      tooltip: 'View students',
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  _RecordEditAction(
                                    onPressed: widget.canEdit
                                        ? () =>
                                            _openCourseDialog(existing: course)
                                        : null,
                                  ),
                                  if (widget.canEdit) ...[
                                    const SizedBox(width: 6),
                                    _RecordDeleteAction(
                                      onPressed: () => _confirmDelete(course),
                                    ),
                                  ],
                                ],
                              ),
                            ];
                          }).toList(),
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

part of '../../dashboard_shell_page.dart';

class _AnalyticsPageHeader extends StatelessWidget {
  const _AnalyticsPageHeader({
    required this.years,
    required this.selectedYear,
    required this.onYearChanged,
    this.graduateSearch,
  });

  final List<String> years;
  final String? selectedYear;
  final ValueChanged<String?> onYearChanged;
  final Widget? graduateSearch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackFilter = constraints.maxWidth < 640;
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedYear == null
                  ? 'Data Analytics'
                  : 'School year $selectedYear',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selectedYear == null
                  ? 'Graduates by school year and program'
                  : 'Program breakdown and graduate list',
              style: _AdminDashTheme.label(size: 13).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

        final filter = years.isNotEmpty
            ? _AnalyticsYearFilter(
                years: years,
                selectedYear: selectedYear,
                onChanged: onYearChanged,
              )
            : null;

        final search = graduateSearch;
        final hasTopControls = filter != null || search != null;

        final topControls = hasTopControls
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter != null) ...[
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 200,
                          maxWidth: 260,
                        ),
                        child: filter,
                      ),
                    ),
                    if (search != null) const SizedBox(width: 12),
                  ],
                  if (search != null)
                    Flexible(
                      flex: 2,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: search,
                      ),
                    ),
                ],
              )
            : null;

        final headerBody = stackFilter
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  titleBlock,
                  if (topControls != null) ...[
                    const SizedBox(height: 14),
                    topControls,
                  ],
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleBlock),
                  if (topControls != null) ...[
                    const SizedBox(width: 20),
                    topControls,
                  ],
                ],
              );

        return headerBody;
      },
    );
  }
}

/// Search graduates across all school years from the analytics overview.
class _AnalyticsGraduateFinder extends StatefulWidget {
  const _AnalyticsGraduateFinder({
    required this.graduates,
    required this.chartAccents,
    required this.onSelect,
  });

  final List<_AnalyticsGraduate> graduates;
  final List<Color> chartAccents;
  final void Function(_AnalyticsGraduate graduate) onSelect;

  @override
  State<_AnalyticsGraduateFinder> createState() =>
      _AnalyticsGraduateFinderState();
}

class _AnalyticsGraduateFinderState extends State<_AnalyticsGraduateFinder> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_AnalyticsGraduate> get _matches {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final results = widget.graduates.where((g) {
      return g.fullName.toLowerCase().contains(q) ||
          g.studentNo.toLowerCase().contains(q) ||
          g.course.toLowerCase().contains(q) ||
          g.programLabel.toLowerCase().contains(q) ||
          g.schoolYear.toLowerCase().contains(q);
    }).toList();
    return results.length > 8 ? results.sublist(0, 8) : results;
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matches;
    final hasQuery = _query.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _DashboardSearchField(
          controller: _controller,
          hintText: 'Search graduates by name, ID, program...',
          onChanged: (value) => setState(() => _query = value),
        ),
        if (hasQuery) ...[
          const SizedBox(height: 8),
          if (matches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                'No graduates match "${_query.trim()}".',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 320),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: matches.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: Color(0xFFE2E8F0),
                ),
                itemBuilder: (context, index) {
                  final graduate = matches[index];
                  final accent = _accentForProgram(
                    graduate.programLabel,
                    widget.chartAccents,
                  );
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onSelect(graduate),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            _GraduateAvatar(
                              initials: _graduateInitials(graduate.fullName),
                              accent: accent,
                              size: 36,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    graduate.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    graduate.studentNo,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _GraduateProgramChip(
                                  label: graduate.programLabel,
                                  accent: accent,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  graduate.schoolYear.isNotEmpty
                                      ? graduate.schoolYear
                                      : '—',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ],
    );
  }
}

class _GraduateAvatar extends StatelessWidget {
  const _GraduateAvatar({
    required this.initials,
    required this.accent,
    this.size = 40,
  });

  final String initials;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.9),
            accent.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        initials,
        style: AppFonts.poppins(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GraduateProgramChip extends StatelessWidget {
  const _GraduateProgramChip({
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: accent.withValues(alpha: 0.95),
        ),
      ),
    );
  }
}

class _AnalyticsYearFilter extends StatefulWidget {
  const _AnalyticsYearFilter({
    required this.years,
    required this.selectedYear,
    required this.onChanged,
  });

  final List<String> years;
  final String? selectedYear;
  final ValueChanged<String?> onChanged;

  static const _allYearsValue = '';

  @override
  State<_AnalyticsYearFilter> createState() => _AnalyticsYearFilterState();
}

class _AnalyticsYearFilterState extends State<_AnalyticsYearFilter> {
  bool _menuOpen = false;

  bool get _isAllYears =>
      widget.selectedYear == null || widget.selectedYear!.isEmpty;

  String get _displayLabel =>
      _isAllYears ? 'All school years' : widget.selectedYear!;

  String get _effectiveValue {
    final year = widget.selectedYear;
    if (year == null || year.isEmpty) return _AnalyticsYearFilter._allYearsValue;
    return widget.years.contains(year) ? year : _AnalyticsYearFilter._allYearsValue;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Filter by school year',
      offset: const Offset(0, 6),
      constraints: const BoxConstraints(minWidth: 240),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x260F172A),
      onOpened: () => setState(() => _menuOpen = true),
      onCanceled: () => setState(() => _menuOpen = false),
      onSelected: (picked) {
        setState(() => _menuOpen = false);
        widget.onChanged(
          picked == _AnalyticsYearFilter._allYearsValue ? null : picked,
        );
      },
      itemBuilder: (context) => [
        _yearMenuItem(
          value: _AnalyticsYearFilter._allYearsValue,
          label: 'All school years',
          subtitle: 'Show every school year',
        ),
        const PopupMenuDivider(height: 1),
        ...widget.years.map(
          (year) => _yearMenuItem(
            value: year,
            label: year,
            subtitle: 'School year $year',
          ),
        ),
      ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _menuOpen ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _menuOpen
                ? const Color(0xFFCBD5E1)
                : const Color(0xFFE2E8F0),
            width: _menuOpen ? 1.5 : 1,
          ),
          boxShadow: _menuOpen
              ? const [
                  BoxShadow(
                    color: Color(0x140F172A),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: _menuOpen
                  ? const Color(0xFF475569)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _displayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.2,
                  fontWeight: _isAllYears ? FontWeight.w400 : FontWeight.w500,
                  color: _isAllYears
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0F172A),
                ),
              ),
            ),
            AnimatedRotation(
              turns: _menuOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              child: Icon(
                Icons.expand_more_rounded,
                size: 22,
                color: _menuOpen
                    ? const Color(0xFF475569)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuEntry<String> _yearMenuItem({
    required String value,
    required String label,
    required String subtitle,
  }) {
    final selected = _effectiveValue == value;

    return PopupMenuItem<String>(
      value: value,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: selected
                ? const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Color(0xFF2563EB),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF334155),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    height: 1.2,
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

class _AnalyticsPanel extends StatelessWidget {
  const _AnalyticsPanel({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _AdminDashTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AdminDashTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _AdminDashTheme.panelTitle(size: 16)),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: _AdminDashTheme.caption(size: 12).copyWith(
                        color: _AdminDashTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _AnalyticsEmptyState extends StatelessWidget {
  const _AnalyticsEmptyState({this.message = 'No data yet.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_outlined,
                size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppFonts.poppins(
                color: const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top summary focused on graduate counts (no document scanning).
class _AnalyticsGraduatesInsightRow extends StatelessWidget {
  const _AnalyticsGraduatesInsightRow({
    required this.data,
    this.filterYear,
  });

  final _AnalyticsData data;
  final String? filterYear;

  @override
  Widget build(BuildContext context) {
    final topCourse = data.byCourse.isEmpty ? null : data.byCourse.first;
    final topYear = data.bySchoolYear.isEmpty
        ? null
        : data.bySchoolYear.reduce(
            (a, b) => b.students > a.students ? b : a,
          );
    final yearFiltered = filterYear != null;
    final yearGraduateCount =
        yearFiltered ? data.students : (topYear?.students ?? 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final children = [
          _AnalyticsHighlightCard(
            dimension: yearFiltered ? 'School year' : 'Largest cohort',
            label: yearFiltered ? filterYear! : (topYear?.year ?? '—'),
            count: yearGraduateCount,
            countLabel: 'graduates',
            icon: Icons.calendar_month_outlined,
            accent: const Color(0xFF7C3AED),
            flex: compact ? 0 : 1,
          ),
          _AnalyticsHighlightCard(
            dimension: 'Top program',
            label: topCourse?.code ?? '—',
            count: topCourse?.count ?? 0,
            countLabel: 'graduates',
            icon: Icons.school_outlined,
            accent: const Color(0xFF2563EB),
            flex: compact ? 0 : 1,
          ),
          _AnalyticsHighlightCard(
            dimension: yearFiltered ? 'Programs' : 'All records',
            label: yearFiltered
                ? '${data.courses} program${data.courses == 1 ? '' : 's'}'
                : '${data.availableYears.length} school years',
            count: data.students,
            countLabel: yearFiltered ? 'graduates' : 'graduates total',
            icon: Icons.groups_outlined,
            accent: const Color(0xFF0D9488),
            flex: compact ? 0 : 1,
          ),
        ];

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: _AdminDashTheme.statSpacing),
                children[i],
              ],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: _AdminDashTheme.statSpacing),
                Expanded(child: children[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticsHighlightCard extends StatelessWidget {
  const _AnalyticsHighlightCard({
    required this.dimension,
    required this.label,
    required this.count,
    required this.countLabel,
    required this.icon,
    required this.accent,
    this.secondaryCount,
    this.secondaryLabel,
    this.flex = 1,
  });

  final String dimension;
  final String label;
  final int count;
  final String countLabel;
  final IconData icon;
  final Color accent;
  final int? secondaryCount;
  final String? secondaryLabel;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return _AdminMetricHighlightCard(
      dimension: dimension,
      label: label,
      metricValue: '$count',
      metricLabel: countLabel,
      icon: icon,
      accent: accent,
      secondaryValue: secondaryCount != null ? '$secondaryCount' : null,
      secondaryLabel: secondaryLabel,
    );
  }
}

class _AnalyticsChartFrame extends StatelessWidget {
  const _AnalyticsChartFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class _AnalyticsBreakdownTable extends StatefulWidget {
  const _AnalyticsBreakdownTable({
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.pageSize = 5,
    this.itemLabel = 'items',
  });

  final List<_AnalyticsTableColumn> columns;
  final List<_AnalyticsTableRow> rows;
  final ValueChanged<int>? onRowTap;
  final int pageSize;
  final String itemLabel;

  @override
  State<_AnalyticsBreakdownTable> createState() =>
      _AnalyticsBreakdownTableState();
}

class _AnalyticsBreakdownTableState extends State<_AnalyticsBreakdownTable> {
  static const _highlightTop = 3;
  static const _rowGap = 6.0;

  int _currentPage = 0;

  int get _totalPages {
    if (widget.rows.isEmpty) return 0;
    return (widget.rows.length + widget.pageSize - 1) ~/ widget.pageSize;
  }

  @override
  void didUpdateWidget(covariant _AnalyticsBreakdownTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.rows, widget.rows)) {
      _currentPage = 0;
    } else if (_currentPage >= _totalPages && _totalPages > 0) {
      _currentPage = _totalPages - 1;
    }
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages || page == _currentPage) return;
    setState(() => _currentPage = page);
  }

  List<int> _visiblePageNumbers() {
    if (_totalPages <= 5) {
      return List.generate(_totalPages, (i) => i);
    }
    var start = _currentPage - 2;
    var end = _currentPage + 2;
    if (start < 0) {
      end -= start;
      start = 0;
    }
    if (end >= _totalPages) {
      start -= end - _totalPages + 1;
      end = _totalPages - 1;
    }
    start = start.clamp(0, _totalPages - 1);
    return List.generate(end - start + 1, (i) => start + i);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final start = _currentPage * widget.pageSize;
    final pageCount = math.min(widget.pageSize, widget.rows.length - start);
    final rangeStart = start + 1;
    final rangeEnd = start + pageCount;
    final showChevron = widget.onRowTap != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AnalyticsTableHeader(
          columns: widget.columns,
          showActionColumn: showChevron,
        ),
        const SizedBox(height: _rowGap),
        ...List.generate(pageCount, (index) {
          final globalIndex = start + index;
          final row = widget.rows[globalIndex];
          final isTop = globalIndex < _highlightTop;
          final dataRow = _AnalyticsTableDataRow(
            columns: widget.columns,
            row: row,
            rank: globalIndex + 1,
            emphasized: isTop,
            showChevron: showChevron,
          );
          return Padding(
            padding:
                EdgeInsets.only(bottom: index < pageCount - 1 ? _rowGap : 0),
            child: showChevron
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onRowTap!(globalIndex),
                      borderRadius: BorderRadius.circular(8),
                      hoverColor: const Color(0xFFF1F5F9),
                      splashColor: const Color(0xFFE2E8F0),
                      child: dataRow,
                    ),
                  )
                : dataRow,
          );
        }),
        if (_totalPages > 1) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$rangeStart–$rangeEnd of ${widget.rows.length} ${widget.itemLabel}',
                  style: _AdminDashTheme.caption(size: 11).copyWith(
                    color: _AdminDashTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: 'Previous page',
                onPressed:
                    _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
                icon: const Icon(Icons.chevron_left_rounded),
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: _AdminDashTheme.textMuted,
              ),
              for (final page in _visiblePageNumbers())
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: page == _currentPage
                        ? _AdminDashTheme.link
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      onTap: () => _goToPage(page),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          '${page + 1}',
                          style: AppFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: page == _currentPage
                                ? Colors.white
                                : _AdminDashTheme.textBody,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              IconButton(
                tooltip: 'Next page',
                onPressed: _currentPage < _totalPages - 1
                    ? () => _goToPage(_currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: _AdminDashTheme.textMuted,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AnalyticsTableColumn {
  const _AnalyticsTableColumn({
    required this.label,
    this.flex = 2,
    this.align = TextAlign.start,
    this.isCount = false,
  });

  final String label;
  final int flex;
  final TextAlign align;
  final bool isCount;
}

class _AnalyticsTableRow {
  const _AnalyticsTableRow({required this.cells, this.accent});

  final List<String> cells;
  final Color? accent;
}

class _AnalyticsTableHeader extends StatelessWidget {
  const _AnalyticsTableHeader({
    required this.columns,
    this.showActionColumn = false,
  });

  final List<_AnalyticsTableColumn> columns;
  final bool showActionColumn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _AdminDashTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AdminDashTheme.border),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 28,
            child: Text(
              '#',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.3,
              ),
            ),
          ),
          ...columns.map(
            (col) => Expanded(
              flex: col.flex,
              child: Text(
                col.label.toUpperCase(),
                textAlign: col.align,
                style: AppFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          if (showActionColumn) const SizedBox(width: 26),
        ],
      ),
    );
  }
}

class _AnalyticsTableDataRow extends StatelessWidget {
  const _AnalyticsTableDataRow({
    required this.columns,
    required this.row,
    required this.rank,
    required this.emphasized,
    this.showChevron = false,
  });

  final List<_AnalyticsTableColumn> columns;
  final _AnalyticsTableRow row;
  final int rank;
  final bool emphasized;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final accent = row.accent ?? const Color(0xFF3B82F6);

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: emphasized ? accent.withValues(alpha: 0.07) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: emphasized
              ? accent.withValues(alpha: 0.28)
              : _AdminDashTheme.border,
        ),
        boxShadow: emphasized
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: AppFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: emphasized ? accent : const Color(0xFF94A3B8),
              ),
            ),
          ),
          ...List.generate(columns.length, (i) {
            final col = columns[i];
            final text = i < row.cells.length ? row.cells[i] : '';
            final isCount = col.isCount;

            return Expanded(
              flex: col.flex,
              child: isCount
                  ? Align(
                      alignment: col.align == TextAlign.end
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: _AnalyticsCountBadge(
                        value: text,
                        accent: emphasized ? accent : const Color(0xFF475569),
                      ),
                    )
                  : Text(
                      text,
                      textAlign: col.align,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                            emphasized ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
            );
          }),
          if (showChevron) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: emphasized ? accent : const Color(0xFF94A3B8),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalyticsCountBadge extends StatelessWidget {
  const _AnalyticsCountBadge({required this.value, required this.accent});

  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }
}

/// School-year panel: overview by year, then drill into programs and graduates.
class _SchoolYearAnalyticsPanel extends StatelessWidget {
  const _SchoolYearAnalyticsPanel({
    required this.data,
    required this.chartAccents,
    required this.courseCountsForYear,
    required this.onViewGraduates,
    required this.selectedYear,
    required this.onSelectedYearChanged,
  });

  final _AnalyticsData data;
  final List<Color> chartAccents;
  final List<_CourseCount> Function(String year) courseCountsForYear;
  final void Function(
    String year, {
    String? programName,
    String? programCode,
  }) onViewGraduates;
  final String? selectedYear;
  final ValueChanged<String?> onSelectedYearChanged;

  @override
  Widget build(BuildContext context) {
    if (selectedYear != null) {
      return _buildYearDetail(context, selectedYear!);
    }
    return _buildOverview(context);
  }

  Widget _buildOverview(BuildContext context) {
    final sortedYears = _schoolYearsChronological(data.bySchoolYear);

    final yearRows = <_AnalyticsTableRow>[];
    for (var i = 0; i < sortedYears.length; i++) {
      final entry = sortedYears[i];
      yearRows.add(
        _AnalyticsTableRow(
          cells: [
            entry.year,
            entry.students.toString(),
          ],
          accent: chartAccents[i % chartAccents.length],
        ),
      );
    }

    final table = _AnalyticsBreakdownTable(
      columns: const [
        _AnalyticsTableColumn(label: 'School year', flex: 3),
        _AnalyticsTableColumn(
          label: 'Graduates',
          flex: 2,
          align: TextAlign.end,
          isCount: true,
        ),
      ],
      rows: yearRows,
      itemLabel: 'years',
      onRowTap: (index) => onViewGraduates(sortedYears[index].year),
    );

    return _AnalyticsPanel(
      title: 'Graduates by school year',
      subtitle:
          'Tap a row to open the graduate list, or use the year filter for programs',
      child: sortedYears.isEmpty
          ? const _AnalyticsEmptyState(
              message: 'No school year breakdown yet.',
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final sideBySide = constraints.maxWidth >= 880;
                final chart = _AdminBarChart(
                  height: sideBySide ? 240 : 220,
                  compact: sortedYears.length > 6,
                  animate: false,
                  valueUnit: 'graduates',
                  yAxisLabel: 'Number of Graduates',
                  values: {
                    for (final entry in sortedYears) entry.year: entry.students,
                  },
                  maxY: _chartMax(sortedYears.map((e) => e.students)),
                  axisLabelForKey: _shortSchoolYearLabel,
                  tooltipTitleForKey: (year) => year,
                  tooltipSubtitleForKey: (year, count) {
                    final programs = courseCountsForYear(year);
                    if (programs.isEmpty) return null;
                    return '$count graduates · ${programs.length} programs';
                  },
                );

                if (!sideBySide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AnalyticsChartFrame(child: chart),
                      const SizedBox(height: 16),
                      table,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _AnalyticsChartFrame(child: chart),
                    ),
                    const SizedBox(width: 20),
                    Expanded(flex: 4, child: table),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildYearDetail(BuildContext context, String year) {
    final courses = courseCountsForYear(year);
    var graduateCount = 0;
    for (final entry in data.bySchoolYear) {
      if (entry.year == year) {
        graduateCount = entry.students;
        break;
      }
    }

    final courseRows = <_AnalyticsTableRow>[];
    for (var i = 0; i < courses.length; i++) {
      final entry = courses[i];
      courseRows.add(
        _AnalyticsTableRow(
          cells: [entry.name, entry.count.toString()],
          accent: chartAccents[i % chartAccents.length],
        ),
      );
    }

    final programTable = _AnalyticsBreakdownTable(
      columns: const [
        _AnalyticsTableColumn(label: 'Program', flex: 3),
        _AnalyticsTableColumn(
          label: 'Graduates',
          flex: 2,
          align: TextAlign.end,
          isCount: true,
        ),
      ],
      rows: courseRows,
      itemLabel: 'programs',
      onRowTap: (index) {
        final course = courses[index];
        onViewGraduates(
          year,
          programName: course.name,
          programCode: course.code,
        );
      },
    );

    return _AnalyticsPanel(
      title: 'Programs · $year',
      subtitle:
          '$graduateCount graduate${graduateCount == 1 ? '' : 's'} across ${courses.length} program${courses.length == 1 ? '' : 's'}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: graduateCount > 0 ? () => onViewGraduates(year) : null,
            icon: const Icon(Icons.groups_outlined, size: 18),
            label: Text(
              'View all',
              style: AppFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: _AdminDashTheme.link,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
          if (data.availableYears.length > 1) ...[
            const SizedBox(width: 4),
            _YearQuickPicker(
              years: _analyticsFilterYears(data.availableYears),
              selectedYear: year,
              onSelected: onSelectedYearChanged,
            ),
          ],
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (courses.isEmpty)
            const _AnalyticsEmptyState(
              message: 'No graduates for this school year.',
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final sideBySide = constraints.maxWidth >= 880;
                final chart = _AdminBarChart(
                  height: sideBySide ? 228 : 208,
                  compact: courses.length > 6,
                  animate: false,
                  valueUnit: 'graduates',
                  yAxisLabel: 'Number of Graduates',
                  showVerticalGrid: courses.length <= 5,
                  values: {
                    for (final entry in courses) entry.code: entry.count
                  },
                  maxY: _chartMax(courses.map((e) => e.count)),
                  emphasizeCourseLabels: true,
                  tooltipTitleForKey: (code) => code,
                  tooltipSubtitleForKey: (code, _) {
                    for (final course in courses) {
                      if (course.code == code) {
                        return course.name == code ? null : course.name;
                      }
                    }
                    return null;
                  },
                );

                if (!sideBySide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AnalyticsChartFrame(child: chart),
                      const SizedBox(height: 16),
                      programTable,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _AnalyticsChartFrame(child: chart),
                    ),
                    const SizedBox(width: 20),
                    Expanded(flex: 4, child: programTable),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _YearQuickPicker extends StatelessWidget {
  const _YearQuickPicker({
    required this.years,
    required this.selectedYear,
    required this.onSelected,
  });

  final List<String> years;
  final String selectedYear;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Switch school year',
      initialValue: selectedYear,
      onSelected: onSelected,
      itemBuilder: (context) => years
          .map(
            (year) => PopupMenuItem<String>(
              value: year,
              child: Text(
                year,
                style: AppFonts.poppins(fontSize: 13),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _AdminDashTheme.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _AdminDashTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: _AdminDashTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              selectedYear,
              style: AppFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _AdminDashTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more,
                size: 18, color: _AdminDashTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

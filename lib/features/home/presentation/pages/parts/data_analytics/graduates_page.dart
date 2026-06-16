part of '../../dashboard_shell_page.dart';

enum _GraduateSort { nameAsc, studentNoAsc, programAsc }

class _YearGraduatesViewPage extends StatefulWidget {
  const _YearGraduatesViewPage({
    required this.year,
    required this.graduates,
    this.programName,
    this.programCode,
    this.onBack,
    this.onBreadcrumbTap,
  });

  final String year;
  final List<_AnalyticsGraduate> graduates;
  final String? programName;
  final String? programCode;
  final VoidCallback? onBack;
  final ValueChanged<int>? onBreadcrumbTap;

  @override
  State<_YearGraduatesViewPage> createState() => _YearGraduatesViewPageState();
}

class _YearGraduatesViewPageState extends State<_YearGraduatesViewPage> {
  static const _chartAccents = <Color>[
    Color(0xFF60A5FA),
    Color(0xFF4ADE80),
    Color(0xFFA78BFA),
    Color(0xFFFB923C),
    Color(0xFF22D3EE),
    Color(0xFFF472B6),
    Color(0xFF3B82F6),
  ];

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  _GraduateSort _sort = _GraduateSort.nameAsc;
  String? _programChipFilter;

  bool get _scopedToProgram =>
      (widget.programName?.trim().isNotEmpty ?? false) ||
      (widget.programCode?.trim().isNotEmpty ?? false);

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<String> get _programOptions {
    final labels = <String>{};
    for (final g in widget.graduates) {
      final label = g.programLabel.trim();
      if (label.isNotEmpty) labels.add(label);
    }
    final list = labels.toList()..sort();
    return list;
  }

  List<_AnalyticsGraduate> get _filtered {
    var list = widget.graduates;
    final chip = _programChipFilter;
    if (!_scopedToProgram && chip != null && chip.isNotEmpty) {
      list = list.where((g) => g.programLabel == chip).toList();
    }

    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (g) =>
                g.fullName.toLowerCase().contains(q) ||
                g.studentNo.toLowerCase().contains(q) ||
                g.course.toLowerCase().contains(q) ||
                g.programLabel.toLowerCase().contains(q),
          )
          .toList();
    }

    list = List<_AnalyticsGraduate>.from(list);
    switch (_sort) {
      case _GraduateSort.nameAsc:
        list.sort(
          (a, b) =>
              a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );
      case _GraduateSort.studentNoAsc:
        list.sort(
          (a, b) =>
              a.studentNo.toLowerCase().compareTo(b.studentNo.toLowerCase()),
        );
      case _GraduateSort.programAsc:
        list.sort((a, b) {
          final byProgram = a.programLabel
              .toLowerCase()
              .compareTo(b.programLabel.toLowerCase());
          if (byProgram != 0) return byProgram;
          return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
        });
    }
    return list;
  }

  void _copyStudentNo(BuildContext context, String studentNo) {
    Clipboard.setData(ClipboardData(text: studentNo));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied $studentNo',
          style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final programOptions = _programOptions;

    final programTitle = widget.programName?.trim().isNotEmpty == true
        ? widget.programName!.trim()
        : widget.programCode?.trim();
    final breadcrumb = <String>[
      'Data Analytics',
      widget.year,
      if (programTitle != null && programTitle.isNotEmpty) programTitle,
      'Graduates',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecordBreadcrumb(
          segments: breadcrumb,
          onBack: widget.onBack,
          onSegmentTap: widget.onBreadcrumbTap,
          backTooltip: _scopedToProgram
              ? 'Back to year overview'
              : 'Back to Data Analytics',
          maxSegmentWidth: 280,
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              programTitle != null && programTitle.isNotEmpty
                  ? programTitle
                  : 'Graduates · ${widget.year}',
              style: _AdminDashTheme.panelTitle(size: 22),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              programTitle != null && programTitle.isNotEmpty
                  ? '${widget.year} · ${widget.graduates.length} graduate${widget.graduates.length == 1 ? '' : 's'}'
                  : '${widget.graduates.length} graduate${widget.graduates.length == 1 ? '' : 's'} in ${widget.year}',
              style: _AdminDashTheme.label(size: 13).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final stackTools = constraints.maxWidth < 640;
            final search = SizedBox(
              width: stackTools ? double.infinity : 360,
              child: _RecordSearchField(
                controller: _searchController,
                focusNode: _searchFocus,
                hintText: 'Search by name, student #, or program…',
                focusColor: const Color(0xFF4F46E5),
                onChanged: (value) => setState(() => _query = value),
              ),
            );
            final sortControl = _GraduateSortControl(
              value: _sort,
              onChanged: (value) => setState(() => _sort = value),
            );

            if (stackTools) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  search,
                  const SizedBox(height: 10),
                  sortControl,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: search),
                const SizedBox(width: 12),
                sortControl,
              ],
            );
          },
        ),
        if (!_scopedToProgram && programOptions.length > 1) ...[
          const SizedBox(height: 12),
          _GraduateProgramFilterBar(
            programs: programOptions,
            selected: _programChipFilter,
            accents: _chartAccents,
            onSelected: (value) => setState(() => _programChipFilter = value),
          ),
        ],
        if (widget.graduates.isNotEmpty) ...[
          const SizedBox(height: 12),
          _GraduateListSummary(
            showing: filtered.length,
            total: widget.graduates.length,
            hasSearch: _query.trim().isNotEmpty,
            hasProgramFilter: _programChipFilter != null,
          ),
        ],
        const SizedBox(height: 16),
        if (widget.graduates.isEmpty)
          const _AnalyticsEmptyState(
            message: 'No graduate records for this school year.',
          )
        else if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No graduates match your filters.',
                    style: AppFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          _YearGraduatesTable(
            graduates: filtered,
            accents: _chartAccents,
            query: _query.trim(),
            onCopyStudentNo: (no) => _copyStudentNo(context, no),
          ),
      ],
    );
  }
}

class _GraduateSortControl extends StatelessWidget {
  const _GraduateSortControl({
    required this.value,
    required this.onChanged,
  });

  final _GraduateSort value;
  final ValueChanged<_GraduateSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _AdminDashTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AdminDashTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_GraduateSort>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.sort_rounded, size: 18, color: Color(0xFF64748B)),
          style: AppFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          items: const [
            DropdownMenuItem(
              value: _GraduateSort.nameAsc,
              child: Text('Name A–Z'),
            ),
            DropdownMenuItem(
              value: _GraduateSort.studentNoAsc,
              child: Text('Student #'),
            ),
            DropdownMenuItem(
              value: _GraduateSort.programAsc,
              child: Text('Program'),
            ),
          ],
          onChanged: (picked) {
            if (picked != null) onChanged(picked);
          },
        ),
      ),
    );
  }
}

class _GraduateProgramFilterBar extends StatelessWidget {
  const _GraduateProgramFilterBar({
    required this.programs,
    required this.selected,
    required this.accents,
    required this.onSelected,
  });

  final List<String> programs;
  final String? selected;
  final List<Color> accents;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _GraduateFilterChip(
            label: 'All programs',
            selected: selected == null,
            accent: const Color(0xFF64748B),
            onTap: () => onSelected(null),
          ),
          for (final program in programs) ...[
            const SizedBox(width: 8),
            _GraduateFilterChip(
              label: program,
              selected: selected == program,
              accent: _accentForProgram(program, accents),
              onTap: () => onSelected(program),
            ),
          ],
        ],
      ),
    );
  }
}

class _GraduateFilterChip extends StatelessWidget {
  const _GraduateFilterChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.14) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? accent : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: AppFonts.poppins(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? accent : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}

class _GraduateListSummary extends StatelessWidget {
  const _GraduateListSummary({
    required this.showing,
    required this.total,
    required this.hasSearch,
    required this.hasProgramFilter,
  });

  final int showing;
  final int total;
  final bool hasSearch;
  final bool hasProgramFilter;

  @override
  Widget build(BuildContext context) {
    final filtered = hasSearch || hasProgramFilter || showing != total;
    return Row(
      children: [
        Icon(
          Icons.people_outline_rounded,
          size: 16,
          color: filtered ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
        ),
        const SizedBox(width: 6),
        Text(
          filtered
              ? 'Showing $showing of $total graduates'
              : '$total graduate${total == 1 ? '' : 's'}',
          style: AppFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: filtered ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _YearGraduatesTable extends StatelessWidget {
  const _YearGraduatesTable({
    required this.graduates,
    required this.accents,
    required this.query,
    required this.onCopyStudentNo,
  });

  final List<_AnalyticsGraduate> graduates;
  final List<Color> accents;
  final String query;
  final void Function(String studentNo) onCopyStudentNo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E8EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                const SizedBox(width: 44),
                Expanded(
                  flex: 4,
                  child: Text(
                    'GRADUATE',
                    style: AppFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'STUDENT NO.',
                    style: AppFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'PROGRAM',
                    textAlign: TextAlign.end,
                    style: AppFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: graduates.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final graduate = graduates[index];
              final accent =
                  _accentForProgram(graduate.programLabel, accents);
              return _YearGraduateRow(
                graduate: graduate,
                accent: accent,
                query: query,
                onCopyStudentNo: () => onCopyStudentNo(graduate.studentNo),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _YearGraduateRow extends StatelessWidget {
  const _YearGraduateRow({
    required this.graduate,
    required this.accent,
    required this.query,
    required this.onCopyStudentNo,
  });

  final _AnalyticsGraduate graduate;
  final Color accent;
  final String query;
  final VoidCallback onCopyStudentNo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _GraduateAvatar(
            initials: _graduateInitials(graduate.fullName),
            accent: accent,
            size: 40,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HighlightedText(
                  text: graduate.fullName,
                  query: query,
                  style: AppFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  highlightStyle: AppFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ).copyWith(
                    backgroundColor: accent.withValues(alpha: 0.15),
                  ),
                ),
                if (graduate.course.trim().isNotEmpty &&
                    graduate.course.trim().toLowerCase() !=
                        graduate.programLabel.trim().toLowerCase()) ...[
                  const SizedBox(height: 2),
                  Text(
                    graduate.course,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: _HighlightedText(
                    text: graduate.studentNo,
                    query: query,
                    style: AppFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                      letterSpacing: 0.2,
                    ),
                    highlightStyle: AppFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ).copyWith(
                      backgroundColor: accent.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy student number',
                  onPressed: onCopyStudentNo,
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  color: const Color(0xFF94A3B8),
                  splashRadius: 18,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _GraduateProgramChip(
                label: graduate.programLabel,
                accent: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightStyle,
  });

  final String text;
  final String query;
  final TextStyle style;
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return Text(text, style: style, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    final lower = text.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;
    while (true) {
      final index = lower.indexOf(q, start);
      if (index < 0) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: style));
        }
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + q.length),
          style: highlightStyle,
        ),
      );
      start = index + q.length;
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }
}

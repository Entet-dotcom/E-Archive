part of '../../dashboard_shell_page.dart';

class _StudentsListTopBar extends StatelessWidget {
  const _StudentsListTopBar({
    required this.canEdit,
    this.onAdd,
    this.drillCollegeName,
    this.drillCourseName,
    this.onDrillBack,
  });

  final bool canEdit;
  final VoidCallback? onAdd;
  final String? drillCollegeName;
  final String? drillCourseName;
  final VoidCallback? onDrillBack;

  @override
  Widget build(BuildContext context) {
    final inDrill = drillCourseName != null && drillCourseName!.isNotEmpty;
    return Row(
      children: [
        if (inDrill)
          _StudentsDrillBreadcrumb(
            collegeName: drillCollegeName ?? '',
            courseName: drillCourseName!,
            onBack: onDrillBack,
          )
        else
          const _StudentsBreadcrumb(),
        const Spacer(),
        if (canEdit && onAdd != null) ...[
          const SizedBox(width: 10),
          _RecordsAddButton(onPressed: onAdd!),
        ],
      ],
    );
  }
}

class _StudentsDrillBreadcrumb extends StatelessWidget {
  const _StudentsDrillBreadcrumb({
    required this.collegeName,
    required this.courseName,
    this.onBack,
  });

  final String collegeName;
  final String courseName;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final segments = <String>[
      'Records',
      if (collegeName.isNotEmpty) collegeName,
      courseName,
      'Students',
    ];
    return _RecordBreadcrumb(
      segments: segments,
      onBack: onBack,
      backTooltip: 'Back to programs',
    );
  }
}

class _StudentsFormTopBar extends StatelessWidget {
  const _StudentsFormTopBar({
    required this.onBack,
    required this.canEdit,
    this.onAdd,
  });

  final VoidCallback onBack;
  final bool canEdit;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RecordBreadcrumb(
            segments: const ['Records', 'Students'],
            onBack: onBack,
            backTooltip: 'Back to list',
          ),
        ),
        if (canEdit && onAdd != null) ...[
          const SizedBox(width: 10),
          _RecordsAddButton(onPressed: onAdd!),
        ],
      ],
    );
  }
}

class _StudentsBreadcrumb extends StatelessWidget {
  const _StudentsBreadcrumb();

  @override
  Widget build(BuildContext context) {
    return const _RecordBreadcrumb(segments: ['Records', 'Students']);
  }
}

class _RecordsAddButton extends StatelessWidget {
  const _RecordsAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _collegeTeal,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.add, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _StudentFormTabBar extends StatelessWidget {
  const _StudentFormTabBar({required this.tab, required this.onChanged});

  final _StudentFormTab tab;
  final ValueChanged<_StudentFormTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _StudentFormTabChip(
            label: 'Student',
            selected: tab == _StudentFormTab.student,
            onTap: () => onChanged(_StudentFormTab.student),
          ),
          _StudentFormTabChip(
            label: 'Academic',
            selected: tab == _StudentFormTab.academic,
            onTap: () => onChanged(_StudentFormTab.academic),
          ),
          _StudentFormTabChip(
            label: 'Contact',
            selected: tab == _StudentFormTab.contact,
            onTap: () => onChanged(_StudentFormTab.contact),
          ),
          _StudentFormTabChip(
            label: 'Notes',
            selected: tab == _StudentFormTab.notes,
            onTap: () => onChanged(_StudentFormTab.notes),
          ),
          _StudentFormTabChip(
            label: 'Dates',
            selected: tab == _StudentFormTab.dates,
            onTap: () => onChanged(_StudentFormTab.dates),
          ),
        ],
      ),
    );
  }
}

class _StudentFormTabChip extends StatelessWidget {
  const _StudentFormTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? _collegeTeal : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: _studentLabelTextStyle.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _StudentLabeledField extends StatelessWidget {
  const _StudentLabeledField({
    required this.label,
    required this.child,
    this.required = false,
  });

  final String label;
  final Widget child;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 168,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Text(label, style: _studentLabelTextStyle),
                  if (required) Text('*', style: _studentRequiredMarkTextStyle),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _StudentTextField extends StatelessWidget {
  const _StudentTextField({
    required this.controller,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: _studentInputTextStyle,
      decoration: _studentInputDecoration(hint: hint),
    );
  }
}

class _StudentDateField extends StatelessWidget {
  const _StudentDateField({
    required this.controller,
    required this.showWarning,
    required this.onPick,
  });

  final TextEditingController controller;
  final bool showWarning;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onPick,
      style: _studentInputTextStyle,
      decoration: _studentInputDecoration().copyWith(
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showWarning)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
            IconButton(
              onPressed: onPick,
              icon: const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentDocumentsSection extends StatelessWidget {
  const _StudentDocumentsSection({
    required this.documents,
    this.existingDocumentCount = 0,
    required this.onAdd,
    required this.onRemove,
    required this.onPickDate,
    required this.onPickFile,
    required this.documentTypes,
    required this.onDocumentChanged,
  });

  final List<_StudentDocumentDraft> documents;
  final int existingDocumentCount;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onPickDate;
  final ValueChanged<int> onPickFile;
  final List<String> documentTypes;
  final VoidCallback onDocumentChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: const Color(0xFFF9FAFB),
          child: Text(
            'Files and documents ${existingDocumentCount + documents.length}',
            style: _studentSectionTitleTextStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < documents.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _StudentDocumentCard(
                  index: existingDocumentCount + i + 1,
                  draft: documents[i],
                  documentTypes: documentTypes,
                  onRemove: () => onRemove(i),
                  onPickDate: () => onPickDate(i),
                  onPickFile: () => onPickFile(i),
                  onChanged: onDocumentChanged,
                ),
              ],
              const SizedBox(height: 8),
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 18, color: _collegeTeal),
                      const SizedBox(width: 8),
                      Text(
                        'Add another Student document',
                        style: _studentLinkTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentHeaderCell extends StatelessWidget {
  const _StudentHeaderCell({
    required this.flex,
    required this.label,
    this.alignEnd = false,
  });

  final int flex;
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(label, style: _studentTableHeaderTextStyle),
        ),
      ),
    );
  }
}

class _StudentSortableHeaderCell extends StatelessWidget {
  const _StudentSortableHeaderCell({
    required this.flex,
    required this.label,
    required this.column,
    required this.activeColumn,
    required this.ascending,
    required this.onSort,
  });

  final int flex;
  final String label;
  final _StudentListSortColumn column;
  final _StudentListSortColumn activeColumn;
  final bool ascending;
  final ValueChanged<_StudentListSortColumn> onSort;

  @override
  Widget build(BuildContext context) {
    final active = column == activeColumn;
    return Expanded(
      flex: flex,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSort(column),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: _studentTableHeaderTextStyle.copyWith(
                      color: active
                          ? const Color(0xFF2563EB)
                          : _studentTableHeaderTextStyle.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  active
                      ? (ascending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded)
                      : Icons.unfold_more_rounded,
                  size: 14,
                  color: active
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentListPaginationBar extends StatelessWidget {
  const _StudentListPaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  List<int> _visiblePageNumbers() {
    if (totalPages <= 5) {
      return List.generate(totalPages, (i) => i);
    }
    var start = currentPage - 2;
    var end = currentPage + 2;
    if (start < 0) {
      end -= start;
      start = 0;
    }
    if (end >= totalPages) {
      start -= end - totalPages + 1;
      end = totalPages - 1;
    }
    start = start.clamp(0, totalPages - 1);
    return List.generate(end - start + 1, (i) => start + i);
  }

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();

    final rangeStart = currentPage * pageSize + 1;
    final rangeEnd = math.min((currentPage + 1) * pageSize, totalItems);
    final showPager = totalPages > 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              showPager
                  ? 'Showing $rangeStart–$rangeEnd of $totalItems students'
                  : '$totalItems student${totalItems == 1 ? '' : 's'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showPager) ...[
            IconButton(
              tooltip: 'Previous page',
              onPressed: currentPage > 0
                  ? () => onPageChanged(currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: const Color(0xFF64748B),
            ),
            for (final page in _visiblePageNumbers())
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Material(
                  color: page == currentPage
                      ? const Color(0xFF2563EB)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: () => onPageChanged(page),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        '${page + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: page == currentPage
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            IconButton(
              tooltip: 'Next page',
              onPressed: currentPage < totalPages - 1
                  ? () => onPageChanged(currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: const Color(0xFF64748B),
            ),
          ],
        ],
      ),
    );
  }
}

class _StudentDataRow extends StatelessWidget {
  const _StudentDataRow({
    required this.student,
    this.striped = false,
    required this.canEdit,
    required this.isAdmin,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final _StudentRow student;
  final bool striped;
  final bool canEdit;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: striped ? const Color(0xFFFAFBFC) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFFF1F5F9),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              _StudentCell(
                flex: 2,
                text: student.studentNo,
                bold: true,
              ),
              _StudentCell(flex: 3, text: student.fullName),
              _StudentCell(flex: 3, text: student.course),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RecordEditAction(onPressed: canEdit ? onEdit : null),
                        if (isAdmin) ...[
                          const SizedBox(width: 2),
                          _RecordDeleteAction(onPressed: onDelete),
                        ],
                      ],
                    ),
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

class _StudentDetailPanel extends StatelessWidget {
  const _StudentDetailPanel({
    required this.student,
    required this.documents,
    this.onEdit,
  });

  final _StudentRow student;
  final List<_DocRow> documents;
  final VoidCallback? onEdit;

  bool _canPreviewImage(_DocRow doc) {
    return doc.type.toLowerCase().contains('image/') ||
        (doc.localImagePath?.trim().isNotEmpty ?? false) ||
        doc.remoteImageUrl.trim().isNotEmpty;
  }

  void _openImageViewer(BuildContext context, _DocRow doc) {
    final localPath = doc.localImagePath?.trim() ?? '';
    final remoteUrl = doc.remoteImageUrl.trim();
    if (localPath.isEmpty && remoteUrl.isEmpty) {
      _showInfo(context, 'Image preview is not available for this document.');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(24),
          child: Theme(
            data: _studentDetailDialogTheme,
            child: Material(
              color: Colors.white,
              elevation: 8,
              shadowColor: const Color(0x1A000000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: 920,
                height: 640,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Preview: ${doc.title}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _studentTextBlack,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InteractiveViewer(
                          minScale: 0.6,
                          maxScale: 6,
                          child: Center(
                            child: localPath.isNotEmpty
                                ? Image.file(
                                    File(localPath),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Text(
                                      'Local image preview failed.',
                                      style: _studentMutedTextStyle.copyWith(
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    remoteUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Text(
                                      'Could not load image from server.',
                                      style: _studentMutedTextStyle.copyWith(
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF0369A1),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName, style: _studentTitleTextStyle),
                    const SizedBox(height: 2),
                    Text(student.studentNo, style: _studentSubtitleTextStyle),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                tooltip: 'Close',
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Student details', style: _studentSectionTitleTextStyle),
                const SizedBox(height: 10),
                _StudentDetailInfoGrid(student: student),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('Documents', style: _studentSectionTitleTextStyle),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${documents.length}',
                        style: _studentBadgeTextStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (documents.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      'No documents in trash for this student yet.',
                      style: _studentMutedTextStyle,
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < documents.length; i++)
                          _StudentDocListTile(
                            doc: documents[i],
                            showDivider: i < documents.length - 1,
                            canPreview: _canPreviewImage(documents[i]),
                            onPreview: () =>
                                _openImageViewer(context, documents[i]),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(
            children: [
              if (onEdit != null) ...[
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit student'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _studentTextBlack,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentDetailInfoGrid extends StatelessWidget {
  const _StudentDetailInfoGrid({required this.student});

  final _StudentRow student;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        children: [
          _StudentDetailField(label: 'Program', value: student.course),
          _StudentDetailField(
            label: 'Status',
            value: student.status.isEmpty ? 'â€”' : student.status,
          ),
          _StudentDetailField(
            label: 'Email',
            value: (student.email ?? '').trim().isEmpty ? 'â€”' : student.email!,
          ),
        ],
      ),
    );
  }
}

class _StudentDetailField extends StatelessWidget {
  const _StudentDetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _studentDetailLabelTextStyle),
          const SizedBox(height: 4),
          Text(value, style: _studentFieldTextStyle),
        ],
      ),
    );
  }
}

class _StudentDocListTile extends StatelessWidget {
  const _StudentDocListTile({
    required this.doc,
    required this.showDivider,
    required this.canPreview,
    required this.onPreview,
  });

  final _DocRow doc;
  final bool showDivider;
  final bool canPreview;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.description_outlined,
            size: 18,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: _studentFieldTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${doc.type} Â· ${doc.uploaded}',
                  style: _studentSubtitleTextStyle.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (canPreview)
            IconButton(
              onPressed: onPreview,
              tooltip: 'Preview image',
              icon: const Icon(
                Icons.image_outlined,
                size: 18,
                color: Color(0xFF16A34A),
              ),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _StudentCell extends StatelessWidget {
  const _StudentCell({
    required this.flex,
    required this.text,
    this.bold = false,
  });

  final int flex;
  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: _studentFieldTextStyle.copyWith(
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _StudentDocumentCard extends StatefulWidget {
  const _StudentDocumentCard({
    required this.index,
    required this.draft,
    required this.documentTypes,
    required this.onRemove,
    required this.onPickDate,
    required this.onPickFile,
    required this.onChanged,
  });

  final int index;
  final _StudentDocumentDraft draft;
  final List<String> documentTypes;
  final VoidCallback onRemove;
  final VoidCallback onPickDate;
  final VoidCallback onPickFile;
  final VoidCallback onChanged;

  @override
  State<_StudentDocumentCard> createState() => _StudentDocumentCardState();
}

class _StudentDocumentCardState extends State<_StudentDocumentCard> {
  late final TextEditingController _titleController;
  late final TextEditingController _remarksController;
  late final TextEditingController _receivedController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _remarksController = TextEditingController(text: widget.draft.remarks);
    _receivedController = TextEditingController(
      text: _formatDate(widget.draft.receivedAt),
    );
  }

  @override
  void didUpdateWidget(covariant _StudentDocumentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.receivedAt != widget.draft.receivedAt) {
      _receivedController.text = _formatDate(widget.draft.receivedAt);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _remarksController.dispose();
    _receivedController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final hasFile = (draft.fileName ?? '').isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Text(
                  'Student document: #${widget.index}',
                  style: _studentDocumentTitleTextStyle,
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFFDC2626)),
                  tooltip: 'Remove document',
                ),
              ],
            ),
          ),
          _StudentLabeledField(
            label: 'Title',
            required: true,
            child: TextField(
              controller: _titleController,
              style: _studentInputTextStyle,
              onChanged: (v) {
                draft.title = v;
                widget.onChanged();
              },
              decoration: _studentInputDecoration(hint: 'Document title'),
            ),
          ),
          _StudentLabeledField(
            label: 'Document type',
            required: true,
            child: DropdownButtonFormField<String>(
              value: draft.documentType,
              style: _studentInputTextStyle,
              decoration: _studentInputDecoration(),
              dropdownColor: Colors.white,
              items: widget.documentTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t, style: _studentInputTextStyle),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => draft.documentType = v);
                widget.onChanged();
              },
            ),
          ),
          _StudentLabeledField(
            label: 'File',
            required: true,
            child: InkWell(
              onTap: widget.onPickFile,
              child: InputDecorator(
                decoration: _studentInputDecoration(
                  hint: 'Choose file to upload',
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasFile ? draft.fileName! : 'Choose file to upload',
                        overflow: TextOverflow.ellipsis,
                        style: hasFile
                            ? _studentInputTextStyle
                            : _studentHintTextStyle,
                      ),
                    ),
                    Icon(
                      Icons.file_upload_outlined,
                      size: 20,
                      color: hasFile ? _collegeTeal : _studentTextMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _StudentLabeledField(
            label: 'Open',
            child: Text(
              hasFile ? 'Use View docs or See all after save.' : 'â€”',
              style: _studentMutedTextStyle,
            ),
          ),
          _StudentLabeledField(
            label: 'Viewer',
            child: Text(
              hasFile
                  ? 'Trash items are grouped by student after save.'
                  : 'Choose a file to upload.',
              style: _studentMutedTextStyle,
            ),
          ),
          _StudentLabeledField(
            label: 'Format',
            child: Text(
              hasFile ? p.extension(draft.filePath!).toUpperCase() : 'â€”',
              style: hasFile
                  ? _studentInputTextStyle
                  : _studentFieldTextStyle.copyWith(color: _studentTextMuted),
            ),
          ),
          _StudentLabeledField(
            label: 'Received at',
            required: true,
            child: TextField(
              readOnly: true,
              onTap: widget.onPickDate,
              controller: _receivedController,
              style: _studentInputTextStyle,
              decoration: _studentInputDecoration().copyWith(
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (draft.receivedAt == null)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFDC2626),
                          size: 20,
                        ),
                      ),
                    IconButton(
                      onPressed: widget.onPickDate,
                      icon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _StudentLabeledField(
            label: 'Trashed by',
            child: Text('â€”', style: _studentMutedTextStyle),
          ),
          _StudentLabeledField(
            label: 'Remarks',
            child: TextField(
              controller: _remarksController,
              maxLines: 4,
              style: _studentInputTextStyle,
              onChanged: (v) {
                draft.remarks = v;
                widget.onChanged();
              },
              decoration: _studentInputDecoration(hint: 'Optional notes'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StudentDepartmentProgramFilterBar extends StatelessWidget {
  const _StudentDepartmentProgramFilterBar({
    required this.department,
    required this.program,
    required this.departments,
    required this.programs,
    required this.onDepartmentChanged,
    required this.onProgramChanged,
    this.onClear,
  });

  final String? department;
  final String? program;
  final List<String> departments;
  final List<String> programs;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onProgramChanged;
  final VoidCallback? onClear;

  static const _filterDecoration = InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: _RecordListTheme.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: _RecordListTheme.border),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackFilters = constraints.maxWidth < 720;
          final departmentField = _buildFilterField(
            label: 'Department',
            icon: Icons.account_balance_outlined,
            child: DropdownButtonFormField<String?>(
              value: department,
              isExpanded: true,
              style: _studentFilterDropdownTextStyle,
              decoration: _filterDecoration.copyWith(
                prefixIcon: const Icon(
                  Icons.account_balance_outlined,
                  size: 18,
                  color: _RecordListTheme.textHint,
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
              ),
              dropdownColor: Colors.white,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'All departments',
                    style: _studentFilterDropdownTextStyle,
                  ),
                ),
                ...departments.map(
                  (d) => DropdownMenuItem<String?>(
                    value: d,
                    child: Text(
                      d,
                      overflow: TextOverflow.ellipsis,
                      style: _studentFilterDropdownTextStyle,
                    ),
                  ),
                ),
              ],
              onChanged: onDepartmentChanged,
            ),
          );
          final programField = _buildFilterField(
            label: 'Program',
            icon: Icons.school_outlined,
            child: DropdownButtonFormField<String?>(
              value: program != null && programs.contains(program)
                  ? program
                  : null,
              isExpanded: true,
              style: _studentFilterDropdownTextStyle,
              decoration: _filterDecoration.copyWith(
                prefixIcon: const Icon(
                  Icons.school_outlined,
                  size: 18,
                  color: _RecordListTheme.textHint,
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
              ),
              dropdownColor: Colors.white,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'All programs',
                    style: _studentFilterDropdownTextStyle,
                  ),
                ),
                ...programs.map(
                  (p) => DropdownMenuItem<String?>(
                    value: p,
                    child: Text(
                      p,
                      overflow: TextOverflow.ellipsis,
                      style: _studentFilterDropdownTextStyle,
                    ),
                  ),
                ),
              ],
              onChanged: onProgramChanged,
            ),
          );

          if (stackFilters) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                departmentField,
                const SizedBox(height: 10),
                programField,
                if (onClear != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildClearButton(onClear!),
                  ),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 5, child: departmentField),
              const SizedBox(width: 12),
              Expanded(flex: 6, child: programField),
              if (onClear != null) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: _buildClearButton(onClear!),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _RecordListTheme.textMuted),
            const SizedBox(width: 6),
            Text(label, style: _studentFilterLabelTextStyle),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildClearButton(VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
      label: const Text('Clear'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _RecordListTheme.textPrimary,
        side: const BorderSide(color: _RecordListTheme.border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _StudentActiveFilterSummary extends StatelessWidget {
  const _StudentActiveFilterSummary({
    required this.department,
    required this.program,
    required this.searchQuery,
    required this.resultCount,
    required this.totalCount,
  });

  final String? department;
  final String? program;
  final String searchQuery;
  final int resultCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (department != null && department!.isNotEmpty) {
      chips.add(_StudentFilterChip(
        label: _shortDepartmentLabel(department!),
        icon: Icons.account_balance_outlined,
      ));
    }
    if (program != null && program!.isNotEmpty) {
      chips.add(_StudentFilterChip(
        label: program!,
        icon: Icons.school_outlined,
      ));
    }
    if (searchQuery.isNotEmpty) {
      chips.add(_StudentFilterChip(
        label: 'Search: $searchQuery',
        icon: Icons.search,
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF6FF),
        border: Border(
          bottom: BorderSide(color: _RecordListTheme.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: chips,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$resultCount of $totalCount',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentFilterChip extends StatelessWidget {
  const _StudentFilterChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2563EB)),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _RecordListTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
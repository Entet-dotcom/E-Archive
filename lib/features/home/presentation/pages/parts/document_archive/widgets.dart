part of '../../dashboard_shell_page.dart';

class _ArchiveFilterBar extends StatelessWidget {
  const _ArchiveFilterBar({
    required this.type,
    required this.bulkMode,
    required this.isAdmin,
    required this.canDeleteAll,
    required this.onTypeChanged,
    required this.onBulkModeToggle,
    this.onDeleteAll,
  });

  final String type;
  final bool bulkMode;
  final bool isAdmin;
  final bool canDeleteAll;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onBulkModeToggle;
  final VoidCallback? onDeleteAll;

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
      borderSide: BorderSide(color: _archiveAccent, width: 1.5),
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
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              value: type,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 13,
                color: _RecordListTheme.textPrimary,
              ),
              decoration: _filterDecoration.copyWith(
                labelText: 'Type',
                labelStyle: const TextStyle(
                  fontSize: 12,
                  color: _RecordListTheme.textMuted,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All types')),
                DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                DropdownMenuItem(value: 'image', child: Text('Image')),
              ],
              onChanged: (v) => onTypeChanged(v ?? 'All'),
            ),
          ),
          TextButton.icon(
            onPressed: onBulkModeToggle,
            icon: Icon(
              bulkMode ? Icons.close : Icons.checklist_outlined,
              size: 18,
            ),
            label: Text(bulkMode ? 'Exit selection' : 'Select'),
            style: TextButton.styleFrom(
              foregroundColor: _RecordListTheme.textMuted,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          if (isAdmin && canDeleteAll && !bulkMode)
            TextButton.icon(
              onPressed: onDeleteAll,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete all'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArchiveBulkBar extends StatelessWidget {
  const _ArchiveBulkBar({
    required this.selectedCount,
    required this.canSelectAll,
    required this.isAllSelected,
    required this.onToggleSelectAll,
    required this.onDownloadSelected,
    this.onDeleteSelected,
  });

  final int selectedCount;
  final bool canSelectAll;
  final bool isAllSelected;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onDownloadSelected;
  final VoidCallback? onDeleteSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: _RecordListTheme.border),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (canSelectAll)
            TextButton.icon(
              onPressed: onToggleSelectAll,
              icon: Icon(
                isAllSelected ? Icons.deselect : Icons.select_all,
                size: 16,
              ),
              label: Text(isAllSelected ? 'Deselect all' : 'Select all'),
            ),
          Text(
            selectedCount > 0
                ? '$selectedCount selected'
                : 'Select documents for bulk actions',
            style: TextStyle(
              fontSize: 13,
              color: selectedCount > 0
                  ? _RecordListTheme.textPrimary
                  : _RecordListTheme.textMuted,
              fontWeight:
                  selectedCount > 0 ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (selectedCount > 0) ...[
            TextButton.icon(
              onPressed: onDownloadSelected,
              icon: const Icon(Icons.download_outlined, size: 16),
              label: const Text('Download'),
            ),
            if (onDeleteSelected != null)
              TextButton.icon(
                onPressed: onDeleteSelected,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ArchiveEmptyState extends StatelessWidget {
  const _ArchiveEmptyState({
    required this.hasFilters,
    this.studentFilter,
    this.onClearFilters,
  });

  final bool hasFilters;
  final String? studentFilter;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final filteredStudent =
        studentFilter != null && studentFilter!.trim().isNotEmpty;
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                size: 40,
                color: _RecordListTheme.textHint.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 12),
              Text(
                filteredStudent
                    ? 'No documents for this student'
                    : 'No documents in trash',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _RecordListTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasFilters
                    ? 'Try adjusting your search or filters.'
                    : 'Deleted documents will appear here, grouped by student.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: _RecordListTheme.textMuted,
                  height: 1.4,
                ),
              ),
              if (hasFilters && onClearFilters != null) ...[
                const SizedBox(height: 14),
                TextButton(onPressed: onClearFilters, child: const Text('Clear filters')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveTableHeader extends StatelessWidget {
  const _ArchiveTableHeader({
    required this.bulkMode,
    required this.canSelectAll,
    required this.isAllSelected,
    required this.selectedCount,
    required this.onSelectAll,
  });

  final bool bulkMode;
  final bool canSelectAll;
  final bool isAllSelected;
  final int selectedCount;
  final ValueChanged<bool?>? onSelectAll;

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF64748B),
    letterSpacing: 0.2,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: _RecordListTheme.headerBg,
        border: Border(bottom: BorderSide(color: _RecordListTheme.border)),
      ),
      child: Row(
        children: [
          if (bulkMode)
            SizedBox(
              width: 40,
              child: Checkbox(
                value: isAllSelected,
                tristate: selectedCount > 0 && !isAllSelected,
                onChanged: canSelectAll ? onSelectAll : null,
                visualDensity: VisualDensity.compact,
              ),
            ),
          const Expanded(flex: 4, child: Text('Title', style: _headerStyle)),
          const Expanded(flex: 3, child: Text('Student', style: _headerStyle)),
          const Expanded(flex: 2, child: Text('Type', style: _headerStyle)),
          const Expanded(flex: 2, child: Text('Size', style: _headerStyle)),
          const Expanded(flex: 2, child: Text('Uploaded', style: _headerStyle)),
          if (!bulkMode)
            const SizedBox(
              width: 108,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Actions', style: _headerStyle),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArchiveDataRow extends StatelessWidget {
  const _ArchiveDataRow({
    required this.doc,
    required this.isAdmin,
    required this.bulkMode,
    required this.selected,
    required this.canViewImage,
    required this.isLast,
    required this.onToggleSelected,
    required this.onViewImage,
    required this.onDownload,
    required this.onDelete,
  });

  final _DocRow doc;
  final bool isAdmin;
  final bool bulkMode;
  final bool selected;
  final bool canViewImage;
  final bool isLast;
  final ValueChanged<bool> onToggleSelected;
  final VoidCallback onViewImage;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  static const _cellStyle = TextStyle(
    fontSize: 13,
    color: _RecordListTheme.textMuted,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: _RecordListTheme.rowHover,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: _RecordListTheme.border),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (bulkMode)
                SizedBox(
                  width: 40,
                  child: Checkbox(
                    value: selected,
                    onChanged: (v) => onToggleSelected(v ?? false),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: _RecordListTheme.textHint,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _RecordListTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  doc.student,
                  overflow: TextOverflow.ellipsis,
                  style: _cellStyle,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(doc.type, overflow: TextOverflow.ellipsis, style: _cellStyle),
              ),
              Expanded(
                flex: 2,
                child: Text(doc.size, overflow: TextOverflow.ellipsis, style: _cellStyle),
              ),
              Expanded(
                flex: 2,
                child: Text(doc.uploaded, overflow: TextOverflow.ellipsis, style: _cellStyle),
              ),
              if (!bulkMode)
                SizedBox(
                  width: 108,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (canViewImage)
                          _RecordIconAction(
                            icon: Icons.image_outlined,
                            color: _RecordListTheme.textMuted,
                            onPressed: onViewImage,
                            tooltip: 'Preview',
                          ),
                        _RecordIconAction(
                          icon: Icons.download_outlined,
                          color: _RecordListTheme.textMuted,
                          onPressed: onDownload,
                          tooltip: 'Download',
                        ),
                        if (isAdmin)
                          _RecordDeleteAction(onPressed: onDelete),
                      ],
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

class _StudentDocumentGroup extends StatelessWidget {
  const _StudentDocumentGroup({
    required this.student,
    required this.docs,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String student;
  final List<_DocRow> docs;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: const Color(0xFFF9FAFB),
          child: InkWell(
            onTap: onToggle,
            hoverColor: _RecordListTheme.rowHover,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _RecordListTheme.border),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                    color: _RecordListTheme.textHint,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      student,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _RecordListTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${docs.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _RecordListTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expanded) child,
      ],
    );
  }
}

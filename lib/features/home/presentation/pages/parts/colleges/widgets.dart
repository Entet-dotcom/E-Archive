part of '../../dashboard_shell_page.dart';

class _CollegeNameCell extends StatelessWidget {
  const _CollegeNameCell({
    required this.collegeName,
    this.minimal = false,
  });

  final String collegeName;
  final bool minimal;

  @override
  Widget build(BuildContext context) {
    final display = _parseCollegeDisplayLabel(collegeName);
    if (minimal) {
      return Text(
        display.code,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          display.code,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        if (display.fullName.isNotEmpty && display.fullName != display.code)
          Text(
            display.fullName,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _CollegeCourseCountChip extends StatelessWidget {
  const _CollegeCourseCountChip({
    required this.count,
    this.minimal = false,
  });

  final int count;
  final bool minimal;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 program' : '$count programs';
    if (minimal) {
      return Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF94A3B8),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF99F6E4)),
      ),
      child: Text(
        label,
        style: AppFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _collegeTeal,
        ),
      ),
    );
  }
}

class _CollegesSettingsList extends StatelessWidget {
  const _CollegesSettingsList({
    required this.rows,
    this.courseCountByCollegeId,
    required this.onDelete,
  });

  final List<_CollegeRow> rows;
  final Map<int, int>? courseCountByCollegeId;
  final ValueChanged<_CollegeRow> onDelete;

  @override
  Widget build(BuildContext context) {
    return _RecordDataTable(
      headers: const ['College'],
      includeActionsColumn: true,
      minimal: true,
      actionsWidth: 44,
      rows: rows.map((college) {
        final courseCount = college.id != null
            ? (courseCountByCollegeId?[college.id!] ?? 0)
            : 0;
        return [
          Row(
            children: [
              Expanded(
                child: _CollegeNameCell(
                  collegeName: college.name,
                  minimal: true,
                ),
              ),
              const SizedBox(width: 16),
              _CollegeCourseCountChip(
                count: courseCount,
                minimal: true,
              ),
            ],
          ),
          _RecordDeleteAction(
            minimal: true,
            onPressed: () => onDelete(college),
          ),
        ];
      }).toList(),
    );
  }
}

class _CollegesEmptyState extends StatelessWidget {
  const _CollegesEmptyState({
    required this.canEdit,
    required this.hasSearchFilter,
    required this.onAdd,
    required this.onResetFilters,
    this.addButtonLabel = 'Add college',
    this.addButtonColor,
    this.addButtonForegroundColor,
  });

  final bool canEdit;
  final bool hasSearchFilter;
  final VoidCallback onAdd;
  final VoidCallback onResetFilters;
  final String addButtonLabel;
  final Color? addButtonColor;
  final Color? addButtonForegroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 56),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSearchFilter
                ? Icons.search_off_outlined
                : Icons.account_balance_outlined,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This page yielded into no results. Create a new item or reset your filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              if (canEdit)
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: Icon(
                    Icons.add,
                    size: 18,
                    color: addButtonForegroundColor ?? Colors.white,
                  ),
                  label: Text(
                    addButtonLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: addButtonForegroundColor ?? Colors.white,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: addButtonColor ?? _collegeTealDark,
                    foregroundColor: addButtonForegroundColor ?? Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: hasSearchFilter ? onResetFilters : null,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Reset filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF374151),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CollegeFormDialog extends StatefulWidget {
  const _CollegeFormDialog({
    this.existing,
    required this.onAddCollege,
    required this.onUpdateCollege,
  });

  final _CollegeRow? existing;
  final Future<String?> Function({required String name}) onAddCollege;
  final Future<String?> Function({
    required _CollegeRow college,
    required String name,
  }) onUpdateCollege;

  @override
  State<_CollegeFormDialog> createState() => _CollegeFormDialogState();
}

class _CollegeFormDialogState extends State<_CollegeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _apiError;
  late String _selectedCollege;

  bool get _isEdit => widget.existing != null;

  List<String> get _collegeOptions {
    final existing = widget.existing?.name?.trim();
    final preset = _resolvePresetCollegeCode(existing);
    if (existing != null && existing.isNotEmpty && preset == null) {
      return [existing, ..._presetCollegeCodes];
    }
    return _presetCollegeCodes;
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existing?.name?.trim();
    final preset = _resolvePresetCollegeCode(existing);
    if (preset != null && _collegeOptions.contains(preset)) {
      _selectedCollege = preset;
    } else if (existing != null &&
        existing.isNotEmpty &&
        _collegeOptions.contains(existing)) {
      _selectedCollege = existing;
    } else {
      _selectedCollege = _presetCollegeCodes.first;
    }
  }

  Future<void> _submit() async {
    setState(() => _apiError = null);
    if (!_formKey.currentState!.validate()) return;

    final name = _collegeAddOptionLabel(_selectedCollege.trim());

    setState(() => _saving = true);
    final error = _isEdit
        ? await widget.onUpdateCollege(
            college: widget.existing!,
            name: name,
          )
        : await widget.onAddCollege(name: name);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _saving = false;
        _apiError = error;
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  static final _fieldTextStyle = AppFonts.poppins(
    fontSize: 14,
    color: Color(0xFF000000),
    fontWeight: FontWeight.w500,
  );

  InputDecoration _collegeFieldDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppFonts.poppins(color: Color(0xFF374151)),
      floatingLabelStyle: AppFonts.poppins(color: Color(0xFF374151)),
      hintStyle: AppFonts.poppins(color: Color(0xFF9CA3AF), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6B7280)),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogTheme = AppTheme.lightSurfaceTheme(
      colorScheme: const ColorScheme.light(
        primary: _collegeTealDark,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF000000),
      ),
      fieldTextStyle: _fieldTextStyle,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Theme(
          data: dialogTheme,
          child: Material(
            color: Colors.white,
            elevation: 8,
            shadowColor: const Color(0x1A000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0FDFA),
                    border:
                        Border(bottom: BorderSide(color: Color(0xFFCCFBF1))),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF99F6E4)),
                        ),
                        child: Icon(
                          _isEdit
                              ? Icons.edit_outlined
                              : Icons.add_circle_outline,
                          color: _collegeTeal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEdit ? 'Edit college' : 'Add college',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isEdit
                                  ? 'Update the selected college.'
                                  : 'Choose a college to add to the database.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(false),
                        tooltip: 'Close',
                        icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _collegeOptions.contains(_selectedCollege)
                              ? _selectedCollege
                              : _collegeOptions.first,
                          style: _fieldTextStyle,
                          dropdownColor: Colors.white,
                          decoration: _collegeFieldDecoration(
                            label: 'College *',
                            hint: 'Select a college',
                          ),
                          items: _collegeOptions
                              .map(
                                (college) => DropdownMenuItem(
                                  value: college,
                                  child: Text(_collegeAddOptionLabel(college)),
                                ),
                              )
                              .toList(),
                          onChanged: _saving
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() => _selectedCollege = value);
                                },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Select a college';
                            }
                            return null;
                          },
                        ),
                        if (_apiError != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Text(
                              _apiError!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF374151),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _saving ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: _collegeTealDark,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF5EEAD4),
                            disabledForegroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isEdit ? 'Save changes' : 'Add college',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

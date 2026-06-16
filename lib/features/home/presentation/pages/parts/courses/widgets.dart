part of '../../dashboard_shell_page.dart';

/// Sentinel value for the “type a custom program name” dropdown row.
const _courseCustomProgramDropdownValue = '\u0000course_custom_program';

List<DropdownMenuItem<String>> _courseProgramDropdownItems(
  List<String> programs,
) {
  return [
    ..._flatProgramDropdownItems(programs),
    DropdownMenuItem(
      value: _courseCustomProgramDropdownValue,
      child: Row(
        children: [
          Icon(Icons.add, size: 18, color: _courseBlue),
          const SizedBox(width: 8),
          Text(
            'Add other program…',
            style: _courseFieldTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: _courseBlue,
            ),
          ),
        ],
      ),
    ),
  ];
}

class _CourseFormDialog extends StatefulWidget {
  const _CourseFormDialog({
    this.existing,
    this.collegeName,
    required this.onAddCourse,
    required this.onUpdateCourse,
    this.onDeleteCourse,
  });

  final _CourseRow? existing;
  final String? collegeName;
  final Future<String?> Function({required String name}) onAddCourse;
  final Future<String?> Function({
    required _CourseRow course,
    required String name,
  }) onUpdateCourse;
  final Future<String?> Function(_CourseRow course)? onDeleteCourse;

  @override
  State<_CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<_CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customProgramController = TextEditingController();
  bool _saving = false;
  String? _apiError;
  late String? _selectedProgram;
  late final List<String> _programOptions;
  late bool _useCustomProgramName;

  bool get _isEdit => widget.existing != null;

  String? get _dropdownValue {
    if (_useCustomProgramName) return _courseCustomProgramDropdownValue;
    if (_selectedProgram != null &&
        _programOptions.contains(_selectedProgram)) {
      return _selectedProgram;
    }
    if (_programOptions.isNotEmpty) return _programOptions.first;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _programOptions = _catalogProgramsForCollege(widget.collegeName);
    final existing = widget.existing?.name.trim() ?? '';
    if (existing.isNotEmpty && !_programOptions.contains(existing)) {
      _useCustomProgramName = true;
      _customProgramController.text = existing;
      _selectedProgram = _courseCustomProgramDropdownValue;
    } else {
      _useCustomProgramName = false;
      _selectedProgram = _resolvedProgramDropdownValue(
        existing,
        _programOptions,
      );
    }
  }

  @override
  void dispose() {
    _customProgramController.dispose();
    super.dispose();
  }

  String? _resolvedProgramName() {
    if (_programOptions.isEmpty) {
      return _customProgramController.text.trim();
    }
    if (_useCustomProgramName) {
      return _customProgramController.text.trim();
    }
    return (_selectedProgram ?? '').trim();
  }

  Future<void> _submit() async {
    setState(() => _apiError = null);
    if (!_formKey.currentState!.validate()) return;

    final name = _resolvedProgramName();
    if (name == null || name.isEmpty) return;

    setState(() => _saving = true);
    final error = _isEdit
        ? await widget.onUpdateCourse(
            course: widget.existing!,
            name: name,
          )
        : await widget.onAddCourse(name: name);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _saving = false;
        _apiError = error;
      });
      return;
    }

    Navigator.of(context).pop(_isEdit ? 'updated' : 'added');
  }

  Future<void> _confirmDelete() async {
    final course = widget.existing;
    final onDelete = widget.onDeleteCourse;
    if (course == null || onDelete == null) return;

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

    setState(() => _saving = true);
    final error = await onDelete(course);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _saving = false;
        _apiError = error;
      });
      return;
    }

    Navigator.of(context).pop('deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                  color: Color(0xFFEFF6FF),
                  border: Border(bottom: BorderSide(color: Color(0xFFBFDBFE))),
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
                        border: Border.all(color: const Color(0xFF93C5FD)),
                      ),
                      child: Icon(
                        _isEdit
                            ? Icons.edit_outlined
                            : Icons.add_circle_outline,
                        color: _courseBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEdit ? 'Edit program' : 'Add program',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isEdit
                                ? 'Update the program.'
                                : widget.collegeName != null
                                    ? 'Select a program for ${widget.collegeName}.'
                                    : 'Select a program to save.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF000000),
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
                      icon: const Icon(Icons.close, color: Color(0xFF000000)),
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
                      if (_programOptions.isEmpty)
                        TextFormField(
                          controller: _customProgramController,
                          enabled: !_saving,
                          style: _courseFieldTextStyle,
                          cursorColor: const Color(0xFF000000),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: _courseInputDecoration(
                            label: 'Program name *',
                            hint: 'e.g. Bachelor of Science in Computer Science',
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Enter a program name';
                            return null;
                          },
                        )
                      else ...[
                        DropdownButtonFormField<String>(
                          value: _dropdownValue,
                          isExpanded: true,
                          style: _courseFieldTextStyle,
                          dropdownColor: Colors.white,
                          decoration: _courseInputDecoration(
                            label: 'Program *',
                            hint: 'Select a program',
                          ),
                          items: _courseProgramDropdownItems(_programOptions),
                          onChanged: _saving
                              ? null
                              : (v) {
                                  if (v == null) return;
                                  setState(() {
                                    _selectedProgram = v;
                                    _useCustomProgramName =
                                        v == _courseCustomProgramDropdownValue;
                                  });
                                },
                          validator: (v) {
                            if (_useCustomProgramName) return null;
                            if (v == null || v.trim().isEmpty) {
                              return 'Select a program';
                            }
                            return null;
                          },
                        ),
                        if (_useCustomProgramName) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _customProgramController,
                            enabled: !_saving,
                            style: _courseFieldTextStyle,
                            cursorColor: const Color(0xFF000000),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: _courseInputDecoration(
                              label: 'Program name *',
                              hint:
                                  'e.g. Bachelor of Science in Computer Science',
                            ),
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty) {
                                return 'Enter a program name';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
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
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Text(
                            _apiError!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w500,
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
                    if (_isEdit && widget.onDeleteCourse != null)
                      TextButton(
                        onPressed: _saving ? null : _confirmDelete,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB91C1C),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (_isEdit && widget.onDeleteCourse != null)
                      const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF000000),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: _courseBlue,
                          foregroundColor: Colors.white,
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
                                _isEdit ? 'Save changes' : 'Add program',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
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
    );
  }
}

part of '../../dashboard_shell_page.dart';

enum _StudentListSortColumn { studentNo, name, program }

class _StudentRecordsPage extends StatefulWidget {
  const _StudentRecordsPage({
    required this.rows,
    required this.documents,
    required this.courseOptions,
    this.programCodeForCourse,
    required this.onRegisterStudent,
    required this.onUploadDocument,
    required this.onViewStudentDocuments,
    required this.onViewAllDocuments,
    required this.onDeleteStudent,
    required this.canEdit,
    required this.isAdmin,
    this.drillCollegeName,
    this.drillCourseName,
    this.drillFromProgramsList = false,
    this.onDrillBack,
    this.drillDownView = false,
  });

  final List<_StudentRow> rows;
  final List<_DocRow> documents;
  final List<String> courseOptions;
  final String? Function(String courseName)? programCodeForCourse;
  final Future<_StudentRow?> Function({
    required String studentNo,
    required String fullName,
    required String course,
    required int year,
    required String status,
    String? email,
    String schoolYear,
  }) onRegisterStudent;
  final Future<bool> Function({
    required String title,
    required String student,
    required String sourceImagePath,
    required String mimeType,
    String studentNo,
    String course,
    String schoolYear,
    String documentType,
    bool isComplete,
    String college,
    String studentCategory,
  }) onUploadDocument;
  final void Function(String student) onViewStudentDocuments;
  final VoidCallback onViewAllDocuments;
  final Future<String?> Function(_StudentRow student) onDeleteStudent;
  final bool canEdit;
  final bool isAdmin;
  final String? drillCollegeName;
  final String? drillCourseName;
  final bool drillFromProgramsList;
  final VoidCallback? onDrillBack;
  final bool drillDownView;

  @override
  State<_StudentRecordsPage> createState() => _StudentRecordsPageState();
}

class _StudentRecordsPageState extends State<_StudentRecordsPage> {
  static const _documentTypes = [
    'Form 137',
    'Other',
    'Transcript',
    'Birth certificate',
    'ID',
    'Medical record',
    'Clearance',
  ];

  bool _showForm = false;
  _StudentRow? _editingStudent;
  _StudentFormTab _formTab = _StudentFormTab.student;
  bool _studentNoManuallyEdited = false;
  String? _filterDepartment;
  String? _filterProgram;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  static const _studentsPageSize = 25;
  int _listPage = 0;
  _StudentListSortColumn _sortColumn = _StudentListSortColumn.studentNo;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _applyDrillFiltersFromWidget();
  }

  void _applyDrillFiltersFromWidget() {
    final program = widget.drillCourseName?.trim();
    if (program != null && program.isNotEmpty) {
      _filterProgram = program;
      _filterDepartment = _departmentForProgram(program) ??
          _resolveCatalogCollegeLabel(widget.drillCollegeName);
      return;
    }
    final dept = _resolveCatalogCollegeLabel(widget.drillCollegeName);
    if (dept != null) _filterDepartment = dept;
  }

  final _studentNoController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _suffixController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _courseController = TextEditingController();
  final _schoolYearController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _enrolledAtController = TextEditingController();
  final _graduatedAtController = TextEditingController();

  DateTime? _birthDate;
  DateTime? _enrolledAt;
  DateTime? _graduatedAt;
  final List<_StudentDocumentDraft> _documents = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _studentNoController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _suffixController.dispose();
    _birthDateController.dispose();
    _courseController.dispose();
    _schoolYearController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _enrolledAtController.dispose();
    _graduatedAtController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        (_filterDepartment != null && _filterDepartment!.isNotEmpty) ||
        (_filterProgram != null && _filterProgram!.isNotEmpty);
  }

  List<String> get _filterProgramOptions {
    final catalog = _filterDepartment == null
        ? _catalogSelectablePrograms()
        : _catalogProgramsForCollege(_filterDepartment);
    final fromRows =
        widget.rows.map((r) => r.course.trim()).where((c) => c.isNotEmpty);
    final merged = <String>{...catalog, ...fromRows};
    if (_filterDepartment != null) {
      merged.removeWhere(
        (course) => !_studentMatchesDepartment(course, _filterDepartment),
      );
    }
    final list = merged.toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  bool _studentMatchesDepartment(String course, String? department) {
    if (department == null || department.isEmpty) return true;
    return _catalogProgramsForCollege(department).contains(course.trim());
  }

  bool _studentMatchesFilters(_StudentRow row) {
    final course = row.course.trim();
    if (_filterProgram != null &&
        _filterProgram!.isNotEmpty &&
        course != _filterProgram) {
      return false;
    }
    if (_filterDepartment != null &&
        _filterDepartment!.isNotEmpty &&
        !_studentMatchesDepartment(course, _filterDepartment)) {
      return false;
    }
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return row.fullName.toLowerCase().contains(q) ||
        row.studentNo.toLowerCase().contains(q) ||
        (row.email ?? '').toLowerCase().contains(q);
  }

  List<_StudentRow> get _filtered {
    return widget.rows.where(_studentMatchesFilters).toList();
  }

  List<_StudentRow> get _filteredSorted {
    final list = List<_StudentRow>.from(_filtered);
    list.sort((a, b) {
      final cmp = switch (_sortColumn) {
        _StudentListSortColumn.studentNo =>
          _compareStudentNumbers(a.studentNo, b.studentNo),
        _StudentListSortColumn.name => a.fullName
            .toLowerCase()
            .compareTo(b.fullName.toLowerCase()),
        _StudentListSortColumn.program =>
          a.course.toLowerCase().compareTo(b.course.toLowerCase()),
      };
      return _sortAscending ? cmp : -cmp;
    });
    return list;
  }

  int _totalListPages(int itemCount) {
    if (itemCount == 0) return 0;
    return (itemCount + _studentsPageSize - 1) ~/ _studentsPageSize;
  }

  int _safeListPage(int itemCount) {
    final pages = _totalListPages(itemCount);
    if (pages == 0) return 0;
    return _listPage.clamp(0, pages - 1);
  }

  List<_StudentRow> _pageSlice(List<_StudentRow> sorted, int page) {
    if (sorted.isEmpty) return const [];
    final start = page * _studentsPageSize;
    final end = math.min(start + _studentsPageSize, sorted.length);
    return sorted.sublist(start, end);
  }

  static int _compareStudentNumbers(String a, String b) {
    final na = a.trim().toUpperCase();
    final nb = b.trim().toUpperCase();
    final partsA = na.split('-');
    final partsB = nb.split('-');
    final maxLen = math.max(partsA.length, partsB.length);
    for (var i = 0; i < maxLen; i++) {
      final pa = i < partsA.length ? partsA[i] : '';
      final pb = i < partsB.length ? partsB[i] : '';
      final ia = int.tryParse(pa);
      final ib = int.tryParse(pb);
      final cmp =
          ia != null && ib != null ? ia.compareTo(ib) : pa.compareTo(pb);
      if (cmp != 0) return cmp;
    }
    return na.compareTo(nb);
  }

  void _onSortColumn(_StudentListSortColumn column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
      _listPage = 0;
    });
  }

  void _goToListPage(int page) {
    final pages = _totalListPages(_filteredSorted.length);
    if (page < 0 || page >= pages || page == _listPage) return;
    setState(() => _listPage = page);
  }

  void _resetListFilters() {
    setState(() {
      _searchController.clear();
      _listPage = 0;
      if (widget.drillDownView) {
        _applyDrillFiltersFromWidget();
      } else {
        _filterDepartment = null;
        _filterProgram = null;
      }
    });
  }

  void _onDepartmentFilterChanged(String? department) {
    setState(() {
      _listPage = 0;
      _filterDepartment = department;
      if (_filterProgram != null &&
          !_filterProgramOptions.contains(_filterProgram)) {
        _filterProgram = null;
      }
    });
  }

  void _onProgramFilterChanged(String? program) {
    setState(() {
      _listPage = 0;
      _filterProgram = program;
      if (program != null && program.isNotEmpty) {
        _filterDepartment ??= _departmentForProgram(program);
      }
    });
  }

  List<_DocRow> _documentsForStudent(_StudentRow student) {
    final name = student.fullName.trim().toLowerCase();
    if (name.isEmpty) return const [];
    return widget.documents
        .where((d) => d.student.trim().toLowerCase() == name)
        .toList();
  }

  int get _existingArchivedDocumentCount {
    final student = _editingStudent;
    if (student == null) return 0;
    return _documentsForStudent(student).length;
  }

  Future<void> _confirmDeleteStudent(_StudentRow student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete student?'),
        content: Text(
          'Remove ${student.fullName} (${student.studentNo})? '
          'Their archived documents will also be deleted. This cannot be undone.',
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

    final error = await widget.onDeleteStudent(student);
    if (!mounted) return;

    if (error != null) {
      _showInfo(context, error);
      return;
    }

    _showInfo(context, 'Student deleted.');
  }

  void _showStudentDetail(_StudentRow student) {
    final docs = _documentsForStudent(student);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 620),
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
                child: _StudentDetailPanel(
                  student: student,
                  documents: docs,
                  onEdit: widget.canEdit
                      ? () {
                          Navigator.of(dialogContext).pop();
                          _openEditForm(student);
                        }
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openAddForm() {
    _editingStudent = null;
    _resetForm();
    setState(() => _showForm = true);
  }

  void _openEditForm(_StudentRow student) {
    _editingStudent = student;
    _resetForm();
    _loadStudentIntoForm(student);
    setState(() => _showForm = true);
  }

  void _backToList() {
    setState(() {
      _showForm = false;
      _editingStudent = null;
      _formTab = _StudentFormTab.student;
    });
  }

  String _programCodeForSelectedCourse() {
    final course = _courseController.text.trim();
    return StudentNumber.resolveProgramCode(
      programName: course,
      courseCode: widget.programCodeForCourse?.call(course),
    );
  }

  String _suggestNextStudentNo() {
    return StudentNumber.next(
      existingStudentNumbers: widget.rows.map((r) => r.studentNo),
      programCode: _programCodeForSelectedCourse(),
      schoolYear: _schoolYearController.text.trim().isEmpty
          ? _defaultSchoolYear()
          : _schoolYearController.text.trim(),
    );
  }

  void _applySuggestedStudentNo() {
    if (_editingStudent != null || _studentNoManuallyEdited) return;
    _studentNoController.text = _suggestNextStudentNo();
  }

  void _resetForm() {
    _formTab = _StudentFormTab.student;
    _studentNoManuallyEdited = false;
    _birthDate = null;
    _enrolledAt = null;
    _graduatedAt = null;
    _documents.clear();
    for (final c in [
      _studentNoController,
      _firstNameController,
      _middleNameController,
      _lastNameController,
      _suffixController,
      _birthDateController,
      _courseController,
      _emailController,
      _phoneController,
      _notesController,
      _enrolledAtController,
      _graduatedAtController,
    ]) {
      c.clear();
    }
    final drillCourse = widget.drillCourseName?.trim() ?? '';
    final selectable = _catalogSelectablePrograms();
    _courseController.text =
        drillCourse.isNotEmpty && selectable.contains(drillCourse)
            ? drillCourse
            : (selectable.isNotEmpty ? selectable.first : '');
    _schoolYearController.text = _defaultSchoolYear();
    if (_editingStudent == null) {
      _applySuggestedStudentNo();
    }
  }

  void _loadStudentIntoForm(_StudentRow student) {
    _studentNoController.text = student.studentNo;
    _courseController.text = student.course;
    _emailController.text = student.email ?? '';

    final parts = student.fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      _firstNameController.text = parts.first;
    } else if (parts.isNotEmpty) {
      _lastNameController.text = parts.last;
      _firstNameController.text = parts.first;
      if (parts.length > 2) {
        _middleNameController.text =
            parts.sublist(1, parts.length - 1).join(' ');
      }
    }
  }

  String _composedFullName() {
    final parts = <String>[
      _firstNameController.text.trim(),
      _middleNameController.text.trim(),
      _lastNameController.text.trim(),
    ].where((p) => p.isNotEmpty);
    final base = parts.join(' ');
    final suffix = _suffixController.text.trim();
    if (suffix.isEmpty) return base;
    return '$base $suffix'.trim();
  }

  String _formatStudentDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseStudentDate(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    try {
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await MinimalDatePicker.show(
      context: context,
      helpText: 'Birth date',
      initialDate: _birthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _birthDateController.text = _formatStudentDate(picked);
    });
  }

  Future<void> _pickEnrolledAt() async {
    final now = DateTime.now();
    final picked = await MinimalDatePicker.show(
      context: context,
      helpText: 'Enrollment date',
      initialDate:
          _enrolledAt ?? _parseStudentDate(_enrolledAtController.text) ?? now,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    setState(() {
      _enrolledAt = picked;
      _enrolledAtController.text = _formatStudentDate(picked);
    });
  }

  Future<void> _pickGraduatedAt() async {
    final now = DateTime.now();
    final enrolled =
        _enrolledAt ?? _parseStudentDate(_enrolledAtController.text);
    final picked = await MinimalDatePicker.show(
      context: context,
      helpText: 'Graduation date',
      initialDate: _graduatedAt ??
          _parseStudentDate(_graduatedAtController.text) ??
          enrolled ??
          now,
      firstDate: enrolled ?? DateTime(1950),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    setState(() {
      _graduatedAt = picked;
      _graduatedAtController.text = _formatStudentDate(picked);
    });
  }

  Future<void> _pickDocumentDate(int index) async {
    final draft = _documents[index];
    final now = DateTime.now();
    final picked = await MinimalDatePicker.show(
      context: context,
      helpText: 'Document date',
      initialDate: draft.receivedAt ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    setState(() => draft.receivedAt = picked);
  }

  void _addDocument() {
    setState(() {
      _documents.add(_StudentDocumentDraft(receivedAt: DateTime.now()));
    });
  }

  void _removeDocument(int index) {
    setState(() => _documents.removeAt(index));
  }

  Future<void> _pickDocumentFile(int index) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'png',
        'jpg',
        'jpeg',
        'gif',
        'webp',
      ],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    final path = picked.path;
    if (path == null || path.isEmpty) return;

    setState(() {
      final draft = _documents[index];
      draft.filePath = path;
      draft.fileName = picked.name;
      if (draft.title.trim().isEmpty) {
        draft.title = p.basenameWithoutExtension(picked.name);
      }
    });
  }

  String _mimeTypeForPath(String path) {
    final ext = p.extension(path).toLowerCase();
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  static String _defaultSchoolYear() {
    final y = DateTime.now().year;
    return '$y-${y + 1}';
  }

  /// School years for the dropdown, newest first (e.g. 2025-2026).
  static List<String> _schoolYearOptions() {
    final current = DateTime.now().year;
    const yearsBack = 25;
    const yearsAhead = 5;
    final options = <String>[];
    for (var start = current + yearsAhead;
        start >= current - yearsBack;
        start--) {
      options.add('$start-${start + 1}');
    }
    return options;
  }

  String _documentTitle(_StudentDocumentDraft doc) {
    final title = doc.title.trim();
    if (title.isNotEmpty) return title;
    return doc.documentType;
  }

  void _showUploadSuccessActions({
    required String studentLabel,
    required int docsSaved,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        content: Row(
          children: [
            Expanded(
              child: Text(
                '$docsSaved document${docsSaved == 1 ? '' : 's'} uploaded for $studentLabel.',
                style: _studentFieldTextStyle,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                widget.onViewStudentDocuments(studentLabel);
              },
              child: const Text('View docs'),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                widget.onViewAllDocuments();
              },
              child: const Text('See all'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveStudent() async {
    var studentNo = _studentNoController.text.trim();
    final fullName = _composedFullName();
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'First name and last name are required.',
            style: _studentFieldTextStyle,
          ),
        ),
      );
      setState(() => _formTab = _StudentFormTab.student);
      return;
    }
    if (studentNo.isEmpty && _editingStudent == null) {
      studentNo = _suggestNextStudentNo();
    }
    if (studentNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Student number is required (e.g. ${StudentNumber.example}).',
            style: _studentFieldTextStyle,
          ),
        ),
      );
      setState(() => _formTab = _StudentFormTab.student);
      return;
    }

    final course = _courseController.text.trim();
    if (course.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a program on the Academic tab.',
            style: _studentFieldTextStyle,
          ),
        ),
      );
      setState(() => _formTab = _StudentFormTab.academic);
      return;
    }

    final email = _emailController.text.trim();

    final docNumberOffset = _existingArchivedDocumentCount;
    for (var i = 0; i < _documents.length; i++) {
      final doc = _documents[i];
      final docNumber = docNumberOffset + i + 1;
      final filePath = doc.filePath?.trim() ?? '';
      if (filePath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Choose a file for document #$docNumber before saving.',
              style: _studentFieldTextStyle,
            ),
          ),
        );
        setState(() => _formTab = _StudentFormTab.student);
        return;
      }
    }

    setState(() => _isSaving = true);
    final created = await widget.onRegisterStudent(
      studentNo: studentNo,
      fullName: fullName,
      course: course,
      year: 0,
      status: 'graduated',
      email: email.isEmpty ? null : email,
      schoolYear: _schoolYearController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (created == null && _editingStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save student. Is the Dart API running (server\\run_server.bat)?',
            style: _studentFieldTextStyle,
          ),
        ),
      );
      return;
    }

    final studentLabel = created?.fullName ?? fullName;
    final resolvedStudentNo = created?.studentNo ?? studentNo;
    final schoolYear = _schoolYearController.text.trim();
    var docsSaved = 0;
    var docsFailed = 0;
    for (final doc in _documents) {
      final path = doc.filePath?.trim() ?? '';
      if (path.isEmpty) continue;
      final college = _departmentForProgram(course) ??
          _resolveCatalogCollegeLabel(widget.drillCollegeName) ??
          '';
      final ok = await widget.onUploadDocument(
        title: _documentTitle(doc),
        student: studentLabel,
        sourceImagePath: path,
        mimeType: _mimeTypeForPath(path),
        studentNo: resolvedStudentNo,
        course: course,
        schoolYear: schoolYear,
        documentType: doc.documentType,
        isComplete: doc.receivedAt != null,
        college: college,
        studentCategory: 'Graduated',
      );
      if (ok) {
        docsSaved++;
      } else {
        docsFailed++;
      }
    }

    if (!mounted) return;

    if (docsFailed > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Student saved. $docsSaved document(s) uploaded, $docsFailed failed.',
            style: _studentFieldTextStyle,
          ),
        ),
      );
    } else if (docsSaved > 0) {
      _showUploadSuccessActions(
        studentLabel: studentLabel,
        docsSaved: docsSaved,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingStudent == null
                ? 'Student $studentLabel saved.'
                : 'Student record updated.',
            style: _studentFieldTextStyle,
          ),
        ),
      );
    }
    _backToList();
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return _buildFormView();
    }
    return _buildListView();
  }

  Widget _buildListView() {
    final filtered = _filteredSorted;
    final listPage = _safeListPage(filtered.length);
    final pageRows = _pageSlice(filtered, listPage);
    final showEmpty = filtered.isEmpty;
    final inDrill =
        widget.drillCourseName != null && widget.drillCourseName!.isNotEmpty;
    final breadcrumbs = inDrill
        ? [
            'Records',
            if (widget.drillFromProgramsList) 'Programs',
            if (widget.drillCollegeName != null &&
                widget.drillCollegeName!.isNotEmpty)
              widget.drillCollegeName!,
            widget.drillCourseName!,
            'Students',
          ]
        : const ['Records', 'Students'];
    final total = widget.rows.length;
    final countLabel = filtered.length == total
        ? (filtered.length == 1 ? '1 student' : '$total students')
        : '${filtered.length} of $total students';

    return Theme(
      data: _studentDetailDialogTheme,
      child: CallbackShortcuts(
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
                onBack: inDrill ? widget.onDrillBack : null,
                backTooltip: inDrill ? 'Back to programs' : null,
                title: 'Students',
                subtitle: inDrill
                    ? 'Graduated students in ${widget.drillCourseName}.'
                    : 'Search and manage graduated student records.',
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
                        onChanged: (_) => setState(() => _listPage = 0),
                        hintText: 'Search by name, ID, or email…',
                        focusColor: const Color(0xFF2563EB),
                      ),
                      trailing: [
                        if (!showEmpty)
                          _RecordCountBadge(
                            icon: Icons.people_outline,
                            label: countLabel,
                            accentColor: const Color(0xFF2563EB),
                          ),
                        if (widget.canEdit && !widget.drillDownView)
                          _RecordPrimaryButton(
                            label: 'Add student',
                            onPressed: _openAddForm,
                            color: const Color(0xFF2563EB),
                          ),
                      ],
                    ),
                    if (!widget.drillDownView) ...[
                      const Divider(height: 1, color: _RecordListTheme.border),
                      _StudentDepartmentProgramFilterBar(
                        department: _filterDepartment,
                        program: _filterProgram,
                        departments: _catalogDepartments(),
                        programs: _filterProgramOptions,
                        onDepartmentChanged: _onDepartmentFilterChanged,
                        onProgramChanged: _onProgramFilterChanged,
                        onClear: _hasActiveFilters ? _resetListFilters : null,
                      ),
                      if (_hasActiveFilters)
                        _StudentActiveFilterSummary(
                          department: _filterDepartment,
                          program: _filterProgram,
                          searchQuery: _searchController.text.trim(),
                          resultCount: filtered.length,
                          totalCount: total,
                        ),
                    ],
                    const Divider(height: 1, color: _RecordListTheme.border),
                    if (showEmpty)
                      _CollegesEmptyState(
                        canEdit: widget.canEdit,
                        hasSearchFilter: _hasActiveFilters,
                        onAdd: _openAddForm,
                        addButtonLabel: 'Add student',
                        addButtonColor: const Color(0xFF2563EB),
                        addButtonForegroundColor: Colors.white,
                        onResetFilters: _resetListFilters,
                      )
                    else
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8FAFC),
                                border: Border(
                                  bottom:
                                      BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _StudentSortableHeaderCell(
                                    flex: 2,
                                    label: 'Student No.',
                                    column: _StudentListSortColumn.studentNo,
                                    activeColumn: _sortColumn,
                                    ascending: _sortAscending,
                                    onSort: _onSortColumn,
                                  ),
                                  _StudentSortableHeaderCell(
                                    flex: 3,
                                    label: 'Name',
                                    column: _StudentListSortColumn.name,
                                    activeColumn: _sortColumn,
                                    ascending: _sortAscending,
                                    onSort: _onSortColumn,
                                  ),
                                  _StudentSortableHeaderCell(
                                    flex: 3,
                                    label: 'Program',
                                    column: _StudentListSortColumn.program,
                                    activeColumn: _sortColumn,
                                    ascending: _sortAscending,
                                    onSort: _onSortColumn,
                                  ),
                                  const _StudentHeaderCell(
                                    flex: 2,
                                    label: 'Actions',
                                    alignEnd: true,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: pageRows.length,
                                itemBuilder: (context, index) {
                                  final s = pageRows[index];
                                  return _StudentDataRow(
                                    student: s,
                                    striped: index.isOdd,
                                    canEdit: widget.canEdit,
                                    isAdmin: widget.isAdmin,
                                    onTap: () => _showStudentDetail(s),
                                    onEdit: () => _openEditForm(s),
                                    onDelete: () => _confirmDeleteStudent(s),
                                  );
                                },
                              ),
                            ),
                            _StudentListPaginationBar(
                              currentPage: listPage,
                              totalPages: _totalListPages(filtered.length),
                              totalItems: filtered.length,
                              pageSize: _studentsPageSize,
                              onPageChanged: _goToListPage,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildFormView() {
    return Theme(
      data: _studentDetailDialogTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StudentsFormTopBar(
            onBack: _backToList,
            canEdit: widget.canEdit,
            onAdd: widget.canEdit ? _openAddForm : null,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StudentFormTabBar(
                    tab: _formTab,
                    onChanged: (t) => setState(() => _formTab = t),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _buildActiveFormTab(),
                            ),
                          ),
                          if (_formTab == _StudentFormTab.student) ...[
                            const Divider(
                              height: 1,
                              color: Color(0xFFE5E7EB),
                            ),
                            _StudentDocumentsSection(
                              documents: _documents,
                              existingDocumentCount:
                                  _existingArchivedDocumentCount,
                              onAdd: _addDocument,
                              onRemove: _removeDocument,
                              onPickDate: _pickDocumentDate,
                              onPickFile: _pickDocumentFile,
                              documentTypes: _documentTypes,
                              onDocumentChanged: () => setState(() {}),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            child: Row(
                              children: [
                                FilledButton(
                                  onPressed: _isSaving ? null : _saveStudent,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _collegeTealDark,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(_editingStudent == null
                                          ? 'Save student'
                                          : 'Update student'),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton(
                                  onPressed: _isSaving ? null : _backToList,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _studentTextBlack,
                                    side: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFormTab() {
    switch (_formTab) {
      case _StudentFormTab.student:
        return _buildStudentTab(key: const ValueKey('student'));
      case _StudentFormTab.academic:
        return _buildAcademicTab(key: const ValueKey('academic'));
      case _StudentFormTab.contact:
        return _buildContactTab(key: const ValueKey('contact'));
      case _StudentFormTab.notes:
        return _buildNotesTab(key: const ValueKey('notes'));
      case _StudentFormTab.dates:
        return _buildDatesTab(key: const ValueKey('dates'));
    }
  }

  Widget _buildStudentTab({required Key key}) {
    return Column(
      key: key,
      children: [
        _StudentLabeledField(
          label: 'Student number',
          required: true,
          child: _StudentTextField(
            controller: _studentNoController,
            hint: StudentNumber.example,
            inputFormatters: [_StudentNumberInputFormatter()],
            onChanged: (_) {
              if (!_studentNoManuallyEdited) {
                _studentNoManuallyEdited = true;
              }
            },
          ),
        ),
        _StudentLabeledField(
          label: 'First name',
          required: true,
          child: _StudentTextField(controller: _firstNameController),
        ),
        _StudentLabeledField(
          label: 'Middle name',
          child: _StudentTextField(controller: _middleNameController),
        ),
        _StudentLabeledField(
          label: 'Last name',
          required: true,
          child: _StudentTextField(controller: _lastNameController),
        ),
        _StudentLabeledField(
          label: 'Suffix',
          child: _StudentTextField(controller: _suffixController),
        ),
        _StudentLabeledField(
          label: 'Birth date',
          child: _StudentDateField(
            controller: _birthDateController,
            showWarning: _birthDate == null,
            onPick: _pickBirthDate,
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicTab({required Key key}) {
    final selectable = _catalogSelectablePrograms();
    final programValue = _resolvedProgramDropdownValue(
      _courseController.text,
      selectable,
    );
    return Column(
      key: key,
      children: [
        _StudentLabeledField(
          label: 'Program',
          required: true,
          child: selectable.isEmpty
              ? _StudentTextField(controller: _courseController)
              : DropdownButtonFormField<String>(
                  value: programValue,
                  style: _studentInputTextStyle,
                  dropdownColor: Colors.white,
                  isExpanded: true,
                  decoration: _studentInputDecoration(),
                  items: _programDropdownItems(selectablePrograms: selectable),
                  onChanged: (v) {
                    if (v == null || v.startsWith('\u0000header:')) return;
                    setState(() {
                      _courseController.text = v;
                      _applySuggestedStudentNo();
                    });
                  },
                ),
        ),
        _StudentLabeledField(
          label: 'School year',
          required: true,
          child: DropdownButtonFormField<String>(
            value: _schoolYearOptions().contains(_schoolYearController.text)
                ? _schoolYearController.text
                : _defaultSchoolYear(),
            style: _studentInputTextStyle,
            dropdownColor: Colors.white,
            isExpanded: true,
            decoration: _studentInputDecoration(),
            items: _schoolYearOptions()
                .map(
                  (y) => DropdownMenuItem(
                    value: y,
                    child: Text(y, style: _studentInputTextStyle),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _schoolYearController.text = v;
                _applySuggestedStudentNo();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactTab({required Key key}) {
    return Column(
      key: key,
      children: [
        _StudentLabeledField(
          label: 'Email',
          child: _StudentTextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        _StudentLabeledField(
          label: 'Phone',
          child: _StudentTextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesTab({required Key key}) {
    return Column(
      key: key,
      children: [
        _StudentLabeledField(
          label: 'Notes',
          child: TextField(
            controller: _notesController,
            maxLines: 6,
            style: _studentInputTextStyle,
            decoration: _studentInputDecoration(),
          ),
        ),
      ],
    );
  }

  Widget _buildDatesTab({required Key key}) {
    return Column(
      key: key,
      children: [
        _StudentLabeledField(
          label: 'Enrolled at',
          child: _StudentDateField(
            controller: _enrolledAtController,
            showWarning: false,
            onPick: _pickEnrolledAt,
          ),
        ),
        _StudentLabeledField(
          label: 'Graduated at',
          child: _StudentDateField(
            controller: _graduatedAtController,
            showWarning: false,
            onPick: _pickGraduatedAt,
          ),
        ),
      ],
    );
  }
}

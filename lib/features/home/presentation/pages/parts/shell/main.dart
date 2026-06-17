part of '../../dashboard_shell_page.dart';

class DashboardShellPage extends StatefulWidget {
  const DashboardShellPage({
    super.key,
    required this.role,
    required this.loginUseCase,
    required this.accountName,
  });

  final UserRole role;
  final LoginUseCase loginUseCase;
  final String accountName;

  @override
  State<DashboardShellPage> createState() => _DashboardShellPageState();
}

class _DashboardShellPageState extends State<DashboardShellPage> {
  final _database = AppDatabase.instance;
  final _dashboardSearchController = TextEditingController();
  String _dashboardSearchQuery = '';
  bool _collapsed = false;
  String _selectedNavId = 'dashboard';
  final Set<String> _collapsedSections = {
    'Dashboard',
    'Student Records',
    'Settings',
    'Accounts',
    'System',
  };
  late final bool _isAdmin;
  // Use a white/light theme for all roles.
  bool get _isDarkAdmin => false;

  final List<_StudentRow> _students = [];
  bool _isLoadingStudents = true;
  String? _studentsLoadError;
  final List<_DocRow> _docs = [];
  bool _isLoadingDocs = true;
  String? _docsLoadError;
  String? _archivedStudentFilter;
  final List<_CollegeRow> _colleges = [];
  bool _isLoadingColleges = true;
  String? _collegesLoadError;
  final List<_CourseRow> _courses = [];
  bool _isLoadingCourses = true;
  String? _coursesLoadError;
  int? _drillCollegeId;
  String? _drillCollegeName;
  int? _drillCourseId;
  String? _drillCourseName;
  String? _analyticsGraduatesYear;
  String? _analyticsGraduatesProgramName;
  String? _analyticsGraduatesProgramCode;
  int _dataAnalyticsSession = 0;
  Map<String, int> _studentCountByCourseName = {};
  Map<int, int> _courseCountByCollegeId = {};
  final List<_AuditRow> _audit = [];
  bool _isLoadingAudit = false;

  Timer? _dashboardSearchDebounce;
  _DashboardPrepared? _cachedDashboardPrepared;
  String? _dashboardPreparedKey;
  int _dashboardDataGeneration = 0;
  bool _dashboardShellDataReady = false;
  bool _dashboardPriorityReady = false;
  bool _dashboardSecondaryReady = false;
  bool _dashboardAnalyticsReady = false;
  _AnalyticsData? _cachedDashboardAnalytics;
  _AnalyticsData? _cachedFullAnalytics;
  int _fullAnalyticsCacheGeneration = -1;
  bool _fullAnalyticsLoading = false;
  Widget? _complianceHubPage;
  final Map<String, List<_AnalyticsGraduate>> _graduatesByYearCache = {};
  final Map<String, List<_CourseCount>> _courseCountsByYearCache = {};
  late final List<_SidebarNavSection> _navSections;

  static const _dashboardSchoolYearsLimit = 5;

  @override
  void dispose() {
    _dashboardSearchDebounce?.cancel();
    _dashboardSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.role == UserRole.admin;
    _database.userRole = _isAdmin ? 'admin' : 'staff';
    _database.userName = widget.accountName;
    _navSections = _createNavSections();
    _expandSectionForNavId(_selectedNavId);
    _loadDashboardPriorityData();
    _loadSecondaryShellData();
    _loadAuditLogs();
  }

  bool get _isDashboardLoading =>
      _selectedNavId == 'dashboard' && !_dashboardShellDataReady;

  void _syncDashboardShellReady() {
    final ready = _dashboardPriorityReady && _dashboardSecondaryReady;
    if (_dashboardShellDataReady == ready &&
        (!ready || !_isAdmin || _dashboardAnalyticsReady)) {
      return;
    }
    _dashboardShellDataReady = ready;
    if (ready && _isAdmin && !_dashboardAnalyticsReady) {
      _dashboardAnalyticsReady = true;
      _refreshDashboardPrepared(withAnalytics: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkAdmin ? _adminBg : const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Row(
          children: [
            _DashboardSidebar(
              isDarkAdmin: _isDarkAdmin,
              collapsed: _collapsed,
              sections: _navSections,
              collapsedSections: _collapsedSections,
              selectedId: _selectedNavId,
              onToggleCollapse: _toggleSidebar,
              onSectionToggle: _toggleSectionCollapsed,
              onLogout: _logout,
              onItemSelected: (id) {
                if (id == _selectedNavId &&
                    id != 'data_analytics' &&
                    _analyticsGraduatesYear == null) {
                  return;
                }
                final fromNavId = _selectedNavId;
                setState(() {
                  _selectedNavId = id;
                  _expandSectionForNavId(id);
                  if (id != 'data_analytics') {
                    _analyticsGraduatesYear = null;
                    _analyticsGraduatesProgramName = null;
                    _analyticsGraduatesProgramCode = null;
                  }
                  if (id != 'colleges' && id != 'courses') {
                    _resetRecordsDrill();
                  } else if (id == 'colleges') {
                    // Always return to the colleges list (sidebar re-click included).
                    _resetRecordsDrill();
                  } else if (id == 'courses') {
                    if (fromNavId != 'courses') {
                      _resetRecordsDrill();
                    } else {
                      // Re-select Programs: leave student drill, keep top-level list.
                      _drillCourseId = null;
                      _drillCourseName = null;
                    }
                  }
                });
                if (id == 'dashboard') {
                  _scheduleDashboardAnalyticsReveal();
                }
                if (id == 'archived_documents') {
                  _loadDocuments(showLoading: _docs.isEmpty);
                }
                if (id == 'colleges' || id == 'settings_colleges') {
                  _loadColleges(showLoading: _colleges.isEmpty);
                }
                if (id == 'courses') {
                  _loadCourses(showLoading: _courses.isEmpty);
                }
                if (id == 'activity_log') {
                  _loadAuditLogs();
                }
                if (id == 'data_analytics') {
                  _openDataAnalytics();
                }
              },
            ),
            Expanded(
              child: _selectedNavId == 'dashboard'
                    ? SizedBox.expand(
                        key: const ValueKey<String>('dashboard'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              color: _isDarkAdmin
                                  ? _adminBg
                                  : const Color(0xFFF4F6F8),
                              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                              child: _isDashboardLoading
                                  ? const _DashboardHeaderSkeleton()
                                  : _DashboardTopHeader(
                                      accountName: widget.accountName,
                                      searchController:
                                          _dashboardSearchController,
                                      onSearchChanged:
                                          _onDashboardSearchChanged,
                                    ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  8,
                                  24,
                                  20,
                                ),
                                child: _buildContent(includeHeader: false),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _selectedNavId == 'data_analytics' &&
                            _analyticsGraduatesYear == null
                        ? Padding(
                            key: const ValueKey<String>('data_analytics'),
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                            child: _buildDataAnalyticsViewport(),
                          )
                        : _contentFillsViewport(_selectedNavId)
                            ? Padding(
                                key: ValueKey<String>(_selectedNavId),
                                padding:
                                    const EdgeInsets.fromLTRB(24, 20, 24, 24),
                                child: _buildContent(),
                              )
                            : SingleChildScrollView(
                                key: ValueKey<String>(
                                  _analyticsGraduatesYear != null
                                      ? 'data_analytics_graduates'
                                      : _selectedNavId,
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  24,
                                  _analyticsGraduatesYear != null ? 8 : 20,
                                  24,
                                  24,
                                ),
                                child: _buildContent(),
                              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(loginUseCase: widget.loginUseCase),
      ),
      (_) => false,
    );
  }

  List<_SidebarNavSection> _createNavSections() {
    final sections = <_SidebarNavSection>[
      _SidebarNavSection(
        title: 'Dashboard',
        items: [
          _SidebarNavItem(
            id: 'dashboard',
            title: 'Overall Dashboard',
            icon: Icons.space_dashboard_outlined,
          ),
          _SidebarNavItem(
            id: 'data_analytics',
            title: 'Data Analytics',
            icon: Icons.query_stats_outlined,
          ),
          _SidebarNavItem(
            id: 'compliance_hub',
            title: 'Compliance Hub',
            icon: Icons.verified_user_outlined,
          ),
        ],
      ),
      _SidebarNavSection(
        title: 'Student Records',
        items: [
          _SidebarNavItem(
            id: 'colleges',
            title: 'Colleges',
            icon: Icons.account_balance_outlined,
          ),
          _SidebarNavItem(
            id: 'courses',
            title: 'Programs',
            icon: Icons.auto_stories_outlined,
          ),
          _SidebarNavItem(
            id: 'students',
            title: 'Students',
            icon: Icons.groups_outlined,
          ),
          _SidebarNavItem(
            id: 'archived_documents',
            title: 'Trash',
            icon: Icons.delete_outline,
          ),
        ],
      ),
    ];
    if (_isAdmin) {
      sections.addAll([
        _SidebarNavSection(
          title: 'Accounts',
          items: [
            _SidebarNavItem(
              id: 'users',
              title: 'Users',
              icon: Icons.manage_accounts_outlined,
            ),
          ],
        ),
        _SidebarNavSection(
          title: 'System',
          items: [
            _SidebarNavItem(
              id: 'activity_log',
              title: 'Activity Log',
              icon: Icons.history_toggle_off_outlined,
            ),
          ],
        ),
        _SidebarNavSection(
          title: 'Settings',
          items: [
            _SidebarNavItem(
              id: 'settings_colleges',
              title: 'Manage Colleges',
              icon: Icons.domain_outlined,
            ),
          ],
        ),
      ]);
    }
    return sections;
  }

  String get _selectedNavTitle {
    for (final section in _navSections) {
      for (final item in section.items) {
        if (item.id == _selectedNavId) return item.title;
      }
    }
    return 'Overall Dashboard';
  }

  Widget _buildDataAnalyticsMainPage() {
    if (_cachedFullAnalytics == null) {
      _ensureFullAnalytics();
      return const _AnalyticsLoadingSkeleton(
        pinnedHeader: true,
      );
    }
    return _DataAnalyticsPage(
      key: ValueKey<int>(_dataAnalyticsSession),
      data: _cachedFullAnalytics!,
      courseCountsForYear: _courseCountsForYear,
      onViewYearGraduates: _viewAnalyticsGraduates,
      allGraduates: _allAnalyticsGraduates,
      onSelectGraduate: _openAnalyticsGraduate,
      pinnedHeader: true,
    );
  }

  Widget _buildDataAnalyticsViewport() {
    return SizedBox.expand(child: _buildDataAnalyticsMainPage());
  }

  Widget _buildContent({bool includeHeader = true}) {
    if (_selectedNavId == 'dashboard') {
      if (!_dashboardShellDataReady) {
        return const _DashboardLoadingSkeleton();
      }

      if (_cachedDashboardPrepared == null) {
        _refreshDashboardPrepared();
      }
      final prepared = _cachedDashboardPrepared;
      if (prepared == null) {
        return const _DashboardLoadingSkeleton();
      }

      final segments = prepared.segments;
      final base = _DashboardBaseData(
        accountName: widget.accountName,
        studentsCount: _students.length,
        documentsCount: _docs.length,
        coursesCount: _courses.length,
        collegesCount: _colleges.length,
        recentUploadsCount: _docs.length,
        studentsWithoutDocs: prepared.studentsWithoutDocs,
        topProgramName: segments.isEmpty ? null : segments.first.label,
        topProgramCount: segments.isEmpty ? 0 : segments.first.count,
        courseSegments: segments,
        recentDocs: prepared.filteredRecentDocs,
        recentAudit: _audit.take(3).toList(),
        searchController: _dashboardSearchController,
        onSearchChanged: _onDashboardSearchChanged,
        onNavigate: widget.role == UserRole.admin
            ? (id) {
                setState(() {
                  _selectedNavId = id;
                  _expandSectionForNavId(id);
                  if (id != 'colleges' && id != 'courses') {
                    _resetRecordsDrill();
                  }
                  if (id == 'data_analytics') {
                    _analyticsGraduatesYear = null;
                    _analyticsGraduatesProgramName = null;
                    _analyticsGraduatesProgramCode = null;
                    _dataAnalyticsSession++;
                  }
                });
                if (id == 'data_analytics') {
                  _ensureFullAnalytics();
                }
              }
            : null,
        onViewStudentDocuments: widget.role == UserRole.admin
            ? _openArchivedDocumentsForStudent
            : null,
        analytics: prepared.analytics,
        showAnalyticsCharts: _dashboardAnalyticsReady,
      );

      if (_studentsLoadError != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Text(
                _studentsLoadError!,
                style: const TextStyle(color: Color(0xFF9A3412), fontSize: 12),
              ),
            ),
            Expanded(
              child: widget.role == UserRole.admin
                  ? _AdminDashboardPage(data: base, includeHeader: includeHeader)
                  : _StaffDashboardPage(data: base, includeHeader: includeHeader),
            ),
          ],
        );
      }

      return widget.role == UserRole.admin
          ? _AdminDashboardPage(data: base, includeHeader: includeHeader)
          : _StaffDashboardPage(data: base, includeHeader: includeHeader);
    }
    if (_selectedNavId == 'colleges') {
      if (_drillCourseId != null && _drillCourseName != null) {
        final courseStudents =
            _students.where((s) => s.course == _drillCourseName).toList();
        return _StudentRecordsPage(
          rows: courseStudents,
          documents: _docs,
          courseOptions: _courses.map((course) => course.name).toList(),
          programCodeForCourse: _programCodeForCourse,
          onRegisterStudent: _registerStudent,
          onUploadDocument: _uploadStudentDocument,
          onViewStudentDocuments: _openArchivedDocumentsForStudent,
          onViewAllDocuments: _openArchivedDocuments,
          onDeleteStudent: _deleteStudent,
          canEdit: true,
          isAdmin: _isAdmin,
          drillCollegeName: _drillCollegeName,
          drillCourseName: _drillCourseName,
          onDrillBack: _backToCollegeCourses,
          drillDownView: true,
        );
      }
      if (_drillCollegeId != null) {
        final collegeCourses =
            _courses.where((c) => c.collegeId == _drillCollegeId).toList();
        return _CoursesPage(
          rows: collegeCourses,
          canEdit: true,
          canAdd: true,
          isLoading: _isLoadingCourses,
          loadError: _coursesLoadError,
          onRefresh: () => _loadCourses(),
          onAddCourse: ({required String name}) =>
              _addCourse(name: name, collegeId: _drillCollegeId),
          onUpdateCourse: _updateCourse,
          onDeleteCourse: _deleteCourse,
          collegeName: _drillCollegeName,
          onBack: _backToColleges,
          onCourseSelected: _openCourseStudents,
          studentCountByName: _studentCountByCourseName,
        );
      }
      return _CollegesPage(
        rows: _colleges,
        canEdit: false,
        isLoading: _isLoadingColleges,
        loadError: _collegesLoadError,
        onRefresh: () => _loadColleges(),
        onAddCollege: _addCollege,
        onUpdateCollege: _updateCollege,
        onDeleteCollege: _deleteCollege,
        onCollegeSelected: _openCollegeCourses,
        courseCountByCollegeId: _courseCountByCollegeId,
      );
    }
    if (_selectedNavId == 'students') {
      return _StudentRecordsPage(
        rows: _students,
        documents: _docs,
        courseOptions: _courses.map((course) => course.name).toList(),
        programCodeForCourse: _programCodeForCourse,
        onRegisterStudent: _registerStudent,
        onUploadDocument: _uploadStudentDocument,
        onViewStudentDocuments: _openArchivedDocumentsForStudent,
        onViewAllDocuments: _openArchivedDocuments,
        onDeleteStudent: _deleteStudent,
        canEdit: true,
        isAdmin: _isAdmin,
      );
    }
    if (_selectedNavId == 'courses') {
      if (_drillCourseId != null && _drillCourseName != null) {
        final courseStudents =
            _students.where((s) => s.course == _drillCourseName).toList();
        return _StudentRecordsPage(
          rows: courseStudents,
          documents: _docs,
          courseOptions: _courses.map((course) => course.name).toList(),
          programCodeForCourse: _programCodeForCourse,
          onRegisterStudent: _registerStudent,
          onUploadDocument: _uploadStudentDocument,
          onViewStudentDocuments: _openArchivedDocumentsForStudent,
          onViewAllDocuments: _openArchivedDocuments,
          onDeleteStudent: _deleteStudent,
          canEdit: true,
          isAdmin: _isAdmin,
          drillCourseName: _drillCourseName,
          drillFromProgramsList: true,
          onDrillBack: _backToPrograms,
          drillDownView: true,
        );
      }
      return _CoursesPage(
        rows: _courses,
        canEdit: true,
        canAdd: false,
        isLoading: _isLoadingCourses,
        loadError: _coursesLoadError,
        onRefresh: () => _loadCourses(),
        onAddCourse: _addCourse,
        onUpdateCourse: _updateCourse,
        onDeleteCourse: _deleteCourse,
        onCourseSelected: _openCourseStudents,
        studentCountByName: _studentCountByCourseName,
      );
    }
    if (_selectedNavId == 'archived_documents') {
      return _DocumentArchivePage(
        rows: _docs,
        isAdmin: _isAdmin,
        isLoading: _isLoadingDocs,
        loadError: _docsLoadError,
        studentFilter: _archivedStudentFilter,
        onStudentFilterChanged: (student) {
          setState(() => _archivedStudentFilter = student);
        },
        onRefreshRequested: () => _loadDocuments(),
        onDeleteDoc: _deleteDocument,
        onDeleteDocs: _deleteDocuments,
      );
    }
    if (_selectedNavId == 'users') {
      return _UserManagementPage(isAdmin: _isAdmin);
    }
    if (_selectedNavId == 'activity_log') {
      return _AuditLogPage(rows: _audit);
    }
    if (_selectedNavId == 'compliance_hub') {
      _complianceHubPage ??= _ComplianceHubPage(
        isAdmin: _isAdmin,
        accountName: widget.accountName,
        initialTab: 0,
      );
      return _complianceHubPage!;
    }
    if (_selectedNavId == 'data_analytics') {
      if (_analyticsGraduatesYear != null) {
        final year = _analyticsGraduatesYear!;
        return _YearGraduatesViewPage(
          year: year,
          graduates: _graduatesForYear(
            year,
            programName: _analyticsGraduatesProgramName,
            programCode: _analyticsGraduatesProgramCode,
          ),
          programName: _analyticsGraduatesProgramName,
          programCode: _analyticsGraduatesProgramCode,
          onBack: _backFromAnalyticsGraduates,
          onBreadcrumbTap: _onAnalyticsBreadcrumbTap,
        );
      }
      return _buildDataAnalyticsMainPage();
    }
    if (_selectedNavId == 'settings_colleges') {
      return _SettingsCollegesPage(
        rows: _colleges,
        isLoading: _isLoadingColleges,
        loadError: _collegesLoadError,
        onRefresh: () => _loadColleges(),
        onAddCollege: _addCollege,
        onDeleteCollege: _deleteCollege,
        courseCountByCollegeId: _courseCountByCollegeId,
      );
    }
    return _TemplatePagePlaceholder(
      title: _selectedNavTitle,
      subtitle: 'This page is ready for feature details.',
    );
  }

  void _toggleSidebar() {
    setState(() {
      _collapsed = !_collapsed;
    });
  }

  void _toggleSectionCollapsed(String title) {
    setState(() {
      if (_collapsedSections.contains(title)) {
        _collapsedSections.remove(title);
      } else {
        _collapsedSections.add(title);
      }
    });
  }

  void _expandSectionForNavId(String id) {
    for (final section in _navSections) {
      if (section.items.any((item) => item.id == id)) {
        _collapsedSections.remove(section.title);
        return;
      }
    }
  }

  void _resetRecordsDrill() {
    _drillCollegeId = null;
    _drillCollegeName = null;
    _drillCourseId = null;
    _drillCourseName = null;
  }

  void _openCollegeCourses(_CollegeRow college) {
    if (college.id == null) return;
    setState(() {
      _drillCollegeId = college.id;
      _drillCollegeName = college.name;
      _drillCourseId = null;
      _drillCourseName = null;
    });
    _loadCourses(showLoading: _courses.isEmpty);
  }

  void _openCourseStudents(_CourseRow course) {
    setState(() {
      _drillCourseId = course.id;
      _drillCourseName = course.name;
    });
  }

  void _backToColleges() {
    setState(_resetRecordsDrill);
  }

  void _backToCollegeCourses() {
    setState(() {
      _drillCourseId = null;
      _drillCourseName = null;
    });
  }

  void _backToPrograms() {
    setState(() {
      _drillCourseId = null;
      _drillCourseName = null;
    });
  }

  void _openDataAnalytics() {
    setState(() {
      _analyticsGraduatesYear = null;
      _analyticsGraduatesProgramName = null;
      _analyticsGraduatesProgramCode = null;
      _dataAnalyticsSession++;
    });
    _ensureFullAnalytics();
  }

  void _viewAnalyticsGraduates(
    String year, {
    String? programName,
    String? programCode,
  }) {
    setState(() {
      _analyticsGraduatesYear = year;
      _analyticsGraduatesProgramName = programName?.trim().isEmpty == true
          ? null
          : programName?.trim();
      _analyticsGraduatesProgramCode = programCode?.trim().isEmpty == true
          ? null
          : programCode?.trim();
    });
  }

  void _backFromAnalyticsGraduates() {
    setState(() {
      final hasProgramScope =
          (_analyticsGraduatesProgramName?.trim().isNotEmpty ?? false) ||
              (_analyticsGraduatesProgramCode?.trim().isNotEmpty ?? false);
      if (hasProgramScope) {
        _analyticsGraduatesProgramName = null;
        _analyticsGraduatesProgramCode = null;
        return;
      }
      _analyticsGraduatesYear = null;
    });
  }

  void _onAnalyticsBreadcrumbTap(int index) {
    if (index == 0) {
      _openDataAnalytics();
      return;
    }
    if (index == 1) {
      setState(() {
        _analyticsGraduatesProgramName = null;
        _analyticsGraduatesProgramCode = null;
      });
    }
  }

  List<_AnalyticsGraduate> _allAnalyticsGraduates() {
    final list = _students
        .map(
          (student) => _AnalyticsGraduate(
            studentNo: student.studentNo,
            fullName: student.fullName,
            course: student.course,
            programLabel: _programChartLabel(student.course),
            schoolYear: _schoolYearFromStudentNo(student.studentNo),
          ),
        )
        .toList()
      ..sort(
        (a, b) =>
            a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
      );
    return list;
  }

  void _openAnalyticsGraduate(_AnalyticsGraduate graduate) {
    final year = graduate.schoolYear.trim().isNotEmpty
        ? graduate.schoolYear
        : _schoolYearFromStudentNo(graduate.studentNo);
    if (year.isEmpty) {
      _viewAnalyticsGraduates(
        _currentSchoolYear(),
        programName: graduate.course,
        programCode: graduate.programLabel,
      );
      return;
    }
    _viewAnalyticsGraduates(
      year,
      programName: graduate.course,
      programCode: graduate.programLabel,
    );
  }

  void _goToDashboard() {
    setState(() {
      _selectedNavId = 'dashboard';
      _expandSectionForNavId('dashboard');
    });
    _scheduleDashboardAnalyticsReveal();
  }

  bool _contentFillsViewport(String navId) {
    switch (navId) {
      case 'colleges':
      case 'courses':
      case 'students':
      case 'archived_documents':
      case 'settings_colleges':
      case 'users':
      case 'activity_log':
      case 'compliance_hub':
        return true;
      default:
        return false;
    }
  }

  void _rebuildAggregateCounts() {
    final studentCounts = <String, int>{};
    for (final student in _students) {
      final course = student.course.trim();
      if (course.isEmpty) continue;
      studentCounts[course] = (studentCounts[course] ?? 0) + 1;
    }
    final courseCounts = <int, int>{};
    for (final course in _courses) {
      final collegeId = course.collegeId;
      if (collegeId == null) continue;
      courseCounts[collegeId] = (courseCounts[collegeId] ?? 0) + 1;
    }
    _studentCountByCourseName = studentCounts;
    _courseCountByCollegeId = courseCounts;
  }

  void _openArchivedDocuments({String? studentFilter}) {
    setState(() {
      _archivedStudentFilter = studentFilter;
      _selectedNavId = 'archived_documents';
    });
    _expandSectionForNavId('archived_documents');
    _loadDocuments(showLoading: _docs.isEmpty);
  }

  void _openArchivedDocumentsForStudent(String student) {
    final name = student.trim();
    if (name.isEmpty) return;
    _openArchivedDocuments(studentFilter: name);
  }

  Future<void> _loadAuditLogs() async {
    if (mounted) {
      setState(() => _isLoadingAudit = true);
    }
    try {
      final results = await _database.fetchAuditLogs(limit: 100);
      final rows = results.map((row) {
        final created = (row['created_at'] ?? '').toString();
        final datePart = created.contains('T')
            ? created.split('T').first
            : created.split(' ').first;
        return _AuditRow(
          actor: (row['actor'] ?? 'system').toString(),
          action: (row['action'] ?? '').toString(),
          date: datePart,
        );
      }).toList();
      if (!mounted) return;
      setState(() {
        _audit
          ..clear()
          ..addAll(rows);
        _isLoadingAudit = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingAudit = false);
    }
  }

  Future<void> _loadDocuments({bool showLoading = true}) async {
    if (mounted && showLoading) {
      setState(() {
        _isLoadingDocs = true;
        _docsLoadError = null;
      });
    }
    try {
      final results = await _database.fetchDocuments();
      final rows = results.map(_docRowFromMap).toList();

      if (!mounted) return;
      _docs
        ..clear()
        ..addAll(rows);
      _isLoadingDocs = false;
      _docsLoadError = null;
      _markDashboardDataDirty();
      _refreshDashboardPrepared();
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingDocs = false;
        _docsLoadError =
            'Could not load documents. Run server\\run_server.bat to start the API.';
      });
    }
  }

  Future<void> _loadColleges({bool showLoading = true}) async {
    if (mounted && showLoading) {
      setState(() {
        _isLoadingColleges = true;
        _collegesLoadError = null;
      });
    }
    try {
      final results = await _database.fetchColleges();
      final rows = results.map(_collegeRowFromMap).toList();

      if (!mounted) return;
      setState(() {
        _colleges
          ..clear()
          ..addAll(rows);
        _isLoadingColleges = false;
        _collegesLoadError = null;
        _rebuildAggregateCounts();
        _markDashboardDataDirty();
        _refreshDashboardPrepared();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingColleges = false;
        _collegesLoadError =
            'Could not load colleges. Run server\\run_server.bat to start the API.';
      });
    }
  }

  Future<String?> _addCollege({required String name}) async {
    try {
      final row = await _database.insertCollege(name: name);
      final created = _collegeRowFromMap(row);
      if (mounted) {
        setState(() {
          _colleges.add(created);
          _colleges.sort((a, b) => a.name.compareTo(b.name));
        });
      }
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Bad state: ', '');
    }
  }

  Future<String?> _updateCollege({
    required _CollegeRow college,
    required String name,
  }) async {
    if (college.id == null) return 'College id is missing.';
    try {
      final row = await _database.updateCollege(
        id: college.id!,
        name: name,
      );
      final updated = _collegeRowFromMap(row);
      if (mounted) {
        setState(() {
          final index = _colleges.indexWhere((c) => c.id == college.id);
          if (index >= 0) {
            _colleges[index] = updated;
            _colleges.sort((a, b) => a.name.compareTo(b.name));
          }
        });
      }
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Bad state: ', '');
    }
  }

  Future<String?> _deleteCollege(_CollegeRow college) async {
    if (college.id == null) return 'College id is missing.';
    try {
      final ok = await _database.deleteCollege(college.id!);
      if (!ok) {
        await _loadColleges();
        return 'College not found.';
      }
      if (mounted) {
        setState(() {
          _colleges.removeWhere((c) => c.id == college.id);
          _courses.removeWhere((c) => c.collegeId == college.id);
        });
      }
      return null;
    } catch (e) {
      await _loadColleges();
      await _loadCourses(showLoading: false);
      return e.toString().replaceFirst('Bad state: ', '');
    }
  }

  _CollegeRow _collegeRowFromMap(Map<String, Object?> item) {
    return _CollegeRow(
      id: int.tryParse('${item['id'] ?? ''}'),
      name: (item['name'] ?? '').toString(),
    );
  }

  Future<void> _loadCourses({bool showLoading = true}) async {
    if (mounted && showLoading) {
      setState(() {
        _isLoadingCourses = true;
        _coursesLoadError = null;
      });
    }
    try {
      final results = await _database.fetchCourses();
      final rows = results.map(_courseRowFromMap).toList();

      if (!mounted) return;
      setState(() {
        _courses
          ..clear()
          ..addAll(rows);
        _isLoadingCourses = false;
        _coursesLoadError = null;
        _rebuildAggregateCounts();
        _markDashboardDataDirty();
        _refreshDashboardPrepared();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingCourses = false;
        _coursesLoadError =
            'Could not load programs. Run server\\run_server.bat to start the API.';
      });
    }
  }

  Future<String?> _addCourse({
    required String name,
    int? collegeId,
  }) async {
    try {
      final row = await _database.insertCourse(
        name: name,
        collegeId: collegeId,
      );
      final created = _courseRowFromMap(row);
      if (mounted) {
        setState(() {
          _courses.add(created);
          _courses.sort((a, b) => a.name.compareTo(b.name));
          _rebuildAggregateCounts();
        });
      }
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Bad state: ', '');
    }
  }

  Future<String?> _updateCourse({
    required _CourseRow course,
    required String name,
  }) async {
    if (course.id == null) return 'Program id is missing.';
    try {
      final row = await _database.updateCourse(
        id: course.id!,
        name: name,
      );
      final updated = _courseRowFromMap(row);
      if (mounted) {
        setState(() {
          final index = _courses.indexWhere((c) => c.id == course.id);
          if (index >= 0) {
            _courses[index] = updated;
            _courses.sort((a, b) => a.name.compareTo(b.name));
          }
          _rebuildAggregateCounts();
        });
      }
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Bad state: ', '');
    }
  }

  Future<String?> _deleteCourse(_CourseRow course) async {
    if (course.id == null) return 'Program id is missing.';
    try {
      final ok = await _database.deleteCourse(course.id!);
      if (!ok) {
        await _loadCourses();
        return 'Program not found.';
      }
      if (mounted) {
        setState(() {
          _courses.removeWhere((c) => c.id == course.id);
          _rebuildAggregateCounts();
        });
      }
      return null;
    } catch (e) {
      await _loadCourses();
      return e.toString().replaceFirst('Bad state: ', '');
    }
  }

  _CourseRow _courseRowFromMap(Map<String, Object?> item) {
    final code = (item['code'] ?? '').toString().trim();
    return _CourseRow(
      id: int.tryParse('${item['id'] ?? ''}'),
      name: (item['name'] ?? '').toString(),
      collegeId: int.tryParse('${item['college_id'] ?? ''}'),
      code: code.isEmpty ? null : code,
    );
  }

  Future<void> _loadStudents({bool showLoading = true}) async {
    if (mounted && showLoading) {
      setState(() {
        _isLoadingStudents = true;
        _studentsLoadError = null;
      });
    }
    try {
      final results = await _database.fetchStudents();
      final rows = results.map(_studentRowFromMap).toList();

      if (!mounted) return;
      _students
        ..clear()
        ..addAll(rows);
      _isLoadingStudents = false;
      _studentsLoadError = null;
      _rebuildAggregateCounts();
      _markDashboardDataDirty();
      _refreshDashboardPrepared();
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingStudents = false;
        _studentsLoadError =
            'Could not load students. Run server\\run_server.bat to start the API.';
      });
    }
  }

  Future<void> _loadDashboardPriorityData() async {
    if (mounted) {
      setState(() {
        _isLoadingStudents = true;
        _isLoadingDocs = true;
        _isLoadingCourses = true;
        _studentsLoadError = null;
        _docsLoadError = null;
        _coursesLoadError = null;
      });
    }

    List<_StudentRow>? students;
    List<_DocRow>? docs;
    List<_CourseRow>? courses;
    String? studentsLoadError;
    String? docsLoadError;
    String? coursesLoadError;

    await Future.wait<void>([
      _database.fetchStudents().then((results) {
        students = results.map(_studentRowFromMap).toList();
      }).catchError((_) {
        studentsLoadError =
            'Could not load students. Run server\\run_server.bat to start the API.';
      }),
      _database.fetchDocuments().then((results) {
        docs = results.map(_docRowFromMap).toList();
      }).catchError((_) {
        docsLoadError =
            'Could not load documents. Run server\\run_server.bat to start the API.';
      }),
      _database.fetchCourses().then((results) {
        courses = results.map(_courseRowFromMap).toList();
      }).catchError((_) {
        coursesLoadError =
            'Could not load programs. Run server\\run_server.bat to start the API.';
      }),
    ]);

    if (!mounted) return;

    if (students != null) {
      _students
        ..clear()
        ..addAll(students!);
    }
    if (docs != null) {
      _docs
        ..clear()
        ..addAll(docs!);
    }
    if (courses != null) {
      _courses
        ..clear()
        ..addAll(courses!);
    }
    _studentsLoadError = studentsLoadError;
    _docsLoadError = docsLoadError;
    _coursesLoadError = coursesLoadError;
    _isLoadingStudents = false;
    _isLoadingDocs = false;
    _isLoadingCourses = false;
    _rebuildAggregateCounts();
    _markDashboardDataDirty(resetAnalytics: true);
    _refreshDashboardPrepared();
    _dashboardPriorityReady = true;
    _syncDashboardShellReady();

    setState(() {});
    _scheduleDashboardAnalyticsReveal();
    Future.microtask(_ensureFullAnalytics);
  }

  Future<void> _loadSecondaryShellData() async {
    List<_CollegeRow>? colleges;
    String? collegesLoadError;

    await _database.fetchColleges().then((results) {
      colleges = results.map(_collegeRowFromMap).toList();
    }).catchError((_) {
      collegesLoadError =
          'Could not load colleges. Run server\\run_server.bat to start the API.';
    });

    if (!mounted) return;

    if (colleges != null) {
      _colleges
        ..clear()
        ..addAll(colleges!);
    }
    _collegesLoadError = collegesLoadError;
    _isLoadingColleges = false;
    _markDashboardDataDirty();
    _refreshDashboardPrepared();
    _dashboardSecondaryReady = true;
    _syncDashboardShellReady();

    setState(() {});
  }

  void _scheduleDashboardAnalyticsReveal() {
    if (!_isAdmin || _dashboardAnalyticsReady) return;
    if (!_dashboardShellDataReady) return;
    setState(() {
      _dashboardAnalyticsReady = true;
      _refreshDashboardPrepared(withAnalytics: true);
    });
  }

  Future<bool> _deleteDocument(_DocRow doc) async {
    if (doc.id.trim().isEmpty) {
      return true;
    }

    final docId = int.tryParse(doc.id.trim());
    if (docId == null) {
      return false;
    }

    if (mounted) {
      setState(() {
        _docs.removeWhere((d) => _isSameDocument(d, doc));
        _markDashboardDataDirty();
        _refreshDashboardPrepared();
      });
    }

    try {
      final ok = await _database.deleteDocument(docId);
      if (!ok) {
        await _loadDocuments();
      }
      return ok;
    } catch (_) {
      await _loadDocuments();
      return false;
    }
  }

  Future<int> _deleteDocuments(List<_DocRow> docs) async {
    var deletedCount = 0;
    for (final doc in docs) {
      final ok = await _deleteDocument(doc);
      if (ok) deletedCount++;
    }
    return deletedCount;
  }

  String? _programCodeForCourse(String courseName) {
    final name = courseName.trim();
    if (name.isEmpty) return null;
    for (final course in _courses) {
      if (course.name == name) {
        final code = course.code?.trim() ?? '';
        return code.isEmpty ? null : code;
      }
    }
    return null;
  }

  String _programChartLabel(String courseName) {
    final name = courseName.trim();
    if (name.isEmpty) return 'N/A';
    return StudentNumber.resolveProgramCode(
      programName: name,
      courseCode: _programCodeForCourse(name),
    );
  }

  String? _collegeNameForCourse(String courseName) {
    final name = courseName.trim();
    if (name.isEmpty) return null;
    for (final course in _courses) {
      if (course.name != name) continue;
      final collegeId = course.collegeId;
      if (collegeId == null) return null;
      for (final college in _colleges) {
        if (college.id == collegeId) return college.name;
      }
      return null;
    }
    return _departmentForProgram(name);
  }

  Future<bool> _uploadStudentDocument({
    required String title,
    required String student,
    required String sourceImagePath,
    required String mimeType,
    String studentNo = '',
    String course = '',
    String schoolYear = '',
    String documentType = '',
    bool isComplete = true,
    String college = '',
    String studentCategory = 'Graduated',
  }) async {
    try {
      final program = _programCodeForCourse(course) ?? course;
      final resolvedCollege = college.trim().isNotEmpty
          ? college.trim()
          : (_collegeNameForCourse(course) ?? '');
      final row = await _database.insertDocument(
        title: title,
        student: student,
        sourceImagePath: sourceImagePath,
        mimeType: mimeType,
        studentNo: studentNo,
        course: course,
        program: program,
        schoolYear: schoolYear,
        documentType: documentType,
        isComplete: isComplete,
        college: resolvedCollege,
        studentCategory: studentCategory,
      );
      final doc = _docRowFromMap(row);
      if (mounted) {
        setState(() => _docs.insert(0, doc));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<_StudentRow?> _registerStudent({
    required String studentNo,
    required String fullName,
    required String course,
    required int year,
    required String status,
    String? email,
    String schoolYear = '',
  }) async {
    final resolvedStudentNo = studentNo.trim().isEmpty
        ? _nextStudentNo(
            _students,
            course: course,
            schoolYear: schoolYear,
          )
        : studentNo.trim();

    try {
      final row = await _database.insertStudent(
        studentNo: resolvedStudentNo,
        fullName: fullName,
        course: course,
        year: year,
        status: 'graduated',
        email: email ?? '',
      );
      final created = _studentRowFromMap(row);
      if (mounted) {
        setState(() {
          _students.add(created);
          _rebuildAggregateCounts();
        });
      }
      return created;
    } catch (_) {
      return null;
    }
  }

  _StudentRow _studentRowFromMap(Map<String, Object?> item) {
    final email = (item['email'] ?? '').toString().trim();
    return _StudentRow(
      id: int.tryParse('${item['id'] ?? ''}'),
      studentNo: (item['student_no'] ?? '').toString(),
      fullName: (item['full_name'] ?? '').toString(),
      course: (item['course'] ?? '').toString(),
      year: int.tryParse('${item['year'] ?? 0}') ?? 0,
      status: 'graduated',
      email: email.isEmpty ? null : email,
    );
  }

  Future<String?> _deleteStudent(_StudentRow student) async {
    if (student.id == null) return 'Student id is missing.';
    try {
      final ok = await _database.deleteStudent(student.id!);
      if (!ok) {
        await _loadStudents();
        return 'Student not found.';
      }
      if (mounted) {
        final name = student.fullName.trim().toLowerCase();
        setState(() {
          _students.removeWhere((s) => s.id == student.id);
          if (name.isNotEmpty) {
            _docs.removeWhere(
              (doc) => doc.student.trim().toLowerCase() == name,
            );
          }
          _rebuildAggregateCounts();
        });
      }
      return null;
    } catch (e) {
      await _loadStudents();
      await _loadDocuments(showLoading: false);
      return e.toString().replaceFirst('Bad state: ', '');
    }
  }

  _DocRow _docRowFromMap(Map<String, Object?> item) {
    final imagePath = (item['image_path'] ?? '').toString().trim();
    final remoteUrl = _documentImageUrl(imagePath);
    final localPath =
        remoteUrl.isEmpty && imagePath.isNotEmpty ? imagePath : null;
    return _DocRow(
      id: (item['id'] ?? '').toString(),
      title: (item['title'] ?? 'Untitled Document').toString(),
      student: (item['student'] ?? '').toString(),
      type: (item['mime_type'] ?? 'image').toString(),
      size: _formatBytesFromApi(item['size_bytes']),
      uploaded: _formatDateFromIso((item['created_at'] ?? '').toString()),
      schoolYear: (item['school_year'] ?? '').toString().trim(),
      localImagePath: localPath,
      remoteImageUrl: remoteUrl,
    );
  }

  /// Resolves API [image_path] values to a URL the preview can load.
  String _documentImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    if (imagePath.startsWith('/uploads/')) {
      return '${ApiConfig.baseUrl}$imagePath';
    }
    return '';
  }

  String _nextStudentNo(
    List<_StudentRow> rows, {
    required String course,
    String schoolYear = '',
  }) {
    final programCode = StudentNumber.resolveProgramCode(
      programName: course,
      courseCode: _programCodeForCourse(course),
    );
    return StudentNumber.next(
      existingStudentNumbers: rows.map((r) => r.studentNo),
      programCode: programCode,
      schoolYear: schoolYear.trim().isEmpty
          ? '${DateTime.now().year}-${DateTime.now().year + 1}'
          : schoolYear,
    );
  }

  bool _isSameDocument(_DocRow a, _DocRow b) {
    final aId = a.id.trim();
    final bId = b.id.trim();
    if (aId.isNotEmpty && bId.isNotEmpty) {
      return aId == bId;
    }
    return a.title == b.title &&
        a.student == b.student &&
        a.uploaded == b.uploaded &&
        a.type == b.type &&
        a.size == b.size;
  }

  String _formatDateFromIso(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    return '$month/$day/$year';
  }

  String _formatBytesFromApi(dynamic value) {
    final bytes = int.tryParse('${value ?? 0}') ?? 0;
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _invalidateFullAnalytics() {
    _cachedFullAnalytics = null;
    _fullAnalyticsCacheGeneration = -1;
    _fullAnalyticsLoading = false;
    _graduatesByYearCache.clear();
    _courseCountsByYearCache.clear();
  }

  void _ensureFullAnalytics() {
    if (_cachedFullAnalytics != null &&
        _fullAnalyticsCacheGeneration == _dashboardDataGeneration) {
      return;
    }
    if (_fullAnalyticsLoading) return;
    _fullAnalyticsLoading = true;

    Future<void>.microtask(() {
      final data = _buildAnalyticsDataFast();
      if (!mounted) return;
      _cachedFullAnalytics = data;
      _fullAnalyticsCacheGeneration = _dashboardDataGeneration;
      _fullAnalyticsLoading = false;
      if (_selectedNavId == 'data_analytics') {
        setState(() {});
      }
    });
  }

  _AnalyticsData _buildAnalyticsDataFast() {
    final byCourse = <String, int>{};
    final studentsByYear = <String, int>{};
    final years = <String>{};

    for (final student in _students) {
      final course =
          student.course.trim().isEmpty ? 'N/A' : student.course.trim();
      byCourse.update(course, (count) => count + 1, ifAbsent: () => 1);

      final year = _schoolYearFromStudentNo(student.studentNo);
      if (year.isEmpty) continue;
      years.add(year);
      studentsByYear.update(year, (count) => count + 1, ifAbsent: () => 1);
    }
    years.add(_currentSchoolYear());

    final byCourseEntries = byCourse.entries
        .map(
          (entry) => _CourseCount(
            name: entry.key,
            code: _programChartLabel(entry.key),
            count: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final availableYears = years.toList()
      ..sort((a, b) {
        final aStart = int.tryParse(a.split('-').first) ?? 0;
        final bStart = int.tryParse(b.split('-').first) ?? 0;
        return bStart.compareTo(aStart);
      });

    final bySchoolYear = availableYears
        .map(
          (year) => _YearCount(
            year: year,
            students: studentsByYear[year] ?? 0,
            documents: 0,
          ),
        )
        .toList();

    final byCourseByYear = <String, List<_CourseCount>>{
      for (final year in availableYears)
        year: _courseCountsInSchoolYear(year),
    };

    return _AnalyticsData(
      students: _students.length,
      courses: _courses.length,
      documents: _docs.length,
      byCourse: byCourseEntries,
      bySchoolYear: bySchoolYear,
      availableYears: availableYears,
      byCourseByYear: byCourseByYear,
      graduatesByYear: const {},
    );
  }

  List<_CourseCount> _courseCountsInSchoolYear(String year) {
    final counts = <String, int>{};
    final names = <String, String>{};

    for (final student in _students) {
      if (_schoolYearFromStudentNo(student.studentNo) != year) continue;
      final courseName =
          student.course.trim().isEmpty ? 'N/A' : student.course.trim();
      final code = _programCodeFromStudentNo(student.studentNo);
      final key = code.isNotEmpty ? code : _programChartLabel(courseName);
      counts.update(key, (count) => count + 1, ifAbsent: () => 1);
      final existing = names[key];
      if (existing == null || courseName.length > existing.length) {
        names[key] = courseName;
      }
    }

    return counts.entries
        .map(
          (entry) => _CourseCount(
            name: names[entry.key] ?? entry.key,
            code: entry.key,
            count: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  List<_AnalyticsGraduate> _graduatesForYear(
    String year, {
    String? programName,
    String? programCode,
  }) {
    final all = _graduatesByYearCache.putIfAbsent(year, () {
      final rows = _students
          .where((s) => _schoolYearFromStudentNo(s.studentNo) == year)
          .toList()
        ..sort(
          (a, b) =>
              a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );
      return rows
          .map(
            (student) => _AnalyticsGraduate(
              studentNo: student.studentNo,
              fullName: student.fullName,
              course: student.course,
              programLabel: _programChartLabel(student.course),
              schoolYear: _schoolYearFromStudentNo(student.studentNo),
            ),
          )
          .toList();
    });

    final nameFilter = programName?.trim();
    final codeFilter = programCode?.trim();
    if ((nameFilter == null || nameFilter.isEmpty) &&
        (codeFilter == null || codeFilter.isEmpty)) {
      return all;
    }

    return all.where((graduate) {
      final course = graduate.course.trim();
      final label = graduate.programLabel.trim();
      if (nameFilter != null &&
          nameFilter.isNotEmpty &&
          course.toLowerCase() == nameFilter.toLowerCase()) {
        return true;
      }
      if (codeFilter != null &&
          codeFilter.isNotEmpty &&
          label.toLowerCase() == codeFilter.toLowerCase()) {
        return true;
      }
      return false;
    }).toList();
  }

  List<_CourseCount> _courseCountsForYear(String year) {
    final cached = _cachedFullAnalytics?.byCourseByYear[year];
    if (cached != null) return cached;
    return _courseCountsByYearCache.putIfAbsent(
      year,
      () => _courseCountsInSchoolYear(year),
    );
  }

  List<_DocRow> _filterDocsForDashboardSearch(List<_DocRow> docs) {
    final q = _dashboardSearchQuery.trim().toLowerCase();
    if (q.isEmpty) return docs;
    return docs
        .where(
          (doc) =>
              doc.title.toLowerCase().contains(q) ||
              doc.student.toLowerCase().contains(q) ||
              doc.uploaded.toLowerCase().contains(q),
        )
        .toList();
  }

  void _markDashboardDataDirty({bool resetAnalytics = false}) {
    _dashboardDataGeneration++;
    if (resetAnalytics) {
      _dashboardAnalyticsReady = false;
      _cachedDashboardAnalytics = null;
    }
    _cachedDashboardPrepared = null;
    _dashboardPreparedKey = null;
    _invalidateFullAnalytics();
  }

  void _onDashboardSearchChanged(String query) {
    _dashboardSearchDebounce?.cancel();
    _dashboardSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final next = query.trim();
      if (_dashboardSearchQuery == next) return;
      setState(() {
        _dashboardSearchQuery = next;
        _markDashboardDataDirty();
        _refreshDashboardPrepared();
      });
    });
  }

  void _refreshDashboardPrepared({bool withAnalytics = false}) {
    final cacheKey =
        '$_dashboardDataGeneration|${_dashboardSearchQuery.trim().toLowerCase()}|${withAnalytics || _dashboardAnalyticsReady}';
    if (_cachedDashboardPrepared != null &&
        _dashboardPreparedKey == cacheKey) {
      return;
    }

    final includeAnalytics =
        withAnalytics || (_dashboardAnalyticsReady && _isAdmin);
    if (includeAnalytics && _cachedDashboardAnalytics == null) {
      _cachedDashboardAnalytics = _buildDashboardAnalyticsPreview();
    }

    _cachedDashboardPrepared = _DashboardPrepared(
      segments: _buildCoursePercentSegments(),
      studentsWithoutDocs: _countStudentsWithoutDocs(),
      filteredRecentDocs: _filterDocsForDashboardSearch(
        _recentDocsForDashboard(),
      ),
      analytics: includeAnalytics ? _cachedDashboardAnalytics : null,
    );
    _dashboardPreparedKey = cacheKey;
  }

  List<_DocRow> _recentDocsForDashboard() {
    if (_docs.isEmpty) return const [];
    final copy = List<_DocRow>.from(_docs);
    copy.sort((a, b) {
      final aDate = _parseUploadedDate(a.uploaded);
      final bDate = _parseUploadedDate(b.uploaded);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return copy;
  }

  DateTime? _parseUploadedDate(String uploaded) {
    final iso = DateTime.tryParse(uploaded);
    if (iso != null) return iso;
    final parts = uploaded.split('/');
    if (parts.length == 3) {
      final month = int.tryParse(parts[0]);
      final day = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (month != null && day != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  int _countStudentsWithoutDocs() {
    if (_students.isEmpty) return 0;
    final docStudentKeys = _docs
        .map((doc) => doc.student.trim().toLowerCase())
        .where((key) => key.isNotEmpty)
        .toList();
    if (docStudentKeys.isEmpty) return _students.length;

    var missing = 0;
    for (final student in _students) {
      final name = student.fullName.trim().toLowerCase();
      final no = student.studentNo.trim().toLowerCase();
      final hasDoc = docStudentKeys.any(
        (key) =>
            (name.isNotEmpty && key.contains(name)) ||
            (no.isNotEmpty && key.contains(no)),
      );
      if (!hasDoc) missing++;
    }
    return missing;
  }

  _AnalyticsData _buildDashboardAnalyticsPreview() {
    final byCourse = <String, int>{};
    final studentsByYear = <String, int>{};
    for (final student in _students) {
      final course =
          student.course.trim().isEmpty ? 'N/A' : student.course.trim();
      byCourse.update(course, (count) => count + 1, ifAbsent: () => 1);
      final year = _schoolYearFromStudentNo(student.studentNo);
      if (year.isNotEmpty) {
        studentsByYear.update(year, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    final byCourseEntries = byCourse.entries
        .map(
          (entry) => _CourseCount(
            name: entry.key,
            code: _programChartLabel(entry.key),
            count: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    if (byCourseEntries.length > 8) {
      byCourseEntries.removeRange(8, byCourseEntries.length);
    }

    final docsPerYear = <String, int>{};
    for (final doc in _docs) {
      final year = doc.schoolYear.trim();
      if (year.isEmpty || year.toLowerCase() == 'unknown') continue;
      docsPerYear.update(year, (count) => count + 1, ifAbsent: () => 1);
    }

    final allYears = _collectSchoolYears(
      students: _students,
      docs: _docs,
    );
    final displayYears = allYears.length <= _dashboardSchoolYearsLimit
        ? allYears
        : allYears.sublist(0, _dashboardSchoolYearsLimit);
    // Oldest → newest for time-series charts (collector returns newest first).
    final chartYears = displayYears.reversed.toList();

    final bySchoolYear = chartYears
        .map(
          (year) => _YearCount(
            year: year,
            students: studentsByYear[year] ?? 0,
            documents: docsPerYear[year] ?? 0,
          ),
        )
        .toList();

    return _AnalyticsData(
      students: _students.length,
      courses: _courses.length,
      documents: _docs.length,
      byCourse: byCourseEntries,
      bySchoolYear: bySchoolYear,
      availableYears: allYears,
      byCourseByYear: const {},
      graduatesByYear: const {},
    );
  }

  List<_PieSeg> _buildCoursePercentSegments() {
    if (_students.isEmpty) return const [];
    final counts = <String, int>{};
    for (final student in _students) {
      final course = student.course.trim().isEmpty ? 'N/A' : student.course;
      counts.update(course, (value) => value + 1, ifAbsent: () => 1);
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = _students.length;
    final percents = _distributePercentages(
      sorted.map((e) => e.value).toList(),
      total,
    );
    const colors = _programChartColors;
    return List<_PieSeg>.generate(sorted.length, (index) {
      final item = sorted[index];
      return _PieSeg(
        _programChartLabel(item.key),
        percents[index],
        colors[index % colors.length],
        count: item.value,
      );
    });
  }
}

class _DashboardPrepared {
  const _DashboardPrepared({
    required this.segments,
    required this.studentsWithoutDocs,
    required this.filteredRecentDocs,
    required this.analytics,
  });

  final List<_PieSeg> segments;
  final int studentsWithoutDocs;
  final List<_DocRow> filteredRecentDocs;
  final _AnalyticsData? analytics;
}

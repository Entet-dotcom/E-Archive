part of '../../dashboard_shell_page.dart';

class _DataAnalyticsPage extends StatefulWidget {
  const _DataAnalyticsPage({
    super.key,
    required this.data,
    required this.courseCountsForYear,
    required this.onViewYearGraduates,
    required this.allGraduates,
    required this.onSelectGraduate,
    this.initialFilterYear,
    this.pinnedHeader = false,
  });

  final _AnalyticsData data;
  final List<_CourseCount> Function(String year) courseCountsForYear;
  final void Function(
    String year, {
    String? programName,
    String? programCode,
  }) onViewYearGraduates;
  final List<_AnalyticsGraduate> Function() allGraduates;
  final void Function(_AnalyticsGraduate graduate) onSelectGraduate;
  final String? initialFilterYear;
  final bool pinnedHeader;

  @override
  State<_DataAnalyticsPage> createState() => _DataAnalyticsPageState();
}

class _DataAnalyticsPageState extends State<_DataAnalyticsPage> {
  static const _chartAccents = <Color>[
    Color(0xFF60A5FA),
    Color(0xFF4ADE80),
    Color(0xFFA78BFA),
    Color(0xFFFB923C),
    Color(0xFF22D3EE),
    Color(0xFFF472B6),
    Color(0xFF3B82F6),
  ];

  String? _filterYear;
  final _bodyScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filterYear = widget.initialFilterYear;
  }

  @override
  void dispose() {
    _bodyScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DataAnalyticsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final years = widget.data.availableYears;
    if (years.isEmpty) return;

    if (_filterYear != null && !years.contains(_filterYear)) {
      _filterYear = null;
    }
  }

  List<_CourseCount> _coursesForYear(String year) {
    final cached = widget.data.byCourseByYear[year];
    if (cached != null) return cached;
    return widget.courseCountsForYear(year);
  }

  _AnalyticsData get _displayData {
    final year = _filterYear;
    if (year == null) return widget.data;
    return widget.data.forSchoolYear(year, _coursesForYear(year));
  }

  void _onFilterYearChanged(String? year) {
    if (_filterYear == year) return;
    setState(() => _filterYear = year);
    if (!widget.pinnedHeader) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_bodyScrollController.hasClients) return;
      _bodyScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Widget _buildHeader(_AnalyticsData fullData) {
    return _AnalyticsPageHeader(
      years: _analyticsFilterYears(fullData.availableYears),
      selectedYear: _filterYear,
      onYearChanged: _onFilterYearChanged,
      graduateSearch: fullData.students > 0
          ? _AnalyticsGraduateFinder(
              graduates: widget.allGraduates(),
              chartAccents: _chartAccents,
              onSelect: widget.onSelectGraduate,
            )
          : null,
    );
  }

  Widget _buildBody(_AnalyticsData data, _AnalyticsData fullData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnalyticsGraduatesInsightRow(
          data: data,
          filterYear: _filterYear,
        ),
        const SizedBox(height: 16),
        _SchoolYearAnalyticsPanel(
          data: fullData,
          chartAccents: _chartAccents,
          courseCountsForYear: _coursesForYear,
          onViewGraduates: widget.onViewYearGraduates,
          selectedYear: _filterYear,
          onSelectedYearChanged: _onFilterYearChanged,
        ),
        if (fullData.students == 0) ...[
          const SizedBox(height: _AdminDashTheme.panelGap),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _AdminDashTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _AdminDashTheme.border),
            ),
            child: Text(
              'Add student records to see graduates by school year and program.',
              style: _AdminDashTheme.label(size: 12),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _displayData;
    final fullData = widget.data;
    final header = _buildHeader(fullData);
    final body = _buildBody(data, fullData);

    if (!widget.pinnedHeader) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          const SizedBox(height: 16),
          body,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: SingleChildScrollView(
            controller: _bodyScrollController,
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: body,
          ),
        ),
      ],
    );
  }
}

/// Lightweight placeholder while analytics cache builds.
class _AnalyticsLoadingSkeleton extends StatelessWidget {
  const _AnalyticsLoadingSkeleton({
    this.pinnedHeader = false,
  });

  final bool pinnedHeader;

  @override
  Widget build(BuildContext context) {
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data Analytics', style: _AdminDashTheme.panelTitle(size: 22)),
        const SizedBox(height: 4),
        Text(
          'Graduates by school year and program',
          style: _AdminDashTheme.label(size: 13).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final loading = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _AdminDashTheme.link,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading graduate records…',
              style: _AdminDashTheme.label(size: 13).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    if (!pinnedHeader) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 32),
          loading,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(child: loading),
      ],
    );
  }
}

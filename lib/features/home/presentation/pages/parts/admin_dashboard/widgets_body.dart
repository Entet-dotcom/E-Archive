part of '../../dashboard_shell_page.dart';

class _AdminDashboardBody extends StatelessWidget {
  const _AdminDashboardBody({required this.data});

  final _DashboardBaseData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 720;
        final chartPanel = RepaintBoundary(
          child: _AdminDashboardChartPanel(data: data),
        );
        final uploadsPanel = RepaintBoundary(
          child: _AdminDashboardUploadsPanel(data: data),
        );

        final Widget mainPanels;
        if (stacked) {
          mainPanels = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: chartPanel),
              const SizedBox(height: _AdminDashTheme.panelGap),
              Expanded(child: uploadsPanel),
            ],
          );
        } else {
          mainPanels = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 4, child: chartPanel),
              const SizedBox(width: _AdminDashTheme.panelGap),
              Expanded(flex: 7, child: uploadsPanel),
            ],
          );
        }

        final analytics = data.showAnalyticsCharts ? data.analytics : null;
        final Widget analyticsSection;
        if (analytics != null) {
          analyticsSection = _AdminDashboardAnalyticsRow(
            data: analytics,
            onNavigate: data.onNavigate,
          );
        } else {
          analyticsSection = const _DashboardAnalyticsRowSkeleton();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: mainPanels),
            const SizedBox(height: _AdminDashTheme.panelGap),
            analyticsSection,
          ],
        );
      },
    );
  }
}

class _AdminDashboardAnalyticsRow extends StatelessWidget {
  const _AdminDashboardAnalyticsRow({
    required this.data,
    this.onNavigate,
  });

  final _AnalyticsData data;
  final ValueChanged<String>? onNavigate;

  static const _chartHeight = 208.0;
  static const _rowHeight = 284.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSideBySide = constraints.maxWidth >= 720;
        final panelWidth =
            useSideBySide ? null : math.max(300.0, constraints.maxWidth - 8);

        Widget panel({
          required String title,
          required Widget child,
          Widget? trailing,
        }) {
          final panel = _AdminPanel(
            compact: true,
            title: title,
            trailing: trailing,
            child: child,
          );
          if (panelWidth == null) return panel;
          return SizedBox(width: panelWidth, child: panel);
        }

        final graduatesPanel = panel(
          title: 'Graduates by School Year',
          trailing: _AdminDashboardAnalyticsLink(onNavigate: onNavigate),
          child: data.bySchoolYear.isEmpty
              ? const _AdminDashboardAnalyticsEmpty()
              : _AdminBarChart(
                  height: _chartHeight,
                  compact: data.bySchoolYear.length > 5,
                  animate: false,
                  valueUnit: 'graduates',
                  yAxisLabel: 'Number of Graduates',
                  values: {
                    for (final entry in data.bySchoolYear)
                      entry.year: entry.students,
                  },
                  maxY: _chartMax(
                    data.bySchoolYear.map((e) => e.students),
                  ),
                  axisLabelForKey: _shortSchoolYearLabel,
                  tooltipTitleForKey: (year) => year,
                ),
        );

        final documentsPanel = panel(
          title: 'Documents by School Year',
          trailing: _AdminDashboardAnalyticsLink(onNavigate: onNavigate),
          child: data.bySchoolYear.isEmpty
              ? const _AdminDashboardAnalyticsEmpty()
              : _AdminBarChart(
                  height: _chartHeight,
                  compact: data.bySchoolYear.length > 5,
                  animate: false,
                  valueUnit: 'documents',
                  yAxisLabel: 'Number of Documents',
                  values: {
                    for (final entry in data.bySchoolYear)
                      entry.year: entry.documents,
                  },
                  maxY: _chartMax(
                    data.bySchoolYear.map((e) => e.documents),
                  ),
                  axisLabelForKey: _shortSchoolYearLabel,
                  tooltipTitleForKey: (year) => year,
                ),
        );

        const analyticsPanelsGap = _AdminDashTheme.panelGap;
        final analyticsPanels = [
          graduatesPanel,
          documentsPanel,
        ];

        if (!useSideBySide) {
          return SizedBox(
            height: _rowHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var i = 0; i < analyticsPanels.length; i++) ...[
                  if (i > 0) const SizedBox(width: analyticsPanelsGap),
                  analyticsPanels[i],
                ],
              ],
            ),
          );
        }

        return SizedBox(
          height: _rowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < analyticsPanels.length; i++) ...[
                if (i > 0) const SizedBox(width: analyticsPanelsGap),
                Expanded(child: analyticsPanels[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AdminDashboardAnalyticsLink extends StatelessWidget {
  const _AdminDashboardAnalyticsLink({this.onNavigate});

  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    if (onNavigate == null) return const SizedBox.shrink();

    return TextButton(
      onPressed: () => onNavigate!('data_analytics'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: _AdminDashTheme.link,
      ),
      child: Text(
        'Full report',
        style: AppFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AdminDashboardAnalyticsEmpty extends StatelessWidget {
  const _AdminDashboardAnalyticsEmpty();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _AdminDashboardAnalyticsRow._chartHeight,
      child: Center(
        child: Text(
          'No data yet.',
          style:
              _AdminDashTheme.label().copyWith(color: _AdminDashTheme.textHint),
        ),
      ),
    );
  }
}

class _AdminDashboardChartPanel extends StatelessWidget {
  const _AdminDashboardChartPanel({required this.data});

  final _DashboardBaseData data;

  @override
  Widget build(BuildContext context) {
    return _AdminPanel(
      compact: true,
      expandChild: true,
      title: 'Records by Program',
      child: _AdminPieChart(
        segments: data.courseSegments,
        compact: true,
        animate: false,
        interactive: true,
      ),
    );
  }
}

class _AdminDashboardUploadsPanel extends StatelessWidget {
  const _AdminDashboardUploadsPanel({required this.data});

  final _DashboardBaseData data;

  @override
  Widget build(BuildContext context) {
    return _AdminPanel(
      compact: true,
      expandChild: true,
      title: 'Recent Uploads',
      titleStyle: _AdminDashTheme.panelTitle(size: 16),
      trailing: _AdminDashboardViewAllLink(onNavigate: data.onNavigate),
      child: _AdminUploadsTable(
        rows: data.recentDocs,
        compact: true,
        onViewStudentDocuments: data.onViewStudentDocuments,
      ),
    );
  }
}

class _AdminDashboardViewAllLink extends StatelessWidget {
  const _AdminDashboardViewAllLink({this.onNavigate});

  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    if (onNavigate == null) return const SizedBox.shrink();

    return TextButton(
      onPressed: () => onNavigate!('archived_documents'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: _AdminDashTheme.link,
      ),
      child: Text(
        'View all',
        style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

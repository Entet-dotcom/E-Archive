part of '../../dashboard_shell_page.dart';

class _DashboardBaseData {
  const _DashboardBaseData({
    required this.accountName,
    required this.studentsCount,
    required this.documentsCount,
    required this.coursesCount,
    required this.recentUploadsCount,
    required this.courseSegments,
    required this.recentDocs,
    required this.searchController,
    this.collegesCount = 0,
    this.studentsWithoutDocs = 0,
    this.topProgramName,
    this.topProgramCount = 0,
    this.recentAudit = const [],
    this.onSearchChanged,
    this.onNavigate,
    this.onViewStudentDocuments,
    this.analytics,
    this.showAnalyticsCharts = false,
  });

  final String accountName;
  final int studentsCount;
  final int documentsCount;
  final int coursesCount;
  final int collegesCount;
  final int recentUploadsCount;
  final int studentsWithoutDocs;
  final String? topProgramName;
  final int topProgramCount;
  final List<_PieSeg> courseSegments;
  final List<_DocRow> recentDocs;
  final List<_AuditRow> recentAudit;
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onNavigate;
  final ValueChanged<String>? onViewStudentDocuments;
  final _AnalyticsData? analytics;
  final bool showAnalyticsCharts;
}

/// Header placeholders while the dashboard loads.
class _DashboardHeaderSkeleton extends StatelessWidget {
  const _DashboardHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonPulseScope(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const welcome = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonBox(width: 168, height: 14, borderRadius: 4),
              SizedBox(height: 8),
              SkeletonBox(width: 220, height: 24, borderRadius: 6),
            ],
          );

          final searchWidth = constraints.maxWidth < 640
              ? constraints.maxWidth
              : 360.0;
          final search = SkeletonBox(
            width: searchWidth,
            height: 42,
            borderRadius: 10,
          );

          if (constraints.maxWidth < 640) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: search,
                ),
                const SizedBox(height: 14),
                welcome,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: welcome),
              const SizedBox(width: 20),
              search,
            ],
          );
        },
      ),
    );
  }
}

/// Bottom analytics row placeholder (matches [_AdminDashboardAnalyticsRow] height).
class _DashboardAnalyticsRowSkeleton extends StatelessWidget {
  const _DashboardAnalyticsRowSkeleton();

  static const rowHeight = 284.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 720;
        if (stacked) {
          return SizedBox(
            height: rowHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                SizedBox(
                  width: 320,
                  child: _DashboardAnalyticsPanelSkeleton(),
                ),
                SizedBox(width: _AdminDashTheme.panelGap),
                SizedBox(
                  width: 320,
                  child: _DashboardAnalyticsPanelSkeleton(),
                ),
              ],
            ),
          );
        }

        return const SizedBox(
          height: rowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _DashboardAnalyticsPanelSkeleton()),
              SizedBox(width: _AdminDashTheme.panelGap),
              Expanded(child: _DashboardAnalyticsPanelSkeleton()),
            ],
          ),
        );
      },
    );
  }
}

/// Placeholder layout matching the dashboard while metrics load.
class _DashboardLoadingSkeleton extends StatelessWidget {
  const _DashboardLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonPulseScope(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = _AdminDashTheme.statColumnCount(constraints.maxWidth);
          final cardWidth = (constraints.maxWidth -
                  ((columns - 1) * _AdminDashTheme.statSpacing)) /
              columns;

          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: _AdminDashTheme.statSpacing,
                  runSpacing: _AdminDashTheme.statSpacing,
                  children: List.generate(
                    4,
                    (_) => _DashboardStatCardSkeleton(width: cardWidth),
                  ),
                ),
                const SizedBox(height: _AdminDashTheme.sectionGap),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, bodyConstraints) {
                      final stacked = bodyConstraints.maxWidth < 720;

                      final mainPanels = stacked
                          ? const Column(
                              children: [
                                Expanded(child: _DashboardChartPanelSkeleton()),
                                SizedBox(height: _AdminDashTheme.panelGap),
                                Expanded(
                                  child: _DashboardUploadsPanelSkeleton(),
                                ),
                              ],
                            )
                          : const Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: _DashboardChartPanelSkeleton(),
                                ),
                                SizedBox(width: _AdminDashTheme.panelGap),
                                Expanded(
                                  flex: 7,
                                  child: _DashboardUploadsPanelSkeleton(),
                                ),
                              ],
                            );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: mainPanels),
                          const SizedBox(height: _AdminDashTheme.panelGap),
                          const _DashboardAnalyticsRowSkeleton(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardStatCardSkeleton extends StatelessWidget {
  const _DashboardStatCardSkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _AdminDashTheme.border),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0x1A2563EB),
              Colors.white,
            ],
            stops: [0.0, 0.72],
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 36, height: 36, borderRadius: 10),
                SizedBox(width: 10),
                Expanded(
                  child: SkeletonBox(height: 11, borderRadius: 4),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                SkeletonBox(width: 88, height: 28, borderRadius: 6),
                SizedBox(width: 6),
                SkeletonBox(width: 100, height: 12, borderRadius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPanelShell extends StatelessWidget {
  const _DashboardPanelShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: _AdminDashTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _AdminDashTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// "Records by Program" donut chart placeholder.
class _DashboardChartPanelSkeleton extends StatelessWidget {
  const _DashboardChartPanelSkeleton();

  @override
  Widget build(BuildContext context) {
    return _DashboardPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SkeletonBox(width: 140, height: 14, borderRadius: 4),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartSize = math.min(
                  168.0,
                  math.min(constraints.maxWidth, constraints.maxHeight) * 0.55,
                );
                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SkeletonBox(
                          width: chartSize,
                          height: chartSize,
                          borderRadius: chartSize / 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (var i = 0; i < 2; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: List.generate(
                                3,
                                (_) => const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      SkeletonBox(
                                        width: 8,
                                        height: 8,
                                        borderRadius: 4,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: SkeletonBox(
                                          height: 10,
                                          borderRadius: 4,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      SkeletonBox(
                                        width: 28,
                                        height: 10,
                                        borderRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// "Recent Uploads" table placeholder.
class _DashboardUploadsPanelSkeleton extends StatelessWidget {
  const _DashboardUploadsPanelSkeleton();

  @override
  Widget build(BuildContext context) {
    return _DashboardPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Expanded(
                child: SkeletonBox(width: 120, height: 14, borderRadius: 4),
              ),
              SkeletonBox(width: 52, height: 12, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                flex: 4,
                child: SkeletonBox(height: 10, borderRadius: 4),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SkeletonBox(height: 10, borderRadius: 4),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SkeletonBox(height: 10, borderRadius: 4),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Column(
              children: List.generate(
                4,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SkeletonBox(height: 12, borderRadius: 4),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: SkeletonBox(height: 24, borderRadius: 6),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: SkeletonBox(height: 10, borderRadius: 4),
                            ),
                            SizedBox(width: 8),
                            SkeletonBox(width: 32, height: 10, borderRadius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SkeletonBox(width: 18, height: 18, borderRadius: 4),
              SizedBox(width: 6),
              SkeletonBox(width: 18, height: 18, borderRadius: 4),
              SizedBox(width: 6),
              SkeletonBox(width: 18, height: 18, borderRadius: 4),
              SizedBox(width: 6),
              SkeletonBox(width: 18, height: 18, borderRadius: 4),
              SizedBox(width: 6),
              SkeletonBox(width: 24, height: 18, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom analytics bar-chart placeholder.
class _DashboardAnalyticsPanelSkeleton extends StatelessWidget {
  const _DashboardAnalyticsPanelSkeleton();

  @override
  Widget build(BuildContext context) {
    return _DashboardPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Expanded(
                child: SkeletonBox(width: 160, height: 14, borderRadius: 4),
              ),
              SkeletonBox(width: 64, height: 12, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 5; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final heights = [0.45, 0.72, 0.58, 0.85, 0.62];
                        final barHeight =
                            constraints.maxHeight * heights[i % heights.length];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SkeletonBox(
                              height: barHeight,
                              borderRadius: 4,
                            ),
                            const SizedBox(height: 8),
                            const SkeletonBox(
                              width: double.infinity,
                              height: 8,
                              borderRadius: 4,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _displayNameFromAccount(String account) {
  final trimmed = account.trim();
  if (trimmed.isEmpty) return 'User';
  if (!trimmed.contains('@')) return trimmed;
  final local = trimmed.split('@').first;
  if (local.contains('.')) {
    return local.split('.').map((part) {
      if (part.isEmpty) return part;
      return '${part[0].toUpperCase()}${part.substring(1)}';
    }).join(' ');
  }
  if (local.isEmpty) return 'User';
  return '${local[0].toUpperCase()}${local.substring(1)}';
}

class _DashboardTopHeader extends StatelessWidget {
  const _DashboardTopHeader({
    required this.accountName,
    required this.searchController,
    this.onSearchChanged,
  });

  final String accountName;
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final displayName = _displayNameFromAccount(accountName);

    return LayoutBuilder(
      builder: (context, constraints) {
        final welcome = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome back, $displayName',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Dashboard overview',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
          ],
        );

        final search = ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth < 640
                ? constraints.maxWidth
                : 360,
          ),
          child: _DashboardSearchField(
            controller: searchController,
            onChanged: onSearchChanged,
          ),
        );

        if (constraints.maxWidth < 640) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: search,
              ),
              const SizedBox(height: 14),
              welcome,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: welcome),
            const SizedBox(width: 20),
            search,
          ],
        );
      },
    );
  }
}

class _DashboardSearchField extends StatelessWidget {
  const _DashboardSearchField({
    required this.controller,
    this.onChanged,
    this.hintText = 'Search students, documents...',
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                height: 1.2,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: hintText,
                hintStyle:
                    const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox(width: 4);
              return IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                visualDensity: VisualDensity.compact,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminPanel extends StatelessWidget {
  const _AdminPanel({
    required this.title,
    required this.child,
    this.compact = false,
    this.expandChild = false,
    this.trailing,
    this.titleStyle,
  });

  final String title;
  final Widget child;
  final bool compact;
  final bool expandChild;
  final Widget? trailing;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: expandChild ? double.infinity : null,
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 18,
        compact ? 12 : 16,
        compact ? 14 : 18,
        compact ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 14 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 18,
            spreadRadius: 0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: titleStyle ??
                      TextStyle(
                        color: const Color(0xFF0F172A),
                        fontSize: compact ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (!compact)
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              height: 1,
              color: const Color(0xFFF1F5F9),
            )
          else
            const SizedBox(height: 10),
          if (expandChild) Expanded(child: child) else child,
        ],
      ),
    );
  }
}

class _ChartEntrance extends StatelessWidget {
  const _ChartEntrance({
    required this.child,
    this.delayMs = 0,
    this.animate = true,
  });

  final Widget child;
  final int delayMs;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return ClipRect(
          child: Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 14),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.hint,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E8EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(hint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminBarChart extends StatefulWidget {
  const _AdminBarChart({
    required this.values,
    required this.maxY,
    this.height = 260,
    this.compact = false,
    this.animate = true,
    this.interactive = true,
    this.valueUnit = 'students',
    this.yAxisLabel,
    this.showVerticalGrid = false,
    this.tooltipTitleForKey,
    this.tooltipSubtitleForKey,
    this.axisLabelForKey,
    this.axisSubtitleForKey,
    this.emphasizeCourseLabels = false,
  });

  final Map<String, int> values;
  final int maxY;
  final double height;
  final bool compact;
  final bool animate;
  final bool interactive;

  /// Noun used in the hover tooltip (e.g. "154 graduates").
  final String valueUnit;

  /// Rotated label on the left (e.g. "Number of Graduates").
  final String? yAxisLabel;

  /// Light vertical grid lines between categories.
  final bool showVerticalGrid;
  final String Function(String key)? tooltipTitleForKey;
  final String? Function(String key, int value)? tooltipSubtitleForKey;

  /// Bottom axis: primary line (defaults to map key).
  final String Function(String key)? axisLabelForKey;

  /// Bottom axis: second line under each bar (e.g. program codes under a year).
  final String? Function(String key)? axisSubtitleForKey;

  /// When true, bottom labels use each bar's color and bolder type (for BSCS, BSHM, …).
  final bool emphasizeCourseLabels;

  @override
  State<_AdminBarChart> createState() => _AdminBarChartState();
}

class _AdminBarChartState extends State<_AdminBarChart> {
  int? _hoveredIndex;
  Offset? _hoverLocal;

  void _setHover(int? index, {Offset? local}) {
    if (_hoveredIndex == index && _hoverLocal == local) return;
    setState(() {
      _hoveredIndex = index;
      _hoverLocal = local;
    });
  }

  Widget _buildChart(double progress, Size chartSize) {
    final painted = CustomPaint(
      size: chartSize,
      painter: _AdminBarChartPainter(
        values: widget.values,
        maxY: widget.maxY,
        progress: progress,
        compact: widget.compact,
        hoveredIndex: widget.interactive ? _hoveredIndex : null,
        yAxisLabel: widget.yAxisLabel,
        showVerticalGrid: widget.showVerticalGrid,
        axisLabelForKey: widget.axisLabelForKey,
        axisSubtitleForKey: widget.axisSubtitleForKey,
        emphasizeCourseLabels: widget.emphasizeCourseLabels,
      ),
    );

    if (!widget.interactive) return painted;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        final hasAxisSubtitle = widget.axisSubtitleForKey != null &&
            widget.values.keys.any((k) {
              final sub = widget.axisSubtitleForKey!(k);
              return sub != null && sub.trim().isNotEmpty;
            });
        final index = _BarChartGeometry.barIndexAt(
          local: event.localPosition,
          size: chartSize,
          values: widget.values,
          maxY: widget.maxY,
          compact: widget.compact,
          progress: progress,
          yAxisLabel: widget.yAxisLabel,
          hasAxisSubtitle: hasAxisSubtitle,
          emphasizeCourseLabels: widget.emphasizeCourseLabels,
        );
        _setHover(index, local: index != null ? event.localPosition : null);
      },
      onExit: (_) => _setHover(null),
      child: painted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartSize = Size(constraints.maxWidth, widget.height);
          final keys = widget.values.keys.toList();
          final hoveredKey = _hoveredIndex != null &&
                  _hoveredIndex! >= 0 &&
                  _hoveredIndex! < keys.length
              ? keys[_hoveredIndex!]
              : null;
          final hoveredValue =
              hoveredKey != null ? widget.values[hoveredKey] ?? 0 : 0;

          Widget buildStack(double progress) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                _buildChart(progress, chartSize),
                if (widget.interactive &&
                    hoveredKey != null &&
                    _hoverLocal != null &&
                    hoveredValue > 0)
                  _BarHoverTooltip(
                    title: widget.tooltipTitleForKey?.call(hoveredKey) ??
                        hoveredKey,
                    subtitle: widget.tooltipSubtitleForKey?.call(
                      hoveredKey,
                      hoveredValue,
                    ),
                    count: hoveredValue,
                    valueUnit: widget.valueUnit,
                    position: _hoverLocal!,
                    chartSize: chartSize,
                  ),
              ],
            );
          }

          if (widget.animate) {
            return TweenAnimationBuilder<double>(
              key: ValueKey(
                'bar-${widget.maxY}-${widget.compact}-${widget.values.length}',
              ),
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, progress, _) => buildStack(progress),
            );
          }
          return buildStack(1);
        },
      ),
    );
  }
}

class _BarHoverTooltip extends StatelessWidget {
  const _BarHoverTooltip({
    required this.title,
    required this.count,
    required this.valueUnit,
    required this.position,
    required this.chartSize,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final int count;
  final String valueUnit;
  final Offset position;
  final Size chartSize;

  @override
  Widget build(BuildContext context) {
    const maxTooltipW = 220.0;
    final left = (position.dx - maxTooltipW / 2)
        .clamp(8.0, chartSize.width - maxTooltipW - 8);
    final top = (position.dy - 72).clamp(8.0, chartSize.height - 80);

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxTooltipW),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x330F172A),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.poppins(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    '$count $valueUnit',
                    style: AppFonts.poppins(
                      color: const Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarChartGeometry {
  static double leftPad({String? yAxisLabel}) =>
      yAxisLabel != null && yAxisLabel.trim().isNotEmpty ? 48.0 : 36.0;

  static double bottomPad(
    bool compact, {
    bool hasAxisSubtitle = false,
    bool emphasizeCourseLabels = false,
  }) {
    if (hasAxisSubtitle) return compact ? 62.0 : 52.0;
    if (emphasizeCourseLabels) return compact ? 50.0 : 38.0;
    return compact ? 44.0 : 32.0;
  }

  static Rect plotArea(
    Size size,
    bool compact, {
    String? yAxisLabel,
    bool hasAxisSubtitle = false,
    bool emphasizeCourseLabels = false,
  }) {
    final left = leftPad(yAxisLabel: yAxisLabel);
    final bottom = bottomPad(
      compact,
      hasAxisSubtitle: hasAxisSubtitle,
      emphasizeCourseLabels: emphasizeCourseLabels,
    );
    return Rect.fromLTWH(
      left,
      12,
      size.width - left - 12,
      size.height - bottom - 12,
    );
  }

  static double barWidth(double slotW, int keyCount, bool compact) {
    return (slotW * (compact ? 0.52 : 0.44)).clamp(
      compact ? 18.0 : 22.0,
      compact ? (keyCount <= 2 ? 68.0 : 48.0) : 60.0,
    );
  }

  static Rect barRect({
    required int index,
    required Rect plot,
    required double slotW,
    required double barW,
    required int value,
    required int maxY,
    required double progress,
  }) {
    final rawH = plot.height * (value / maxY).clamp(0.0, 1.0) * progress;
    final h = value > 0 ? math.max(rawH, 8.0 * progress) : 0.0;
    final x = plot.left + index * slotW + (slotW - barW) / 2;
    return Rect.fromLTWH(x, plot.bottom - h, barW, h);
  }

  static int? barIndexAt({
    required Offset local,
    required Size size,
    required Map<String, int> values,
    required int maxY,
    required bool compact,
    required double progress,
    String? yAxisLabel,
    bool hasAxisSubtitle = false,
    bool emphasizeCourseLabels = false,
  }) {
    final keys = values.keys.toList();
    if (keys.isEmpty) return null;

    final plot = plotArea(
      size,
      compact,
      yAxisLabel: yAxisLabel,
      hasAxisSubtitle: hasAxisSubtitle,
      emphasizeCourseLabels: emphasizeCourseLabels,
    );
    if (!plot.inflate(4).contains(local)) return null;

    final slotW = plot.width / keys.length;
    final barW = barWidth(slotW, keys.length, compact);

    for (var i = 0; i < keys.length; i++) {
      final hit = barRect(
        index: i,
        plot: plot,
        slotW: slotW,
        barW: barW,
        value: values[keys[i]] ?? 0,
        maxY: maxY,
        progress: progress,
      );
      if (hit.contains(local)) return i;
    }
    return null;
  }
}

class _AdminBarChartPainter extends CustomPainter {
  _AdminBarChartPainter({
    required this.values,
    required this.maxY,
    required this.progress,
    this.compact = false,
    this.hoveredIndex,
    this.yAxisLabel,
    this.showVerticalGrid = false,
    this.axisLabelForKey,
    this.axisSubtitleForKey,
    this.emphasizeCourseLabels = false,
  });
  final Map<String, int> values;
  final int maxY;
  final double progress;
  final bool compact;
  final int? hoveredIndex;
  final String? yAxisLabel;
  final bool showVerticalGrid;
  final String Function(String key)? axisLabelForKey;
  final String? Function(String key)? axisSubtitleForKey;
  final bool emphasizeCourseLabels;

  bool get _hasAxisSubtitle {
    if (axisSubtitleForKey == null) return false;
    return values.keys.any((k) {
      final sub = axisSubtitleForKey!(k);
      return sub != null && sub.trim().isNotEmpty;
    });
  }

  static const _axisStyle = TextStyle(
    color: Color(0xFF64748B),
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static String _formatSharePercent(int value, int total) {
    if (total <= 0) return '0%';
    final pct = value / total * 100;
    return '${pct.toStringAsFixed(1)}%';
  }

  static void _paintBarValueLabel(
    Canvas canvas, {
    required String text,
    required double centerX,
    required double topY,
    required bool emphasize,
  }) {
    final style = TextStyle(
      color: emphasize ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
      fontSize: 11,
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
      height: 1,
    );
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(centerX - tp.width / 2, topY - tp.height - 8));
  }

  static void _paintYAxisTitle(Canvas canvas, String label, Rect plot) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: _axisStyle.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF94A3B8),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(10, plot.top + plot.height / 2);
    canvas.rotate(-math.pi / 2);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _BarChartGeometry.plotArea(
      size,
      compact,
      yAxisLabel: yAxisLabel,
      hasAxisSubtitle: _hasAxisSubtitle,
      emphasizeCourseLabels: emphasizeCourseLabels,
    );

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    final steps = _chartGridSteps(maxY);
    for (var i = 0; i <= steps; i++) {
      final y = plot.top + (plot.height / steps) * i;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        gridPaint,
      );
    }

    final keys = values.keys.toList();
    if (keys.isNotEmpty && showVerticalGrid) {
      final slotW = plot.width / keys.length;
      for (var i = 0; i <= keys.length; i++) {
        final x = plot.left + i * slotW;
        canvas.drawLine(
          Offset(x, plot.top),
          Offset(x, plot.bottom),
          gridPaint,
        );
      }
    }

    final textStyle = const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    final tickLeft = _BarChartGeometry.leftPad(yAxisLabel: yAxisLabel) - 8;
    for (var i = 0; i <= steps; i++) {
      final v = ((steps - i) * (maxY / steps)).round();
      final y = plot.top + (plot.height / steps) * i;
      final tp = TextPainter(
        text: TextSpan(text: v.toString(), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(tickLeft - tp.width, y - tp.height / 2));
    }

    if (yAxisLabel != null && yAxisLabel!.trim().isNotEmpty) {
      _paintYAxisTitle(canvas, yAxisLabel!.trim(), plot);
    }

    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 1,
    );

    if (keys.isEmpty) return;

    final total = values.values.fold<int>(0, (sum, n) => sum + n);
    final slotW = plot.width / keys.length;
    final barW = _BarChartGeometry.barWidth(slotW, keys.length, compact);
    final showValueLabels = keys.length <= 6;
    final hasHover = hoveredIndex != null;
    final topRadius = Radius.circular(math.min(10.0, barW / 2));

    for (var i = 0; i < keys.length; i++) {
      final k = keys[i];
      final v = values[k] ?? 0;
      final rawH = plot.height * (v / maxY).clamp(0.0, 1.0) * progress;
      final h = v > 0 ? math.max(rawH, 10.0 * progress) : 0.0;
      final x = plot.left + i * slotW + (slotW - barW) / 2;
      final color = _programChartColors[i % _programChartColors.length];
      final isHovered = hoveredIndex == i;
      final dimOthers = hasHover && !isHovered;

      if (h > 0) {
        final barRect = Rect.fromLTWH(x, plot.bottom - h, barW, h);
        final r = RRect.fromRectAndCorners(
          barRect,
          topLeft: topRadius,
          topRight: topRadius,
        );
        canvas.drawRRect(
          r,
          Paint()..color = dimOthers ? color.withValues(alpha: 0.45) : color,
        );
        if (isHovered && !dimOthers) {
          canvas.drawRRect(
            r,
            Paint()
              ..color = color.withValues(alpha: 0.18)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }

      if (showValueLabels && v > 0 && progress > 0.85) {
        _paintBarValueLabel(
          canvas,
          text: _formatSharePercent(v, total),
          centerX: x + barW / 2,
          topY: plot.bottom - h,
          emphasize: i == 0,
        );
      }

      final mainLabel = axisLabelForKey?.call(k) ?? k;
      final subtitle = axisSubtitleForKey?.call(k)?.trim();
      final hasSubtitle = subtitle != null && subtitle.isNotEmpty;
      final barColor = _programChartColors[i % _programChartColors.length];

      final mainStyle = emphasizeCourseLabels
          ? textStyle.copyWith(
              color: barColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            )
          : hasSubtitle
              ? textStyle.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                )
              : textStyle.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                );

      final mainBaseline = plot.bottom + 8;
      final mainHeight = _paintBarAxisLabel(
        canvas: canvas,
        label: mainLabel,
        centerX: x + barW / 2,
        baselineY: mainBaseline,
        maxWidth: slotW - 6,
        style: mainStyle,
        compact: compact && !emphasizeCourseLabels && mainLabel.length > 8,
        forceHorizontal: emphasizeCourseLabels || mainLabel.length <= 10,
      );

      if (hasSubtitle) {
        final subStyle = emphasizeCourseLabels
            ? textStyle.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              )
            : textStyle.copyWith(
                color: barColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              );
        _paintBarAxisLabel(
          canvas: canvas,
          label: subtitle,
          centerX: x + barW / 2,
          baselineY: mainBaseline + mainHeight + 3,
          maxWidth: slotW - 4,
          style: subStyle,
          compact: compact && subtitle.length > 12,
          forceHorizontal: subtitle.length <= 14,
        );
      }

      final tickX = plot.left + (i + 1) * slotW;
      canvas.drawLine(
        Offset(tickX, plot.bottom),
        Offset(tickX, plot.bottom + 4),
        Paint()
          ..color = const Color(0xFFCBD5E1)
          ..strokeWidth = 1,
      );
    }
  }

  static String _fitAxisLabel(String raw, double maxWidth, TextStyle style) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    var tp = TextPainter(
      text: TextSpan(text: trimmed, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);
    if (tp.width <= maxWidth) return trimmed;

    var end = trimmed.length;
    while (end > 2) {
      final candidate = '${trimmed.substring(0, end)}…';
      tp = TextPainter(
        text: TextSpan(text: candidate, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: maxWidth);
      if (tp.width <= maxWidth) return candidate;
      end--;
    }
    return trimmed.substring(0, 1);
  }

  static double _paintBarAxisLabel({
    required Canvas canvas,
    required String label,
    required double centerX,
    required double baselineY,
    required double maxWidth,
    required TextStyle style,
    required bool compact,
    bool forceHorizontal = false,
  }) {
    final fitted = _fitAxisLabel(label, maxWidth, style);
    var tp = TextPainter(
      text: TextSpan(text: fitted, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);

    if (forceHorizontal || !compact || tp.width <= maxWidth) {
      tp.paint(canvas, Offset(centerX - tp.width / 2, baselineY));
      return tp.height;
    }

    canvas.save();
    canvas.translate(centerX, baselineY + 4);
    canvas.rotate(-0.55);
    tp = TextPainter(
      text: TextSpan(text: fitted, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth * 1.6);
    tp.paint(canvas, Offset(-tp.width / 2, 0));
    canvas.restore();
    return tp.height + 8;
  }

  @override
  bool shouldRepaint(covariant _AdminBarChartPainter oldDelegate) =>
      oldDelegate.maxY != maxY ||
      oldDelegate.compact != compact ||
      oldDelegate.progress != progress ||
      oldDelegate.hoveredIndex != hoveredIndex ||
      oldDelegate.yAxisLabel != yAxisLabel ||
      oldDelegate.showVerticalGrid != showVerticalGrid ||
      oldDelegate.emphasizeCourseLabels != emphasizeCourseLabels ||
      oldDelegate.values.toString() != values.toString();
}

/// Top-N bar palette (blue, lavender, orange, green, blue).
const _programChartColors = <Color>[
  Color(0xFF3B82F6),
  Color(0xFFA78BFA),
  Color(0xFFFB923C),
  Color(0xFF22C55E),
  Color(0xFF3B82F6),
  Color(0xFF60A5FA),
  Color(0xFFF472B6),
];

class _PieSeg {
  const _PieSeg(this.label, this.percent, this.color, {this.count = 0});
  final String label;
  final int percent;
  final Color color;
  final int count;
}

class _AdminPieChart extends StatefulWidget {
  const _AdminPieChart({
    required this.segments,
    this.compact = false,
    this.animate = true,
    this.interactive = true,
  });

  final List<_PieSeg> segments;
  final bool compact;
  final bool animate;
  final bool interactive;

  @override
  State<_AdminPieChart> createState() => _AdminPieChartState();
}

class _AdminPieChartState extends State<_AdminPieChart> {
  int? _hoveredIndex;
  Offset? _hoverLocal;

  void _setHover(int? index, {Offset? local}) {
    if (_hoveredIndex == index && _hoverLocal == local) return;
    setState(() {
      _hoveredIndex = index;
      _hoverLocal = local;
    });
  }

  Widget _buildPieStack({
    required List<_PieSeg> segments,
    required bool compact,
    required double chartSide,
  }) {
    Widget buildStack(double progress) {
      final chartSize = Size(chartSide, chartSide);
      final chart = CustomPaint(
        size: chartSize,
        painter: _AdminPiePainter(
          segments: segments,
          progress: progress,
          compact: compact,
          hoveredIndex: widget.interactive ? _hoveredIndex : null,
        ),
      );

      final painted = widget.interactive
          ? MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: (event) {
                final index = _PieChartGeometry.segmentIndexAt(
                  local: event.localPosition,
                  size: chartSize,
                  segments: segments,
                  progress: progress,
                );
                _setHover(
                  index,
                  local: index != null ? event.localPosition : null,
                );
              },
              onExit: (_) => _setHover(null),
              child: chart,
            )
          : chart;

      return Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          painted,
          if (widget.interactive &&
              _hoveredIndex != null &&
              _hoverLocal != null &&
              _hoveredIndex! < segments.length)
            _PieHoverTooltip(
              segment: segments[_hoveredIndex!],
              position: _hoverLocal!,
              chartSize: chartSize,
              compact: compact,
            ),
        ],
      );
    }

    if (!widget.animate) {
      return buildStack(1);
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('pie-${segments.length}-${segments.hashCode}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) => buildStack(progress),
    );
  }

  @override
  Widget build(BuildContext context) {
    final segments = widget.segments;
    final compact = widget.compact;

    if (segments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.donut_large_outlined,
              size: compact ? 36 : 40,
              color: const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 10),
            Text(
              'No program records yet',
              style: AppFonts.poppins(
                color: const Color(0xFF94A3B8),
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (compact) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final sideLegend = constraints.maxWidth >= 300;
          final legend = _PieChartLegend(
            segments: segments,
            compact: compact,
            hoveredIndex: _hoveredIndex,
            onHover: (index) => _setHover(index),
          );

          if (sideLegend) {
            final chartSide = math.min(
              constraints.maxHeight,
              math.min(constraints.maxWidth * 0.38, 168.0),
            );
            if (chartSide <= 0) return const SizedBox.shrink();

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: chartSide,
                  height: chartSide,
                  child: _buildPieStack(
                    segments: segments,
                    compact: compact,
                    chartSide: chartSide,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: legend,
                    ),
                  ),
                ),
              ],
            );
          }

          final chartSide = math
              .min(constraints.maxWidth, constraints.maxHeight * 0.58)
              .toDouble();
          if (chartSide <= 0) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: chartSide,
                    height: chartSide,
                    child: _buildPieStack(
                      segments: segments,
                      compact: compact,
                      chartSide: chartSide,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: legend,
                ),
              ),
            ],
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final legendHeight = _PieChartLegend.estimatedHeight(
          segments.length,
          compact: compact,
        );
        const gap = 10.0;
        final chartSide = math
            .min(
              constraints.maxWidth,
              math.max(0.0, constraints.maxHeight - legendHeight - gap),
            )
            .toDouble();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: chartSide,
              height: chartSide,
              child: _buildPieStack(
                segments: segments,
                compact: compact,
                chartSide: chartSide,
              ),
            ),
            const SizedBox(height: gap),
            SizedBox(
              width: constraints.maxWidth,
              child: _PieChartLegend(
                segments: segments,
                compact: compact,
                hoveredIndex: _hoveredIndex,
                onHover: (index) => _setHover(index),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PieHoverTooltip extends StatelessWidget {
  const _PieHoverTooltip({
    required this.segment,
    required this.position,
    required this.chartSize,
    this.compact = false,
  });

  final _PieSeg segment;
  final Offset position;
  final Size chartSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    const tooltipW = 148.0;
    const tooltipH = 54.0;
    final left =
        (position.dx - tooltipW / 2).clamp(4.0, chartSize.width - tooltipW - 4);
    final top = (position.dy - tooltipH - 14)
        .clamp(4.0, chartSize.height - tooltipH - 4);

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          child: Container(
            width: tooltipW,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330F172A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  segment.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.poppins(
                    color: Colors.white,
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${segment.count} students · ${segment.percent}%',
                  style: AppFonts.poppins(
                    color: const Color(0xFFCBD5E1),
                    fontSize: compact ? 10 : 11,
                    fontWeight: FontWeight.w500,
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

class _PieChartGeometry {
  static const _tau = math.pi * 2;
  static const _startAngle = -math.pi / 2;

  static ({Offset center, double strokeWidth, double arcRadius}) layout(
    Size size,
  ) {
    final center = Offset(size.width / 2, size.height / 2);
    final dim = math.min(size.width, size.height);
    final radius = (dim * 0.44).clamp(40.0, 130.0);
    final strokeWidth = (radius * 0.34).clamp(20.0, 46.0);
    final arcRadius = radius - strokeWidth / 2;
    return (center: center, strokeWidth: strokeWidth, arcRadius: arcRadius);
  }

  static int? segmentIndexAt({
    required Offset local,
    required Size size,
    required List<_PieSeg> segments,
    double progress = 1,
  }) {
    final geo = layout(size);
    final delta = local - geo.center;
    final dist = delta.distance;
    final inner = geo.arcRadius - geo.strokeWidth / 2 - 4;
    final outer = geo.arcRadius + geo.strokeWidth / 2 + 4;
    if (dist < inner || dist > outer) return null;

    var angle = math.atan2(delta.dy, delta.dx) - _startAngle;
    if (angle < 0) angle += _tau;
    if (angle >= _tau) angle -= _tau;

    var cursor = 0.0;
    for (var i = 0; i < segments.length; i++) {
      final sweep = (segments[i].percent / 100) * _tau * progress;
      if (angle >= cursor && angle < cursor + sweep) return i;
      cursor += sweep;
    }
    return null;
  }
}

class _PieChartLegend extends StatelessWidget {
  const _PieChartLegend({
    required this.segments,
    this.compact = false,
    this.hoveredIndex,
    this.onHover,
  });

  final List<_PieSeg> segments;
  final bool compact;
  final int? hoveredIndex;
  final ValueChanged<int?>? onHover;

  static const _rowGap = 4.0;

  static double estimatedHeight(int segmentCount, {bool compact = false}) {
    if (segmentCount <= 0) return 0;
    if (compact) {
      return segmentCount * 24.0 + math.max(0, segmentCount - 1) * _rowGap;
    }
    final rows = (segmentCount / 2).ceil();
    return rows * 32.0 + math.max(0, rows - 1) * _rowGap;
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(height: _rowGap),
            MouseRegion(
              onEnter: (_) => onHover?.call(i),
              onExit: (_) => onHover?.call(null),
              child: _PieLegendRow(
                segment: segments[i],
                compact: true,
                highlighted: hoveredIndex == i,
              ),
            ),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const columnGap = 16.0;
        final itemWidth = (constraints.maxWidth - columnGap) / 2;
        return Wrap(
          spacing: columnGap,
          runSpacing: _rowGap,
          children: [
            for (var i = 0; i < segments.length; i++)
              SizedBox(
                width: itemWidth,
                child: MouseRegion(
                  onEnter: (_) => onHover?.call(i),
                  onExit: (_) => onHover?.call(null),
                  child: _PieLegendRow(
                    segment: segments[i],
                    highlighted: hoveredIndex == i,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PieLegendRow extends StatelessWidget {
  const _PieLegendRow({
    required this.segment,
    this.compact = false,
    this.highlighted = false,
  });

  final _PieSeg segment;
  final bool compact;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final labelSize = compact ? 12.0 : 13.0;
    final metaSize = compact ? 11.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 2 : 4),
      child: Row(
        children: [
          Container(
            width: compact ? 6 : 7,
            height: compact ? 6 : 7,
            decoration: BoxDecoration(
              color: segment.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: compact ? 8 : 10),
          Expanded(
            child: Text(
              segment.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.poppins(
                color: highlighted
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF475569),
                fontSize: labelSize,
                fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
          Text(
            '${segment.count}',
            style: AppFonts.poppins(
              color: const Color(0xFF0F172A),
              fontSize: metaSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: compact ? 34 : 38,
            child: Text(
              '${segment.percent}%',
              textAlign: TextAlign.end,
              style: AppFonts.poppins(
                color: const Color(0xFF94A3B8),
                fontSize: metaSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPiePainter extends CustomPainter {
  _AdminPiePainter({
    required this.segments,
    required this.progress,
    this.compact = false,
    this.hoveredIndex,
  });

  final List<_PieSeg> segments;
  final double progress;
  final bool compact;
  final int? hoveredIndex;

  static const _tau = math.pi * 2;
  static const _startAngle = -math.pi / 2;
  static const _trackColor = Color(0xFFF1F5F9);
  static double _gapRadiansFor(int segmentCount) =>
      segmentCount <= 6 ? 0.012 : 0.022;

  @override
  void paint(Canvas canvas, Size size) {
    final geo = _PieChartGeometry.layout(size);
    final center = geo.center;
    final strokeWidth = geo.strokeWidth;
    final arcRadius = geo.arcRadius;
    final dim = math.min(size.width, size.height);
    final radius = (dim * 0.44).clamp(40.0, 130.0);
    final arcRect = Rect.fromCircle(center: center, radius: arcRadius);
    final totalStudents =
        segments.fold<int>(0, (sum, segment) => sum + segment.count);
    final hasHover = hoveredIndex != null;

    canvas.drawCircle(
      center,
      radius + 6,
      Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = _trackColor;
    canvas.drawArc(arcRect, 0, _tau, false, trackPaint);

    final gapRadians = _gapRadiansFor(segments.length);
    var start = _startAngle;
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final sweep = (segment.percent / 100) * _tau * progress;
      final drawSweep = math.max(0.0, sweep - gapRadians);
      if (drawSweep <= 0) {
        start += sweep;
        continue;
      }

      final isHovered = hoveredIndex == i;
      final dimOthers = hasHover && !isHovered;
      final midAngle = start + drawSweep / 2;
      final explode = isHovered ? 6.0 : 0.0;
      final segmentCenter = Offset(
        center.dx + math.cos(midAngle) * explode,
        center.dy + math.sin(midAngle) * explode,
      );
      final segmentRect = Rect.fromCircle(
        center: segmentCenter,
        radius: arcRadius,
      );
      final segmentStroke = isHovered ? strokeWidth * 1.08 : strokeWidth;

      final segmentPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = segmentStroke
        ..strokeCap = StrokeCap.round
        ..color =
            dimOthers ? segment.color.withValues(alpha: 0.38) : segment.color;

      canvas.drawArc(segmentRect, start, drawSweep, false, segmentPaint);
      start += sweep;
    }

    final innerRadius = arcRadius - strokeWidth / 2 - 3;
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()
        ..color = const Color(0xFFE8EDF3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final countStyle = AppFonts.poppins(
      color: const Color(0xFF0F172A),
      fontSize: compact ? 26 : 24,
      fontWeight: FontWeight.w700,
      height: 1,
    );
    final labelStyle = AppFonts.poppins(
      color: const Color(0xFF64748B),
      fontSize: compact ? 11 : 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    );

    final countPainter = TextPainter(
      text: TextSpan(text: '$totalStudents', style: countStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: innerRadius * 1.8);

    final labelPainter = TextPainter(
      text: TextSpan(text: 'students', style: labelStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: innerRadius * 1.8);

    final blockH = countPainter.height + 4 + labelPainter.height;
    final top = center.dy - blockH / 2;

    countPainter.paint(
      canvas,
      Offset(center.dx - countPainter.width / 2, top),
    );
    labelPainter.paint(
      canvas,
      Offset(
        center.dx - labelPainter.width / 2,
        top + countPainter.height + 4,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _AdminPiePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.compact != compact ||
      oldDelegate.hoveredIndex != hoveredIndex ||
      oldDelegate.segments.toString() != segments.toString();
}

class _AdminUploadsTable extends StatefulWidget {
  const _AdminUploadsTable({
    required this.rows,
    this.compact = false,
    this.onViewStudentDocuments,
  });

  final List<_DocRow> rows;
  final bool compact;
  final ValueChanged<String>? onViewStudentDocuments;

  @override
  State<_AdminUploadsTable> createState() => _AdminUploadsTableState();
}

class _AdminUploadsTableState extends State<_AdminUploadsTable> {
  final Set<String> _expandedStudents = {};

  static const _pageSize = 5;

  int _currentPage = 0;
  List<MapEntry<String, List<_DocRow>>>? _cachedGroups;
  List<_DocRow>? _cachedRowsSource;

  @override
  void didUpdateWidget(covariant _AdminUploadsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.rows, widget.rows)) {
      _cachedGroups = null;
      _cachedRowsSource = null;
      _currentPage = 0;
      _expandedStudents.clear();
    } else if (_currentPage >= _totalPages && _totalPages > 0) {
      _currentPage = _totalPages - 1;
    }
  }

  List<MapEntry<String, List<_DocRow>>> get _allGroups {
    if (_cachedGroups != null && identical(_cachedRowsSource, widget.rows)) {
      return _cachedGroups!;
    }
    _cachedRowsSource = widget.rows;
    _cachedGroups = _sortedStudentGroups(widget.rows);
    return _cachedGroups!;
  }

  int get _totalPages {
    final count = _allGroups.length;
    if (count == 0) return 0;
    return (count + _pageSize - 1) ~/ _pageSize;
  }

  List<MapEntry<String, List<_DocRow>>> get _pageGroups {
    final groups = _allGroups;
    if (groups.isEmpty) return const [];
    final maxPageIndex = _totalPages > 0 ? _totalPages - 1 : 0;
    final safePage = _currentPage < 0
        ? 0
        : (_currentPage > maxPageIndex ? maxPageIndex : _currentPage);
    final start = safePage * _pageSize;
    if (start >= groups.length) return const [];
    final end = math.min(start + _pageSize, groups.length);
    return groups.sublist(start, end);
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages || page == _currentPage) return;
    setState(() {
      _currentPage = page;
      _expandedStudents.clear();
    });
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

  Widget _buildPaginationControls(bool compact) {
    if (_totalPages <= 1) return const SizedBox.shrink();

    final groups = _allGroups;
    final rangeStart = _currentPage * _pageSize + 1;
    final rangeEnd = math.min((_currentPage + 1) * _pageSize, groups.length);
    final labelStyle = AppFonts.poppins(
      fontSize: compact ? 11 : 12,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF64748B),
    );

    return Padding(
      padding: EdgeInsets.only(top: compact ? 8 : 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$rangeStart–$rangeEnd of ${groups.length} students',
              style: labelStyle,
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
            color: const Color(0xFF64748B),
          ),
          for (final page in _visiblePageNumbers())
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: page == _currentPage
                    ? const Color(0xFF2563EB)
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
                            : const Color(0xFF475569),
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
            color: const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final headerSize = compact ? 12.0 : 13.0;
    final nameSize = compact ? 13.0 : 14.0;
    final metaSize = compact ? 12.0 : 13.0;
    final actionSize = compact ? 11.0 : 12.0;
    final detailSize = compact ? 11.0 : 12.0;
    final rowMinHeight = compact ? 42.0 : 46.0;
    final viewWidth = compact ? 48.0 : 52.0;

    final headerStyle = AppFonts.poppins(
      color: const Color(0xFF475569),
      fontSize: headerSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );
    final groups = _pageGroups;

    if (_allGroups.isEmpty) {
      return Center(
        child: Text(
          'No uploads yet',
          style: AppFonts.poppins(
            color: const Color(0xFF94A3B8),
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(flex: 5, child: Text('Student', style: headerStyle)),
              Expanded(flex: 2, child: Text('Files', style: headerStyle)),
              Expanded(flex: 2, child: Text('Latest', style: headerStyle)),
              SizedBox(width: viewWidth),
            ],
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: groups.length,
            separatorBuilder: (_, __) => SizedBox(height: compact ? 5 : 6),
            itemBuilder: (context, index) {
              final entry = groups[index];
              final studentKey = entry.key;
              final docs = entry.value;
              final expanded = _expandedStudents.contains(studentKey);
              final latest = _latestUploadLabel(docs);

              return DecoratedBox(
                decoration: BoxDecoration(
                  color: expanded ? const Color(0xFFF8FAFC) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: expanded
                        ? const Color(0xFFBFDBFE)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (expanded) {
                              _expandedStudents.remove(studentKey);
                            } else {
                              _expandedStudents.add(studentKey);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: rowMinHeight),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 8 : 10,
                              vertical: compact ? 6 : 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  expanded
                                      ? Icons.expand_more_rounded
                                      : Icons.chevron_right_rounded,
                                  size: compact ? 20 : 22,
                                  color: const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    _studentDisplayName(studentKey),
                                    style: AppFonts.poppins(
                                      color: const Color(0xFF0F172A),
                                      fontSize: nameSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: compact ? 7 : 8,
                                        vertical: compact ? 2 : 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${docs.length} file${docs.length == 1 ? '' : 's'}',
                                        style: AppFonts.poppins(
                                          color: const Color(0xFF1D4ED8),
                                          fontSize: metaSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    latest,
                                    style: AppFonts.poppins(
                                      color: const Color(0xFF64748B),
                                      fontSize: metaSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.onViewStudentDocuments != null)
                                  SizedBox(
                                    width: viewWidth,
                                    child: TextButton(
                                      onPressed: () =>
                                          widget.onViewStudentDocuments!(
                                        studentKey,
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        foregroundColor:
                                            const Color(0xFF2563EB),
                                        backgroundColor:
                                            const Color(0xFFEFF6FF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'View',
                                        style: AppFonts.poppins(
                                          fontSize: actionSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  SizedBox(width: viewWidth),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (expanded) ...[
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE2E8F0),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 12 : 14,
                          compact ? 6 : 8,
                          compact ? 10 : 12,
                          compact ? 10 : 12,
                        ),
                        child: Column(
                          children: [
                            for (final doc in docs)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: compact ? 5 : 6,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _docIcon(doc),
                                      size: compact ? 16 : 18,
                                      color: const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        doc.title,
                                        style: AppFonts.poppins(
                                          color: const Color(0xFF334155),
                                          fontSize: detailSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      doc.uploaded,
                                      style: AppFonts.poppins(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: detailSize,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _openDocPreview(context, doc),
                                      icon: Icon(
                                        Icons.visibility_outlined,
                                        size: compact ? 18 : 20,
                                        color: const Color(0xFF2563EB),
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(
                                        minWidth: compact ? 28 : 32,
                                        minHeight: compact ? 28 : 32,
                                      ),
                                      tooltip: 'Preview file',
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        _buildPaginationControls(compact),
      ],
    );
  }

  static List<MapEntry<String, List<_DocRow>>> _sortedStudentGroups(
    List<_DocRow> rows,
  ) {
    final grouped = <String, List<_DocRow>>{};
    for (final row in rows) {
      final key =
          row.student.trim().isEmpty ? 'Unknown student' : row.student.trim();
      grouped.putIfAbsent(key, () => []).add(row);
    }

    for (final docs in grouped.values) {
      docs.sort((a, b) {
        final aDate = _parseUploaded(a.uploaded);
        final bDate = _parseUploaded(b.uploaded);
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) {
        final aDate = _parseUploaded(_latestUploadLabel(a.value));
        final bDate = _parseUploaded(_latestUploadLabel(b.value));
        if (aDate == null && bDate == null) {
          return a.key.toLowerCase().compareTo(b.key.toLowerCase());
        }
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

    return entries;
  }

  static DateTime? _parseUploaded(String uploaded) {
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

  static String _latestUploadLabel(List<_DocRow> docs) {
    if (docs.isEmpty) return '—';
    return docs.first.uploaded;
  }

  static String _studentDisplayName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Unknown student';
    for (final sep in [' — ', ' - ', '\u2014', 'â€”']) {
      final parts = trimmed.split(sep);
      if (parts.length > 1) {
        return parts.sublist(1).join(sep).trim();
      }
    }
    return trimmed;
  }

  static IconData _docIcon(_DocRow doc) {
    final type = doc.type.toLowerCase();
    if (type.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (type.contains('image')) return Icons.image_outlined;
    return Icons.insert_drive_file_outlined;
  }

  static bool _canPreviewImage(_DocRow doc) {
    return doc.type.toLowerCase().contains('image/') ||
        (doc.localImagePath?.trim().isNotEmpty ?? false) ||
        doc.remoteImageUrl.trim().isNotEmpty;
  }

  void _openDocPreview(BuildContext context, _DocRow doc) {
    if (!_canPreviewImage(doc)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Preview is only available for image files.',
            style: AppFonts.poppins(),
          ),
        ),
      );
      return;
    }

    final localPath = doc.localImagePath?.trim() ?? '';
    final remoteUrl = doc.remoteImageUrl.trim();
    if (localPath.isEmpty && remoteUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image preview is not available for this document.',
            style: AppFonts.poppins(),
          ),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 720,
            height: 520,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doc.title,
                        style: AppFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close, size: 20),
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
                                  style: AppFonts.poppins(
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              )
                            : Image.network(
                                remoteUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Text(
                                  'Could not load image from server.',
                                  style: AppFonts.poppins(
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
        );
      },
    );
  }
}

class _DashboardSearchCard extends StatelessWidget {
  const _DashboardSearchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6E8EB)),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search apps, users, and activity logs',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Text(
            'Ctrl + K',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _DashboardStatTile extends StatelessWidget {
  const _DashboardStatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.hint,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E8EB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(hint,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentUploadsTable extends StatelessWidget {
  const _RecentUploadsTable({required this.rows});
  final List<_DocRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: Center(
          child: Text(
            'No documents uploaded yet.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return _TableCard(
      headers: const ['Document', 'Student', 'Uploaded'],
      rows: rows.map((d) {
        return [
          Text(d.title, overflow: TextOverflow.ellipsis),
          Text(d.student, style: const TextStyle(color: Color(0xFF64748B))),
          Text(d.uploaded, style: const TextStyle(color: Color(0xFF64748B))),
        ];
      }).toList(),
    );
  }
}

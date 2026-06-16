part of '../../dashboard_shell_page.dart';

/// Shared KPI card used on the admin dashboard and data analytics pages.
class _AdminMetricHighlightCard extends StatelessWidget {
  const _AdminMetricHighlightCard({
    required this.dimension,
    required this.metricValue,
    required this.metricLabel,
    required this.icon,
    required this.accent,
    this.label,
    this.secondaryValue,
    this.secondaryLabel,
  });

  final String dimension;
  final String? label;
  final String metricValue;
  final String metricLabel;
  final IconData icon;
  final Color accent;
  final String? secondaryValue;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.trim().isNotEmpty;
    final hasSecondary =
        secondaryValue != null && secondaryLabel != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _AdminDashTheme.border),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            accent.withValues(alpha: 0.14),
            Colors.white,
          ],
          stops: const [0.0, 0.72],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dimension.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          if (hasLabel) ...[
            const SizedBox(height: 12),
            Text(
              label!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _AdminDashTheme.textPrimary,
                height: 1.25,
              ),
            ),
          ],
          SizedBox(height: hasLabel ? 10 : 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                metricValue,
                style: AppFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  metricLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _AdminDashTheme.textMuted,
                  ),
                ),
              ),
              if (hasSecondary) ...[
                const SizedBox(width: 14),
                Text(
                  secondaryValue!,
                  style: AppFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    secondaryLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _AdminDashTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminDashboardStatsRow extends StatelessWidget {
  const _AdminDashboardStatsRow({required this.data});

  final _DashboardBaseData data;

  @override
  Widget build(BuildContext context) {
    final metrics = _adminDashStatMetrics();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final compact = maxWidth < _AdminDashTheme.statColumnsMedium;
        final columns = _AdminDashTheme.statColumnCount(maxWidth);

        final cards = [
          for (final metric in metrics)
            _AdminMetricHighlightCard(
              dimension: metric.title,
              metricValue: metric.valueOf(data),
              metricLabel: metric.hintOf(data),
              icon: metric.icon,
              accent: metric.accent,
            ),
        ];

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: _AdminDashTheme.statSpacing),
                cards[i],
              ],
            ],
          );
        }

        if (columns < 4) {
          final cardWidth = (maxWidth -
                  ((columns - 1) * _AdminDashTheme.statSpacing)) /
              columns;
          return Wrap(
            spacing: _AdminDashTheme.statSpacing,
            runSpacing: _AdminDashTheme.statSpacing,
            children: [
              for (final card in cards)
                SizedBox(width: cardWidth, child: card),
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: _AdminDashTheme.statSpacing),
                Expanded(child: cards[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

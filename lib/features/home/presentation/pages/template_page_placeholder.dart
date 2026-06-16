part of 'dashboard_shell_page.dart';

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.breadcrumbs,
    this.onBack,
    this.onBreadcrumbTap,
    this.backTooltip,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<String>? breadcrumbs;
  final VoidCallback? onBack;
  final ValueChanged<int>? onBreadcrumbTap;
  final String? backTooltip;

  @override
  Widget build(BuildContext context) {
    final crumbs = breadcrumbs;
    final hasBreadcrumbs = crumbs != null && crumbs.isNotEmpty;
    final titleMatchesCurrentCrumb =
        hasBreadcrumbs && crumbs.last.trim() == title.trim();
    final showTitle = !titleMatchesCurrentCrumb;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18,
        hasBreadcrumbs ? 12 : 16,
        18,
        showTitle || (subtitle?.isNotEmpty ?? false) ? 16 : 12,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _RecordListTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasBreadcrumbs) ...[
            _RecordBreadcrumb(
              segments: crumbs,
              onBack: onBack,
              onSegmentTap: onBreadcrumbTap,
              backTooltip: backTooltip ?? 'Go back',
              maxSegmentWidth: 280,
            ),
            if (showTitle || (subtitle?.isNotEmpty ?? false))
              const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showTitle)
                      Text(
                        title,
                        style: AppFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _RecordListTheme.textPrimary,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      if (showTitle) const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppFonts.poppins(
                          color: const Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TemplatePagePlaceholder extends StatelessWidget {
  const _TemplatePagePlaceholder({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _PageHeader(title: title, subtitle: subtitle);
  }
}

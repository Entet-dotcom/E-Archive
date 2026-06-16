part of 'dashboard_shell_page.dart';

/// Shared layout and table styling for Colleges, Courses, Settings, etc.
abstract final class _RecordListTheme {
  static const cardRadius = 12.0;
  static const border = Color(0xFFE5E7EB);
  static const headerBg = Color(0xFFF8FAFC);
  static const rowHover = Color(0xFFF8FAFC);
  static const textPrimary = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);

  // Breadcrumb navigation
  static const breadcrumbBg = Color(0xFFF8FAFC);
  static const breadcrumbBorder = Color(0xFFE2E8F0);
  static const breadcrumbLink = Color(0xFF475569);
  static const breadcrumbLinkHover = Color(0xFF2563EB);
  static const breadcrumbCurrentBg = Color(0xFFEEF2FF);
  static const breadcrumbCurrentBorder = Color(0xFFC7D2FE);
  static const breadcrumbCurrentText = Color(0xFF1E293B);
}

class _RecordBreadcrumb extends StatelessWidget {
  const _RecordBreadcrumb({
    required this.segments,
    this.onBack,
    this.onSegmentTap,
    this.backTooltip = 'Go back',
    this.maxSegmentWidth = 220,
  });

  final List<String> segments;
  final VoidCallback? onBack;
  final ValueChanged<int>? onSegmentTap;
  final String backTooltip;
  final double maxSegmentWidth;

  static const _separator = _BreadcrumbSeparator();

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();

    return Semantics(
      container: true,
      label: 'Breadcrumb: ${segments.join(', ')}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: _RecordListTheme.breadcrumbBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _RecordListTheme.breadcrumbBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (onBack != null) ...[
              _BreadcrumbBackButton(
                onPressed: onBack!,
                tooltip: backTooltip,
              ),
              Container(
                width: 1,
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: _RecordListTheme.breadcrumbBorder,
              ),
            ],
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final items = _resolveItems(constraints.maxWidth);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: constraints.maxWidth),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < items.length; i++) ...[
                            if (i > 0) _separator,
                            items[i].build(
                              context: context,
                              isCurrent: i == items.length - 1,
                              maxWidth: maxSegmentWidth,
                              onSegmentTap: onSegmentTap,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_BreadcrumbItem> _resolveItems(double maxWidth) {
    if (segments.isEmpty) return const [];

    final estimated = _estimateTrailWidth(segments);
    if (segments.length <= 3 || estimated <= maxWidth) {
      return [
        for (var i = 0; i < segments.length; i++)
          _BreadcrumbItem.segment(label: segments[i], index: i),
      ];
    }

    final hidden = segments.sublist(1, segments.length - 1);
    return [
      _BreadcrumbItem.segment(label: segments.first, index: 0),
      _BreadcrumbItem.collapsed(hidden: hidden, startIndex: 1),
      _BreadcrumbItem.segment(
        label: segments.last,
        index: segments.length - 1,
      ),
    ];
  }

  double _estimateTrailWidth(List<String> labels) {
    const separatorWidth = 22.0;
    const charWidth = 7.2;
    var width = 0.0;
    for (var i = 0; i < labels.length; i++) {
      final label = labels[i];
      final isLast = i == labels.length - 1;
      final cap = isLast ? maxSegmentWidth * 1.35 : maxSegmentWidth;
      width += (label.length * charWidth).clamp(48.0, cap);
      if (i > 0) width += separatorWidth;
    }
    return width;
  }
}

class _BreadcrumbBackButton extends StatelessWidget {
  const _BreadcrumbBackButton({
    required this.onPressed,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        hoverColor: _RecordListTheme.breadcrumbCurrentBg,
        child: Tooltip(
          message: tooltip,
          child: Semantics(
            button: true,
            label: tooltip,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _RecordListTheme.breadcrumbBorder),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: _RecordListTheme.breadcrumbLink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BreadcrumbSeparator extends StatelessWidget {
  const _BreadcrumbSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 15,
        color: _RecordListTheme.textHint.withValues(alpha: 0.85),
      ),
    );
  }
}

class _BreadcrumbItem {
  const _BreadcrumbItem._({
    required this.label,
    this.index,
    this.hidden = const [],
    this.startIndex = 0,
    this.isCollapsed = false,
  });

  factory _BreadcrumbItem.segment({
    required String label,
    required int index,
  }) =>
      _BreadcrumbItem._(label: label, index: index);

  factory _BreadcrumbItem.collapsed({
    required List<String> hidden,
    required int startIndex,
  }) =>
      _BreadcrumbItem._(
        label: '…',
        hidden: hidden,
        startIndex: startIndex,
        isCollapsed: true,
      );

  final String label;
  final int? index;
  final List<String> hidden;
  final int startIndex;
  final bool isCollapsed;

  Widget build({
    required BuildContext context,
    required bool isCurrent,
    required double maxWidth,
    ValueChanged<int>? onSegmentTap,
  }) {
    if (isCollapsed) {
      return _BreadcrumbCollapsedMenu(
        hidden: hidden,
        startIndex: startIndex,
        onSegmentTap: onSegmentTap,
      );
    }

    final segmentIndex = index!;
    final tappable = !isCurrent && onSegmentTap != null;

    return _BreadcrumbSegment(
      label: label,
      isCurrent: isCurrent,
      tappable: tappable,
      maxWidth: isCurrent ? maxWidth * 1.35 : maxWidth,
      onTap: tappable ? () => onSegmentTap(segmentIndex) : null,
    );
  }
}

class _BreadcrumbSegment extends StatelessWidget {
  const _BreadcrumbSegment({
    required this.label,
    required this.isCurrent,
    required this.tappable,
    required this.maxWidth,
    this.onTap,
  });

  final String label;
  final bool isCurrent;
  final bool tappable;
  final double maxWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isCurrent) {
      return Semantics(
        header: true,
        label: '$label, current page',
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _RecordListTheme.breadcrumbCurrentBg,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: _RecordListTheme.breadcrumbCurrentBorder,
              ),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.poppins(
                fontSize: 13,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: _RecordListTheme.breadcrumbCurrentText,
                letterSpacing: -0.15,
              ),
            ),
          ),
        ),
      );
    }

    final textStyle = AppFonts.poppins(
      fontSize: 13,
      height: 1.25,
      color: _RecordListTheme.breadcrumbLink,
      fontWeight: FontWeight.w500,
    );

    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );

    final child = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: text,
    );

    if (!tappable) {
      return Semantics(label: label, child: child);
    }

    return Semantics(
      button: true,
      label: label,
      child: _BreadcrumbLinkButton(onTap: onTap!, child: child),
    );
  }
}

class _BreadcrumbLinkButton extends StatefulWidget {
  const _BreadcrumbLinkButton({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_BreadcrumbLinkButton> createState() => _BreadcrumbLinkButtonState();
}

class _BreadcrumbLinkButtonState extends State<_BreadcrumbLinkButton> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: _hovered
                ? Border.all(color: _RecordListTheme.breadcrumbBorder)
                : null,
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: _hovered
                  ? _RecordListTheme.breadcrumbLinkHover
                  : _RecordListTheme.breadcrumbLink,
              decoration: _hovered ? TextDecoration.underline : null,
              decorationColor: _RecordListTheme.breadcrumbLinkHover,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _BreadcrumbCollapsedMenu extends StatelessWidget {
  const _BreadcrumbCollapsedMenu({
    required this.hidden,
    required this.startIndex,
    this.onSegmentTap,
  });

  final List<String> hidden;
  final int startIndex;
  final ValueChanged<int>? onSegmentTap;

  @override
  Widget build(BuildContext context) {
    final canNavigate = onSegmentTap != null;

    final label = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _RecordListTheme.breadcrumbBorder),
      ),
      child: Text(
        '…',
        style: AppFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: canNavigate
              ? _RecordListTheme.breadcrumbLink
              : _RecordListTheme.textHint,
        ),
      ),
    );

    if (!canNavigate || hidden.isEmpty) return label;

    return PopupMenuButton<int>(
      tooltip: 'Show hidden breadcrumb levels',
      padding: EdgeInsets.zero,
      offset: const Offset(0, 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      itemBuilder: (context) => [
        for (var i = 0; i < hidden.length; i++)
          PopupMenuItem<int>(
            value: startIndex + i,
            height: 44,
            child: Text(
              hidden[i],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _RecordListTheme.textPrimary,
              ),
            ),
          ),
      ],
      onSelected: onSegmentTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: label,
      ),
    );
  }
}

class _RecordSearchField extends StatelessWidget {
  const _RecordSearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.hintText = 'Search…',
    this.focusColor,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final String hintText;
  final Color? focusColor;

  @override
  Widget build(BuildContext context) {
    final accent = focusColor ?? _collegeTealDark;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: _RecordListTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: _RecordListTheme.textHint,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: _RecordListTheme.textHint,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _RecordListTheme.border),
            ),
            child: const Text(
              '/',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _RecordListTheme.textHint,
              ),
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _RecordListTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _RecordListTheme.border),
        ),
      ),
    );
  }
}

class _RecordCountBadge extends StatelessWidget {
  const _RecordCountBadge({
    required this.icon,
    required this.label,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? const Color(0xFF2563EB);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accent.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordPrimaryButton extends StatelessWidget {
  const _RecordPrimaryButton({
    required this.label,
    required this.onPressed,
    this.color,
    this.icon = Icons.add,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? _collegeTealDark;
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        disabledBackgroundColor: bg.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }
}

class _RecordListCard extends StatelessWidget {
  const _RecordListCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_RecordListTheme.cardRadius),
        border: Border.all(color: _RecordListTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _RecordListToolbar extends StatelessWidget {
  const _RecordListToolbar({
    required this.search,
    this.trailing = const [],
  });

  final Widget search;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackToolbar = constraints.maxWidth < 640;
          if (stackToolbar) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                if (trailing.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: trailing,
                  ),
                ],
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: search),
              if (trailing.isNotEmpty) ...[
                const SizedBox(width: 12),
                ...trailing,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RecordIconAction extends StatelessWidget {
  const _RecordIconAction({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
    this.hoverColor,
    this.hoverForegroundColor,
    this.minimal = false,
  });

  final IconData icon;
  final Color color;
  final Color? hoverColor;
  final Color? hoverForegroundColor;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool minimal;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final idleColor =
        enabled ? color : _RecordListTheme.textHint.withValues(alpha: 0.35);

    if (minimal) {
      return IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: 18),
        style: IconButton.styleFrom(
          minimumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          hoverColor: hoverColor ?? const Color(0xFFF8FAFC),
        ).copyWith(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (!enabled) {
              return _RecordListTheme.textHint.withValues(alpha: 0.35);
            }
            if (states.contains(WidgetState.hovered) &&
                hoverForegroundColor != null) {
              return hoverForegroundColor;
            }
            return color;
          }),
        ),
      );
    }

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 16),
      color: idleColor,
      style: IconButton.styleFrom(
        minimumSize: const Size(28, 28),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        hoverColor: hoverColor ?? const Color(0xFFF1F5F9),
      ),
    );
  }
}

class _RecordEditAction extends StatelessWidget {
  const _RecordEditAction({
    required this.onPressed,
    this.minimal = false,
  });

  final VoidCallback? onPressed;
  final bool minimal;

  @override
  Widget build(BuildContext context) {
    return _RecordIconAction(
      icon: Icons.edit_outlined,
      color: minimal ? const Color(0xFFCBD5E1) : _RecordListTheme.textMuted,
      hoverForegroundColor: minimal ? const Color(0xFF475569) : null,
      minimal: minimal,
      onPressed: onPressed,
      tooltip: 'Edit',
    );
  }
}

class _RecordDeleteAction extends StatelessWidget {
  const _RecordDeleteAction({
    required this.onPressed,
    this.minimal = false,
  });

  final VoidCallback? onPressed;
  final bool minimal;

  @override
  Widget build(BuildContext context) {
    return _RecordIconAction(
      icon: Icons.delete_outline,
      color: minimal ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8),
      hoverColor: const Color(0xFFFEF2F2),
      hoverForegroundColor: minimal ? const Color(0xFFEF4444) : null,
      minimal: minimal,
      onPressed: onPressed,
      tooltip: 'Delete',
    );
  }
}

class _RecordDataTable extends StatelessWidget {
  const _RecordDataTable({
    required this.headers,
    required this.rows,
    this.actionsWidth = 108,
    this.includeActionsColumn = false,
    this.minimal = false,
  });

  final List<String> headers;
  final List<List<Widget>> rows;
  final double actionsWidth;
  final bool includeActionsColumn;
  final bool minimal;

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF64748B),
    letterSpacing: 0.2,
  );

  static const _minimalHeaderStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Color(0xFF94A3B8),
    letterSpacing: 0.15,
  );

  @override
  Widget build(BuildContext context) {
    final hasActions = includeActionsColumn || headers.length > 1;
    final headerStyle = minimal ? _minimalHeaderStyle : _headerStyle;
    final actionsHeader =
        headers.length > 1 ? headers.last : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: minimal ? 16 : 20,
            vertical: minimal ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: minimal ? Colors.white : _RecordListTheme.headerBg,
            border: const Border(
              bottom: BorderSide(color: _RecordListTheme.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(headers.first, style: headerStyle)),
              if (hasActions &&
                  actionsHeader != null &&
                  actionsHeader.isNotEmpty)
                SizedBox(
                  width: actionsWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(actionsHeader, style: headerStyle),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              return _RecordDataRow(
                cells: rows[i],
                actionsWidth: actionsWidth,
                hasActions: hasActions,
                isLast: i == rows.length - 1,
                minimal: minimal,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecordDataRow extends StatelessWidget {
  const _RecordDataRow({
    required this.cells,
    required this.actionsWidth,
    required this.hasActions,
    required this.isLast,
    this.minimal = false,
  });

  final List<Widget> cells;
  final double actionsWidth;
  final bool hasActions;
  final bool isLast;
  final bool minimal;

  @override
  Widget build(BuildContext context) {
    final nameCell = cells.isNotEmpty ? cells.first : const SizedBox.shrink();
    final actionsCell = cells.length > 1 ? cells.last : const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: minimal ? const Color(0xFFFAFAFA) : _RecordListTheme.rowHover,
        child: Container(
          constraints: BoxConstraints(minHeight: minimal ? 44 : 52),
          padding: EdgeInsets.symmetric(
            horizontal: minimal ? 16 : 20,
            vertical: minimal ? 4 : 6,
          ),
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
              Expanded(child: nameCell),
              if (hasActions) ...[
                SizedBox(width: minimal ? 8 : 12),
                SizedBox(
                  width: actionsWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: actionsCell,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordLoadBanner extends StatelessWidget {
  const _RecordLoadBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 18, color: Color(0xFF9A3412)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF9A3412), fontSize: 13),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

part of '../../dashboard_shell_page.dart';

class _SidebarToggleIcon extends StatelessWidget {
  const _SidebarToggleIcon({
    required this.collapsed,
    this.size = 20,
    this.color = const Color(0xFF667085),
  });

  final bool collapsed;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SidebarToggleIconPainter(color: color, collapsed: collapsed),
    );
  }
}

class _SidebarToggleIconPainter extends CustomPainter {
  _SidebarToggleIconPainter({required this.color, required this.collapsed});

  final Color color;
  final bool collapsed;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    if (collapsed) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.18,
        size.width * 0.76,
        size.height * 0.64,
      ),
      Radius.circular(size.width * 0.1),
    );
    canvas.drawRRect(outer, stroke);

    final dividerX = size.width * 0.7;
    canvas.drawLine(
      Offset(dividerX, size.height * 0.18),
      Offset(dividerX, size.height * 0.82),
      stroke,
    );

    final dotX = dividerX + (size.width * 0.88 - dividerX) / 2;
    final dotRadius = size.width * 0.034;
    final spacing = size.height * 0.13;
    final centerY = size.height * 0.5;
    for (var i = -1; i <= 1; i++) {
      canvas.drawCircle(Offset(dotX, centerY + i * spacing), dotRadius, fill);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SidebarToggleIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.collapsed != collapsed;
}

class _SidebarIconShell extends StatelessWidget {
  const _SidebarIconShell({
    required this.icon,
    required this.active,
    required this.isDarkAdmin,
    this.iconSize = 20,
  });

  final IconData icon;
  final bool active;
  final bool isDarkAdmin;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final iconColor = active
        ? _sidebarActive
        : (isDarkAdmin ? _adminMuted : _sidebarItem);

    return SizedBox(
      width: 22,
      height: 22,
      child: Center(
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}

class _SidebarControlButton extends StatelessWidget {
  const _SidebarControlButton({
    this.icon,
    this.child,
    required this.tooltip,
    required this.onPressed,
    required this.isDarkAdmin,
  }) : assert(icon != null || child != null);

  final IconData? icon;
  final Widget? child;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isDarkAdmin;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDarkAdmin ? _adminMuted : const Color(0xFF667085);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          hoverColor: isDarkAdmin
              ? Colors.white.withValues(alpha: 0.06)
              : _sidebarHoverBg,
          splashColor: _sidebarActive.withValues(alpha: 0.06),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: child ??
                  Icon(
                    icon,
                    size: 18,
                    color: iconColor,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarUniversityLogo extends StatelessWidget {
  const _SidebarUniversityLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.asset(
          'assets/images/university-logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.collapsed,
    required this.isDarkAdmin,
    required this.onToggleCollapse,
  });

  final bool collapsed;
  final bool isDarkAdmin;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        collapsed ? 0 : 18,
        18,
        collapsed ? 0 : 14,
        14,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkAdmin ? _adminBorder : _sidebarBorder,
          ),
        ),
      ),
      child: collapsed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _SidebarUniversityLogo(size: 40),
                  const SizedBox(height: 8),
                  _SidebarControlButton(
                    tooltip: 'Expand sidebar',
                    onPressed: onToggleCollapse,
                    isDarkAdmin: isDarkAdmin,
                    child: _SidebarToggleIcon(
                      collapsed: true,
                      size: 18,
                      color: isDarkAdmin ? _adminMuted : const Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                const _SidebarUniversityLogo(size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JRMSU-KC Registrar',
                        style: _sidebarText(
                          size: 13,
                          weight: FontWeight.w600,
                          height: 1.25,
                          color: isDarkAdmin
                              ? _adminText
                              : const Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Management System',
                        style: _sidebarText(
                          size: 11,
                          weight: FontWeight.w400,
                          color: isDarkAdmin
                              ? _adminMuted
                              : _sidebarHeading,
                        ),
                      ),
                    ],
                  ),
                ),
                _SidebarControlButton(
                  tooltip: 'Collapse sidebar',
                  onPressed: onToggleCollapse,
                  isDarkAdmin: isDarkAdmin,
                  child: _SidebarToggleIcon(
                    collapsed: false,
                    size: 18,
                    color: isDarkAdmin ? _adminMuted : const Color(0xFF667085),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SidebarSectionBlock extends StatelessWidget {
  const _SidebarSectionBlock({
    required this.section,
    required this.collapsed,
    required this.isDarkAdmin,
    required this.sectionCollapsed,
    required this.selectedId,
    required this.hoverTarget,
    required this.onHoverEnter,
    required this.onHoverExit,
    required this.onSectionToggle,
    required this.onItemSelected,
  });

  final _SidebarNavSection section;
  final bool collapsed;
  final bool isDarkAdmin;
  final bool sectionCollapsed;
  final String selectedId;
  final String? hoverTarget;
  final ValueChanged<String> onHoverEnter;
  final ValueChanged<String> onHoverExit;
  final ValueChanged<String> onSectionToggle;
  final ValueChanged<String> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final showItems = collapsed || !sectionCollapsed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!collapsed)
          _SidebarSection(
            title: section.title,
            isDarkAdmin: isDarkAdmin,
            collapsed: sectionCollapsed,
            onTap: () => onSectionToggle(section.title),
          )
        else
          const SizedBox(height: 6),
        AnimatedCrossFade(
          firstCurve: _sidebarAnimCurve,
          secondCurve: _sidebarAnimCurve,
          sizeCurve: _sidebarAnimCurve,
          crossFadeState: showItems
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: _sidebarAnimDuration,
          firstChild: Column(
            children: [
              for (final item in section.items)
                _SidebarTile(
                  item: item,
                  active: selectedId == item.id,
                  hovered: hoverTarget == item.id,
                  collapsed: collapsed,
                  isDarkAdmin: isDarkAdmin,
                  onHoverEnter: () => onHoverEnter(item.id),
                  onHoverExit: () => onHoverExit(item.id),
                  onTap: () => onItemSelected(item.id),
                ),
            ],
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SidebarSection extends StatelessWidget {
  const _SidebarSection({
    required this.title,
    required this.isDarkAdmin,
    required this.collapsed,
    required this.onTap,
  });

  final String title;
  final bool isDarkAdmin;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final headingColor = isDarkAdmin ? _adminMuted : _sidebarHeading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 14, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: _sidebarText(
                    size: 11,
                    weight: FontWeight.w500,
                    letterSpacing: 0.15,
                    color: headingColor,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: collapsed ? -0.25 : 0,
                duration: _sidebarAnimDuration,
                curve: _sidebarAnimCurve,
                child: Icon(
                  Icons.expand_more,
                  size: 15,
                  color: headingColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.active,
    required this.hovered,
    required this.collapsed,
    required this.isDarkAdmin,
    required this.onHoverEnter,
    required this.onHoverExit,
    required this.onTap,
  });

  final _SidebarNavItem item;
  final bool active;
  final bool hovered;
  final bool collapsed;
  final bool isDarkAdmin;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = active
        ? _sidebarActive
        : (hovered
            ? (isDarkAdmin ? _adminText : const Color(0xFF344054))
            : (isDarkAdmin ? _adminText : _sidebarItem));

    final displayIcon = item.iconFor(active: active);

    if (collapsed) {
      final badge = item.badge;
      return Tooltip(
        message: item.title,
        waitDuration: const Duration(milliseconds: 400),
        child: MouseRegion(
          onEnter: (_) => onHoverEnter(),
          onExit: (_) => onHoverExit(),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              hoverColor: Colors.transparent,
              splashColor: _sidebarActive.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _SidebarIconShell(
                        icon: displayIcon,
                        active: active,
                        isDarkAdmin: isDarkAdmin,
                      ),
                      if (badge != null && badge > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: _SidebarCollapsedBadge(count: badge),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => onHoverEnter(),
      onExit: (_) => onHoverExit(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.transparent,
          splashColor: _sidebarActive.withValues(alpha: 0.08),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? (isDarkAdmin
                      ? _sidebarActiveDarkBg.withValues(alpha: 0.28)
                      : _sidebarActiveBg)
                  : (hovered
                      ? (isDarkAdmin
                          ? Colors.white.withValues(alpha: 0.04)
                          : _sidebarHoverBg)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _SidebarIconShell(
                  icon: displayIcon,
                  active: active,
                  isDarkAdmin: isDarkAdmin,
                  iconSize: 19,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: _sidebarText(
                      size: 13,
                      weight: active ? FontWeight.w500 : FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ),
                if (item.badge != null && item.badge! > 0)
                  _SidebarBadge(
                    count: item.badge!,
                    isDarkAdmin: isDarkAdmin,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarCollapsedBadge extends StatelessWidget {
  const _SidebarCollapsedBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 9 ? '9+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _sidebarBadge,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: _sidebarText(
          size: 9,
          weight: FontWeight.w600,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _SidebarBadge extends StatelessWidget {
  const _SidebarBadge({required this.count, required this.isDarkAdmin});

  final int count;
  final bool isDarkAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDarkAdmin ? const Color(0xFFDC2626) : _sidebarBadge,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: _sidebarText(
          size: 11,
          weight: FontWeight.w500,
          color: Colors.white,
          height: 1.1,
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({
    required this.collapsed,
    required this.isDarkAdmin,
    required this.onLogout,
  });

  final bool collapsed;
  final bool isDarkAdmin;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        collapsed ? 0 : 16,
        12,
        collapsed ? 0 : 14,
        collapsed ? 12 : 14,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkAdmin ? _adminBorder : _sidebarBorder,
          ),
        ),
      ),
      child: collapsed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SidebarUserAvatar(isDarkAdmin: isDarkAdmin, size: 34),
                  const SizedBox(height: 8),
                  _SidebarControlButton(
                    icon: Icons.logout_outlined,
                    tooltip: 'Logout',
                    onPressed: onLogout,
                    isDarkAdmin: isDarkAdmin,
                  ),
                ],
              ),
            )
          : Row(
              children: [
                _SidebarUserAvatar(isDarkAdmin: isDarkAdmin, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Administrator',
                        style: _sidebarText(
                          size: 12.5,
                          weight: FontWeight.w500,
                          color: isDarkAdmin
                              ? _adminText
                              : const Color(0xFF101828),
                        ),
                      ),
                      Text(
                        'admin@gmail.com',
                        overflow: TextOverflow.ellipsis,
                        style: _sidebarText(
                          size: 11,
                          color: isDarkAdmin
                              ? _adminMuted
                              : _sidebarHeading,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onLogout,
                    borderRadius: BorderRadius.circular(10),
                    hoverColor: const Color(0xFFFEF2F2),
                    splashColor: const Color(0xFFFECACA).withValues(alpha: 0.4),
                    child: const SizedBox(
                      width: 34,
                      height: 34,
                      child: Icon(
                        Icons.logout_outlined,
                        size: 18,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SidebarUserAvatar extends StatelessWidget {
  const _SidebarUserAvatar({
    required this.isDarkAdmin,
    required this.size,
  });

  final bool isDarkAdmin;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkAdmin
            ? _sidebarActiveDarkBg.withValues(alpha: 0.5)
            : _sidebarActiveBg,
      ),
      child: Text(
        'A',
        style: _sidebarText(
          size: size * 0.38,
          weight: FontWeight.w600,
          color: isDarkAdmin ? Colors.white : _sidebarActive,
        ),
      ),
    );
  }
}
part of '../../dashboard_shell_page.dart';

class _DashboardSidebar extends StatefulWidget {
  const _DashboardSidebar({
    required this.isDarkAdmin,
    required this.collapsed,
    required this.sections,
    required this.collapsedSections,
    required this.selectedId,
    required this.onToggleCollapse,
    required this.onSectionToggle,
    required this.onLogout,
    required this.onItemSelected,
  });

  final bool isDarkAdmin;
  final bool collapsed;
  final List<_SidebarNavSection> sections;
  final Set<String> collapsedSections;
  final String selectedId;
  final VoidCallback onToggleCollapse;
  final ValueChanged<String> onSectionToggle;
  final VoidCallback onLogout;
  final ValueChanged<String> onItemSelected;

  @override
  State<_DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<_DashboardSidebar> {
  String? _hoverTarget;

  void _onHoverEnter(String target) {
    if (_hoverTarget != target) {
      setState(() => _hoverTarget = target);
    }
  }

  void _onHoverExit(String target) {
    if (_hoverTarget == target) {
      setState(() => _hoverTarget = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _sidebarAnimDuration,
      curve: _sidebarAnimCurve,
      width: widget.collapsed ? _sidebarCollapsedWidth : _sidebarExpandedWidth,
      decoration: BoxDecoration(
        color: widget.isDarkAdmin ? _adminSidebar : _sidebarBg,
        border: Border(
          right: BorderSide(
            color: widget.isDarkAdmin
                ? _adminBorder.withValues(alpha: 0.5)
                : _sidebarBorder,
          ),
        ),
      ),
      child: Column(
        children: [
          _SidebarHeader(
            collapsed: widget.collapsed,
            isDarkAdmin: widget.isDarkAdmin,
            onToggleCollapse: widget.onToggleCollapse,
          ),
          Expanded(
            child: MouseRegion(
              onExit: (_) {
                if (_hoverTarget != null) {
                  setState(() => _hoverTarget = null);
                }
              },
              child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 6, 0, 12),
              children: [
                for (var i = 0; i < widget.sections.length; i++) ...[
                  if (i > 0) const SizedBox(height: 4),
                  _SidebarSectionBlock(
                    section: widget.sections[i],
                    collapsed: widget.collapsed,
                    isDarkAdmin: widget.isDarkAdmin,
                    sectionCollapsed: widget.collapsedSections
                        .contains(widget.sections[i].title),
                    selectedId: widget.selectedId,
                    hoverTarget: _hoverTarget,
                    onHoverEnter: _onHoverEnter,
                    onHoverExit: _onHoverExit,
                    onSectionToggle: widget.onSectionToggle,
                    onItemSelected: widget.onItemSelected,
                  ),
                ],
              ],
            ),
            ),
          ),
          _SidebarFooter(
            collapsed: widget.collapsed,
            isDarkAdmin: widget.isDarkAdmin,
            onLogout: widget.onLogout,
          ),
        ],
      ),
    );
  }
}
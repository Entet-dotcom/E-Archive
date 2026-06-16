part of '../../dashboard_shell_page.dart';

class _SidebarNavSection {
  _SidebarNavSection({required this.title, required this.items});

  final String title;
  final List<_SidebarNavItem> items;
}

class _SidebarNavItem {
  _SidebarNavItem({
    required this.id,
    required this.title,
    required this.icon,
    this.activeIcon,
    this.badge,
  });

  final String id;
  final String title;
  final IconData icon;
  final IconData? activeIcon;
  final int? badge;

  IconData iconFor({required bool active}) =>
      active ? (activeIcon ?? icon) : icon;
}
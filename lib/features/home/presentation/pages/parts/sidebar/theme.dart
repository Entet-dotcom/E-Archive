part of '../../dashboard_shell_page.dart';

// Minimal neutral sidebar palette.
const _sidebarBg = Color(0xFFFAFBFC);
const _sidebarBorder = Color(0xFFE4E7EC);
const _sidebarHeading = Color(0xFF98A2B3);
const _sidebarItem = Color(0xFF475467);
const _sidebarHoverBg = Color(0xFFF2F4F7);
const _sidebarActiveBg = Color(0xFFEFF4FF);
const _sidebarActive = Color(0xFF1570EF);
const _sidebarActiveDarkBg = Color(0xFF1D4ED8);
const _sidebarBadge = Color(0xFFF04438);
const _sidebarExpandedWidth = 260.0;
const _sidebarCollapsedWidth = 68.0;
const _sidebarAnimDuration = Duration(milliseconds: 240);
const _sidebarAnimCurve = Curves.easeOutCubic;

TextStyle _sidebarText({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return AppFonts.poppins(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

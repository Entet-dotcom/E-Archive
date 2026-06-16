part of '../../dashboard_shell_page.dart';

/// Layout and visual tokens for the admin dashboard.
abstract final class _AdminDashTheme {
  static const sectionGap = 18.0;
  static const panelGap = 16.0;
  static const featureGap = 8.0;
  static const pagePaddingH = 24.0;

  static const featuresBreakpoint = 1080.0;
  static const featuresSidebarWidth = 220.0;
  static const featuresBarHeight = 128.0;

  static const statSpacing = 10.0;
  static const statColumnsWide = 1100.0;
  static const statColumnsMedium = 720.0;

  static const border = Color(0xFFE2E8F0);
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF8FAFC);
  static const textPrimary = Color(0xFF0F172A);
  static const textBody = Color(0xFF334155);
  static const textMuted = Color(0xFF64748B);
  static const textHint = Color(0xFF94A3B8);
  static const link = Color(0xFF2563EB);
  static const warning = Color(0xFFD97706);

  static int statColumnCount(double maxWidth) {
    if (maxWidth >= statColumnsWide) return 4;
    if (maxWidth >= statColumnsMedium) return 2;
    return 1;
  }

  static TextStyle panelTitle({double size = 13}) => AppFonts.poppins(
        color: textPrimary,
        fontSize: size,
        fontWeight: FontWeight.w700,
      );

  static TextStyle label({double size = 11}) => AppFonts.poppins(
        color: textMuted,
        fontSize: size,
        fontWeight: FontWeight.w600,
      );

  static TextStyle caption({double size = 10}) => AppFonts.poppins(
        color: textHint,
        fontSize: size,
      );

  static TextStyle value({double size = 22}) => AppFonts.poppins(
        color: textPrimary,
        fontSize: size,
        height: 1,
        fontWeight: FontWeight.w800,
      );
}

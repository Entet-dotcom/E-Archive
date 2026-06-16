part of '../../dashboard_shell_page.dart';

/// User management list UI palette (light card on dashboard).
abstract final class _UserManagementTheme {
  static const accent = Color(0xFF2563EB);
  static const textPrimary = Color(0xFF0F172A);
  static const textBody = Color(0xFF334155);
  static const textMuted = Color(0xFF64748B);
  static const border = Color(0xFFE5E7EB);
  static const headerBg = Color(0xFFF8FAFC);
  static const editIcon = Color(0xFFCA8A04);
  static const deleteIcon = Color(0xFFDC2626);
  static const toastOkBg = Color(0xFFDCFCE7);
  static const toastOkBorder = Color(0xFF86EFAC);
  static const toastOkFg = Color(0xFF166534);
  static const toastErrBg = Color(0xFFFEE2E2);
  static const toastErrBorder = Color(0xFFFCA5A5);
  static const toastErrFg = Color(0xFFB91C1C);
}

const _userTableHeaderStyle = TextStyle(
  fontSize: 12,
  color: _UserManagementTheme.textMuted,
  fontWeight: FontWeight.w600,
);

const _userConfirmTitleStyle = TextStyle(
  fontWeight: FontWeight.w700,
  color: _UserManagementTheme.textPrimary,
  fontSize: 16,
);

/// Background and foreground for role badges.
({Color bg, Color fg}) _userRoleChipColors(String role) {
  switch (role) {
    case 'admin':
      return (
        bg: const Color(0xFFDBEAFE),
        fg: const Color(0xFF1D4ED8),
      );
    case 'staff':
      return (
        bg: const Color(0xFFCCFBF1),
        fg: const Color(0xFF0F766E),
      );
    default:
      return (
        bg: const Color(0xFFEFF6FF),
        fg: const Color(0xFF0369A1),
      );
  }
}

String _nextManagedUserRole(String role) {
  switch (role) {
    case 'student':
      return 'staff';
    case 'staff':
      return 'admin';
    default:
      return 'student';
  }
}

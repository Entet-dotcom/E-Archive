import 'package:flutter/material.dart';

import '../constants/app_fonts.dart';

/// Minimal light-theme date picker for forms and dialogs.
abstract final class MinimalDatePicker {
  MinimalDatePicker._();

  static const _accent = Color(0xFF115E59);
  static const _accentSoft = Color(0xFF0F766E);
  static const _textPrimary = Color(0xFF111827);
  static const _textMuted = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _disabled = Color(0xFFD1D5DB);

  static ThemeData themeOf(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _accent,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: _textPrimary,
      ),
    );

    return base.copyWith(
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _border),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _border),
        ),
        headerBackgroundColor: Colors.white,
        headerForegroundColor: _textPrimary,
        headerHeadlineStyle: AppFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          height: 1.2,
        ),
        headerHelpStyle: AppFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _textMuted,
        ),
        weekdayStyle: AppFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _textMuted,
          letterSpacing: 0.3,
        ),
        dayStyle: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _textPrimary,
        ),
        yearStyle: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _textPrimary,
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) return _disabled;
          return _textPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _accent;
          return Colors.transparent;
        }),
        todayForegroundColor: WidgetStateProperty.all(_accentSoft),
        todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
        todayBorder: const BorderSide(color: _accentSoft, width: 1),
        rangeSelectionBackgroundColor: _accent.withValues(alpha: 0.08),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: _textMuted,
          textStyle: AppFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: _accent,
          textStyle: AppFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: AppFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: _textPrimary,
        displayColor: _textPrimary,
      ),
    );
  }

  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String helpText = 'Select date',
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Theme(
          data: themeOf(context),
          child: child,
        );
      },
    );
  }
}

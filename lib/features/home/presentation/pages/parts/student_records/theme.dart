part of '../../dashboard_shell_page.dart';

const _studentTextBlack = Color(0xFF111827);
const _studentTextMuted = Color(0xFF6B7280);
const _studentTextHint = Color(0xFF9CA3AF);

final _studentLabelTextStyle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: _studentTextBlack,
  height: 1.35,
  letterSpacing: 0.1,
);

final _studentInputTextStyle = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w500,
  color: _studentTextBlack,
  height: 1.45,
  letterSpacing: 0.15,
);

final _studentHintTextStyle = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: _studentTextHint,
  height: 1.45,
);

final _studentFieldTextStyle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: _studentTextBlack,
  height: 1.4,
);

final _studentMutedTextStyle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: _studentTextMuted,
  height: 1.4,
);

final _studentSectionTitleTextStyle = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: _studentTextBlack,
  letterSpacing: 0.3,
);

final _studentTitleTextStyle = GoogleFonts.poppins(
  fontSize: 18,
  fontWeight: FontWeight.w700,
  color: _studentTextBlack,
);

final _studentSubtitleTextStyle = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w500,
  color: _studentTextMuted,
);

final _studentTableHeaderTextStyle = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: Color(0xFF64748B),
);

final _studentDropdownHeaderTextStyle = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: _studentTextBlack,
);

final _studentFilterDropdownTextStyle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: _studentTextBlack,
  height: 1.4,
);

final _studentFilterLabelTextStyle = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: _studentTextMuted,
  letterSpacing: 0.2,
);

final _studentLinkTextStyle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: _collegeTeal,
);

final _studentDetailLabelTextStyle = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: _studentTextMuted,
  letterSpacing: 0.4,
);

final _studentDocumentTitleTextStyle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: _studentTextBlack,
);

final _studentRequiredMarkTextStyle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: Color(0xFFDC2626),
);

final _studentButtonTextStyle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

final _studentBadgeTextStyle = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: Color(0xFF2563EB),
);

/// Light theme for student records UI (app root uses [AppTheme.darkTheme]).
final _studentDetailDialogTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: _collegeTealDark,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: _studentTextBlack,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(
    ThemeData.light().textTheme,
  )
      .apply(
        bodyColor: _studentTextBlack,
        displayColor: _studentTextBlack,
      )
      .copyWith(
        bodyLarge: _studentInputTextStyle,
        bodyMedium: _studentInputTextStyle,
        bodySmall: _studentFieldTextStyle,
        titleMedium: _studentFieldTextStyle,
        labelLarge: _studentLabelTextStyle,
        titleLarge: _studentTitleTextStyle,
      ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: _studentHintTextStyle,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(textStyle: _studentButtonTextStyle),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(textStyle: _studentButtonTextStyle),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(textStyle: _studentButtonTextStyle),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(textStyle: _studentInputTextStyle),
);

InputDecoration _studentInputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: _studentHintTextStyle,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
  );
}
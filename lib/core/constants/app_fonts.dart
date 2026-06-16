import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central Poppins font helpers for the app.
class AppFonts {
  AppFonts._();

  static String? get family => GoogleFonts.poppins().fontFamily;

  static TextStyle poppins({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.poppins(
      textStyle: textStyle,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  static TextStyle merge(TextStyle style) {
    return style.copyWith(fontFamily: family);
  }

  static TextTheme poppinsTextTheme(TextTheme base) {
    return GoogleFonts.poppinsTextTheme(base);
  }
}

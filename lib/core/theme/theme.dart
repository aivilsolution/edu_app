import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color seedColor = Color.fromARGB(1, 36, 41, 62);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seedColor,
    brightness: Brightness.light,
    textTheme: AppTextTheme.textTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seedColor,
    brightness: Brightness.dark,
    textTheme: AppTextTheme.textTheme,
  );
}

class AppTextTheme {
  static final TextTheme textTheme = TextTheme(
    displayLarge: _roboto(57, 64, FontWeight.w400, -0.25),
    displayMedium: _roboto(45, 52, FontWeight.w400, 0),
    displaySmall: _roboto(36, 44, FontWeight.w400, 0),
    headlineLarge: _roboto(32, 40, FontWeight.w400, 0),
    headlineMedium: _roboto(28, 36, FontWeight.w400, 0),
    headlineSmall: _roboto(24, 32, FontWeight.w400, 0),
    titleLarge: _openSans(22, 28, FontWeight.w400, 0),
    titleMedium: _openSans(16, 24, FontWeight.w500, 0.15),
    titleSmall: _openSans(14, 20, FontWeight.w500, 0.1),
    bodyLarge: _openSans(16, 24, FontWeight.w400, 0.5),
    bodyMedium: _openSans(14, 20, FontWeight.w400, 0.25),
    bodySmall: _openSans(12, 16, FontWeight.w400, 0.4),
    labelLarge: _openSans(14, 20, FontWeight.w500, 0.1),
    labelMedium: _openSans(12, 16, FontWeight.w500, 0.5),
    labelSmall: _openSans(11, 16, FontWeight.w500, 0.5),
  );

  static TextStyle _roboto(
    double fontSize,
    double lineHeight,
    FontWeight fontWeight,
    double letterSpacing,
  ) => GoogleFonts.roboto(
    fontSize: fontSize,
    height: lineHeight / fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
  );

  static TextStyle _openSans(
    double fontSize,
    double lineHeight,
    FontWeight fontWeight,
    double letterSpacing,
  ) => GoogleFonts.openSans(
    fontSize: fontSize,
    height: lineHeight / fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
  );
}

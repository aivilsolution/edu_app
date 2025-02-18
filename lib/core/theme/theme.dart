import 'package:flutter/material.dart';

class AppTheme {
  static const _dark = Color(0xFF121212);
  static const _darker = Color(0xFF1E1E1E);
  static const _text = Color(0xFFF5F5F5);
  static const _borderColor = Color(0xFF2C2C2C);

  static const _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, height: 1.5),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );

  static OutlineInputBorder _buildBorder([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: color ?? _borderColor,
      width: color != null ? 2 : 1,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: _dark,
      surface: _darker,
      primary: _darker,
      secondary: _darker,
      error: const Color(0xFF3A1A1A),
      onBackground: _text,
      onSurface: _text,
      onPrimary: _text,
      onSecondary: _text,
      onError: _text,
    ),
    scaffoldBackgroundColor: _dark,
    cardTheme: CardTheme(
      color: _borderColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _borderColor),
      ),
      margin: const EdgeInsets.all(8),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: _darker,
      selectedTileColor: _darker,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darker,
      centerTitle: true,
      scrolledUnderElevation: 3,
      titleTextStyle: _textTheme.titleLarge?.copyWith(
        color: _text,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darker,
      selectedItemColor: _text,
      unselectedItemColor: _text,
      elevation: 3,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: _textTheme.apply(bodyColor: _text, displayColor: _text),
    iconTheme: IconThemeData(color: _text, size: 24),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darker,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: _buildBorder(),
      enabledBorder: _buildBorder(),
      focusedBorder: _buildBorder(_text),
      errorBorder: _buildBorder(const Color(0xFF3A1A1A)),
      focusedErrorBorder: _buildBorder(const Color(0xFF3A1A1A)),
      prefixIconColor: _text,
      suffixIconColor: _text,
    ),
  );
}

extension BuildContextThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  EdgeInsets get screenPadding => MediaQuery.of(this).padding;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;
}

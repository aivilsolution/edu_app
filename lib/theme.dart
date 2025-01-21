import 'package:flutter/material.dart';

class AppTheme {
  static const headerBackground =
      Color(0xFF2D2D2D); // Using primary color for headers

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Core colors
    colorScheme: ColorScheme.dark(
      background: Color(0xFF000000),
      surface: Color(0xFF121212),
      primary: headerBackground,
      secondary: Color(0xFF404040),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),

    // Background colors
    scaffoldBackgroundColor: Color(0xFF000000),

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: headerBackground,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    // Text themes
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Color(0xFF94A3B8)),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Color(0xFF94A3B8)),
    ),

    // Component themes
    cardTheme: CardTheme(
      color: Color(0xFF121212),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Color(0xFF1E293B)),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: Color(0xFF1E293B),
    ),

    iconTheme: IconThemeData(
      color: Color(0xFFE0E0E0),
    ),

    inputDecorationTheme: InputDecorationTheme(
      fillColor: Color(0xFF121212),
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1E293B)),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1E293B)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: headerBackground),
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: headerBackground,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}

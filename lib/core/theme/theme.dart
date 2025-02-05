import 'package:flutter/material.dart';

class AppTheme {
  static const _colors = {
    'background': Color.fromARGB(255, 0, 0, 0),
    'surface': Color.fromARGB(255, 18, 18, 18),
    'primary': Color.fromARGB(255, 45, 45, 45),
    'accent': Color.fromARGB(255, 224, 224, 224),
    'text': Colors.white,
    'textSecondary': Color.fromARGB(255, 148, 163, 184),
    'border': Color.fromARGB(255, 30, 41, 59),
  };

  static final _baseTextTheme = TextTheme(
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),
  );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: _colors['accent'],
        scaffoldBackgroundColor: Colors.white,
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: _colors['accent']),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: _baseTextTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black,
        ),
        iconTheme: IconThemeData(color: _colors['accent']),
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: _colors['accent'],
        scaffoldBackgroundColor: _colors['background'],
        cardTheme: CardTheme(
          color: _colors['surface'],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _colors['border']!),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: _colors['accent']),
          titleTextStyle: TextStyle(
            color: _colors['text'],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: _baseTextTheme.apply(
          bodyColor: _colors['text'],
          displayColor: _colors['text'],
        ),
        iconTheme: IconThemeData(color: _colors['accent']),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _colors['primary'],
          hintStyle: TextStyle(color: _colors['textSecondary']),
          border: _buildInputBorder(),
          enabledBorder: _buildInputBorder(),
          focusedBorder: _buildInputBorder(_colors['accent']!),
        ),
      );

  static OutlineInputBorder _buildInputBorder([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color ?? _colors['border']!),
    );
  }
}

extension BuildContextThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
}

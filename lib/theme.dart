import 'package:flutter/material.dart';

class CourseAppTheme {
  // Base colors
  static const colors = {
    'background': Color(0xFF000000),
    'surface': Color(0xFF121212),
    'primary': Color(0xFF2D2D2D),
    'secondary': Color(0xFF404040),
    'accent': Color(0xFFE0E0E0),
    'text': Colors.white,
    'textSecondary': Color(0xFF94A3B8),
    'border': Color(0xFF1E293B),
  };

  // Light theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: colors['accent'],
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
      iconTheme: IconThemeData(color: colors['accent']),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.black54,
      ),
    ),
    iconTheme: IconThemeData(
      color: colors['accent'],
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors['accent'],
      foregroundColor: Colors.white,
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: colors['accent'],
    scaffoldBackgroundColor: colors['background'],
    cardTheme: CardTheme(
      color: colors['surface'],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors['border']!),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: colors['accent']),
      titleTextStyle: TextStyle(
        color: colors['text'],
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colors['text'],
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colors['text'],
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: colors['text'],
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: colors['textSecondary'],
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: colors['textSecondary'],
      ),
    ),
    iconTheme: IconThemeData(
      color: colors['accent'],
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors['accent'],
      foregroundColor: colors['background'],
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors['primary'],
      hintStyle: TextStyle(color: colors['textSecondary']),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors['border']!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors['border']!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors['accent']!),
      ),
    ),
  );

  // Custom theme extensions
  static ThemeData customizeTheme(
    ThemeData base, {
    Color? primaryColor,
    Color? accentColor,
    double borderRadius = 12,
    FontWeight titleWeight = FontWeight.bold,
  }) {
    return base.copyWith(
      primaryColor: primaryColor ?? base.primaryColor,
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: titleWeight,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: titleWeight,
        ),
      ),
      colorScheme: base.colorScheme.copyWith(
        secondary: accentColor ?? base.colorScheme.secondary,
      ),
    );
  }
}

// Usage example:
void configureApp() {
  // In your MaterialApp widget:
  MaterialApp(
    theme: CourseAppTheme.lightTheme,
    darkTheme: CourseAppTheme.darkTheme,
    themeMode: ThemeMode.system, // or ThemeMode.light/dark
  );

  // Or with custom theme:
  MaterialApp(
    theme: CourseAppTheme.customizeTheme(
      CourseAppTheme.lightTheme,
      primaryColor: Colors.blue,
      accentColor: Colors.orange,
      borderRadius: 16,
      titleWeight: FontWeight.w600,
    ),
  );
}

// Extension methods for easier theme access
extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

// Custom theme colors extension
extension CourseThemeColorsExtension on ThemeData {
  Map<String, Color> get courseColors => CourseAppTheme.colors;
}

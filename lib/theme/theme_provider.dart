import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme;

  ThemeProvider() : _currentTheme = _buildLightTheme();

  ThemeData get currentTheme => _currentTheme;

  static ThemeData _buildLightTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF4A6FA5),
      onPrimary: Colors.white,
      secondary: Color(0xFF89B0D9),
      onSecondary: Colors.white,
      error: Color(0xFFB00020),
      onError: Colors.white,
      background: Color(0xFFF4F6FA),
      onBackground: Color(0xFF121212),
      surface: Colors.white,
      onSurface: Color(0xFF1A1A1A),
    );

    return ThemeData.from(
      colorScheme: colorScheme,
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        elevation: 0,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withOpacity(0.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}

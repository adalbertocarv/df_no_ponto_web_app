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
      surface: Colors.white,
      onSurface: Color(0xFF1A1A1A),
      // Adicionando as propriedades que faltavam
      surfaceVariant: Color(0xFFF4F6FA),
      onSurfaceVariant: Color(0xFF121212),
      outline: Color(0xFF79747E),
      shadow: Colors.black,
      inverseSurface: Color(0xFF121212),
      onInverseSurface: Color(0xFFF4F6FA),
      inversePrimary: Color(0xFF89B0D9),
      // Estas são obrigatórias no Material 3
      primaryContainer: Color(0xFF89B0D9),
      onPrimaryContainer: Colors.white,
      secondaryContainer: Color(0xFFE3F2FD),
      onSecondaryContainer: Color(0xFF121212),
      tertiary: Color(0xFF4A6FA5),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE3F2FD),
      onTertiaryContainer: Color(0xFF121212),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surfaceTint: Color(0xFF4A6FA5),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surfaceVariant,

      // Configurações específicas para garantir que a primary seja aplicada
      primarySwatch: _createMaterialColor(const Color(0xFF4A6FA5)),
      primaryColor: const Color(0xFF4A6FA5),

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
        titleTextStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Tema dos botões elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),

      // Tema dos botões de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),

      // Tema dos botões outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
        ),
      ),

      // Tema dos campos de texto
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.primary),
        floatingLabelStyle: TextStyle(color: colorScheme.primary),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withOpacity(0.4),
        selectionHandleColor: colorScheme.primary,
      ),

      // Tema dos checkboxes, switches, etc.
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return null;
        }),
      ),

      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return null;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return null;
        }),
      ),
    );
  }

  // Função auxiliar para criar MaterialColor
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      swatch[(i * 100)] = Color.fromRGBO(r, g, b, strengths[i]);
    }
    return MaterialColor(color.value, swatch);
  }
}
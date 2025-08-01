import 'package:flutter/material.dart';
// Importe seus arquivos separados aqui:
import 'mobile_home.dart';
import 'desktop_home.dart';

class ResponsiveFavoritesApp extends StatelessWidget {
  const ResponsiveFavoritesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DF no Ponto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ResponsiveFavoritesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ResponsiveFavoritesScreen extends StatelessWidget {
  const ResponsiveFavoritesScreen({Key? key}) : super(key: key);

  // Breakpoints para diferentes tamanhos de tela
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Detecta o tipo de dispositivo
        if (screenWidth >= tabletBreakpoint) {
          // Desktop/Tablet grande
          return const DesktopFavoritesScreen();
        } else if (screenWidth >= mobileBreakpoint) {
          // Tablet pequeno - pode usar versão desktop simplificada
          return const DesktopFavoritesScreen();
        } else {
          // Mobile
          return const MobileFavoritesScreen();
        }
      },
    );
  }
}

// Classe utilitária para detectar tipo de dispositivo
class DeviceType {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }
}

// Classe para constantes responsivas
class ResponsiveConstants {
  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;

  // Padding responsivo
  static double getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return 40;
    if (width >= tabletBreakpoint) return 24;
    return 16;
  }

  // Número de colunas para grids
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return 3;
    if (width >= tabletBreakpoint) return 2;
    return 1;
  }

  // Tamanho de fonte responsivo
  static double getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return 28;
    if (width >= tabletBreakpoint) return 24;
    return 18;
  }

  // Largura máxima do conteúdo
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return 1200;
    if (width >= tabletBreakpoint) return 800;
    return double.infinity;
  }
}

// Widget helper para centralizar conteúdo com largura máxima
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.maxWidth,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.getPadding(context),
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? ResponsiveConstants.getMaxContentWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Placeholder para as telas (substitua pelos seus imports)
class MobileFavoritesScreen extends StatelessWidget {
  const MobileFavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Version'),
        backgroundColor: const Color(0xFF4A6FA5),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 64, color: Color(0xFF4A6FA5)),
            SizedBox(height: 16),
            Text(
              'Versão Mobile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            FavoritesScreen()
          ],
        ),
      ),
    );
  }
}

class DesktopFavoritesScreen extends StatelessWidget {
  const DesktopFavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desktop Version'),
        backgroundColor: const Color(0xFF4A6FA5),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.desktop_windows, size: 64, color: Color(0xFF4A6FA5)),
            SizedBox(height: 16),
            Text(
              'Versão Desktop',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            DesktopScreen()
          ],
        ),
      ),
    );
  }
}

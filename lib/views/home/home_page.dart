import 'package:df_no_ponto_web_app/controller/home/main_navigation.dart';
import 'package:flutter/material.dart';
import 'desktop/desktop_home.dart';

class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfoÔnibus - SEMOB',
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
  const ResponsiveFavoritesScreen({super.key});

  // Breakpoints para diferentes tamanhos de tela
  static const double mobileBreakpoint = 780.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Detecta o tipo de dispositivo
        if (screenWidth >= mobileBreakpoint) {
          // Desktop/Tablet grande
          return const DesktopHome();
        } else {
          // Mobile
          return const MainNavigation();
        }
      },
    );
  }
}

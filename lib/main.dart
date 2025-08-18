import 'package:df_no_ponto_web_app/providers/favoritos_linha.dart';
import 'package:df_no_ponto_web_app/providers/theme/theme_provider.dart';
import 'package:df_no_ponto_web_app/views/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const DfNoPontoWebApp(),
    ),
  );
}

class DfNoPontoWebApp extends StatelessWidget {
  const DfNoPontoWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'InfoÔnibus - SEMOB',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: const ResponsiveHome(),
    );
  }
}

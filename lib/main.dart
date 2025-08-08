import 'package:df_no_ponto_web_app/providers/favoritos.dart';
import 'package:df_no_ponto_web_app/views/home/home_page.dart';
import 'package:df_no_ponto_web_app/views/theme/theme_provider.dart';
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
    //final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'DF no Ponto - SEMOB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),      home: const ResponsiveHome(),
    );
  }
}

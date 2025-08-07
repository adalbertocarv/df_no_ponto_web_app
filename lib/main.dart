import 'package:df_no_ponto_web_app/providers/favoritos.dart';
import 'package:df_no_ponto_web_app/views/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ],
          child: const DfNoPontoWebApp()));
}

class DfNoPontoWebApp extends StatelessWidget {
  const DfNoPontoWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DF no Ponto - SEMOB',
     debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6FA5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        primaryColor: const Color(0xFF4A6FA5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF4A6FA5),
          elevation: 0,
        ),
      ),
      home: const ResponsiveHome(),
    );
  }
}

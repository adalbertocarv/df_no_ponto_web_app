import 'package:df_no_ponto_web_app/views/home/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DfNoPontoWebApp());
}

class DfNoPontoWebApp extends StatelessWidget {
  const DfNoPontoWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DF no Ponto - SEMOB',
     debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4A6FA5)),
        useMaterial3: true,
      ),
      home: const ResponsiveHome(),
    );
  }
}

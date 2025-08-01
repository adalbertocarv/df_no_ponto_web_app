import 'package:df_no_ponto_web_app/views/home/desktop/widgets/header.dart';
import 'package:df_no_ponto_web_app/views/home/desktop/widgets/secao_favoritos.dart';
import 'package:df_no_ponto_web_app/views/home/desktop/widgets/secao_hero.dart';
import 'package:df_no_ponto_web_app/views/home/desktop/widgets/secao_noticias.dart';
import 'package:flutter/material.dart';

class DesktopHome extends StatelessWidget {
  const DesktopHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // Header Desktop
          buildDesktopHeader(context),

          // Body principal
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section com imagem de fundo
                  buildHeroSection(context),

                  // Seção de Favoritos (flutuante sobre hero)
                  Transform.translate(
                    offset: const Offset(0, -50),
                    child: buildFavoritesSection(isDesktop, isTablet),
                  ),

                  // Seção de Notícias
                  buildNewsSection(isDesktop, isTablet),
                  Row(

                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'Secretaria de Estado de Transporte e Mobilidade do Distrito Federal',
                              style: TextStyle(
                              ),
                            ),
                            SizedBox(width: 12,),
                            Text('|'),
                            SizedBox(width: 12,),
                            Text('GOVERNO DO DISTRITO FEDERAL')
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

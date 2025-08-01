import 'package:df_no_ponto_web_app/views/home/mobile/widgets/bottom_navigation.dart';
import 'package:df_no_ponto_web_app/views/home/mobile/widgets/item_favoritos.dart';
import 'package:flutter/material.dart';

import '../mobile/widgets/card_noticias.dart';

class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      // IMPORTANTE: Esta propriedade impede que o body se redimensione quando o teclado aparece
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.grey),
          onPressed: () {},
        ),
        title: Image.asset(
          'assets/images/logo.png',
          height: 60,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Digite a linha que deseja consultar',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
          SizedBox(height: 24,),

          // Seção de Favoritos (título)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'Favoritos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Área scrollável - Lista de favoritos
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  buildFavoriteItem(
                    rating: '0.898',
                    title: 'Riacho Fundo II (...',
                    isFavorited: true,
                  ),
                  const SizedBox(height: 12),
                  buildFavoriteItem(
                    rating: '0.881',
                    title: 'Riacho Fundo II (...',
                    isFavorited: true,
                  ),
                  const SizedBox(height: 12),
                  buildFavoriteItem(
                    rating: '0.875',
                    title: 'Samambaia Norte (...',
                    isFavorited: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // FOOTER FIXO - Seção de Notícias
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título da seção
                const Text(
                  'NOTÍCIAS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fique por dentro',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                // Card de notícia
                buildNewsCard(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }
}

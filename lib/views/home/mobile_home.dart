import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // IMPORTANTE: Esta propriedade impede que o body se redimensione quando o teclado aparece
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.grey),
          onPressed: () {},
        ),
        title: Image.asset(
          '/images/logo.png', // Substitua pelo caminho do seu logo
          height: 40,
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
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Digite a linha que deseja co...',
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
                  _buildFavoriteItem(
                    rating: '0.898',
                    title: 'Riacho Fundo II (...',
                    isFavorited: true,
                  ),
                  const SizedBox(height: 12),
                  _buildFavoriteItem(
                    rating: '0.881',
                    title: 'Riacho Fundo II (...',
                    isFavorited: true,
                  ),
                  const SizedBox(height: 12),
                  _buildFavoriteItem(
                    rating: '0.875',
                    title: 'Samambaia Norte (...',
                    isFavorited: true,
                  ),
                  // const SizedBox(height: 12),
                  // _buildFavoriteItem(
                  //   rating: '0.860',
                  //   title: 'Ceilândia Centro (...',
                  //   isFavorited: true,
                  // ),
                  // const SizedBox(height: 12),
                  // _buildFavoriteItem(
                  //   rating: '0.845',
                  //   title: 'Taguatinga Sul (...',
                  //   isFavorited: true,
                  // ),
                  // Padding extra para não ficar grudado no footer
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // FOOTER FIXO - Seção de Notícias
          Container(
            // decoration: BoxDecoration(
            //   color: Colors.grey[50],
            //   border: Border(
            //     top: BorderSide(
            //       color: Colors.grey.withOpacity(0.2),
            //       width: 1,
            //     ),
            //   ),
            // ),
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
                _buildNewsCard(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFavoriteItem({
    required String rating,
    required String title,
    required bool isFavorited,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rating badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4A6FA5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          // Heart icon
          Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem da notícia
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              height: 80, // Reduzido para economizar espaço
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: const Icon(
                Icons.directions_bus,
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),

          // Conteúdo da notícia
          Padding(
            padding: const EdgeInsets.all(12), // Reduzido padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Programação do transporte público',
                  style: TextStyle(
                    fontSize: 14, // Fonte um pouco menor
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Serviço reativa quatro linhas de ônibus para o Metrô de Ceilândia...',
                  style: TextStyle(
                    fontSize: 12, // Fonte menor para economizar espaço
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2, // Limita a 2 linhas
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A6FA5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF4A6FA5),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            label: '',
          ),
        ],
      ),
    );
  }
}

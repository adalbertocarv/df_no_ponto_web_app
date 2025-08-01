import 'package:flutter/material.dart';

import 'item_favoritos.dart';

Widget buildFavoritesSection(bool isDesktop, bool isTablet) {
  return Container(
    constraints: BoxConstraints(
      maxWidth: isDesktop ? 800 : double.infinity,
    ),
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          spreadRadius: 2,
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        const Text(
          'Favoritos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 30),
        Column(
          children: [
            buildDesktopFavoriteItem(
              rating: '0.898',
              title:
              'Riacho Fundo II (QS 18) / Setor P Sul (Pistão Sul - Estádio)',
              isFavorited: true,
            ),
            const SizedBox(height: 16),
            buildDesktopFavoriteItem(
              rating: '0.881',
              title:
              'Riacho Fundo II (QS 18) - CAUB III (Rodoviária do Plano Piloto (SIG - Pistão Sul)',
              isFavorited: true,
            ),
            buildDesktopFavoriteItem(
              rating: '0.875',
              title: 'Samambaia Norte (...',
              isFavorited: true,
            ),
          ],
        ),
      ],
    ),
  );
}

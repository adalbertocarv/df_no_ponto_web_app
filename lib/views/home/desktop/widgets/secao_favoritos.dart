import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/favoritos_linha.dart';
import '../../../resultado_linha/resultado_linha.dart';
import 'item_favoritos.dart';

Widget buildFavoritesSection(bool isDesktop, bool isTablet, BuildContext context) {
  return Consumer<FavoritesProvider>(
    builder: (context, favoritesProvider, _) {
      final favoritos = favoritesProvider.favorites;

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
              color: Colors.grey.withValues(alpha: 0.08),
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

            if (favoritos.isEmpty)
              const Text(
                'Salve suas linhas favoritas para exibi-las aqui.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: favoritos.map((linha) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: buildDesktopFavoriteItem(
                      numero: linha['numero'] ?? '',
                      descricao: linha['descricao'] ?? '',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ResultadoLinhaPage(numero: linha['numero']!),
                          ),
                        );
                      },
                      onRemove: () {
                        favoritesProvider.removeFavorite(linha['numero']!);
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    },
  );
}

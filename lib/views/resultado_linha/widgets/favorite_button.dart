import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/favoritos.dart';

class FavoriteButtonWidget extends StatelessWidget {
  final String numero;
  final String descricao;

  const FavoriteButtonWidget({
    super.key,
    required this.numero,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        final isFavorited = favoritesProvider.isFavorite(numero);
        return IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.black,
          ),
          onPressed: () {
            if (isFavorited) {
              favoritesProvider.removeFavorite(numero);
            } else {
              favoritesProvider.addFavorite({
                'numero': numero,
                'descricao': descricao,
              });
            }
          },
        );
      },
    );
  }
}

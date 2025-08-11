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
          tooltip: isFavorited ? 'Desfavoritar' : 'Favoritar',
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.black,
          ),
          onPressed: () {
            if (isFavorited) {
              favoritesProvider.removeFavorite(numero);
            } else {
              final sucesso = favoritesProvider.addFavorite({
                'numero': numero,
                'descricao': descricao,
              });

              if (!sucesso) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Limite atingido'),
                    content: const Text(
                      'Você só pode salvar até 5 Linhas favoritas.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK', style: TextStyle(color: Colors.blueAccent),),
                      ),
                    ],
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/favoritos_linha.dart';

class LinhaSugestaoTile extends StatelessWidget {
  final String numero;
  final String descricao;
  final double tarifa;
  final VoidCallback onTap;

  const LinhaSugestaoTile({
    super.key,
    required this.numero,
    required this.descricao,
    required this.tarifa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        final isFavorited = favoritesProvider.isFavorite(numero);

        return ListTile(
          leading: const Image(
            image: AssetImage('assets/images/icon_bus_azul.png'),
            width: 20,
            height: 20,
          ),
          title: Text(
            '$numero - $descricao',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Tarifa: R\$${tarifa.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : Colors.grey,
              size: 20,
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
          ),
          onTap: onTap,
          dense: true,
        );
      },
    );
  }
}

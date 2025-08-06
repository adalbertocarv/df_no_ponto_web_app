import 'package:flutter/material.dart';

class LinhaSugestaoTile extends StatelessWidget {
  final String numero;
  final String descricao;
  final double tarifa;
  final bool isFavorited;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const LinhaSugestaoTile({
    super.key,
    required this.numero,
    required this.descricao,
    required this.tarifa,
    required this.isFavorited,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.directions_bus,
        color: Colors.blue,
        size: 20,
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
        onPressed: onToggleFavorite,
      ),
      onTap: onTap,
      dense: true,
    );
  }
}

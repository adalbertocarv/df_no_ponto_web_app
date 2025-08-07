import 'package:flutter/material.dart';

class SentidoListTile extends StatelessWidget {
  final String sentido;
  final int trechos;
  final VoidCallback onTap;

  const SentidoListTile({
    super.key,
    required this.sentido,
    required this.trechos,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.alt_route),
      title: Text('Sentido: $sentido'),
      subtitle: Text('$trechos trecho(s)'),
      onTap: onTap,
    );
  }
}

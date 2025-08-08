import 'package:flutter/material.dart';
import 'card_noticias.dart';

Widget buildNewsSectionDesktop() {
  return Container(
    width: double.infinity,
    color: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
    child: Column(
      children: [
        // Header da seção
        const Text(
          'NOTÍCIAS',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fique por dentro',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 50),

        // Grid de notícias (Desktop fixo)
        Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: const NoticiasDesktop(),
        ),
      ],
    ),
  );
}

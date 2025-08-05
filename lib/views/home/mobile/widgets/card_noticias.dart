import 'package:flutter/material.dart';

Widget buildNewsCard() {
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
              color: Colors.blue[300],
            ),
            child: const Icon(
              Icons.directions_bus,
              size: 40,
              color: Colors.white,
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

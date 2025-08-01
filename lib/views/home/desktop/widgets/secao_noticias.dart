import 'package:flutter/material.dart';

import 'card_noticias.dart';

Widget buildNewsSection(bool isDesktop, bool isTablet) {
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
            color: Colors.grey[600],
          ),
        ),

        const SizedBox(height: 50),

        // Grid de notícias
        Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
              double childAspectRatio = isDesktop ? 0.8 : 0.9;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                children: [
                  buildNewsCard(
                    'Vai de Graça ultrapassa 10 milhões de acessos no transporte do DF',
                    'Medida facilita a mobilidade da população, estimula a lázer e fomenta a economia local',
                    Icons.directions_bus,
                    Colors.blue,
                  ),
                  buildNewsCard(
                    'Mais de 3,5 milhões de viagens pelo Vai de Graça na Semana Santa e aniversário de Brasília',
                    'Período teve cinco dias seguidos de transporte público coletivo gratuito no DF',
                    Icons.subway,
                    Colors.green,
                  ),
                  buildNewsCard(
                    'Encerrada a fase de oficinas de diagnóstico do transporte urbano e mobilidade do DF',
                    'Projeto do PDTU passou por audiência pública em maio e novas oficinas em junho',
                    Icons.apartment,
                    Colors.orange,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../controller/resultado_linha/mapa_linha_controller.dart';
import '../../../../providers/theme/theme_provider.dart';

class CentralizarPolylines extends StatelessWidget {
  final ResultadoMapaController mapaController;

  const CentralizarPolylines({
    super.key,
    required this.mapaController,
  });

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<ThemeProvider>();

    return Positioned(
      top: 150,
      right: 16,
      child: FloatingActionButton.small(
        backgroundColor: tema.primary,
        onPressed: () {
          mapaController.centralizarMapaAtual();
        },
        tooltip: 'Centralizar no percurso',
        heroTag: 'Centralizar no percurso',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.center_focus_strong, color: Colors.white,),
      ),
    );
  }
}

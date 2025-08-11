import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../../services/dados_espaciais/localizacao/localizacao_usuario.dart';
import '../../../theme/theme_provider.dart';

class CentralizarLocalizacao extends StatelessWidget {
  final MapController mapController;
  const CentralizarLocalizacao({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<ThemeProvider>();

    return Positioned(
      top: 100,
      right: 16,
      child: FloatingActionButton.small(
        heroTag: null,
        tooltip: 'Centralizar localização',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: tema.primary,
        onPressed: () async {
          try {
            final posicao = await LocalizacaoService.pegarLocalizacaoAtual();
            mapController.move(
              LatLng(posicao.latitude, posicao.longitude),
              16.0,
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}

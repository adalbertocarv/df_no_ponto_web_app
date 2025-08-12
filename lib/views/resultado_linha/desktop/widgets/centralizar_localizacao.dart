import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../services/dados_espaciais/localizacao/localizacao_usuario.dart';
import '../../../theme/theme_provider.dart';

class CentralizarLocalizacao extends StatelessWidget {
  final MapController mapController;
  final double bottom;
  final double right;

  const CentralizarLocalizacao({
    super.key,
    required this.mapController,
    required this.bottom,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<ThemeProvider>();

    return Positioned(
      bottom: bottom,
      right: right,
      child: FloatingActionButton.small(
        heroTag: null,
        tooltip: 'Centralizar localização',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: tema.primary,
        onPressed: () async {
          // Usar o serviço de localização para obter a posição do usuário
          LatLng? userLocation = await LocalizacaoUsuarioService().obterLocalizacaoUsuario();

          // Verifica se a localização do usuário foi obtida
          if (userLocation != null) {
            mapController.move(userLocation, 16); // Centraliza o mapa na localização do usuário
          } else {
            // Pode exibir um alerta ou um snackbar se não conseguir obter a localização
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Não foi possível obter a localização do usuário')),
            );
          }
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}

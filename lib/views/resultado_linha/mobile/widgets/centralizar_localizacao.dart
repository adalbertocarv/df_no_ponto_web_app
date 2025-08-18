import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../providers/theme/theme_provider.dart';
import '../../../../services/dados_espaciais/localizacao/localizacao_usuario.dart';

class CentralizarLocalizacao extends StatelessWidget {
  final MapController mapController;
  final double top;
  final double right;
  // NOVO: Adicione este callback para retornar a localização
  final void Function(LatLng)? onLocationObtained;

  const CentralizarLocalizacao({
    super.key,
    required this.mapController,
    required this.top,
    required this.right,
    this.onLocationObtained, // Callback opcional
  });

  void _showErrorSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: action != null ? const Duration(seconds: 10) : const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<ThemeProvider>();

    return Positioned(
      top: top,
      right: right,
      child: FloatingActionButton.small(
        heroTag: null,
        tooltip: 'Centralizar localização',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: tema.primary,
        onPressed: () async {
          final resultado = await LocalizacaoUsuarioService().obterLocalizacaoUsuario();

          if (!context.mounted) return;

          switch (resultado.status) {
            case LocalizacaoStatus.sucesso:
              if (resultado.localizacao != null) {
                // Move o mapa para a localização
                mapController.move(resultado.localizacao!, 16);

                // NOVO: Chama o callback para informar a localização obtida
                onLocationObtained?.call(resultado.localizacao!);
              }
              break;

            case LocalizacaoStatus.servicoDesabilitado:
              _showErrorSnackBar(context, 'Por favor, ative o serviço de localização (GPS).');
              break;

            case LocalizacaoStatus.permissaoNegada:
              _showErrorSnackBar(context, 'Você precisa conceder permissão de localização para usar esta função.');
              break;

            case LocalizacaoStatus.permissaoNegadaPermanentemente:
              _showErrorSnackBar(
                context,
                'A permissão de localização foi negada permanentemente.',
                action: SnackBarAction(
                  label: 'ABRIR CONFIG.',
                  onPressed: () {
                    Geolocator.openAppSettings();
                  },
                ),
              );
              break;

            case LocalizacaoStatus.erroInesperado:
              _showErrorSnackBar(context, 'Ocorreu um erro ao buscar sua localização. Tente novamente.');
              break;
          }
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
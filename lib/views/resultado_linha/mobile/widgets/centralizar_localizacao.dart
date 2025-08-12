import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart'; // NECESSÁRIO para openAppSettings

// Importe seu serviço de localização que retorna o status detalhado
import '../../../../services/dados_espaciais/localizacao/localizacao_usuario.dart';
import '../../../theme/theme_provider.dart';

class CentralizarLocalizacao extends StatelessWidget {
  final MapController mapController;
  final double top;
  final double right;

  const CentralizarLocalizacao({
    super.key,
    required this.mapController,
    required this.top,
    required this.right,
  });

  // Função auxiliar para exibir o SnackBar de forma limpa
  void _showErrorSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    // Garante que qualquer SnackBar anterior seja removido antes de mostrar um novo
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        // Duração maior se houver uma ação, para dar tempo ao usuário
        duration: action != null ? const Duration(seconds: 10) : const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating, // Melhora a aparência em telas maiores
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
        heroTag: null, // Evita erro de HeroTag duplicado se houver múltiplos FABs
        tooltip: 'Centralizar localização',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: tema.primary,
        // --- INÍCIO DA SEÇÃO ADAPTADA ---
        onPressed: () async {
          // Chama o serviço que retorna o resultado detalhado
          final resultado = await LocalizacaoUsuarioService().obterLocalizacaoUsuario();

          // É uma boa prática verificar se o widget ainda está na árvore antes de usar o BuildContext
          if (!context.mounted) return;

          // Usa um switch para tratar cada caso possível retornado pelo serviço
          switch (resultado.status) {
            case LocalizacaoStatus.sucesso:
            // Caso de sucesso: move o mapa para a localização do usuário
              if (resultado.localizacao != null) {
                mapController.move(resultado.localizacao!, 16);
              }
              break;

            case LocalizacaoStatus.servicoDesabilitado:
              _showErrorSnackBar(context, 'Por favor, ative o serviço de localização (GPS).');
              break;

            case LocalizacaoStatus.permissaoNegada:
              _showErrorSnackBar(context, 'Você precisa conceder permissão de localização para usar esta função.');
              break;

            case LocalizacaoStatus.permissaoNegadaPermanentemente:
            // Caso especial: oferece uma ação para o usuário corrigir o problema
              _showErrorSnackBar(
                context,
                'A permissão de localização foi negada permanentemente.',
                action: SnackBarAction(
                  label: 'ABRIR CONFIG.',
                  onPressed: () {
                    // Abre as configurações do aplicativo (no celular) ou do site (no navegador)
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
        // --- FIM DA SEÇÃO ADAPTADA ---
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../controller/resultado_linha/resultado_linha_controller.dart';
import '../../widgets/build_titulo.dart';
import '../../widgets/favorite_button.dart';

class DesktopSidePanel extends StatelessWidget {
  const DesktopSidePanel({
    super.key,
    required this.numero,
    required this.dadosController,
    required this.onAlternarSentido,
    required this.onMoveToPercurso,
  });

  final String numero;
  final ResultadoLinhaController dadosController;
  final VoidCallback onAlternarSentido;
  final Function(List) onMoveToPercurso;

  @override
  Widget build(BuildContext context) {
    final percursos = dadosController.percursos ?? {};
    final itinerario = dadosController.itinerarioDescritivo;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 380,
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header com navegação, título e favorito
            _buildHeader(context),

            // Botão de trocar sentido
            if (!dadosController.ehCircular && !dadosController.unicaDirecao)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: onAlternarSentido,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    overlayColor: Colors.blueAccent.withOpacity(0.1), // Cor ao pressionar
                  ),
                  child: const Text(
                    'Trocar sentido',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

            // Conteúdo do painel lateral
            Expanded(
              child: dadosController.carregando
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : _buildContent(percursos, itinerario),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TituloWidget(numero: numero),
        FavoriteButtonWidget(
          numero: numero,
          descricao: dadosController.infoLinha?.firstOrNull?.descricao ??
              'Descrição não disponível',
        ),
      ],
    );
  }

  Widget _buildContent(Map percursos, List? itinerario) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Itinerário descritivo (se disponível)
        if (itinerario != null && itinerario.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Itinerário Descritivo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...itinerario.map(
                (item) => ListTile(
              dense: true,
              leading: const Icon(Icons.location_on_outlined),
              title: Text(item.destino),
              subtitle: Text(item.origem),
            ),
          ),
        ],
      ],
    );
  }
}
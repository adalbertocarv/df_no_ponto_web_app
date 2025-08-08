// Arquivo complementar: sistema_alternancia_sentido.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../../controller/resultado_linha/resultado_linha_controller.dart';

// 1. Widget customizado para o botão de alternar sentido
class BotaoAlternarSentido extends StatelessWidget {
  final String sentidoAtual;
  final bool ehCircular;
  final bool unicaDirecao;
  final VoidCallback onPressed;
  final int quantidadeVeiculosIda;
  final int quantidadeVeiculosVolta;

  const BotaoAlternarSentido({
    Key? key,
    required this.sentidoAtual,
    required this.ehCircular,
    required this.unicaDirecao,
    required this.onPressed,
    this.quantidadeVeiculosIda = 0,
    this.quantidadeVeiculosVolta = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Não mostra o botão para linhas circulares ou unidirecionais
    if (ehCircular || unicaDirecao) {
      return const SizedBox.shrink();
    }

    final isIda = sentidoAtual.toUpperCase() == 'IDA';
    final proximoSentido = isIda ? 'VOLTA' : 'IDA';
    final corAtual = isIda ? Colors.blueAccent : Colors.orangeAccent;
    final proximaCor = isIda ? Colors.orangeAccent : Colors.blueAccent;
    final quantidadeAtual = isIda ? quantidadeVeiculosIda : quantidadeVeiculosVolta;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone do sentido atual
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: corAtual.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: corAtual,
                  ),
                ),

                const SizedBox(width: 8),

                // Texto com informação
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sentidoAtual.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: corAtual,
                        fontSize: 14,
                      ),
                    ),
                    if (quantidadeAtual > 0)
                      Text(
                        '$quantidadeAtual veículo${quantidadeAtual > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // Ícone de troca
                Icon(
                  Icons.swap_horiz,
                  color: Colors.grey[600],
                  size: 20,
                ),

                const SizedBox(width: 8),

                // Próximo sentido (preview)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: proximaCor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: proximaCor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//
// // 2. Extensão para o controller com métodos auxiliares
// extension ResultadoLinhaControllerExtension on ResultadoLinhaController {
//   /// Conta quantos veículos existem em cada sentido
//   Map<String, int> get contagemVeiculosPorSentido {
//     if (veiculos == null) return {'IDA': 0, 'VOLTA': 0, 'CIRCULAR': 0};
//
//     final contagem = <String, int>{'IDA': 0, 'VOLTA': 0, 'CIRCULAR': 0};
//
//     for (final veiculo in veiculos!.features) {
//       final sentido = veiculo.properties.sentido?.toUpperCase() ?? 'DESCONHECIDO';
//       contagem[sentido] = (contagem[sentido] ?? 0) + 1;
//     }
//
//     return contagem;
//   }
//
//   /// Verifica se é uma linha IDA-VOLTA (não circular e não unidirecional)
//   bool get ehIdaVolta {
//     return !ehCircular && !unicaDirecao;
//   }
//
//   /// Retorna a cor associada ao sentido atual
//   Color get corSentidoAtual {
//     switch (sentidoSelecionado.toUpperCase()) {
//       case 'IDA':
//         return Colors.blueAccent;
//       case 'VOLTA':
//         return Colors.orangeAccent;
//       case 'CIRCULAR':
//         return Colors.redAccent;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   /// Sincroniza os dados após alternar sentido
//   void sincronizarAposAlternarSentido() {
//     // Pode ser usado para fazer atualizações específicas após troca
//     atualizarVeiculos();
//   }
// }
//
// // 3. Mixin para funcionalidades do mapa relacionadas aos veículos
// mixin VeiculoMapaMixin {
//   /// Centraliza o mapa nos veículos do sentido atual
//   void centralizarNosVeiculos(
//       MapController mapController,
//       List<Feature> veiculos, {
//         double padding = 50.0,
//       }) {
//     if (veiculos.isEmpty) return;
//
//     final pontos = veiculos
//         .map((v) => LatLng(
//       v.geometry.coordinates[1],
//       v.geometry.coordinates[0],
//     ))
//         .toList();
//
//     if (pontos.length == 1) {
//       mapController.move(pontos.first, 15);
//       return;
//     }
//
//     // Calcula os bounds
//     double minLat = pontos.first.latitude;
//     double maxLat = pontos.first.latitude;
//     double minLng = pontos.first.longitude;
//     double maxLng = pontos.first.longitude;
//
//     for (final ponto in pontos) {
//       minLat = math.min(minLat, ponto.latitude);
//       maxLat = math.max(maxLat, ponto.latitude);
//       minLng = math.min(minLng, ponto.longitude);
//       maxLng = math.max(maxLng, ponto.longitude);
//     }
//
//     final bounds = LatLngBounds(
//       LatLng(minLat, minLng),
//       LatLng(maxLat, maxLng),
//     );
//
//     mapController.fitBounds(
//       bounds,
//       options: FitBoundsOptions(padding: EdgeInsets.all(padding)),
//     );
//   }
// }
//
// // 4. Widget de indicador de sentido para o mapa
// class IndicadorSentidoMapa extends StatelessWidget {
//   final String sentidoAtual;
//   final bool ehCircular;
//   final bool unicaDirecao;
//   final int quantidadeVeiculos;
//
//   const IndicadorSentidoMapa({
//     Key? key,
//     required this.sentidoAtual,
//     required this.ehCircular,
//     required this.unicaDirecao,
//     required this.quantidadeVeiculos,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     if (ehCircular) {
//       return _buildIndicador('CIRCULAR', Colors.redAccent, Icons.refresh);
//     }
//
//     if (unicaDirecao) {
//       return _buildIndicador(sentidoAtual, Colors.grey, Icons.arrow_forward);
//     }
//
//     // Linha IDA-VOLTA
//     final cor = sentidoAtual.toUpperCase() == 'IDA'
//         ? Colors.blueAccent
//         : Colors.orangeAccent;
//
//     return _buildIndicador(sentidoAtual, cor, Icons.arrow_forward);
//   }
//
//   Widget _buildIndicador(String texto, Color cor, IconData icone) {
//     return Positioned(
//       top: 10,
//       right: 10,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icone, color: cor, size: 16),
//             const SizedBox(width: 6),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   texto.toUpperCase(),
//                   style: TextStyle(
//                     color: cor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//                 if (quantidadeVeiculos > 0)
//                   Text(
//                     '$quantidadeVeiculos veículo${quantidadeVeiculos > 1 ? 's' : ''}',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 10,
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// 5. Como integrar tudo no seu código existente:

/*
No seu método _buildMap(), adicione o indicador:

Widget _buildMap() {
  // ... código existente ...

  return Stack(
    children: [
      FlutterMap(
        // ... configuração existente ...
        children: [
          // ... layers existentes ...
        ],
      ),
      // Adicione o indicador
      IndicadorSentidoMapa(
        sentidoAtual: _dadosController.sentidoSelecionado,
        ehCircular: _dadosController.ehCircular,
        unicaDirecao: _dadosController.unicaDirecao,
        quantidadeVeiculos: _dadosController.veiculosExibidos.length,
      ),
    ],
  );
}

No seu header do DraggableSheet, substitua o botão simples:

// Substitua o TextButton por:
BotaoAlternarSentido(
  sentidoAtual: _dadosController.sentidoSelecionado,
  ehCircular: _dadosController.ehCircular,
  unicaDirecao: _dadosController.unicaDirecao,
  quantidadeVeiculosIda: _dadosController.contagemVeiculosPorSentido['IDA'] ?? 0,
  quantidadeVeiculosVolta: _dadosController.contagemVeiculosPorSentido['VOLTA'] ?? 0,
  onPressed: () {
    _alternarSentido();
    // Opcionalmente, centralize nos novos veículos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final veiculosExibidos = _dadosController.veiculosExibidos;
        if (veiculosExibidos.isNotEmpty) {
          centralizarNosVeiculos(_map, veiculosExibidos);
        }
      }
    });
  },
),

*/
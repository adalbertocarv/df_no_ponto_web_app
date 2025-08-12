import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../controller/resultado_linha/resultado_linha_controller.dart';
import '../../../../models/linha/horario.dart';
import '../../../../models/linha/veiculos_tempo_real.dart';
import '../../widgets/build_titulo.dart';
import '../../widgets/favorite_button.dart';

class DesktopSidePanel extends StatelessWidget {
  const DesktopSidePanel({
    super.key,
    required this.numero,
    required this.dadosController,
    required this.onAlternarSentido,
    required this.onMoveToPercurso,
    required this.mapController, // Adicionar controller do mapa
    this.onShowVehicleDetails,
  });

  final String numero;
  final ResultadoLinhaController dadosController;
  final VoidCallback onAlternarSentido;
  final Function(List) onMoveToPercurso;
  final MapController mapController;
  final Function(BuildContext, Feature)? onShowVehicleDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header com navegação, título e favorito
          _buildHeader(context),

          // Sistema de alternância de sentido aprimorado
          _buildSentidoControls(context),

          // Conteúdo com tabs
          Expanded(
            child: dadosController.carregando
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _buildTabContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
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
      ),
    );
  }

  Widget _buildSentidoControls(BuildContext context) {
    if (dadosController.ehCircular || dadosController.unicaDirecao) {
      return const SizedBox.shrink();
    }

    final contagem = dadosController.contagemVeiculosPorSentido;
    final sentidoAtual = dadosController.sentidoSelecionado;
    final quantidadeAtual = sentidoAtual.toUpperCase() == 'IDA'
        ? (contagem['IDA'] ?? 0)
        : (contagem['VOLTA'] ?? 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Indicador do sentido atual
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: sentidoAtual.toUpperCase() == 'IDA'
                  ? Colors.blueAccent.withValues(alpha: 0.1)
                  : Colors.orangeAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sentidoAtual.toUpperCase() == 'IDA'
                    ? Colors.blueAccent
                    : Colors.orangeAccent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_forward,
                  color: sentidoAtual.toUpperCase() == 'IDA'
                      ? Colors.blueAccent
                      : Colors.orangeAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sentido: ${sentidoAtual.toUpperCase()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: sentidoAtual.toUpperCase() == 'IDA'
                              ? Colors.blueAccent
                              : Colors.orangeAccent,
                        ),
                      ),
                      if (quantidadeAtual > 0)
                        Text(
                          '$quantidadeAtual veículo${quantidadeAtual > 1 ? 's' : ''} ativo${quantidadeAtual > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Botão de trocar sentido
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAlternarSentido,
              icon: const Icon(Icons.swap_horiz, size: 20),
              label: Text(
                'Trocar para ${sentidoAtual.toUpperCase() == 'IDA' ? 'VOLTA' : 'IDA'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blueAccent,
            labelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.schedule, size: 18),
                text: 'Horários',
              ),
              Tab(
                icon: Icon(Icons.route, size: 18),
                text: 'Itinerário',
              ),
              Tab(
                icon: Icon(Icons.info, size: 18),
                text: 'Informações',
              ),
              Tab(
                icon: Icon(Icons.directions_bus, size: 18),
                text: 'Veículos',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildHorariosTab(context),
                _buildItinerarioTab(context),
                _buildInformacoesTab(context),
                _buildVeiculosTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Aba de Horários
  Widget _buildHorariosTab(BuildContext context) {
    final horarios = dadosController.horarios;

    if (horarios == null || horarios.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum horário disponível',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: horarios.length,
      itemBuilder: (context, index) {
        final horario = horarios[index];

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.schedule, color: Colors.blueAccent),
            title: Text(
              'Sentido: ${horario.sentido}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              horario.duracaoMedia != null
                  ? 'Duração média: ${horario.duracaoMedia} min'
                  : 'Duração não informada',
              style: const TextStyle(fontSize: 12),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ..._agruparHorariosPorDia(horario.horarios).entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              Horario.formatarDiaSemana(entry.key),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: entry.value.map((h) => Chip(
                              label: Text(
                                h.horario,
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: Colors.grey[100],
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<Horario>> _agruparHorariosPorDia(List<Horario> horarios) {
    final Map<String, List<Horario>> agrupados = {};

    for (final horario in horarios) {
      if (!agrupados.containsKey(horario.diasSemana)) {
        agrupados[horario.diasSemana] = [];
      }
      agrupados[horario.diasSemana]!.add(horario);
    }

    for (final lista in agrupados.values) {
      lista.sort((a, b) => (a.hora * 60 + a.minuto).compareTo(b.hora * 60 + b.minuto));
    }

    return agrupados;
  }

  // Aba de Itinerário
  Widget _buildItinerarioTab(BuildContext context) {
    final itinerarios = dadosController.itinerarios;

    if (itinerarios == null || itinerarios.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum itinerário disponível',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itinerarios.length,
      itemBuilder: (context, index) {
        final itinerario = itinerarios[index];

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.route, color: Colors.orangeAccent),
            title: Text(
              '${itinerario.origem} → ${itinerario.destino}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sentido: ${itinerario.sentido}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Extensão: ${itinerario.extensao.toStringAsFixed(2)} km',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            children: [
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: itinerario.itinerario.map((item) {
                      final isFirst = itinerario.itinerario.first == item;
                      final isLast = itinerario.itinerario.last == item;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isFirst
                                    ? Colors.green
                                    : isLast
                                    ? Colors.red
                                    : Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  item.sequencial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.via.isNotEmpty)
                                    Text(
                                      item.via,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (item.localidade.isNotEmpty)
                                    Text(
                                      item.localidade,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Aba de Informações
  Widget _buildInformacoesTab(BuildContext context) {
    final infoLinhas = dadosController.infoLinha;

    if (infoLinhas == null || infoLinhas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhuma informação disponível',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: infoLinhas.length,
      itemBuilder: (context, index) {
        final info = infoLinhas[index];

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Linha ${info.numero}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildInfoRow('Descrição', info.descricao),
                _buildInfoRow('Sentido', info.sentido),
                _buildInfoRow('Operadora', info.operadora),
                _buildInfoRow('Tarifa', 'R\$ ${info.tarifa.toStringAsFixed(2)}'),
                _buildInfoRow('Faixa Tarifária', info.faixaTarifaria),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Aba de Veículos
  Widget _buildVeiculosTab(BuildContext context) {
    final veiculosExibidos = dadosController.veiculosExibidos;

    if (veiculosExibidos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus_filled,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum veículo em tempo real',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header com informações do sentido
        if (!dadosController.ehCircular && !dadosController.unicaDirecao)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dadosController.sentidoSelecionado.toUpperCase() == 'IDA'
                  ? Colors.blueAccent.withValues(alpha: 0.1)
                  : Colors.orangeAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: dadosController.sentidoSelecionado.toUpperCase() == 'IDA'
                    ? Colors.blueAccent
                    : Colors.orangeAccent,
                width: 1,
              ),
            ),
            child: Text(
              'Exibindo ${veiculosExibidos.length} veículo${veiculosExibidos.length > 1 ? 's' : ''} do sentido: ${dadosController.sentidoSelecionado}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: dadosController.sentidoSelecionado.toUpperCase() == 'IDA'
                    ? Colors.blueAccent
                    : Colors.orangeAccent,
              ),
            ),
          ),

        // Lista de veículos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: veiculosExibidos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculosExibidos[index];
              final props = veiculo.properties;
              final sentidoColor = veiculo.getColorBySentido();

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sentidoColor.withValues(alpha: 0.1),
                      border: Border.all(color: sentidoColor, width: 2),
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: sentidoColor,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    'Prefixo: ${props.prefixo ?? 'N/A'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (props.nm_operadora != null)
                        Text(
                          'Operadora: ${props.nm_operadora?.split(' ')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10),
                        ),
                      Row(
                        children: [
                          if (props.velocidade != null)
                            Text(
                              '${props.velocidade}km/h',
                              style: const TextStyle(fontSize: 10),
                            ),
                          if (props.velocidade != null && props.sentido != null)
                            const Text(' • ', style: TextStyle(fontSize: 10)),
                          if (props.sentido != null)
                            Text(
                              props.sentido!,
                              style: TextStyle(
                                color: sentidoColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.my_location,
                          color: sentidoColor,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        onPressed: () {
                          final coords = veiculo.geometry.coordinates;
                          if (coords.length >= 2) {
                            mapController.move(LatLng(coords[1], coords[0]), 16);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    if (onShowVehicleDetails != null) {
                      onShowVehicleDetails!(context, veiculo);
                    } else {
                      _showVehicleDetails(context, veiculo);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showVehicleDetails(BuildContext context, Feature veiculo) {
    final props = veiculo.properties;
    final datalocal = props.datalocal ?? 'N/A';
    final dataFormatada = formatarDataHora(datalocal);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Veículo ${props.prefixo ?? 'N/A'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (props.nm_operadora != null)
              Text('Operadora: ${props.nm_operadora}'),
            if (props.cdLinha != null)
              Text('Código da Linha: ${props.cdLinha}'),
            if (props.velocidade != null)
              Text('Velocidade: ${props.velocidade} km/h'),
            // if (props.direcao != null)
            //   Text('Direção: ${props.direcao}'),
            if (props.datalocal != null)
              Text('Última atualização: $dataFormatada'),
            const SizedBox(height: 8),
            Text('Coordenadas: ${veiculo.geometry.coordinates[1].toStringAsFixed(6)}, ${veiculo.geometry.coordinates[0].toStringAsFixed(6)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar', style: TextStyle(color: Colors.blueAccent),),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final coords = veiculo.geometry.coordinates;
              if (coords.length >= 2) {
                mapController.move(LatLng(coords[1], coords[0]), 18);
              }
            },
            child: const Text('Ver no Mapa', style: TextStyle(color: Colors.blueAccent),),
          ),
        ],
      ),
    );
  }

  /// Formata a data e hora para exibição amigável
  String formatarDataHora(String datalocal) {
    try {
      final dateTime = DateTime.parse(datalocal);
      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year} às '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}:'
          '${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Data inválida';
    }
  }
}

// Extensão para adicionar os métodos necessários ao controller
extension DesktopPanelExtension on ResultadoLinhaController {
  /// Contagem de veículos por sentido (reutilizado da implementação mobile)
  Map<String, int> get contagemVeiculosPorSentido {
    if (veiculos == null) return {'IDA': 0, 'VOLTA': 0, 'CIRCULAR': 0};

    final contagem = <String, int>{'IDA': 0, 'VOLTA': 0, 'CIRCULAR': 0};

    for (final veiculo in veiculos!.features) {
      final sentido = veiculo.properties.sentido?.toUpperCase() ?? 'DESCONHECIDO';
      contagem[sentido] = (contagem[sentido] ?? 0) + 1;
    }

    return contagem;
  }

  /// Veículos filtrados para exibição (reutilizado da implementação mobile)
  List<Feature> get veiculosExibidos {
    if (veiculos == null || veiculos!.features.isEmpty) {
      return [];
    }

    // Para linhas circulares, mostra todos os veículos
    if (ehCircular) {
      return veiculos!.features;
    }

    // Para linhas unidirecionais, mostra todos os veículos
    if (unicaDirecao) {
      return veiculos!.features;
    }

    // Para linhas IDA-VOLTA, filtra pelo sentido selecionado
    return veiculos!.features.where((feature) =>
    feature.properties.sentido?.toUpperCase() == sentidoSelecionado.toUpperCase()
    ).toList();
  }
}
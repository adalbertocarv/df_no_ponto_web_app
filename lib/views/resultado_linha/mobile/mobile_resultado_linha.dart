import 'dart:async';

import 'package:df_no_ponto_web_app/views/resultado_linha/mobile/widgets/centralizar_localizacao.dart';
import 'package:df_no_ponto_web_app/views/resultado_linha/mobile/widgets/centralizar_polylines.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../controller/resultado_linha/mapa_linha_controller.dart';
import '../../../controller/resultado_linha/resultado_linha_controller.dart';
import '../../../models/linha/horario.dart';
import '../../../models/linha/veiculos_tempo_real.dart';
import '../widgets/build_titulo.dart';
import '../widgets/favorite_button.dart';

class MobileResultadoLinha extends StatefulWidget {
  const MobileResultadoLinha({super.key, required this.numero});
  final String numero;

  @override
  State<MobileResultadoLinha> createState() => _MobileResultadoLinhaState();
}

class _MobileResultadoLinhaState extends State<MobileResultadoLinha> {
  final _map = MapController();
  late final ResultadoLinhaController _dadosController;
  late final ResultadoMapaController _mapaController;
  final DraggableScrollableController _draggableController = DraggableScrollableController();

  bool _mapaInicializado = false;
  bool showBottomSheet = false;

  static const _fallbackCenter = LatLng(-15.7942, -47.8822);
  static const _fallbackZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _dadosController = ResultadoLinhaController(widget.numero);
    _mapaController = ResultadoMapaController(widget.numero);

    // Adiciona listener para reagir às mudanças de dados
    _dadosController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dadosController.removeListener(_onDataChanged);
    _dadosController.dispose();
    _mapaController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (!mounted) return;
    setState(() {
      _initializeMapIfReady();
    });
  }

  void _initializeMapIfReady() {
    if (!_mapaInicializado ||
        _dadosController.carregando ||
        _dadosController.percursos == null ||
        _dadosController.percursos!.isEmpty) {
      return;
    }

    final percursos = _dadosController.percursos!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapaController.init(_map, percursos);
    });
  }

  void _onMapReady() {
    if (_mapaInicializado) return;
    _mapaInicializado = true;
    _initializeMapIfReady();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: TituloWidget(numero: widget.numero),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          FavoriteButtonWidget(
            numero: widget.numero,
            descricao: _dadosController.infoLinha?.firstOrNull?.descricao ??
                'Descrição não disponível',
          ),
        ],
      ),
      body: _dadosController.carregando
          ? _loader()
          : _dadosController.erro != null
              ? Center(child: Text(_dadosController.erro!))
              : Stack(
                  children: [
                    _buildMap(),
                    _buildDraggableSheet(),
                  ],
                ),
    );
  }

  void _alternarSentido() {
    if (!_dadosController.ehCircular && !_dadosController.unicaDirecao) {
      _dadosController.alternarSentido();
      // Força a reconstrução do mapa com os novos veículos
      setState(() {});
    }
  }

  void _showVehicleTooltip(BuildContext context, Feature veiculo, Offset position) {
    final props = veiculo.properties;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned(
            left: position.dx - 100,
            top: position.dy - 120,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prefixo: ${props.prefixo ?? 'N/A'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (props.velocidade != null)
                      Text(
                        'Velocidade: ${props.velocidade} km/h',
                        style: const TextStyle(fontSize: 12),
                      ),
                    if (props.sentido != null)
                      Text(
                        'Sentido: ${props.sentido}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    if (props.nm_operadora != null)
                      Text(
                        'Operadora: ${props.nm_operadora}',
                        style: const TextStyle(fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Auto-fecha o tooltip após 3 segundos
    Timer(const Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }


  Widget _loader() =>
      const Center(child: CircularProgressIndicator(strokeWidth: 2));

  // --------------------------- MAPA ---------------------------
  Widget _buildMap() {
    final percursos = _dadosController.percursos ?? {};
    if (percursos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum percurso encontrado',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final percursosExibidos = _dadosController.percursosExibidos;
    final veiculosExibidos = _dadosController.veiculosExibidos;

    // Cria as camadas de polylines
    final polylineLayers = percursosExibidos.entries.expand((entry) {
      final color = switch (entry.key.toUpperCase()) {
        'VOLTA' => Colors.orangeAccent,
        'IDA' => Colors.blueAccent,
        'CIRCULAR' => Colors.redAccent,
        _ => Colors.grey,
      };
      return entry.value.map(
            (p) => PolylineLayer(
          polylines: [
            Polyline(
              points: p.coordenadas,
              strokeWidth: 4,
              color: color,
            ),
          ],
        ),
      );
    }).toList();

    // Cria os markers dos veículos
    final vehicleMarkers = veiculosExibidos.map((veiculo) =>
        veiculo.toMarker(
          onTap: () => _showVehicleDetails(context, veiculo),
        )
    ).toList();

    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          cursorKeyboardRotationOptions: CursorKeyboardRotationOptions.disabled(),
        ),
        initialCenter: _fallbackCenter,
        initialZoom: _fallbackZoom,
        onMapReady: _onMapReady,
        maxZoom: 20,
        minZoom: 9.5,
      ),
      children: [
        TileLayer(
          tileProvider: CancellableNetworkTileProvider(),
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.df.no.ponto.df_no_ponto_web_app',
        ),
        // Polylines primeiro (camada de fundo)
        ...polylineLayers,
        // Markers dos veículos por cima
        if (vehicleMarkers.isNotEmpty)
          MarkerLayer(markers: vehicleMarkers),
        CentralizarLocalizacao(mapController: _map, top: 100,right: 16,),
        CentralizarPolylines(mapaController: _mapaController),
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
      ],
    );
  }
  // --------------------------- DRAGGABLE SHEET ---------------------------
// Substitua o método _buildDraggableSheet() no seu arquivo mobile_resultado_linha.dart

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.25,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header com GestureDetector aplicado
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                final currentSize = _draggableController.size;
                final screenHeight = MediaQuery.of(context).size.height;
                if (screenHeight == 0) return;
                final newSize = currentSize - (details.primaryDelta! / screenHeight);
                _draggableController.jumpTo(newSize.clamp(0.2, 0.65));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 40,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 40,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      // Botão trocar sentido
                      if (!_dadosController.ehCircular && !_dadosController.unicaDirecao)
                      // Botão de trocar sentido
                        SizedBox(
                          width: 180,
                          child: ElevatedButton.icon(
                            onPressed: _alternarSentido,
                            icon: const Icon(Icons.swap_horiz, size: 20),
                            label: Text(
                              'Trocar para ${_dadosController.sentidoSelecionado.toUpperCase() == 'IDA' ? 'VOLTA' : 'IDA'}',
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
                    ])
                  ],
                ),
              ),
            ),
            // Tabs
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: false,
                      tabAlignment: TabAlignment.fill,
                      labelColor: Colors.blueAccent,
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: Colors.blueAccent,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.schedule, size: 20),
                          text: 'Horários',
                          iconMargin: EdgeInsets.only(bottom: 4),
                        ),
                        Tab(
                          icon: Icon(Icons.route, size: 20),
                          text: 'Itinerário',
                          iconMargin: EdgeInsets.only(bottom: 4),
                        ),
                        Tab(
                          icon: Icon(Icons.info, size: 20),
                          text: 'Informações',
                          iconMargin: EdgeInsets.only(bottom: 4),
                        ),
                        Tab(
                          icon: Icon(Icons.directions_bus, size: 20),
                          text: 'Veículos',
                          iconMargin: EdgeInsets.only(bottom: 4),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildHorariosTab(scrollController),
                          _buildItinerarioTab(scrollController),
                          _buildInformacoesTab(scrollController),
                          _buildVeiculosTab(scrollController),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Aba de Horários
  Widget _buildHorariosTab(ScrollController scrollController) {
    final horarios = _dadosController.horarios;

    if (horarios == null || horarios.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum horário disponível',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: horarios.length,
      itemBuilder: (context, index) {
        final horario = horarios[index];

        return Card(
          color: Colors.grey[100],
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.schedule, color: Colors.blueAccent),
            title: Text(
              'Sentido: ${horario.sentido}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              horario.duracaoMedia != null
                  ? 'Duração média: ${horario.duracaoMedia} min'
                  : 'Duração não informada',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Agrupa horários por tipo de dia
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
                                fontSize: 16,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: entry.value.map((h) => Chip(
                              label: Text(
                                h.horario,
                                style: const TextStyle(fontSize: 12),
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

    // Ordena os horários dentro de cada grupo
    for (final lista in agrupados.values) {
      lista.sort((a, b) => (a.hora * 60 + a.minuto).compareTo(b.hora * 60 + b.minuto));
    }

    return agrupados;
  }

// Aba de Itinerário
  Widget _buildItinerarioTab(ScrollController scrollController) {
    final itinerarios = _dadosController.itinerarios;

    if (itinerarios == null || itinerarios.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum itinerário disponível',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: itinerarios.length,
      itemBuilder: (context, index) {
        final itinerario = itinerarios[index];

        return Card(
          color: Colors.grey[100],
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.route, color: Colors.orangeAccent),
            title: Text(
              '${itinerario.origem} → ${itinerario.destino}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sentido: ${itinerario.sentido}'),
                Text('Extensão: ${itinerario.extensao.toStringAsFixed(2)} km'),
              ],
            ),
            children: [
              Container(
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
                            width: 24,
                            height: 24,
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
                                  fontSize: 10,
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
                                    ),
                                  ),
                                if (item.localidade.isNotEmpty)
                                  Text(
                                    item.localidade,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
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
            ],
          ),
        );
      },
    );
  }

// Aba de Informações
  Widget _buildInformacoesTab(ScrollController scrollController) {
    final infoLinhas = _dadosController.infoLinha;

    if (infoLinhas == null || infoLinhas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma informação disponível',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: infoLinhas.length,
      itemBuilder: (context, index) {
        final info = infoLinhas[index];

        return Card(
          color: Colors.grey[100],
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
                          fontSize: 18,
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
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

// Aba de Veículos
  Widget _buildVeiculosTab(ScrollController scrollController) {
    final veiculosExibidos = _dadosController.veiculosExibidos;

    if (veiculosExibidos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus_filled,
              size: 64,
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
        if (!_dadosController.ehCircular && !_dadosController.unicaDirecao)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _dadosController.sentidoSelecionado.toUpperCase() == 'IDA'
                  ? Colors.blueAccent.withValues(alpha: 0.1)
                  : Colors.orangeAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _dadosController.sentidoSelecionado.toUpperCase() == 'IDA'
                    ? Colors.blueAccent
                    : Colors.orangeAccent,
                width: 1,
              ),
            ),
            child: Text(
              'Exibindo veículos do sentido: ${_dadosController.sentidoSelecionado}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _dadosController.sentidoSelecionado.toUpperCase() == 'IDA'
                    ? Colors.blueAccent
                    : Colors.orangeAccent,
              ),
            ),
          ),

        // Lista de veículos
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: veiculosExibidos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculosExibidos[index];
              final props = veiculo.properties;
              final sentidoColor = veiculo.getColorBySentido();

              return Card(
                color: Colors.grey[100],
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sentidoColor.withValues(alpha: 0.1),
                      border: Border.all(color: sentidoColor, width: 2),
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: sentidoColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Prefixo: ${props.prefixo ?? 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (props.nm_operadora != null)
                        Text(
                          'Operadora: ${props.nm_operadora}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (props.velocidade != null)
                        Text('Velocidade: ${props.velocidade} km/h'),
                      if (props.sentido != null)
                        Text(
                          'Sentido: ${props.sentido}',
                          style: TextStyle(
                            color: sentidoColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.my_location,
                      color: sentidoColor,
                    ),
                    onPressed: () {
                      final coords = veiculo.geometry.coordinates;
                      if (coords.length >= 2) {
                        _map.move(LatLng(coords[1], coords[0]), 16);

                        // Fecha o bottom sheet temporariamente para melhor visualização
                        _draggableController.animateTo(
                          0.15,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  ),
                  onTap: () => _showVehicleDetails(context, veiculo),
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
                _map.move(LatLng(coords[1], coords[0]), 18);
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

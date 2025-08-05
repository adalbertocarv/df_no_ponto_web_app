import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import '../../../controller/resultado_linha/mapa_linha_controller.dart';
import '../../../controller/resultado_linha/resultado_linha_controller.dart';

class DesktopResultadoLinha extends StatefulWidget {
  const DesktopResultadoLinha({super.key, required this.numero});
  final String numero;

  @override
  State<DesktopResultadoLinha> createState() => _DesktopResultadoLinhaState();
}

class _DesktopResultadoLinhaState extends State<DesktopResultadoLinha> {
  final _map = MapController();
  late final ResultadoLinhaController _dadosController;
  late final ResultadoMapaController _mapaController;
  bool _mapaInicializado = false;
  String _sentidoSelecionado = 'IDA';

  static const _fallbackCenter = LatLng(-15.7942, -47.8822);
  static const _fallbackZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _dadosController = ResultadoLinhaController(widget.numero);
    _mapaController = ResultadoMapaController(widget.numero);

    // Escuta carregamento dos dados
    _dadosController.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    // Força reconstrução quando dados mudarem
    if (mounted) {
      setState(() {
        // Inicializa o mapa quando os dados estiverem carregados
        _initializeMapIfReady();
      });
    }
  }

  bool get _isLinhaCircular {
    final sentidos = _dadosController.percursos?.keys.map((e) => e.toUpperCase()) ?? {};
    return sentidos.contains('CIRCULAR');
  }

  void _alternarSentido() {
    setState(() {
      _sentidoSelecionado = _sentidoSelecionado == 'IDA' ? 'VOLTA' : 'IDA';
      _initializeMapIfReady(); // Atualiza o mapa com o novo sentido
    });
  }

  void _initializeMapIfReady() {
    if (_mapaInicializado &&
        !_dadosController.carregando &&
        _dadosController.percursos != null &&
        _dadosController.percursos!.isNotEmpty) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final percursos = _dadosController.percursos!;
          final sentidos = percursos.keys.map((e) => e.toUpperCase()).toSet();

          if (sentidos.contains('CIRCULAR')) {
            // Mostra todos os percursos disponíveis
            _mapaController.init(_map, percursos);
          } else {
            // Mostra apenas os de IDA no início
            final percursoIda = {'IDA': percursos['IDA'] ?? []};
            _mapaController.init(_map, percursoIda);
          }
        }
      });
    }
  }

  void _onMapReady() {
    if (!_mapaInicializado) {
      _mapaInicializado = true;
      _initializeMapIfReady();
    }
  }

  @override
  void dispose() {
    _dadosController.removeListener(_onDataChanged);
    _dadosController.dispose();
    _mapaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidePanel(),
          Expanded(
            child: _buildMapArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    if (_dadosController.carregando) {
      return _loader();
    }

    final percursos = _dadosController.percursos;
    if (percursos == null || percursos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum percurso encontrado',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return _buildMap();
  }

  /* ---------- SIDE PANEL ---------- */
  Widget _buildSidePanel() {
    final percursos = _dadosController.percursos ?? {};
    final itinerario = _dadosController.itinerarioDescritivo;

    return Container(
      width: 380,
      color: Colors.grey[100],
      child: Column(
        children: [
          TextButton(onPressed: _alternarSentido, child: Text('Trocar sentido')),
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Linha ${widget.numero}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _dadosController.carregando
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _buildSidePanelContent(percursos, itinerario),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanelContent(Map percursos, List? itinerario) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ...percursos.entries.expand((e) => [
          ListTile(
            leading: const Icon(Icons.alt_route),
            title: Text('Sentido: ${e.key}'),
            subtitle: Text('${e.value.length} trecho(s)'),
            onTap: () => _moveToPercurso(e.value),
          ),
          const Divider(height: 1),
        ]),
        if (itinerario != null && itinerario.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Itinerário Descritivo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...itinerario.map((item) => ListTile(
            dense: true,
            leading: const Icon(Icons.location_on_outlined),
            title: Text(item.destino),
            subtitle: Text(item.origem),
          )),
        ]
      ],
    );
  }

  void _moveToPercurso(List percursoList) {
    if (_mapaInicializado &&
        percursoList.isNotEmpty &&
        percursoList.first.coordenadas.isNotEmpty) {
      try {
        _map.move(percursoList.first.coordenadas.first, 14);
      } catch (e) {
        debugPrint('Erro ao mover mapa: $e');
      }
    }
  }

  Widget _loader() =>
      const Center(child: CircularProgressIndicator(strokeWidth: 2));

  /* ---------- MAP ---------- */

  Widget _buildMap() {
    final percursos = _dadosController.percursos ?? {};
    final percursosExibidos = _isLinhaCircular
        ? percursos
        : {
      if (percursos.containsKey(_sentidoSelecionado))
        _sentidoSelecionado: percursos[_sentidoSelecionado]!,
    };

    final layers = _buildPolylineLayers(percursosExibidos);
    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        initialCenter: _fallbackCenter,
        initialZoom: _fallbackZoom,
        onMapReady: _onMapReady,
      ),
      children: [
        TileLayer(
          tileProvider: CancellableNetworkTileProvider(),
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        ...layers,
      ],
    );
  }

  List _buildPolylineLayers(Map percursos) {
    return percursos.entries.expand((entry) {
      final color = _getColorForSentido(entry.key);
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
  }

  Color _getColorForSentido(String sentido) {
    return switch (sentido) {
      'VOLTA' => Colors.blueAccent,
      'CIRCULAR' => Colors.blueAccent,
      _ => Colors.blueAccent,
    };
  }
}
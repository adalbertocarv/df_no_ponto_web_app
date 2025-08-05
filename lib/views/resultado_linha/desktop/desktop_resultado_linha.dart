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

  static const _fallbackCenter = LatLng(-15.7942, -47.8822);
  static const _fallbackZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _dadosController = ResultadoLinhaController(widget.numero);
    _mapaController = ResultadoMapaController(widget.numero);

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
    final sentidos = percursos.keys.map((e) => e.toUpperCase()).toSet();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (sentidos.contains('CIRCULAR')) {
        _mapaController.init(_map, percursos);
      } else {
        final percursoIda = {'IDA': percursos['IDA'] ?? []};
        _mapaController.init(_map, percursoIda);
      }
    });
  }

  void _onMapReady() {
    if (_mapaInicializado) return;

    _mapaInicializado = true;
    _initializeMapIfReady();
  }

  void _alternarSentido() {
    _dadosController.alternarSentido();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidePanel(),
          Expanded(child: _buildMapArea()),
        ],
      ),
    );
  }

  Widget _buildSidePanel() {
    final percursos = _dadosController.percursos ?? {};
    final itinerario = _dadosController.itinerarioDescritivo;

    return Container(
      width: 380,
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_dadosController.ehCircular && !_dadosController.unicaDirecao)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed: _alternarSentido,
                child: const Text('Trocar sentido'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Linha ${widget.numero}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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

  Widget _buildMapArea() {
    if (_dadosController.carregando) return _loader();

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

  Widget _buildMap() {
    final percursosExibidos = _dadosController.percursosExibidos;

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

  Color _getColorForSentido(String sentido) {
    switch (sentido.toUpperCase()) {
      case 'VOLTA':
        return Colors.orange;
      case 'IDA':
        return Colors.blueAccent;
      case 'CIRCULAR':
      default:
        return Colors.redAccent;
    }
  }

  Widget _loader() => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
}

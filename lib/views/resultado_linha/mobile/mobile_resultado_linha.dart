import 'package:df_no_ponto_web_app/views/resultado_linha/mobile/widgets/centralizar_localizacao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../controller/resultado_linha/mapa_linha_controller.dart';
import '../../../controller/resultado_linha/resultado_linha_controller.dart';
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

  bool _mapaInicializado = false;

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
    _dadosController.alternarSentido();
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

    final layers = percursosExibidos.entries.expand((entry) {
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

    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        initialCenter: _fallbackCenter,
          initialZoom: _fallbackZoom,
          onMapReady: _onMapReady,
          maxZoom: 20,
          minZoom: 9.5),
      children: [
        TileLayer(
          tileProvider: CancellableNetworkTileProvider(),
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        ...layers,
        CentralizarLocalizacao(),
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
      ],
    );
  }

  // --------------------------- DRAGGABLE SHEET ---------------------------
  Widget _buildDraggableSheet() {
    final percursos = _dadosController.percursos ?? {};

    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.15,
      maxChildSize: 0.8,
      builder: (_, controller) => Container(
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
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Center(
              child: Text(
                'Linha: ${widget.numero}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (!_dadosController.ehCircular && !_dadosController.unicaDirecao)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: _alternarSentido,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    overlayColor: Colors.blueAccent.withValues(alpha: 0.1), // Cor ao pressionar
                  ),
                  child: const Text(
                    'Trocar sentido',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ...percursos.entries.expand((e) => [
                  ListTile(
                    leading: const Icon(Icons.alt_route),
                    title: Text('Sentido: ${e.key}'),
                    subtitle: Text('${e.value.length} trecho(s)'),
                    onTap: () {
                      if (e.value.isNotEmpty &&
                          e.value.first.coordenadas.isNotEmpty) {
                        _map.move(e.value.first.coordenadas.first, 14);
                      }
                    },
                  ),
                  const Divider(height: 1),
                ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

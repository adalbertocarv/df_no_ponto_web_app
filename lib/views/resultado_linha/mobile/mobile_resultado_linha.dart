import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../controller/resultado_linha/mapa_linha_controller.dart';
import '../../../controller/resultado_linha/resultado_linha_controller.dart';
import '../../../providers/favoritos.dart';

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
  late final Future<void> _future;

  static const _fallbackCenter = LatLng(-15.7942, -47.8822);
  static const _fallbackZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _dadosController = ResultadoLinhaController(widget.numero);
    _mapaController = ResultadoMapaController(widget.numero);
    _future = _dadosController.carregarDados();
  }

  @override
  void dispose() {
    _dadosController.dispose();
    _mapaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: _buildTitulo(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [_buildFavoriteButton()],
      ),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loader();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os dados.'));
          }

          final percursos = _dadosController.percursos ?? {};
          _mapaController.init(_map, percursos);

          return Stack(
            children: [
              _buildMap(percursos),
              _buildDraggableSheet(percursos),
            //  _buildBackButton(context),
            ],
          );
        },
      ),
    );
  }

  void _alternarSentido() {
    setState(() {
      _dadosController.alternarSentido();
    });
  }



  Widget _buildTitulo() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF4A6FA5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_bus_rounded, size: 20, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            widget.numero,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        final isFavorited = favoritesProvider.isFavorite(widget.numero);
        return IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.black,
          ),
          onPressed: () {
            final descricao = _dadosController.infoLinha?.firstOrNull?.descricao ?? 'Descrição não disponível';
            if (isFavorited) {
              favoritesProvider.removeFavorite(widget.numero);
            } else {
              favoritesProvider.addFavorite({
                'numero': widget.numero,
                'descricao': descricao,
              });
            }
          },
        );
      },
    );
  }

  Widget _loader() => const Center(child: CircularProgressIndicator(strokeWidth: 2));

  // --------------------------- MAPA ---------------------------
  Widget _buildMap(Map<String, List<dynamic>> percursos) {
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
      options: const MapOptions(
        initialCenter: _fallbackCenter,
        initialZoom: _fallbackZoom,
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

  // --------------------------- DRAGGABLE SHEET ---------------------------
  Widget _buildDraggableSheet(Map<String, List<dynamic>> percursos) {
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
                'Linha ${widget.numero}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_dadosController.ehCircular && !_dadosController.unicaDirecao)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: _alternarSentido,
                  child: const Text('Trocar sentido'),
                ),
              ),
            ...percursos.entries.expand((e) => [
              ListTile(
                leading: const Icon(Icons.alt_route),
                title: Text('Sentido: ${e.key}'),
                subtitle: Text('${e.value.length} trecho(s)'),
                onTap: () {
                  if (e.value.isNotEmpty && e.value.first.coordenadas.isNotEmpty) {
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

  // // --------------------------- BOTÃO VOLTAR ---------------------------
  // Widget _buildBackButton(BuildContext context) => SafeArea(
  //   child: Padding(
  //     padding: const EdgeInsets.all(12.0),
  //     child: CircleAvatar(
  //       backgroundColor: Colors.white,
  //       child: IconButton(
  //         icon: const Icon(Icons.arrow_back, color: Colors.black),
  //         onPressed: () => Navigator.pop(context),
  //       ),
  //     ),
  //   ),
  // );
}

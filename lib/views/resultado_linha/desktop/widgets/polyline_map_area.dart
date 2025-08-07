import 'package:df_no_ponto_web_app/views/resultado_linha/desktop/widgets/centralizar_localizacao.dart';
import 'package:df_no_ponto_web_app/views/resultado_linha/desktop/widgets/zoom_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../../controller/resultado_linha/resultado_linha_controller.dart';

class DesktopMapArea extends StatelessWidget {
  const DesktopMapArea({
    super.key,
    required this.dadosController,
    required this.mapController,
    required this.onMapReady,
  });

  final ResultadoLinhaController dadosController;
  final MapController mapController;
  final VoidCallback onMapReady;

  static const _fallbackCenter = LatLng(-15.7942, -47.8822);
  static const _fallbackZoom = 12.0;

  @override
  Widget build(BuildContext context) {
    if (dadosController.carregando) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final percursos = dadosController.percursos;
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
    final percursosExibidos = dadosController.percursosExibidos;
    final layers = _buildPolylineLayers(percursosExibidos);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
        initialCenter: _fallbackCenter,
        initialZoom: _fallbackZoom,
        onMapReady: onMapReady,
        maxZoom: 20,
        minZoom: 9.5,
      ),
      children: [
        TileLayer(
          tileProvider: CancellableNetworkTileProvider(),
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.df.no.ponto',
        ),
        ...layers,
        CentralizarLocalizacao(),
        ZoomControls(mapController: mapController),
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
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
}
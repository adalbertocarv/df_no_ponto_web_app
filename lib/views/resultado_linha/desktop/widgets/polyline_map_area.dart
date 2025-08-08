import 'package:df_no_ponto_web_app/views/resultado_linha/desktop/widgets/centralizar_localizacao.dart';
import 'package:df_no_ponto_web_app/views/resultado_linha/desktop/widgets/zoom_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../../controller/resultado_linha/resultado_linha_controller.dart';
import '../../../../models/linha/veiculos_tempo_real.dart';

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

    return _buildMap(context);

  }

   Widget _buildMap(BuildContext context) {
     final percursosExibidos = dadosController.percursosExibidos;
     final layers = _buildPolylineLayers(percursosExibidos);
     final veiculosExibidos = dadosController.veiculosExibidos;

     // Cria os markers dos veículos
     final vehicleMarkers = veiculosExibidos.map((veiculo) =>
         veiculo.toMarker(
           onTap: () => _showVehicleDetails(context, veiculo),
         )
     ).toList();

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
           userAgentPackageName: 'com.df.no.ponto.df_no_ponto_web_app',
         ),
         ...layers,
         // Markers dos veículos por cima
         if (vehicleMarkers.isNotEmpty)
           MarkerLayer(markers: vehicleMarkers),
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

  void _showVehicleDetails(BuildContext context, Feature veiculo) {
    final props = veiculo.properties;

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
            if (props.direcao != null)
              Text('Direção: ${props.direcao}'),
            if (props.datalocal != null)
              Text('Última atualização: ${props.datalocal}'),
            const SizedBox(height: 8),
            Text('Coordenadas: ${veiculo.geometry.coordinates[1].toStringAsFixed(6)}, ${veiculo.geometry.coordinates[0].toStringAsFixed(6)}'),
            if (props.sentido != null)
              Text('Sentido: ${props.sentido}'),
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
}
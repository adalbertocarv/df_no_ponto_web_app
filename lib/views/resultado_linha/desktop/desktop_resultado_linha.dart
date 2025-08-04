// lib/resultado_linha/desktop/desktop_resultado_linha.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

class DesktopResultadoLinha extends StatelessWidget {
  const DesktopResultadoLinha({super.key, required this.numero});
  final String numero;

  static const _initialCenter = LatLng(-15.7942, -47.8822);
  static const _initialZoom = 12.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Painel lateral
          Container(
            width: 380,
            color: Colors.grey[100],
            child: Center(
              child: Text(
                'Detalhes da linha $numero',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          ),
          // Mapa
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: _initialCenter,
                initialZoom: _initialZoom,
              ),
              children: [
                TileLayer(
                  tileProvider: CancellableNetworkTileProvider(),
                  urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

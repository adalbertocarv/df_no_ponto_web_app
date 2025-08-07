import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class ZoomControls extends StatelessWidget {
  final MapController mapController;

  const ZoomControls({super.key, required this.mapController});

  void _zoomIn() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            tooltip: 'Aumentar zoom',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            mini: true,
            onPressed: _zoomIn,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 6),
          FloatingActionButton(
            heroTag: 'zoomOut',
            tooltip: 'Diminuir zoom',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            mini: true,
            onPressed: _zoomOut,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

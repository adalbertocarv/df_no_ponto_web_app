import 'package:flutter/material.dart';

class CentralizarLocalizacao extends StatelessWidget {
  const CentralizarLocalizacao({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 100,
        right: 16,
        child: FloatingActionButton.small(
          heroTag: 'Centralizar localização',
          tooltip: 'Centralizar localização',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.white,
          onPressed: () => (),
          child: const Icon(Icons.my_location),
        ));
  }
}

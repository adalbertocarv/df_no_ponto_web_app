import 'package:flutter/material.dart';

class CentralizarLocalizacao extends StatelessWidget {
  const CentralizarLocalizacao({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 132,
        right: 24,
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

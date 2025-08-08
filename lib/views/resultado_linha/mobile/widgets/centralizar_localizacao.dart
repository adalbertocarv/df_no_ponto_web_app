import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/theme_provider.dart';

class CentralizarLocalizacao extends StatelessWidget {
  const CentralizarLocalizacao({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<ThemeProvider>();
    return Positioned(
        top: 100,
        right: 16,
        child: FloatingActionButton.small(
          heroTag: 'Centralizar localização',
          tooltip: 'Centralizar localização',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: tema.primary,
          onPressed: () => (),
          child: const Icon(Icons.my_location, color: Colors.white,),
        ));
  }
}

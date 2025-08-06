import 'package:flutter/material.dart';

class TituloWidget extends StatelessWidget {
  final String numero;

  const TituloWidget({super.key, required this.numero});

  @override
  Widget build(BuildContext context) {
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
            numero,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

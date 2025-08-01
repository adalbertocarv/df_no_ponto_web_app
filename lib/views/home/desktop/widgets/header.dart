import 'package:flutter/material.dart';

import 'nav_item.dart';

Widget buildDesktopHeader() {
  return Container(
    height: 70,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              const SizedBox(width: 12),
              Image.asset('/images/logo.png')
            ],
          ),

          const Spacer(),

          // Menu de navegação
          Row(
            children: [
              buildNavItem(Icons.directions_bus, 'Linhas'),
              buildNavItem(Icons.map, 'Mapa'),
              buildNavItem(Icons.language, 'GeoServer'),
              buildNavItem(Icons.forum, 'ParticipaDF'),
              const SizedBox(width: 20),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.asset('/images/gdf-logo.png'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

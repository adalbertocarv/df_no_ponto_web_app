import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../veiculos/mobile/mobile_veiculos.dart';
import 'nav_item.dart';

Widget buildDesktopHeader(BuildContext context) {
  return Container(
    height: 70,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
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
          Row(
            children: [
              const SizedBox(width: 12),
              Image.asset('assets/images/logo.png')
            ],
          ),
          const Spacer(),
          Row(
            children: [
              buildNavItem(Icons.map, 'Mapa', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
              }),
              buildNavItem(Icons.language, 'GeoServer', onTap: () async {
                final uri = Uri.parse('https://geoserver.semob.df.gov.br/');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, webOnlyWindowName: '_blank');
                }
              }),
              buildNavItem(Icons.forum, 'ParticipaDF', onTap: () async {
                final uri = Uri.parse('https://www.participa.df.gov.br/pages/registro-manifestacao/relato');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, webOnlyWindowName: '_blank');
                }
              }),

              const SizedBox(width: 20),
              InkWell(
                onTap: () => '',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.asset('assets/images/gdf-logo.png'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

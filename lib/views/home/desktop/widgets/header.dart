import 'package:df_no_ponto_web_app/views/veiculos/desktop/desktop_veiculos.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../veiculos/veiculos.dart';
import 'nav_item.dart';

Widget buildDesktopHeader(BuildContext context) {
  Future<void> _abrirLink(String url) async {
    final uri = Uri.parse(url);

    // Para web, abrir em nova guia (_blank)
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    )) {
      throw 'Não foi possível abrir $url';
    }
  }

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
              buildNavItem(Icons.map, 'Veículos', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DesktopVeiculos()),
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
                onTap: () => _abrirLink('https://www.df.gov.br/'),
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

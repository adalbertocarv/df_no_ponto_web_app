import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[100],
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Botão Fechar
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF4A6FA5),
                ),
              ),
            ),
          ),
          // Recarregar cartão
          ListTile(
            leading: Icon(
              Icons.credit_card,
              color: Color(0xFF4A6FA5),
            ),
            title: const Text('Recarregue seu cartão'),
            onTap: () async {
              const url =
                  'https://play.google.com/store/apps/details?id=br.com.brb.mobilidade&hl=pt_BR';
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),

          const Spacer(), // <- empurra o bloco abaixo para o fim

          // OUVIDORIA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 5,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF4A6FA5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ExpansionTile(

                    shape: const Border(),
                    title: const Text(
                      'OUVIDORIA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Registre sua manifestação',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          const url =
                              'https://www.participa.df.gov.br/pages/registro-manifestacao/relato';
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        child: Image.asset(
                          'assets/images/ouvidoria.webp',
                          semanticLabel: 'Participa DF',
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

/// Tela mobile que exibe:
/// • Mapa ocupando toda a tela
/// • DraggableScrollableSheet com detalhes da linha
class MobileResultadoLinha extends StatelessWidget {
  const MobileResultadoLinha({super.key, required this.numero});
  final String numero;

  // ajuste o ponto inicial da câmera, se desejar
  static const _initialCenter = LatLng(-15.7942, -47.8822);
  static const _initialZoom = 12.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('$numero'),),
      body: Stack(
        children: [
          // ---------- MAPA (base) ----------
          FlutterMap(
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
              // Adicione aqui Polylines ou Markers da linha, se necessário
            ],
          ),

          // ---------- DRAGGABLE SHEET ----------
          DraggableScrollableSheet(
            initialChildSize: 0.25,   // 25 % da altura da tela ao abrir
            minChildSize: 0.15,       // pode “fechar” até 15 %
            maxChildSize: 0.80,       // e expandir até 80 %
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // ------ Puxador + título ------
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            width: 50,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Linha $numero',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // ------ Conteúdo rolável ------
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          _infoTile(
                            title: 'Descrição',
                            value: 'Texto descritivo da linha $numero',
                          ),
                          _infoTile(
                            title: 'Sentido',
                            value: 'Ida / Volta',
                          ),
                          _infoTile(
                            title: 'Tarifa',
                            value: 'R\$ 5,50',
                          ),
                          _infoTile(
                            title: 'Operadora',
                            value: 'Consórcio X',
                          ),
                          const Divider(),
                          // exemplo de paradas
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              'Paradas da linha',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          for (int i = 1; i <= 20; i++)
                            ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: Text('Parada $i'),
                              subtitle: i.isEven
                                  ? const Text('Linha escolar')
                                  : null,
                              onTap: () {
                                // eventualmente mover o mapa para a parada
                              },
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ---------- BOTÃO VOLTAR ----------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para listar informações simples
  Widget _infoTile({required String title, required String value}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      dense: true,
    );
  }
}

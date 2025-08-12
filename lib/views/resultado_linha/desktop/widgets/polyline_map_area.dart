import 'package:df_no_ponto_web_app/views/resultado_linha/desktop/widgets/centralizar_localizacao.dart';
import 'package:df_no_ponto_web_app/views/widgets/zoom_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../../controller/resultado_linha/resultado_linha_controller.dart';
import '../../../../models/linha/veiculos_tempo_real.dart';
import '../../../../services/dados_espaciais/localizacao/localizacao_usuario.dart';

class DesktopMapArea extends StatefulWidget {
    DesktopMapArea({
    super.key,
    required this.dadosController,
    required this.mapController,
    required this.onMapReady,
  });

  final ResultadoLinhaController dadosController;
  final MapController mapController;
  final VoidCallback onMapReady;
  static const _fallbackCenter = LatLng(-15.7942, -47.8822);
  static const _fallbackZoom = 12.0;

  @override
  State<DesktopMapArea> createState() => _DesktopMapAreaState();
}

class _DesktopMapAreaState extends State<DesktopMapArea> {
   LatLng? _userLocation;

    Future<void> _obterLocalizacaoInicial() async {
      final resultado = await LocalizacaoUsuarioService().obterLocalizacaoUsuario();

      if (resultado.status == LocalizacaoStatus.sucesso && resultado.localizacao != null) {
        setState(() {
          _userLocation = resultado.localizacao;
        });
      }
    }

    @override
    void initState(){
      super.initState();
      _obterLocalizacaoInicial();
    }

  @override
  Widget build(BuildContext context) {
    if (widget.dadosController.carregando) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final percursos = widget.dadosController.percursos;
    if (percursos == null || percursos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum percurso encontrado',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return _buildMap(context);

  }

   Widget _buildMap(BuildContext context) {
     final percursosExibidos = widget.dadosController.percursosExibidos;
     final layers = _buildPolylineLayers(percursosExibidos);
     final veiculosExibidos = widget.dadosController.veiculosExibidos;

     // Cria os markers dos veículos
     final vehicleMarkers = veiculosExibidos.map((veiculo) =>
         veiculo.toMarker(
           onTap: () => _showVehicleDetails(context, veiculo),
         )
     ).toList();

     return FlutterMap(
       mapController: widget.mapController,
       options: MapOptions(
         interactionOptions: InteractionOptions(
           flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
           cursorKeyboardRotationOptions: CursorKeyboardRotationOptions.disabled(),
         ),
         initialCenter: DesktopMapArea._fallbackCenter,
         initialZoom: DesktopMapArea._fallbackZoom,
         onMapReady: widget.onMapReady,
         maxZoom: 20,
         minZoom: 9.5,
       ),
       children: [
         TileLayer(
           tileProvider: CancellableNetworkTileProvider(),
           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
           userAgentPackageName: 'com.df.no.ponto.df_no_ponto_web_app',
         ),
         ...layers,
         // Markers dos veículos por cima
         if (vehicleMarkers.isNotEmpty)
           MarkerLayer(markers: vehicleMarkers),
         MarkerLayer(
           markers: [
             if (_userLocation != null)
               Marker(
                 point: _userLocation!,
                 width: 50,
                 height: 50,
                 child: Transform.translate(
                   offset: const Offset(0, -22),
                   child: Image.asset(
                     'assets/images/user.png',
                     width: 40,
                     height: 40,
                     fit: BoxFit.contain,
                   ),
                 ),
               ),
           ],
         ),
         CentralizarLocalizacao(mapController: widget.mapController, bottom: 136, right: 24,),
         ZoomControls(mapController: widget.mapController),
         const SimpleAttributionWidget(
           source: Text('OpenStreetMap contributors'),
         ),
       ],
     );
   }

   List _buildPolylineLayers(Map percursos) {
    return percursos.entries.expand((entry) {
      final color = _getColorForSentido(entry.key);
      return entry.value.map(
            (p) => PolylineLayer(
          polylines: [
            Polyline(
              points: p.coordenadas,
              strokeWidth: 4,
              color: color,
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getColorForSentido(String sentido) {
    switch (sentido.toUpperCase()) {
      case 'VOLTA':
        return Colors.orange;
      case 'IDA':
        return Colors.blueAccent;
      case 'CIRCULAR':
      default:
        return Colors.redAccent;
    }
  }

   void _showVehicleDetails(BuildContext context, Feature veiculo) {
     final props = veiculo.properties;
     final datalocal = props.datalocal ?? 'N/A';
     final dataFormatada = formatarDataHora(datalocal);

     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         backgroundColor: Colors.white,
         title: Text('Veículo ${props.prefixo ?? 'N/A'}'),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             if (props.nm_operadora != null)
               Text('Operadora: ${props.nm_operadora}'),
             if (props.cdLinha != null)
               Text('Código da Linha: ${props.cdLinha}'),
             if (props.velocidade != null)
               Text('Velocidade: ${props.velocidade} km/h'),
             // if (props.direcao != null)
             //   Text('Direção: ${props.direcao}'),
             if (props.datalocal != null)
               Text('Última atualização: ${dataFormatada}'),
             const SizedBox(height: 8),
             Text('Coordenadas: ${veiculo.geometry.coordinates[1].toStringAsFixed(6)}, ${veiculo.geometry.coordinates[0].toStringAsFixed(6)}'),
           ],
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(),
             child: const Text('Fechar', style: TextStyle(color: Colors.blueAccent),),
           ),
           TextButton(
             onPressed: () {
               Navigator.of(context).pop();
               final coords = veiculo.geometry.coordinates;
               if (coords.length >= 2) {
                 widget.mapController.move(LatLng(coords[1], coords[0]), 18);
               }
             },
             child: const Text('Ver no Mapa', style: TextStyle(color: Colors.blueAccent),),
           ),
         ],
       ),
     );
   }

   /// Formata a data e hora para exibição amigável
   String formatarDataHora(String datalocal) {
     try {
       final dateTime = DateTime.parse(datalocal);
       return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} às '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
     } catch (e) {
       return 'Data inválida';
     }
   }
}
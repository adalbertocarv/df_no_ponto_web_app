import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../services/dados_espaciais/operadoras/bsbus.dart';
import '../../../services/dados_espaciais/operadoras/marechal.dart';
import '../../../services/dados_espaciais/operadoras/pioneira.dart';
import '../../../services/dados_espaciais/operadoras/piracicabana.dart';
import '../../../services/dados_espaciais/operadoras/urbi.dart';
import '../../resultado_linha/mobile/widgets/centralizar_localizacao.dart';
import '../../theme/theme_provider.dart';
import '../widget/popup_veiculo.dart';

class MobileVeiculos extends StatefulWidget {
  const MobileVeiculos({super.key});

  @override
  State<MobileVeiculos> createState() => _MobileVeiculosState();
}

class _MobileVeiculosState extends State<MobileVeiculos> {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  List<Marker> _markers = [];
  bool _isLoading = true;
  Timer? _timer;

  // Configurações do cluster
  static const double _clusterRadius = 120;
  static const Size _clusterSize = Size(40, 40);
  static const EdgeInsets _clusterPadding = EdgeInsets.all(50);
  static const LatLng brasiliaCenter = LatLng(-15.793823, -47.882688);

  @override
  void initState() {
    super.initState();
    _carregarVeiculos();

    // Atualiza automaticamente a cada 30 segundos
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _carregarVeiculos();
    });
  }

  @override
  void dispose() {
    // Cancela o timer para evitar execução depois que a tela for destruída
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregarVeiculos() async {
    setState(() => _isLoading = true);

    try {
      // Carrega dados de todas as operadoras
      final futures = [
        UrbiVeiculosService().buscarPosicaoUrbi(),
        PiracicabanaVeiculosService().buscarPosicaoPiracicabana(),
        PioneiraVeiculosService().buscarPosicaoPioneira(),
        MarechalVeiculosService().buscarPosicaoMarechal(),
        BsbusVeiculosService().buscarPosicaoBsbus(),
      ];

      final results = await Future.wait(futures);

      // Combina todos os veículos
      final allMarkers = <Marker>[];

      for (var veiculosOperadora in results) {
        for (var feature in veiculosOperadora.features) {
          final coords = feature.geometry.coordinates;

          // Validação de coordenadas
          if (coords.length >= 2) {
            final lat = coords[1];
            final lng = coords[0];

            // Coordenadas válidas para o Brasil
            if (lat != 0.0 &&
                lng != 0.0 &&
                lat >= -35.0 &&
                lat <= 6.0 &&
                lng >= -75.0 &&
                lng <= -30.0) {
              allMarkers.add(
                Marker(
                  point: LatLng(lat, lng),
                  width: 40,
                  height: 40,
                  key: ValueKey(feature),
                  child: Image.asset(
                    feature.properties.busImage,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return                   const Image(
                        image: AssetImage('assets/images/icon_bus.png'),
                        width: 20,
                        height: 20,
                      );
                    },
                  ),
                ),
              );
            }
          }
        }
            }

      setState(() {
        _markers = allMarkers;
      });
    } catch (e) {
      debugPrint("Erro ao carregar veículos: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PopupScope(
            popupController: _popupController,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  cursorKeyboardRotationOptions: CursorKeyboardRotationOptions.disabled(),
                ),
                initialCenter: brasiliaCenter,
                initialZoom: 13.0,
                onTap: (_, __) {
                  _popupController.hideAllPopups();
                },
                maxZoom: 20,
                minZoom: 9.5,
              ),
              children: [
                TileLayer(
                  tileProvider: CancellableNetworkTileProvider(),
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.df.no.ponto.df_no_ponto_web_app',
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: _clusterRadius.toInt(),
                    size: _clusterSize,
                    padding: _clusterPadding,
                    markers: _markers,
                    builder: (context, markers) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                    popupOptions: PopupOptions(
                      popupController: _popupController,
                      popupBuilder: (_, marker) {
                        final feature = (marker.key as ValueKey).value;

                        return CustomPopup(
                          dadosVeiculo: {
                            'nm_operadora': feature.properties.nomeOperadora,
                            'prefixo': feature.properties.veiculo.prefixo,
                            'sentido': feature.properties.veiculo.sentido,
                            'datalocal': feature.properties.datalocal,
                          },
                          popupController: _popupController,
                          linha: feature.properties.veiculo.numero,
                          onClose: () {
                            _popupController.hideAllPopups(); // Fecha o popup
                          },
                        );
                      },
                    ),
                    showPolygon: true, // Exibe o polígono de agrupamento
                    polygonOptions: PolygonOptions(
                      borderColor: Colors.blue, // Cor da borda do polígono
                      borderStrokeWidth: 3, // Largura da borda
                      color: Colors.blue.withValues(
                          alpha: 0.2), // Cor de preenchimento com opacidade
                    ),
                  ),
                ),
                const SimpleAttributionWidget(
                  source: Text('OpenStreetMap contributors'),
                ),
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          CentralizarLocalizacao(
            mapController: _mapController,
          ),

          // Debug info
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Veículos: ${_markers.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'Recarregar_veículos',
              tooltip: 'Recarregar veículos',
              backgroundColor: tema.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              onPressed: _carregarVeiculos,
              child: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

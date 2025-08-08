import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoading = false;
  bool _locationPermissionGranted = false;

  // Localização padrão (Brasília - DF)
  final LatLng _defaultLocation = const LatLng(-15.7942, -47.8822);

  // Lista de marcadores de exemplo (pontos de ônibus)
  List<Marker> _busStopMarkers = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _checkLocationPermission();
    _createBusStopMarkers();
    if (_locationPermissionGranted) {
      await _getCurrentLocation();
    }
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;

    if (status.isDenied) {
      final result = await Permission.location.request();
      _locationPermissionGranted = result.isGranted;
    } else {
      _locationPermissionGranted = status.isGranted;
    }

    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    if (!_locationPermissionGranted) {
      _showLocationPermissionDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentLocation = LatLng(position.latitude, position.longitude);

      // Anima o mapa para a localização atual
      _mapController.move(_currentLocation!, 15.0);

      setState(() {
        _isLoading = false;
      });

      _showLocationFoundSnackBar();

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showLocationErrorDialog();
    }
  }

  void _createBusStopMarkers() {
    // Pontos de ônibus fictícios em Brasília
    final busStops = [
      {'name': 'Rodoviária do Plano Piloto', 'lat': -15.7942, 'lng': -47.8822},
      {'name': 'Estação Central', 'lat': -15.7801, 'lng': -47.9292},
      {'name': 'Ceilândia Centro', 'lat': -15.8198, 'lng': -48.1067},
      {'name': 'Taguatinga Centro', 'lat': -15.8270, 'lng': -48.0441},
      {'name': 'Samambaia Norte', 'lat': -15.8759, 'lng': -48.0935},
    ];

  }

  void _showBusStopInfo(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.directions_bus, color: const Color(0xFF4A6FA5)),
            const SizedBox(width: 8),
            const Text('Ponto de Ônibus'),
          ],
        ),
        content: Text(name),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Aqui você pode adicionar lógica para mostrar rotas, horários, etc.
              _showRouteOptions(name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A6FA5),
            ),
            child: const Text('Ver Rotas', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRouteOptions(String stopName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Consultando rotas para $stopName...'),
        backgroundColor: const Color(0xFF4A6FA5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permissão Necessária'),
          ],
        ),
        content: const Text(
          'Para centralizar no seu local, precisamos acessar sua localização. '
              'Vá nas configurações e permita o acesso à localização.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A6FA5),
            ),
            child: const Text('Configurações', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLocationErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Erro de Localização'),
          ],
        ),
        content: const Text(
          'Não foi possível obter sua localização. '
              'Verifique se o GPS está ativado e tente novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationFoundSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Localização encontrada!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? _defaultLocation,
              initialZoom: _currentLocation != null ? 15.0 : 11.0,
              minZoom: 8.0,
              maxZoom: 18.0,

              interactionOptions: const InteractionOptions(
                enableMultiFingerGestureRace: true,
                flags:
                InteractiveFlag.doubleTapDragZoom |
                InteractiveFlag.doubleTapZoom |
                InteractiveFlag.drag |
                InteractiveFlag.flingAnimation |
                InteractiveFlag.pinchZoom |
                InteractiveFlag.scrollWheelZoom,
              ),
            ),
            children: [
              // Camada do mapa base
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.df.no.ponto.df_no_ponto_web_app',
                maxZoom: 18,
              ),

            ],
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color:  const Color(0xFF4A6FA5),
              ),
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                backgroundColor:const Color(0xFF4A6FA5),
                child: const Icon(Icons.arrow_back, color: Colors.white,),
                onPressed: () {Navigator.pop(context);},
              ),
            )
          ),
          // Botões flutuantes
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                // Botão para centralizar na localização do usuário
                FloatingActionButton(
                  heroTag: "location",
                  onPressed: _isLoading ? null : _getCurrentLocation,
                  backgroundColor: _locationPermissionGranted
                      ? const Color(0xFF4A6FA5)
                      : Colors.grey,
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.my_location, color: Colors.white),
                ),

                const SizedBox(height: 12),

                // Botão para mostrar todos os pontos
                FloatingActionButton(
                  heroTag: "show_all",
                  onPressed: () {
                    if (_busStopMarkers.isNotEmpty) {
                      // Calcula bounds para mostrar todos os marcadores
                      double minLat = _busStopMarkers.first.point.latitude;
                      double maxLat = _busStopMarkers.first.point.latitude;
                      double minLng = _busStopMarkers.first.point.longitude;
                      double maxLng = _busStopMarkers.first.point.longitude;

                      for (var marker in _busStopMarkers) {
                        if (marker.point.latitude < minLat) minLat = marker.point.latitude;
                        if (marker.point.latitude > maxLat) maxLat = marker.point.latitude;
                        if (marker.point.longitude < minLng) minLng = marker.point.longitude;
                        if (marker.point.longitude > maxLng) maxLng = marker.point.longitude;
                      }

                      final bounds = LatLngBounds(
                        LatLng(minLat, minLng),
                        LatLng(maxLat, maxLng),
                      );

                      // _mapController.fitBounds(
                      //   bounds,
                      //   options: const FitBoundsOptions(
                      //     padding: EdgeInsets.all(50),
                      //   ),
                      // );
                    }
                  },
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.center_focus_strong, color: Colors.white),
                ),
              ],
            ),
          ),

          // Indicador de carregamento quando necessário
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Obtendo localização...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      // Drawer com informações adicionais
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF4A6FA5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.map, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Mapa Interativo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Transporte Público DF',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text('Pontos de Ônibus'),
              subtitle: Text('${_busStopMarkers.length} pontos encontrados'),
              onTap: () {
                Navigator.pop(context);
                // Lógica para filtrar apenas pontos de ônibus
              },
            ),
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('Rotas'),
              subtitle: const Text('Ver todas as rotas disponíveis'),
              onTap: () {
                Navigator.pop(context);
                // Lógica para mostrar rotas
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              subtitle: const Text('Seus locais favoritos'),
              onTap: () {
                Navigator.pop(context);
                // Lógica para mostrar favoritos
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                _showSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMapLayerOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opções do Mapa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Mapa Padrão'),
              onTap: () {
                Navigator.pop(context);
                // Trocar para mapa padrão
              },
            ),
            ListTile(
              leading: const Icon(Icons.satellite),
              title: const Text('Visão Satélite'),
              onTap: () {
                Navigator.pop(context);
                // Trocar para visão satélite
              },
            ),
            ListTile(
              leading: const Icon(Icons.terrain),
              title: const Text('Relevo'),
              onTap: () {
                Navigator.pop(context);
                // Trocar para mapa de relevo
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações do Mapa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permissão de localização: ${_locationPermissionGranted ? "Concedida" : "Negada"}'),
            const SizedBox(height: 8),
            Text('Localização atual: ${_currentLocation != null ? "Disponível" : "Indisponível"}'),
            const SizedBox(height: 8),
            Text('Pontos de ônibus: ${_busStopMarkers.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}


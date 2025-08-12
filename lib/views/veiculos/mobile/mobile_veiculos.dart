import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../../services/dados_espaciais/linha/itinerario_espacial_completo.dart';
import '../../../services/dados_espaciais/operadoras/bsbus.dart';
import '../../../services/dados_espaciais/operadoras/marechal.dart';
import '../../../services/dados_espaciais/operadoras/pioneira.dart';
import '../../../services/dados_espaciais/operadoras/piracicabana.dart';
import '../../../services/dados_espaciais/operadoras/urbi.dart';
import '../../resultado_linha/mobile/widgets/centralizar_localizacao.dart';
import '../widget/popup_veiculo.dart';

class MobileVeiculos extends StatefulWidget {
  const MobileVeiculos({super.key});

  @override
  State<MobileVeiculos> createState() => _MobileVeiculosState();
}

class _MobileVeiculosState extends State<MobileVeiculos> {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Marker> _markers = [];
  bool _isLoading = true;

  // Variáveis para controle de linhas e percursos
  Map<String, List<LatLng>> _percursosCarregados = {};
  Set<String> _linhasSelecionadas = {};
  bool _carregandoPercurso = false;
  String? _linhaAtual;
  Timer? _timer;

  // Variáveis para filtro
  String _searchText = '';
  bool _showFilteredLines = false;
  Set<String> _linhasFiltradas = {};

  // Variáveis para paginação
  int _paginaAtual = 0;
  static const int _itensPorPagina = 5;

  // Configurações do cluster
  static const double _clusterRadius = 120;
  static const Size _clusterSize = Size(40, 40);
  static const EdgeInsets _clusterPadding = EdgeInsets.all(50);
  static const LatLng BRASILIA_CENTER = LatLng(-15.793823, -47.882688);

  // Getter para markers filtrados
  List<Marker> get _filteredMarkers {
    if (_searchText.isEmpty) {
      return _markers;
    }

    return _markers.where((marker) {
      final feature = (marker.key as ValueKey).value;
      final numeroLinha = feature.properties.veiculo.numero.toString().toLowerCase();
      return numeroLinha.contains(_searchText.toLowerCase());
    }).toList();
  }

  // Instância do service de percurso
  final PercursoCompletoService _percursoService = PercursoCompletoService();

  @override
  void initState() {
    super.initState();
    _loadVeiculos();

    // Atualiza automaticamente a cada 30 segundos
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadVeiculos();
    });

    // Listener para o campo de busca
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        _updateLinhasFiltradas();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _updateLinhasFiltradas() {
    if (_searchText.isEmpty) {
      _linhasFiltradas.clear();
      _paginaAtual = 0;
      return;
    }

    final linhasEncontradas = <String>{};
    for (var marker in _markers) {
      final feature = (marker.key as ValueKey).value;
      final numeroLinha = feature.properties.veiculo.numero.toString();
      if (numeroLinha.toLowerCase().contains(_searchText.toLowerCase())) {
        linhasEncontradas.add(numeroLinha);
      }
    }
    _linhasFiltradas = linhasEncontradas;
    _paginaAtual = 0; // Resetar para primeira página
  }

  Future<void> _loadVeiculos() async {
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
        if (veiculosOperadora?.features != null) {
          for (var feature in veiculosOperadora!.features) {
            final coords = feature.geometry.coordinates;

            // Validação de coordenadas
            if (coords.length >= 2) {
              final lat = coords[1];
              final lng = coords[0];

              // Coordenadas válidas para o Brasil
              if (lat != 0.0 && lng != 0.0 &&
                  lat >= -35.0 && lat <= 6.0 &&
                  lng >= -75.0 && lng <= -30.0) {

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
                        return const Image(
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
      }

      setState(() {
        _markers = allMarkers;
        _updateLinhasFiltradas();
      });

    } catch (e) {
      debugPrint("Erro ao carregar veículos: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Método para carregar percursos de uma linha específica
  Future<void> _carregarPercurso(String linha) async {
    // Ignora se linha for inválida
    if (linha == 'N/A' || linha.isEmpty) {
      return;
    }

    // Verifica se já temos o percurso em cache
    if (_percursosCarregados.containsKey(linha)) {
      setState(() {
        _linhaAtual = linha;
        _linhasSelecionadas.add(linha);
      });
      return;
    }

    // Verifica se já está carregando
    if (_carregandoPercurso) {
      return;
    }

    setState(() {
      _carregandoPercurso = true;
    });

    try {
      final service = PercursoCompletoService();
      final percursoCompleto = await service.buscarPercursoCompleto(linha);

      if (mounted) {
        final pontos = percursoCompleto.coordinates
            .map((coord) => LatLng(coord.latitude, coord.longitude))
            .toList();

        setState(() {
          _percursosCarregados[linha] = pontos; // Salva no cache
          _linhasSelecionadas.add(linha);
          _linhaAtual = linha;
        });
      }

    } catch (e) {
      debugPrint("Erro ao carregar percurso da linha $linha: $e");

      if (mounted) {
        // Mostrar erro ao usuário (opcional)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar rota da linha $linha'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregandoPercurso = false;
        });
      }
    }
  }

  // Método para carregar todas as rotas das linhas filtradas da página atual
  Future<void> _carregarTodasRotasFiltradas() async {
    for (String linha in _linhasPaginadas) {
      if (!_percursosCarregados.containsKey(linha)) {
        await _carregarPercurso(linha);
      }
    }
  }

  // Método para limpar percursos
  void _limparPercursos() {
    setState(() {
      _percursosCarregados.clear();
      _linhasSelecionadas.clear();
      _linhaAtual = null;
    });
  }

  // Método para limpar apenas uma linha específica
  void _limparPercursoLinha(String linha) {
    setState(() {
      _percursosCarregados.remove(linha);
      _linhasSelecionadas.remove(linha);
      if (_linhaAtual == linha) {
        _linhaAtual = null;
      }
    });
  }

  // Método para limpar filtro
  void _limparFiltro() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchText = '';
      _linhasFiltradas.clear();
      _showFilteredLines = false;
      _paginaAtual = 0;
    });
  }

  // Getters para paginação
  List<String> get _linhasPaginadas {
    final linhasList = _linhasFiltradas.toList();
    final startIndex = _paginaAtual * _itensPorPagina;
    final endIndex = (startIndex + _itensPorPagina).clamp(0, linhasList.length);
    return linhasList.sublist(startIndex, endIndex);
  }

  int get _totalPaginas => (_linhasFiltradas.length / _itensPorPagina).ceil();

  bool get _temPaginaAnterior => _paginaAtual > 0;
  bool get _temProximaPagina => _paginaAtual < _totalPaginas - 1;

  @override
  Widget build(BuildContext context) {
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
                initialCenter: BRASILIA_CENTER,
                initialZoom: 13.0,
                onTap: (_, __) {
                  _popupController.hideAllPopups();
                  _searchFocusNode.unfocus();
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

                // Polylines das linhas selecionadas
                if (_percursosCarregados.isNotEmpty)
                  PolylineLayer(
                    polylines: _percursosCarregados.entries.map((entry) {
                      final cores = [
                        Colors.lightBlueAccent,
                        Colors.blue,
                        Colors.blueAccent,
                        Colors.blueGrey,
                        Colors.lightBlue
                      ];
                      final index = _linhasSelecionadas.toList().indexOf(entry.key);
                      return Polyline(
                        points: entry.value, // Agora é List<LatLng> diretamente
                        strokeWidth: 4.0,
                        color: cores[index % cores.length],
                      );
                    }).toList(),
                  ),

                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: _clusterRadius.toInt(),
                    size: _clusterSize,
                    padding: _clusterPadding,
                    markers: _filteredMarkers,
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
                          carregandoPercurso: _carregandoPercurso,
                          temRota: _percursosCarregados.containsKey(feature.properties.veiculo.numero),
                          isLinhaAtual: _linhaAtual == feature.properties.veiculo.numero,
                          onVerRota: () {
                            final numeroLinha = feature.properties.veiculo.numero;

                            // Se já tem o percurso, remove. Senão, carrega.
                            if (_percursosCarregados.containsKey(numeroLinha)) {
                              _limparPercursoLinha(numeroLinha);
                            } else {
                              _carregarPercurso(numeroLinha);
                            }

                            _popupController.hideAllPopups();
                          },
                          onClose: () {
                            _popupController.hideAllPopups();
                          },
                        );                      },
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
              ],
            ),
          ),

          // Campo de busca
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Buscar linha...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty && _linhasFiltradas.isNotEmpty) {
                          _carregarTodasRotasFiltradas();
                        }
                      },
                    ),
                  ),
                  if (_searchText.isNotEmpty) ...[
                    IconButton(
                      icon: const Icon(Icons.route),
                      tooltip: 'Carregar todas as rotas',
                      onPressed: _linhasPaginadas.isEmpty ? null : _carregarTodasRotasFiltradas,
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                    onPressed: (){
                        _limparFiltro();
                        _limparPercursos();
                    },),
                  ],
                ],
              ),
            ),
          ),

          // Lista de linhas filtradas
          if (_searchText.isNotEmpty && _linhasFiltradas.isNotEmpty)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Linhas encontradas (${_linhasFiltradas.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_percursosCarregados.isNotEmpty)
                            TextButton(
                              onPressed: _limparPercursos,
                              child: const Text(
                                'Limpar Todas',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _linhasFiltradas.length,
                        itemBuilder: (context, index) {
                          final linha = _linhasFiltradas.elementAt(index);
                          final temRota = _percursosCarregados.containsKey(linha);

                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: temRota ? Colors.blue : Colors.grey.shade300,
                              child: Text(
                                linha,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: temRota ? Colors.white : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            title: TextButton(
                              onPressed: () {
                                if (temRota) {
                                  _limparPercursoLinha(linha);
                                } else {
                                  _carregarPercurso(linha);
                                }
                              },
                              child: Text('Linha $linha',style: TextStyle(color: Colors.blueAccent),),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    temRota ? Icons.visibility_off : Icons.visibility,
                                    size: 20,
                                    color: temRota ? Colors.red : Colors.blue,
                                  ),
                                  tooltip: temRota ? 'Ocultar rota' : 'Ver rota',
                                  onPressed: () {
                                    if (temRota) {
                                      _limparPercursoLinha(linha);
                                    } else {
                                      _carregarPercurso(linha);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
            mapController: _mapController, top: 300,right: 16,
          ),

          // Debug info
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Veículos: ${_filteredMarkers.length}/${_markers.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  if (_searchText.isNotEmpty)
                    Text(
                      'Linhas encontradas: ${_linhasFiltradas.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  if (_percursosCarregados.isNotEmpty)
                    Text(
                      'Rotas filtradas: ${_percursosCarregados.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  if (_carregandoPercurso)
                    const Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Carregando rota...',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Botão para limpar todas as rotas (quando não há busca ativa)
          if (_percursosCarregados.isNotEmpty && _searchText.isEmpty)
            Positioned(
              top: 80,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _limparPercursos,
                tooltip: 'Limpar Todas as Rotas',
                backgroundColor: Colors.red,
                child: const Icon(Icons.clear_all, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
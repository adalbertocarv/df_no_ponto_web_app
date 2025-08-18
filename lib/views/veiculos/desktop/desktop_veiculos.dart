import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../../services/dados_espaciais/linha/itinerario_espacial_completo.dart';
import '../../../services/dados_espaciais/localizacao/localizacao_usuario.dart';
import '../../../services/dados_espaciais/operadoras/bsbus.dart';
import '../../../services/dados_espaciais/operadoras/marechal.dart';
import '../../../services/dados_espaciais/operadoras/pioneira.dart';
import '../../../services/dados_espaciais/operadoras/piracicabana.dart';
import '../../../services/dados_espaciais/operadoras/urbi.dart';
import '../../resultado_linha/desktop/widgets/centralizar_localizacao.dart';
import '../../widgets/zoom_map.dart';
import '../widget/popup_veiculo.dart';

class DesktopVeiculos extends StatefulWidget {
  const DesktopVeiculos({super.key});

  @override
  State<DesktopVeiculos> createState() => _DesktopVeiculosState();
}

class _DesktopVeiculosState extends State<DesktopVeiculos> {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  //Botões visibilidade operadoras
  final Map<String, bool> _visibilidadeServicos = {
    'urbi': true,
    'piracicabana': true,
    'pioneira': true,
    'marechal': true,
    'bsbus': true,
  };

  // Controle da gaveta de operadoras
  bool _mostrarGavetaOperadoras = false;

  List<Marker> _markers = [];
  final Map<String, List<Marker>> _markersOperadoras = {
    'urbi': [],
    'piracicabana': [],
    'pioneira': [],
    'marechal': [],
    'bsbus': [],
  };
  bool _isLoading = true;

  // Variáveis para controle de linhas e percursos
  final Map<String, List<LatLng>> _percursosCarregados = {};
  final Set<String> _linhasSelecionadas = {};
  bool _carregandoPercurso = false;
  String? _linhaAtual;
  Timer? _timer;

  // Variáveis para filtro múltiplo
  String _searchText = '';
  bool _showFilteredLines = false;
  Set<String> _linhasFiltradas = {};
  List<String> _numerosFiltrados = []; // Lista de números para filtrar
  static const int _maxFiltros = 5; // Máximo de 5 números

  // Variáveis para paginação
  int _paginaAtual = 0;
  static const int _itensPorPagina = 5;

  // Configurações do cluster
  static const double _clusterRadius = 120;
  static const Size _clusterSize = Size(40, 40);
  static const EdgeInsets _clusterPadding = EdgeInsets.all(50);
  static const LatLng brasiliaCenter = LatLng(-15.793823, -47.882688);
  LatLng? _userLocation;

  // Getter para markers filtrados considerando visibilidade das operadoras
  List<Marker> get _filteredMarkers {
    List<Marker> visibleMarkers = [];

    // Adiciona markers das operadoras visíveis
    _markersOperadoras.forEach((operadora, markers) {
      if (_visibilidadeServicos[operadora] ?? true) {
        visibleMarkers.addAll(markers);
      }
    });

    // Aplica filtro de números se existir
    if (_numerosFiltrados.isEmpty) {
      return visibleMarkers;
    }

    return visibleMarkers.where((marker) {
      final feature = (marker.key as ValueKey).value;
      final numeroLinha = feature.properties.veiculo.numero.toString();

      // Verifica se o número da linha está na lista de filtros
      return _numerosFiltrados.any((filtro) =>
          numeroLinha.toLowerCase().contains(filtro.toLowerCase()));
    }).toList();
  }

  // Instância do service de percurso
  final PercursoCompletoService _percursoService = PercursoCompletoService();

  Future<void> _obterLocalizacaoInicial() async {
    final resultado = await LocalizacaoUsuarioService().obterLocalizacaoUsuario();

    if (resultado.status == LocalizacaoStatus.sucesso && resultado.localizacao != null) {
      setState(() {
        _userLocation = resultado.localizacao;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVeiculos();
    _obterLocalizacaoInicial();

    // Atualiza automaticamente a cada 30 segundos
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadVeiculos();
    });

    // Listener para o campo de busca
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        _parseNumerosFiltrados();
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

  // Método para processar os números inseridos no campo de busca
  void _parseNumerosFiltrados() {
    if (_searchText.isEmpty) {
      _numerosFiltrados.clear();
      return;
    }

    // Separa por espaço e limpa espaços em branco
    final numeros = _searchText
        .split(' ')
        .map((numero) => numero.trim())
        .where((numero) => numero.isNotEmpty)
        .take(_maxFiltros) // Limita a 5 números
        .toList();

    _numerosFiltrados = numeros;
  }

  void _updateLinhasFiltradas() {
    if (_numerosFiltrados.isEmpty) {
      _linhasFiltradas.clear();
      _paginaAtual = 0;
      return;
    }

    final linhasEncontradas = <String>{};
    for (var marker in _filteredMarkers) {
      final feature = (marker.key as ValueKey).value;
      final numeroLinha = feature.properties.veiculo.numero.toString();

      // Verifica se o número da linha corresponde a algum dos filtros
      if (_numerosFiltrados.any((filtro) =>
          numeroLinha.toLowerCase().contains(filtro.toLowerCase()))) {
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
        if (_visibilidadeServicos['urbi'] ?? true) UrbiVeiculosService().buscarPosicaoUrbi(),
        if (_visibilidadeServicos['piracicabana'] ?? true) PiracicabanaVeiculosService().buscarPosicaoPiracicabana(),
        if (_visibilidadeServicos['pioneira'] ?? true) PioneiraVeiculosService().buscarPosicaoPioneira(),
        if (_visibilidadeServicos['marechal'] ?? true) MarechalVeiculosService().buscarPosicaoMarechal(),
        if (_visibilidadeServicos['bsbus'] ?? true) BsbusVeiculosService().buscarPosicaoBsbus(),
      ];

      // Executa as requisições apenas para operadoras visíveis
      final operadorasAtivas = ['urbi', 'piracicabana', 'pioneira', 'marechal', 'bsbus']
          .where((op) => _visibilidadeServicos[op] ?? true)
          .toList();

      final results = await Future.wait([
        if (_visibilidadeServicos['urbi'] ?? true) UrbiVeiculosService().buscarPosicaoUrbi(),
        if (_visibilidadeServicos['piracicabana'] ?? true) PiracicabanaVeiculosService().buscarPosicaoPiracicabana(),
        if (_visibilidadeServicos['pioneira'] ?? true) PioneiraVeiculosService().buscarPosicaoPioneira(),
        if (_visibilidadeServicos['marechal'] ?? true) MarechalVeiculosService().buscarPosicaoMarechal(),
        if (_visibilidadeServicos['bsbus'] ?? true) BsbusVeiculosService().buscarPosicaoBsbus(),
      ]);

      // Limpa os markers das operadoras
      _markersOperadoras.forEach((key, value) => value.clear());

      // Processa os resultados
      int resultIndex = 0;
      for (String operadora in operadorasAtivas) {
        if (resultIndex < results.length) {
          final veiculosOperadora = results[resultIndex];
          if (veiculosOperadora?.features != null) {
            final markersOperadora = <Marker>[];

            for (var feature in veiculosOperadora!.features) {
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
                  markersOperadora.add(
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
            _markersOperadoras[operadora] = markersOperadora;
          }
        }
        resultIndex++;
      }

      // Combina todos os markers visíveis
      final allMarkers = <Marker>[];
      _markersOperadoras.forEach((operadora, markers) {
        if (_visibilidadeServicos[operadora] ?? true) {
          allMarkers.addAll(markers);
        }
      });

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

  // Widget para criar botões das operadoras
  Widget _buildOperadoraButton(String nome, Color cor) {
    final nomeKey = nome.toLowerCase();
    final isVisible = _visibilidadeServicos[nomeKey] ?? true;
    final count = _markersOperadoras[nomeKey]?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: FloatingActionButton.extended(
        heroTag: 'operadora_$nome',
        onPressed: () {
          setState(() {
            _visibilidadeServicos[nomeKey] = !isVisible;
          });
          // Recarrega apenas se necessário
          if (!isVisible) {
            _loadVeiculos();
          }
        },
        backgroundColor: isVisible ? cor : Colors.grey.shade400,
        foregroundColor: Colors.white,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '$nome ($count)',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
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
      _numerosFiltrados.clear();
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

  // Método para obter texto de placeholder dinâmico
  String get _placeholderText {
    if (_numerosFiltrados.length >= _maxFiltros) {
      return 'Máximo de $_maxFiltros números atingido';
    }
    return 'Ex: 0.898, 2302, 0.110... (máx $_maxFiltros)';
  }

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
                  cursorKeyboardRotationOptions:
                  CursorKeyboardRotationOptions.disabled(),
                ),
                initialCenter: brasiliaCenter,
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
                        Colors.lightBlue,
                        Colors.indigo,
                        Colors.cyan,
                        Colors.teal,
                      ];
                      final index =
                      _linhasSelecionadas.toList().indexOf(entry.key);
                      return Polyline(
                        points: entry.value, // Agora é List<LatLng> diretamente
                        strokeWidth: 4.0,
                        color: cores[index % cores.length],
                      );
                    }).toList(),
                  ),
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
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: _clusterRadius.toInt(),
                    size: _clusterSize,
                    padding: _clusterPadding,
                    markers: _filteredMarkers,
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          color: _numerosFiltrados.isNotEmpty ? Colors.orange : Colors.blue,
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
                          temRota: _percursosCarregados
                              .containsKey(feature.properties.veiculo.numero),
                          isLinhaAtual:
                          _linhaAtual == feature.properties.veiculo.numero,
                          onVerRota: () {
                            final numeroLinha =
                                feature.properties.veiculo.numero;

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
                        );
                      },
                    ),
                    showPolygon: true, // Exibe o polígono de agrupamento
                    polygonOptions: PolygonOptions(
                      borderColor: _numerosFiltrados.isNotEmpty ? Colors.orange : Colors.blue,
                      borderStrokeWidth: 3,
                      color: (_numerosFiltrados.isNotEmpty ? Colors.orange : Colors.blue).withValues(
                          alpha: 0.2),
                    ),
                  ),
                ),
                const SimpleAttributionWidget(
                  source: Text('OpenStreetMap contributors'),
                ),
              ],
            ),
          ),

          // Campo de busca
          Positioned(
            top: 20,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 280,
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: _placeholderText,
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          enabled: _numerosFiltrados.length < _maxFiltros || _searchText.isNotEmpty,
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
                          tooltip: 'Carregar todas as rotas de linhas filtradas (5 primeiras)',
                          onPressed: _linhasPaginadas.isEmpty
                              ? null
                              : _carregarTodasRotasFiltradas,
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _limparFiltro();
                            _limparPercursos();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                // Indicador dos números filtrados
                if (_numerosFiltrados.isNotEmpty)
                  Container(
                    width: 350,
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _numerosFiltrados.map((numero) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          numero,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // Lista de linhas filtradas
          if (_searchText.isNotEmpty && _linhasFiltradas.isNotEmpty)
            Positioned(
              top: _numerosFiltrados.isNotEmpty ? 120 : 80,
              right: 16,
              child: SizedBox(
                width: 350,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                          color: Colors.orange,
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
                            final temRota =
                            _percursosCarregados.containsKey(linha);

                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: temRota
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                                child: Text(
                                  linha,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: temRota
                                        ? Colors.white
                                        : Colors.grey.shade600,
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
                                child: Text('Linha $linha',style: const TextStyle(color: Colors.orangeAccent),),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      temRota
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 20,
                                      color: temRota ? Colors.red : Colors.orange,
                                    ),
                                    tooltip:
                                    temRota ? 'Ocultar rota' : 'Ver rota',
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
            ),

          // Botões de controle das operadoras
          Positioned(
            bottom: 190, // Ajustado para não sobrepor outros elementos
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'operadoras_visiveis',
                  onPressed: () {
                    setState(() {
                      _mostrarGavetaOperadoras = !_mostrarGavetaOperadoras;
                    });
                  },
                  backgroundColor: const Color(0xFF4A6FA5),
                  child: Icon(
                    _mostrarGavetaOperadoras ? Icons.close : Icons.menu,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _mostrarGavetaOperadoras ? null : 0,
                  curve: Curves.easeInOut,
                  child: Visibility(
                    visible: _mostrarGavetaOperadoras,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 10),
                        _buildOperadoraButton('Urbi', Colors.blue),
                        const SizedBox(height: 10),
                        _buildOperadoraButton('Piracicabana', Colors.redAccent),
                        const SizedBox(height: 10),
                        _buildOperadoraButton('Pioneira', Colors.yellow),
                        const SizedBox(height: 10),
                        _buildOperadoraButton('Marechal', Colors.orange),
                        const SizedBox(height: 10),
                        _buildOperadoraButton('Bsbus', Colors.lightGreenAccent),
                      ],
                    ),
                  ),
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
            bottom: 136,
            right: 24,
          ),

          // Debug info
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
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
                  // // Mostra contagem por operadora
                  // ..._markersOperadoras.entries.map((entry) {
                  //   final operadora = entry.key;
                  //   final count = entry.value.length;
                  //   final isVisible = _visibilidadeServicos[operadora] ?? true;
                  //   final color = isVisible ? Colors.white : Colors.grey;
                  //
                  //   return Text(
                  //     '${operadora.toUpperCase()}: $count${isVisible ? '' : ' (oculto)'}',
                  //     style: TextStyle(color: color, fontSize: 10),
                  //   );
                  // }),
                  if (_numerosFiltrados.isNotEmpty)
                    Text(
                      'Filtros ativos: ${_numerosFiltrados.join(", ")}',
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  if (_searchText.isNotEmpty)
                    Text(
                      'Linhas encontradas: ${_linhasFiltradas.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  if (_percursosCarregados.isNotEmpty)
                    Text(
                      'Rotas carregadas: ${_percursosCarregados.length}',
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

          Positioned(
            top: 20,
            left: 24,
            child: FloatingActionButton.small(
              heroTag: 'Voltar_página',
              tooltip: 'Voltar para início',
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),

          ZoomControls(mapController: _mapController),

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
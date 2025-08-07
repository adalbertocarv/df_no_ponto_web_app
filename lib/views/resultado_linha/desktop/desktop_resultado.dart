import 'package:df_no_ponto_web_app/views/resultado_linha/desktop/widgets/polyline_map_area.dart';
import 'package:df_no_ponto_web_app/views/resultado_linha/desktop/widgets/side_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../controller/resultado_linha/mapa_linha_controller.dart';
import '../../../controller/resultado_linha/resultado_linha_controller.dart';


class DesktopResultadoLinhaPage extends StatefulWidget {
  const DesktopResultadoLinhaPage({super.key, required this.numero});
  final String numero;

  @override
  State<DesktopResultadoLinhaPage> createState() => _DesktopResultadoLinhaPageState();
}

class _DesktopResultadoLinhaPageState extends State<DesktopResultadoLinhaPage> {
  final _map = MapController();
  late final ResultadoLinhaController _dadosController;
  late final ResultadoMapaController _mapaController;

  bool _mapaInicializado = false;

  @override
  void initState() {
    super.initState();
    _dadosController = ResultadoLinhaController(widget.numero);
    _mapaController = ResultadoMapaController(widget.numero);

    _dadosController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dadosController.removeListener(_onDataChanged);
    _dadosController.dispose();
    _mapaController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (!mounted) return;

    setState(() {
      _initializeMapIfReady();
    });
  }

  void _initializeMapIfReady() {
    if (!_mapaInicializado ||
        _dadosController.carregando ||
        _dadosController.percursos == null ||
        _dadosController.percursos!.isEmpty) {
      return;
    }

    final percursos = _dadosController.percursos!;
    final sentidos = percursos.keys.map((e) => e.toUpperCase()).toSet();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (sentidos.contains('CIRCULAR')) {
        _mapaController.init(_map, percursos);
      } else {
        final percursoIda = {'IDA': percursos['IDA'] ?? []};
        _mapaController.init(_map, percursoIda);
      }
    });
  }

  void _onMapReady() {
    if (_mapaInicializado) return;

    _mapaInicializado = true;
    _initializeMapIfReady();
  }

  void _alternarSentido() {
    _dadosController.alternarSentido();
  }

  void _moveToPercurso(List percursoList) {
    if (_mapaInicializado &&
        percursoList.isNotEmpty &&
        percursoList.first.coordenadas.isNotEmpty) {
      try {
        _map.move(percursoList.first.coordenadas.first, 14);
      } catch (e) {
        debugPrint('Erro ao mover mapa: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Painel lateral esquerdo
          DesktopSidePanel(
            numero: widget.numero,
            dadosController: _dadosController,
            onAlternarSentido: _alternarSentido,
            onMoveToPercurso: _moveToPercurso,
          ),

          // Área do mapa
          Expanded(
            child: DesktopMapArea(
              dadosController: _dadosController,
              mapController: _map,
              onMapReady: _onMapReady,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/linha/percurso.dart';

class ResultadoMapaController {
  ResultadoMapaController(this.numero);

  final String numero;
  MapController? _mapController;

  /// true enquanto busca dados
  final loading = ValueNotifier<bool>(true);

  /// mapa dos percursos ("IDA" | "VOLTA" | "CIRCULAR")
  final percursos =
  ValueNotifier<Map<String, List<PercursoModel>>>({});

  /// Carrega dados e prepara para centralizar mapa
  Future<void> init(MapController map, Map<String, List<PercursoModel>> dados) async {
    _mapController = map;

    try {
      percursos.value = dados;

      await Future.delayed(const Duration(milliseconds: 100));

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        _centralizarMapa(dados);
      });
    } finally {
      loading.value = false;
    }
  }

  /// Centraliza o mapa considerando todos os pontos das polylines
  void _centralizarMapa(Map<String, List<PercursoModel>> dados) {
    if (_mapController == null) return;

    // Coleta todos os pontos de todas as polylines
    final List<LatLng> todosPontos = [];
    for (final lista in dados.values) {
      for (final percurso in lista) {
        todosPontos.addAll(percurso.coordenadas);
      }
    }

    if (todosPontos.isEmpty) return;

    try {
      if (todosPontos.length == 1) {
        // Se há apenas um ponto, centraliza nele
        _mapController!.move(todosPontos.first, 14);
      } else {
        // Se há múltiplos pontos, ajusta para mostrar todos
        final bounds = LatLngBounds.fromPoints(todosPontos);

        // Calcula o centro e um zoom apropriado
        final center = bounds.center;

        // Ajusta o zoom baseado na extensão dos pontos
        double zoom = _calculateZoomLevel(bounds);

        _mapController!.move(center, zoom);
      }
    } catch (e) {
      debugPrint('Erro ao centralizar mapa: $e');
      // Fallback: tenta centralizar no primeiro ponto disponível
      if (todosPontos.isNotEmpty) {
        try {
          _mapController!.move(todosPontos.first, 12);
        } catch (fallbackError) {
          debugPrint('Erro no fallback: $fallbackError');
        }
      }
    }
  }

  /// Calcula um nível de zoom apropriado baseado nos bounds
  double _calculateZoomLevel(LatLngBounds bounds) {
    final double latDiff = (bounds.north - bounds.south).abs();
    final double lngDiff = (bounds.east - bounds.west).abs();
    final double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    if (maxDiff > 0.5) return 10.5;
    if (maxDiff > 0.2) return 11.5;
    if (maxDiff > 0.1) return 12.5;
    if (maxDiff > 0.05) return 13.5;
    if (maxDiff > 0.02) return 14.5;
    if (maxDiff > 0.01) return 15.5;
    return 16.0;
  }

  /// Chamada externa para centralizar o mapa com os dados já carregados
  void centralizarMapaAtual() {
    _centralizarMapa(percursos.value);
  }

  /// Libera os notifiers (chame em dispose da view)
  void dispose() {
    loading.dispose();
    percursos.dispose();
    _mapController = null;
  }
}
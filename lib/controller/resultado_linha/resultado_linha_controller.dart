import 'package:flutter/material.dart';
import 'dart:async'; // Adicione esta importação
import '../../services/dados_espaciais/linha/itinerario_espacial.dart';
import '../../services/dados_espaciais/linha/veiculos_tempo_real.dart';
import '../../services/info_linha/informacoes.dart';
import '../../services/info_linha/horario.dart';
import '../../services/info_linha/itinerario_descritivo.dart';

import '../../models/linha/percurso.dart';
import '../../models/linha/veiculos_tempo_real.dart';
import '../../models/linha/linha_info.dart';
import '../../models/linha/horario.dart';
import '../../models/linha/itinerario.dart';

class ResultadoLinhaController extends ChangeNotifier {
  final String numero;
  Timer? _vehicleUpdateTimer; // Adicione o timer

  ResultadoLinhaController(this.numero) {
    carregarDados();
    _startVehicleUpdateTimer(); // Inicia o timer para veículos
  }

  // Serviços
  final _itinerarioService = PercursoService();
  final _tempoRealService = VeiculosService();
  final _infoService = LinhaInfoService();
  final _horarioService = HorarioService();
  final _itinerarioDescritivoService = ItinerarioService();

  // Estado
  String _sentidoSelecionado = 'IDA';
  bool carregando = false;
  String? erro;
  bool ehCircular = false;
  bool unicaDirecao = false;

  // Dados carregados
  Map<String, List<PercursoModel>>? percursos;
  VeiculosTempoReal? veiculos;
  List<LinhaInfoModel>? infoLinha;
  List<HorarioModel>? horarios;
  List<ItinerarioModel>? itinerarioDescritivo;

  // Getter do sentido atual
  String get sentidoSelecionado => _sentidoSelecionado;

  // Adicione estes getters para manter compatibilidade com o código anterior
  List<ItinerarioModel>? get itinerarios => itinerarioDescritivo;

  // Alternância entre IDA e VOLTA
  void alternarSentido() {
    if (!isLinhaCircular) {
      _sentidoSelecionado = _sentidoSelecionado == 'IDA' ? 'VOLTA' : 'IDA';
      notifyListeners();
    }
  }

  /// Verifica se a linha é circular com base nas chaves do mapa
  bool get isLinhaCircular {
    if (percursos == null) return false;
    final sentidos = percursos!.keys.map((e) => e.toUpperCase()).toSet();
    return sentidos.length == 1 && sentidos.contains('CIRCULAR');
  }

  /// Verifica se a linha é de única direção com base nas chaves do mapa
  bool get isUnidirecional {
    if (percursos == null) return false;
    final sentidos = percursos!.keys.map((e) => e.toUpperCase()).toSet();
    return sentidos.length == 1 && !sentidos.contains('CIRCULAR');
  }

  /// Retorna os veículos que devem ser exibidos no mapa baseado no sentido selecionado
  List<Feature> get veiculosExibidos {
    if (veiculos == null || veiculos!.features.isEmpty) {
      return [];
    }

    // Para linhas circulares, mostra todos os veículos
    if (ehCircular) {
      return veiculos!.todosVeiculos();
    }

    // Para linhas unidirecionais, mostra todos os veículos
    if (unicaDirecao) {
      return veiculos!.todosVeiculos();
    }

    // Para linhas IDA-VOLTA, filtra pelo sentido selecionado
    return veiculos!.veiculosPorSentido(_sentidoSelecionado);
  }

  /// Retorna apenas os percursos que devem ser exibidos no momento
  Map<String, List<PercursoModel>> get percursosExibidos {
    final exibidos = <String, List<PercursoModel>>{};

    // Sempre tenta incluir o sentido selecionado (IDA ou VOLTA)
    final selecionado = _sentidoSelecionado.toUpperCase();
    if (percursos?.containsKey(selecionado) ?? false) {
      exibidos[selecionado] = percursos![selecionado]!;
    }

    // Inclui também "CIRCULAR", se existir
    if (percursos?.containsKey('CIRCULAR') ?? false) {
      exibidos['CIRCULAR'] = percursos!['CIRCULAR']!;
    }

    return exibidos;
  }

  /// Retorna a descrição da linha (ou null)
  LinhaInfoModel? get linhaInfo {
    if (infoLinha == null || infoLinha!.isEmpty) return null;
    return infoLinha!.first;
  }

  /// Inicia o carregamento dos dados
  Future<void> carregarDados() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _itinerarioService.buscarPercursos(numero),
        _tempoRealService.buscarUltimaPosicao(numero),
        _infoService.procurarLinha(numero),
        _horarioService.procurarHorarios(numero),
        _itinerarioDescritivoService.procurarItinerario(numero),
      ]);

      percursos = results[0] as Map<String, List<PercursoModel>>;
      veiculos = results[1] as VeiculosTempoReal;
      infoLinha = results[2] as List<LinhaInfoModel>;
      horarios = results[3] as List<HorarioModel>;
      itinerarioDescritivo = results[4] as List<ItinerarioModel>;

      // 🚀 Determinação explícita do tipo de linha:
      final sentidos = percursos!.map((k, v) => MapEntry(k.toUpperCase(), v));

      final rawMapas = percursos!;
      final mapas = <String, List<PercursoModel>>{};
      for (final entry in rawMapas.entries) {
        mapas[entry.key.toUpperCase()] = entry.value;
      }

      final circularList = mapas['CIRCULAR'];
      final idaList = mapas['IDA'];
      final voltaList = mapas['VOLTA'];

      final hasCircular = circularList != null && circularList.isNotEmpty;
      final hasIda = idaList != null && idaList.isNotEmpty;
      final hasVolta = voltaList != null && voltaList.isNotEmpty;

      if (hasCircular && !hasIda && !hasVolta) {
        ehCircular = true;
        unicaDirecao = false;
      } else if ((hasIda && !hasVolta) || (hasVolta && !hasIda)) {
        ehCircular = false;
        unicaDirecao = true;
      } else {
        ehCircular = false;
        unicaDirecao = false;
      }

      // Corrige sentido padrão se necessário
      final sentidosDisponiveis = sentidos.keys.toSet();
      if (!sentidosDisponiveis.contains(_sentidoSelecionado)) {
        _sentidoSelecionado = sentidosDisponiveis.firstOrNull ?? 'IDA';
      }

    } catch (e) {
      erro = 'Erro ao carregar dados: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // Novos métodos para funcionalidades adicionais:

  /// Atualiza apenas os veículos em tempo real
  Future<void> atualizarVeiculos() async {
    try {
      final novosVeiculos = await _tempoRealService.buscarUltimaPosicao(numero);
      veiculos = novosVeiculos;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar veículos: $e');
    }
  }

  /// Recarrega todos os dados
  Future<void> recarregarDados() async {
    await carregarDados();
  }

  /// Inicia o timer para atualização automática de veículos
  void _startVehicleUpdateTimer() {
    _vehicleUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => atualizarVeiculos(),
    );
  }

  /// Para o timer de atualização
  void _stopVehicleUpdateTimer() {
    _vehicleUpdateTimer?.cancel();
    _vehicleUpdateTimer = null;
  }

  @override
  void dispose() {
    _stopVehicleUpdateTimer();
    super.dispose();
  }

  // Método auxiliar para saber se tem dados suficientes para exibir
  bool get temDadosParaExibir {
    return percursos != null && percursos!.isNotEmpty;
  }

  // Método para obter estatísticas rápidas
  String get resumoLinha {
    if (infoLinha == null || infoLinha!.isEmpty) return 'Informações não disponíveis';

    final info = infoLinha!.first;
    return '${info.descricao} - R\$ ${info.tarifa.toStringAsFixed(2)}';
  }
}
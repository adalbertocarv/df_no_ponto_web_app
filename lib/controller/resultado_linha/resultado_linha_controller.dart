import 'package:flutter/material.dart';
import '../../services/dados_espaciais/linha/itinerario_espacial.dart';
import '../../services/dados_espaciais/linha/veiculos_tempo_real.dart';
import '../../services/info_linha/informacoes.dart';
import '../../services/info_linha/horario.dart';
import '../../models/linha/percurso.dart';
import '../../models/linha/veiculos_tempo_real.dart';
import '../../models/linha/linha_info.dart';
import '../../models/linha/horario.dart';
import '../../services/info_linha/itinerario_descritivo.dart';
import '../../models/linha/itinerario.dart';

class ResultadoLinhaController extends ChangeNotifier {
  final String numero;

  ResultadoLinhaController(this.numero) {
    carregarDados();
  }

  final _itinerarioService = PercursoService();
  final _tempoRealService = VeiculosService();
  final _infoService = LinhaInfoService();
  final _horarioService = HorarioService();
  final _itinerarioDescritivoService = ItinerarioService();


  // Variáveis para armazenar os dados
  Map<String, List<PercursoModel>>? percursos;
  VeiculosTempoReal? veiculos;
  List<LinhaInfoModel>? infoLinha;
  List<HorarioModel>? horarios;
  List<ItinerarioModel>? itinerarioDescritivo;

  // Estado da tela
  bool carregando = false;
  String? erro;

  Future<void> carregarDados() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      // Chamadas paralelas
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
    } catch (e) {
      erro = 'Erro ao carregar dados: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}

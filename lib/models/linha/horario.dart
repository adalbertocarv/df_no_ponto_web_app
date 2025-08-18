class HorarioModel {
  final String numeroLinha;
  final String sentido;
  final int? duracaoMedia;
  final List<Horario> horarios;

  HorarioModel({
    required this.numeroLinha,
    required this.sentido,
    this.duracaoMedia,
    required this.horarios,
  });

  factory HorarioModel.fromJson(Map<String, dynamic> json) {
    var horariosFromJson = json['horarios'] as List;
    List<Horario> horariosList =
    horariosFromJson.map((horario) => Horario.fromJson(horario)).toList();

    return HorarioModel(
      numeroLinha: json['numero'] as String,
      sentido: traduzirSentido(json['sentido'] as String), // aqui aplica tradução
      duracaoMedia: json['tempo_percurso'] as int?,
      horarios: horariosList,
    );
  }


  /// Traduz código do sentido para texto
  static String traduzirSentido(String codigo) {
    switch (codigo) {
      case 'C':
        return 'CIRCULAR';
      case 'I':
        return 'IDA';
      case 'V':
        return 'VOLTA';
      default:
        return codigo; // retorna o código original se não for reconhecido
    }
  }
}

class Horario {
  final String horario;
  final String operador;
  final String diaLabel;
  final String diasSemana;
  final int hora;
  final int minuto;

  Horario({
    required this.horario,
    required this.operador,
    required this.diaLabel,
    required this.diasSemana,
    required this.hora,
    required this.minuto,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      horario: json['horario'] as String,
      operador: (json['operadoras'] as List).join(', '), // Combina os operadores em uma string
      diaLabel: json['dia_label'] as String,
      diasSemana: json['dias_semana'] as String,
      hora: int.parse(json['hora'] as String),
      minuto: int.parse(json['minuto'] as String),
    );
  }

  static String formatarDiaSemana(String diasSemana) {
    switch (diasSemana) {
    // Todos os dias
      case 'SSSSSSS':
        return 'TODOS OS DIAS';

    // Dias únicos
      case 'SNNNNNN':
        return 'SEGUNDA';
      case 'NSNNNNN':
        return 'TERÇA';
      case 'NNSNNNN':
        return 'QUARTA';
      case 'NNNSNNN':
        return 'QUINTA';
      case 'NNNNSNN':
        return 'SEXTA';
      case 'NNNNNSN':
        return 'SÁBADO';
      case 'NNNNNNS':
        return 'DOMINGO';

    // Dias úteis
      case 'SSSSSNN':
        return 'SEGUNDA-SEXTA';

    // Fim de semana
      case 'NNNNNSS':
        return 'SÁBADO-DOMINGO';

    // Dias alternados comuns
      case 'SSNNSNN':
        return 'SEGUNDA-TERÇA-QUINTA';
      case 'NNSSNNN':
        return 'QUARTA-QUINTA';
      case 'SSNNNNN':
        return 'SEGUNDA-TERÇA';
      case 'NNSSSNN':
        return 'QUARTA-SEXTA';
      case 'SSSSNSN':
        return 'SEGUNDA-QUINTA + SÁBADO';
      case 'SSSSNNS':
        return 'SEGUNDA-QUINTA + DOMINGO';
      case 'SSSSSSN':
        return 'SEGUNDA-SÁBADO';

    // Padrões especiais conhecidos
      case 'SNNNNNS':
        return 'SEGUNDA-DOMINGO';
      case 'SSNNNNS':
        return 'SEGUNDA-TERÇA-DOMINGO';

    // Padrões incomuns mas possíveis
      case 'SNSNSNS':
        return 'DIAS ALTERNADOS (SEG, QUA, SEX, DOM)';
      case 'NSNSNSN':
        return 'DIAS ALTERNADOS (TER, QUI, SÁB)';

    // Padrões não mapeados
      default:
        return diasSemana;
    }
  }
}
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
      sentido: json['sentido'] as String,
      duracaoMedia: json['tempo_percurso'] as int?,
      horarios: horariosList,
    );
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
      case 'SSSSSNN':
        return 'SEGUNDA-SEXTA';
      case 'NNNNNSN':
        return 'SÁBADO';
      case 'NNNNNNS':
        return 'DOMINGO';
      default:
        return diasSemana;
    }
  }
}
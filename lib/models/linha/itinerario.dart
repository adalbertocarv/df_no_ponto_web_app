class ItinerarioModel {
  final String origem;
  final String destino;
  final String sentido;
  final double extensao;
  final List<Itinerario> itinerario;

  ItinerarioModel({
    required this.origem,
    required this.destino,
    required this.sentido,
    required this.extensao,
    required this.itinerario,
  });

  factory ItinerarioModel.fromJson(Map<String, dynamic> json) {
    var itinerarioFromJson = json['itinerario'] as List;
    List<Itinerario> itinerarioList = itinerarioFromJson
        .map((item) => Itinerario.fromJson(item))
        .toList();

    return ItinerarioModel(
      origem: json['origem'],
      destino: json['destino'],
      sentido: json['sentido'],
      extensao: double.tryParse(json['extensao']) ?? 0.0, // Conversão segura
      itinerario: itinerarioList,
    );
  }
}

class Itinerario {
  final String sequencial;
  final String via;
  final String localidade;

  Itinerario({
    required this.sequencial,
    required this.via,
    required this.localidade,
  });

  factory Itinerario.fromJson(Map<String, dynamic> json) {
    return Itinerario(
      sequencial: json['sequencial'],
      via: json['via'],
      localidade: json['localidade'],
    );
  }
}
import 'package:latlong2/latlong.dart';

class PercursoCompleto {
  final String numero;
  final String sentido;
  final List<LatLng> coordinates;

  PercursoCompleto({
    required this.numero,
    required this.sentido,
    required this.coordinates,
  });

  /// Cria um objeto de percurso completo a partir de uma lista de JSON
  factory PercursoCompleto.fromJsonList(List<dynamic> jsonList) {
    if (jsonList.isEmpty) {
      throw ArgumentError('A lista de percursos está vazia.');
    }

    // Obter a linha IDA (se existir)
    final linhaIda = jsonList.isNotEmpty ? jsonList[0] : null;

    // Obter a linha VOLTA (se existir)
    final linhaVolta = jsonList.length > 1 ? jsonList[1] : null;

    // Obter o número da linha
    final String numero = linhaIda?['Numero'] ?? 'Desconhecido';

    // Determinar o sentido
    String sentido = 'CIRCULAR';
    if (linhaIda != null && linhaVolta != null) {
      sentido = 'IDA/VOLTA';
    } else if (linhaIda != null) {
      sentido = linhaIda['Sentido'] ?? 'Desconhecido';
    }

    // Obter as coordenadas de IDA
    final List<List<dynamic>> coordinatesIda =
    linhaIda != null && linhaIda['GeoLinhas'] != null
        ? List<List<dynamic>>.from(linhaIda['GeoLinhas']['coordinates'])
        : [];

    // Obter as coordenadas de VOLTA
    final List<List<dynamic>> coordinatesVolta =
    linhaVolta != null && linhaVolta['GeoLinhas'] != null
        ? List<List<dynamic>>.from(linhaVolta['GeoLinhas']['coordinates'])
        : [];

    // Combinar as coordenadas, garantindo que sejam do tipo `LatLng`
    final List<LatLng> coordinates = [
      ...coordinatesIda.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())),
      ...coordinatesVolta.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())),
    ];

    return PercursoCompleto(
      numero: numero,
      sentido: sentido,
      coordinates: coordinates,
    );
  }

  /// Converte o objeto unificado em um JSON
  Map<String, dynamic> toJson() {
    return {
      "type": "LineString",
      "coordinates": coordinates.map((c) => [c.longitude, c.latitude]).toList(),
    };
  }
}
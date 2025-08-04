import 'package:latlong2/latlong.dart';

class PercursoModel {
  final String sentido;
  final List<LatLng> coordenadas;

  PercursoModel({required this.sentido, required this.coordenadas});

  factory PercursoModel.fromJson(Map<String, dynamic> json) {
    final coordinates = json['GeoLinhas']['coordinates'] as List<dynamic>;

    return PercursoModel(
      sentido: json['Sentido'] as String,
      coordenadas: coordinates
          .map((coord) => LatLng(coord[1] as double, coord[0] as double))
          .toList(),
    );
  }
}
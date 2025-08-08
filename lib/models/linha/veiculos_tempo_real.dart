import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class VeiculosTempoReal {
  final List<Feature> features;
  final String type;

  VeiculosTempoReal({required this.features, required this.type});

  factory VeiculosTempoReal.fromJson(Map<String, dynamic> json) {
    return VeiculosTempoReal(
      features: (json['features'] as List)
          .map((featureJson) => Feature.fromJson(featureJson))
          .toList(),
      type: json['type'],
    );
  }

  /// Filtra veículos por sentido (IDA ou VOLTA)
  List<Feature> veiculosPorSentido(String sentido) {
    return features.where((feature) =>
    feature.properties.sentido?.toUpperCase() == sentido.toUpperCase()
    ).toList();
  }

  /// Retorna todos os veículos para linhas circulares ou unidirecionais
  List<Feature> todosVeiculos() {
    return features;
  }
}

class Feature {
  final Geometry geometry;
  final String type;
  final Properties properties;

  Feature(
      {required this.geometry, required this.type, required this.properties});

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      geometry: Geometry.fromJson(json['geometry']),
      type: json['type'],
      properties: Properties.fromJson(json['properties']),
    );
  }

  /// Cria um marker para o veículo com informações no tooltip
  Marker toMarker({VoidCallback? onTap}) {
    return Marker(
      point: LatLng(geometry.coordinates[1], geometry.coordinates[0]),
      width: 35,
      height: 35,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: getColorBySentido(),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              properties.busImage,
              width: 25,
              height: 25,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(
                Icons.directions_bus,
                size: 20,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
  /// Retorna a cor baseada no sentido do veículo
  Color getColorBySentido() {
    switch (properties.sentido?.toUpperCase()) {
      case 'IDA':
        return Colors.blueAccent;
      case 'VOLTA':
        return Colors.orangeAccent;
      case 'CIRCULAR':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}




class Geometry {
  final List<double> coordinates;
  final String type;

  Geometry({required this.coordinates, required this.type});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      coordinates: List<double>.from(json['coordinates']),
      type: json['type'],
    );
  }
}

class Properties {
  final String? nm_operadora;
  final String? prefixo;
  final String? datalocal;
  final String? velocidade;
  final String? cdLinha;
  final String? direcao;
  final String? sentido;

  Properties({
    required this.nm_operadora,
    required this.prefixo,
    required this.datalocal,
    required this.velocidade,
    required this.cdLinha,
    required this.direcao,
    required this.sentido,
  });

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      nm_operadora: json['nm_operadora'],
      prefixo: json['prefixo'],
      datalocal: json['datalocal'],
      velocidade: json['velocidade'],
      cdLinha: json['cd_linha'],
      direcao: json['direcao'],
      sentido: json['sentido'],
    );
  }

  // Mapa de imagens para cada operadora
  static const Map<String, String> operadoraCores = {
    'VIAÇÃO PIRACICABANA - BACIA 01': 'assets/images/piracicabanaBus.png',
    'VIAÇÃO PIONEIRA BACIA - 02': 'assets/images/pioneiraBus.png',
    'URBI - MOBILID. URBANA - BACIA 03': 'assets/images/urbiBus.png',
    'AUTO VIAÇÃO MARECHAL - BACIA 04': 'assets/images/marechalBus.png',
    'EXPRESSO SÃO JOSÉ BACIA - 05': 'assets/images/sao_joseBus.png',
  };

  // Método para obter a imagem correta da operadora
  String get busImage =>
      operadoraCores[nm_operadora] ?? 'assets/images/defaultBus.png';
}
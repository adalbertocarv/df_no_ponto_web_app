class VeiculosOperadoras {
  final String nomeOperadora;
  final List<Feature> features;

  VeiculosOperadoras({
    this.nomeOperadora = 'Desconhecida',
    required this.features,
  });

  factory VeiculosOperadoras.fromJson(Map<String, dynamic> json) {
    var featuresJson = json['features'];
    List<Feature> featuresList = [];

    if (featuresJson != null && featuresJson is List) {
      String operadora = json['NomeOperadora']?.toString() ?? 'Desconhecida';
      featuresList = featuresJson
          .where((feature) => feature != null)
          .map((featureJson) => Feature.fromJson(featureJson, operadora))
          .toList();
    }

    return VeiculosOperadoras(
      nomeOperadora: json['NomeOperadora']?.toString() ?? 'Desconhecida',
      features: featuresList,
    );
  }
}

class Feature {
  final Geometry geometry;
  final Properties properties;

  Feature({required this.geometry, required this.properties});

  factory Feature.fromJson(Map<String, dynamic> json, String operadora) {
    try {
      return Feature(
        geometry: Geometry.fromJson(json['geometry'] ?? {}),
        properties: Properties.fromJson(json['properties'] ?? {}, operadora),
      );
    } catch (e) {
      return Feature(
        geometry: Geometry(coordinates: [0.0, 0.0]),
        properties: Properties.defaultProperties(operadora),
      );
    }
  }
}

class Geometry {
  final List<double> coordinates;

  Geometry({required this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    List<double> coords = [];
    try {
      var coordsList = json['coordinates'];
      if (coordsList is List) {
        coords = coordsList.map((coord) => (coord as num?)?.toDouble() ?? 0.0).toList();
      }
    } catch (e) {
      coords = [0.0, 0.0];
    }

    // Garantir que sempre teremos pelo menos duas coordenadas
    while (coords.length < 2) {
      coords.add(0.0);
    }

    return Geometry(coordinates: coords);
  }
}

class Properties {
  final String nomeOperadora;
  final Veiculo veiculo;
  final double direcao;
  final double velocidade;
  final String datalocal;

  Properties({
    required this.nomeOperadora,
    required this.veiculo,
    required this.direcao,
    required this.velocidade,
    required this.datalocal,
  });

  factory Properties.defaultProperties(String operadora) {
    return Properties(
      nomeOperadora: operadora,
      veiculo: Veiculo(prefixo: '', numero: '', sentido: ''),
      direcao: 0.0,
      velocidade: 0.0,
      datalocal: '',
    );
  }

  factory Properties.fromJson(Map<String, dynamic> json, String operadora) {
    return Properties(
      nomeOperadora: operadora,
      veiculo: Veiculo.fromJson(json['veiculo'] ?? {}),
      direcao: _parseDouble(json['direcao']),
      velocidade: _parseDouble(json['velocidade']),
      datalocal: json['datalocal']?.toString() ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // Mapa de imagens para cada operadora
  static const Map<String, String> operadoraCores = {
    'VIAÇÃO PIRACICABANA - BACIA 01': 'assets/images/piracicabanaBus.png',
    'VIAÇÃO PIONEIRA BACIA - 02': 'assets/images/pioneiraBus.png',
    'URBI - MOBILID. URBANA - BACIA 03': 'assets/images/urbiBus.png',
    'AUTO VIAÇÃO MARECHAL - BACIA 04': 'assets/images/marechalBus.png',
    'EXPRESSO SÃO JOSÉ BACIA - 05': 'assets/images/sao_joseBus.png',
  };

  String get busImage => operadoraCores[nomeOperadora] ?? 'assets/images/defaultBus.png';
}

class Veiculo {
  final String prefixo;
  final String numero;
  final String sentido;

  Veiculo({
    required this.prefixo,
    required this.numero,
    required this.sentido
  });

  factory Veiculo.fromJson(Map<String, dynamic> json) {
    return Veiculo(
      prefixo: json['prefixo']?.toString() ?? '',
      numero: json['numero']?.toString() ?? '',
      sentido: json['sentido']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Prefixo: $prefixo, Número: $numero, Sentido: $sentido';
  }
}
class LinhaInfoModel {
  final int idOperadora;
  final String operadora;
  final String numero;
  final String sentido;
  final String descricao;
  final double tarifa;
  final String faixaTarifaria;

  LinhaInfoModel({
    required this.idOperadora,
    required this.operadora,
    required this.numero,
    required this.sentido,
    required this.descricao,
    required this.tarifa,
    required this.faixaTarifaria,
  });

  // Criação do objeto a partir do JSON
  factory LinhaInfoModel.fromJson(Map<String, dynamic> json) {
    return LinhaInfoModel(
      idOperadora: json['id_operadora'],
      operadora: json['operadora'],
      numero: json['numero'],
      sentido: json['sentido'],
      descricao: json['descricao'],
      tarifa: double.tryParse(json['tarifa'].toString()) ?? 0.0,
      faixaTarifaria: json['faixatarifaria'],
    );
  }

  // Conversão do objeto para JSON
  Map<String, dynamic> toJson() {
    return {
      'id_operadora': idOperadora,
      'operadora': operadora,
      'numero': numero,
      'sentido': sentido,
      'descricao': descricao,
      'tarifa': tarifa.toStringAsFixed(2),
      'faixatarifaria': faixaTarifaria,
    };
  }
}
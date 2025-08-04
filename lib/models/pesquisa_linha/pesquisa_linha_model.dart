class LinhaPesquisa {
  final int idOperadora;
  final String operadora;
  final String numero;
  final String sentido;
  final String descricao;
  final double tarifa;
  final String faixaTarifaria;

  LinhaPesquisa({
    required this.idOperadora,
    required this.operadora,
    required this.numero,
    required this.sentido,
    required this.descricao,
    required this.tarifa,
    required this.faixaTarifaria,
  });

  factory LinhaPesquisa.fromJson(Map<String, dynamic> json) => LinhaPesquisa(
    idOperadora: json['id_operadora'],
    operadora: json['operadora'],
    numero: json['numero'],
    sentido: json['sentido'],
    descricao: json['descricao'],
    tarifa: double.tryParse(json['tarifa'].toString()) ?? 0,
    faixaTarifaria: json['faixatarifaria'],
  );

  Map<String, dynamic> toJson() => {
    'id_operadora': idOperadora,
    'operadora': operadora,
    'numero': numero,
    'sentido': sentido,
    'descricao': descricao,
    'tarifa': tarifa.toStringAsFixed(2),
    'faixatarifaria': faixaTarifaria,
  };

  @override
  String toString() => '$numero - $descricao ($sentido)';
}

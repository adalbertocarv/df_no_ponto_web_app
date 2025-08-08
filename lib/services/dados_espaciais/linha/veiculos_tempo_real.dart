import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/linha/veiculos_tempo_real.dart';
import '../../constants/api_headers.dart';
import '../../constants/url.dart';

class VeiculosService {
  Future<VeiculosTempoReal> buscarUltimaPosicao(String numero) async {
    final url = Uri.parse("${caminhoBackend.baseUrl}/recente/$numero");

    final response = await http.get(url, headers: ApiHeaders.json);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List;

      return VeiculosTempoReal.fromJson({
        'type': 'FeatureCollection',
        'features': jsonData.map((data) {
          return {
            'geometry': {
              'type': 'Point',
              'coordinates': [
                (data['longitude'] as num).toDouble(),
                (data['latitude'] as num).toDouble(),
              ],
            },
            'type': 'Feature',
            'properties': {
              'nm_operadora': data['nm_operadora'],
              'prefixo': data['prefixo'],
              'datalocal': data['datalocal'],
              'velocidade': data['velocidade'],
              'cd_linha': data['cd_linha'],
              'direcao': data['direcao'],
              'sentido': data['sentido'],
            },
          };
        }).toList(),
      });
    } else {
      throw Exception("Erro ao buscar posições dos veículos");
    }
  }
}
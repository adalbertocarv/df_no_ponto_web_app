import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/veiculos/veiculos_posicao_model.dart';
import '../../constants/api_headers.dart';
import '../../constants/url.dart';

class MarechalVeiculosService {

  Future<VeiculosOperadoras> buscarPosicaoMarechal() async {
    final url = Uri.parse("${CaminhoBackend.baseUrl}/posicao/marechal");

    try {
      final response = await http.get(url, headers: ApiHeaders.json);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;

        // Procura pela primeira FeatureCollection válida
        final featureCollection = jsonData.firstWhere(
              (element) => element is Map<String, dynamic> &&
              element['type'] == 'FeatureCollection',
          orElse: () => {'features': []},  // Retorna um mapa vazio se não encontrar
        );

        return VeiculosOperadoras.fromJson(featureCollection);
      } else {
        // Retorna uma coleção vazia em caso de erro
        return VeiculosOperadoras(features: []);
      }
    } catch (e) {
      // Retorna uma coleção vazia em caso de exceção
      return VeiculosOperadoras(features: []);
    }
  }
}
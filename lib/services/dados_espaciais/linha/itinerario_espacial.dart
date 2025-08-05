import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/linha/percurso.dart';
import '../../constants/api_headers.dart';
import '../../constants/url.dart';

class PercursoService {

  Future<Map<String, List<PercursoModel>>> buscarPercursos(String numero) async {
    final url = Uri.parse("${caminhoBackend.baseUrl}/espaciais/$numero");

    try {
      final response = await http.get(url, headers: ApiHeaders.json);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;

        final idaPercursos = jsonData
            .where((item) => item['Sentido'] == 'IDA')
            .map((item) => PercursoModel.fromJson(item as Map<String, dynamic>))
            .toList();

        final voltaPercursos = jsonData
            .where((item) => item['Sentido'] == 'VOLTA')
            .map((item) => PercursoModel.fromJson(item as Map<String, dynamic>))
            .toList();

        final circularPercursos = jsonData
            .where((item) => item['Sentido'] == 'CIRCULAR')
            .map((item) => PercursoModel.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          "IDA": idaPercursos,
          "VOLTA": voltaPercursos,
          "CIRCULAR": circularPercursos,
        };
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar percursos: $e');
    }
  }
}
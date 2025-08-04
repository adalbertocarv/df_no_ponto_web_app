import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/linha/percurso.dart';
import '../../constants/url.dart';

class PercursoService {

  Future<Map<String, List<PercursoModel>>> buscarPercursos(String linha) async {
    final url = Uri.parse("${caminhoBackend.baseUrl}/espaciais/$linha");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer kP\$7g@2n!Vx3X#wQ5^z', // Adicionando o Bearer Token com escape
          'Content-Type': 'application/json', // Opcional, mas recomendado
        },
      );


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
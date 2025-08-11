import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/linha/itinerario_completo.dart';
import '../../constants/api_headers.dart';
import '../../constants/url.dart';

class PercursoCompletoService {

  /// Consulta a API para obter as linhas e retorna uma linha unificada
  Future<PercursoCompleto> buscarPercursoCompleto(String linha) async {
    final url = Uri.parse('${caminhoBackend.baseUrl}/espaciais/$linha');

    try {
      final response = await http.get(url, headers: ApiHeaders.json);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return PercursoCompleto.fromJsonList(data);
      } else {
        throw Exception('Erro ao buscar linha: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar à API: $e');
    }
  }
}
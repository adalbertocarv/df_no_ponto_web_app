import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/constants/api_headers.dart';
import '../../models/pesquisa_linha/pesquisa_linha_model.dart';
import '../../services/constants/url.dart';

class SugestoesLinha {

  /// Retorna no máximo [limite] sugestões cujo número COMEÇA com [query].
  Future<List<LinhaPesquisa>> buscarSugestoes(String query,
      {int limite = 10}) async {
    if (query.trim().isEmpty) return [];
    try {
      final url =
      Uri.parse('${caminhoBackend.baseUrl}/numeros/find/$query/$limite');

      final response = await http.get(url, headers: ApiHeaders.json);

      if (response.statusCode != 200) {
        throw Exception(
            'Código inesperado: ${response.statusCode} - ${response.body}');
      }

      final List<dynamic> jsonData = json.decode(response.body);

      // Remove duplicados por número, priorizando sentido IDA ou CIRCULAR
      final vistos = <String>{};
      final filtrados = jsonData.where((item) {
        final numero = item['numero'];
        final sentido = item['sentido'];
        if (!vistos.contains(numero) &&
            (sentido == 'IDA' || sentido == 'CIRCULAR')) {
          vistos.add(numero);
          return true;
        }
        return false;
      });

      return filtrados
          .map<LinhaPesquisa>((e) => LinhaPesquisa.fromJson(e))
          .toList();
    } catch (e) {
      // Repropaga para ser tratado no widget
      rethrow;
    }
  }
}

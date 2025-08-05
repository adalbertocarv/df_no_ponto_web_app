import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/linha/itinerario.dart';
import '../constants/api_headers.dart';
import '../constants/url.dart';

class ItinerarioService {

  Future<List<ItinerarioModel>> procurarItinerario(String numero) async {
    final url = Uri.parse("${caminhoBackend.baseUrl}/descritivo/$numero");
    // Faz a requisição GET
    final response = await http.get(url, headers: ApiHeaders.json);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ItinerarioModel.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar o itinerário para a linha $numero');
    }
  }
}
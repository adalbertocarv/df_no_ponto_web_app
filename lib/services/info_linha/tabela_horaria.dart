import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/linha/horario.dart';
import '../constants/api_headers.dart';
import '../constants/url.dart';


class HorarioService {
  Future<List<HorarioModel>> procurarHorarios(String numero) async {
    final url = Uri.parse("${CaminhoBackend.baseUrl}/horario/$numero");

    final response = await http.get(url, headers: ApiHeaders.json);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => HorarioModel.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar os horários para a linha $numero');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/linha/linha_info.dart';
import '../constants/api_headers.dart';
import '../constants/url.dart';

class LinhaInfoService {

  Future<List<LinhaInfoModel>> procurarLinha(String numero) async {
    final url = Uri.parse("${CaminhoBackend.baseUrl}/numeros/$numero");

    // Faz a requisição GET
    final response = await http.get(url, headers: ApiHeaders.json);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => LinhaInfoModel.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar informações da linha $numero');
    }
  }
}
import 'dart:typed_data';
import 'package:df_no_ponto_web_app/services/constants/api_headers.dart';
import 'package:http/http.dart' as http;

class ImagemService {

  Future<Uint8List?> carregarImagemProtegida(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${ApiHeaders.bearerToken}',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return null;
    }
  }
}
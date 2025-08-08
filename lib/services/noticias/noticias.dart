import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../services/constants/api_headers.dart';
import '../../services/constants/url.dart';

class NoticiasSemob {
  Future<List<Map<String, dynamic>>> procurarNoticias() async {
    try {
      final url = Uri.parse("${caminhoBackend.baseUrl}/noticias");
      final response = await http.get(url, headers: ApiHeaders.json);

      if (response.statusCode == 200) {
        final List<dynamic> noticiasJson = json.decode(response.body);
        return noticiasJson.map((noticia) {
          return {
            'id': (noticia['id_noticias'] ?? '').toString(),
            'titulo': (noticia['titulo'] ?? '').toString(),
            'descricao': (noticia['descricao'] ?? '').toString(),
            'link': (noticia['link'] ?? '').toString(),
            'img': (noticia['linkImagem'] ?? '').toString(),
          };
        }).toList();
      } else {
        debugPrint('Erro HTTP ${response.statusCode} ao buscar notícias.');
        return [];
      }
    } catch (e, stack) {
      debugPrint('Erro ao buscar notícias: $e');
      debugPrintStack(stackTrace: stack);
      return [];
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../services/constants/api_headers.dart';
import '../../models/pesquisa_linha/pesquisa_linha_model.dart';
import '../../services/constants/url.dart';

/// Exceções específicas do serviço de sugestões
abstract class SugestoesLinhaException implements Exception {
  final String message;
  final String? details;

  const SugestoesLinhaException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

class NetworkException extends SugestoesLinhaException {
  const NetworkException([String? details])
      : super('Erro de conexão', details);
}

class ServerException extends SugestoesLinhaException {
  final int statusCode;

  const ServerException(this.statusCode, [String? details])
      : super('Erro no servidor', details);
}

class DataParsingException extends SugestoesLinhaException {
  const DataParsingException([String? details])
      : super('Erro ao processar dados', details);
}

class TimeoutException extends SugestoesLinhaException {
  const TimeoutException([String? details])
      : super('Tempo limite excedido', details);
}

class SugestoesLinha {
  static const Duration _timeout = Duration(seconds: 10);

  /// Retorna no máximo [limite] sugestões cujo número COMEÇA com [query].
  Future<List<LinhaPesquisa>> buscarSugestoes(String query,
      {int limite = 10}) async {

    // Validação de entrada
    if (query.trim().isEmpty) return [];

    final queryLimpa = query.trim();
    if (queryLimpa.length > 50) {
      throw const DataParsingException('Termo de busca muito longo');
    }

    try {
      final url = Uri.parse('${caminhoBackend.baseUrl}/numeros/find/$queryLimpa/$limite');

      // Faz a requisição com timeout
      final response = await http
          .get(url, headers: ApiHeaders.json)
          .timeout(_timeout);

      // Trata diferentes códigos de status
      switch (response.statusCode) {
        case 200:
          return _processarResposta(response.body);

        case 400:
          throw const ServerException(400, 'Parâmetros inválidos');

        case 404:
        // Não é erro, apenas não encontrou resultados
          return [];

        case 429:
          throw const ServerException(429, 'Muitas requisições. Tente novamente em alguns instantes');

        case 500:
        case 502:
        case 503:
          throw const ServerException(500, 'Servidor temporariamente indisponível');

        default:
          throw ServerException(
              response.statusCode,
              'Código inesperado: ${response.statusCode}'
          );
      }

    } on SocketException catch (e) {
      throw NetworkException('Sem conexão com a internet: ${e.message}');

    } on http.ClientException catch (e) {
      throw NetworkException('Erro de rede: ${e.message}');

    } on TimeoutException catch (_) {
      throw const TimeoutException('A busca demorou mais que o esperado');

    } on FormatException catch (e) {
      throw DataParsingException('Formato de resposta inválido: ${e.message}');

    } on SugestoesLinhaException {
      // Re-propaga exceções próprias
      rethrow;

    } catch (e) {
      // Captura qualquer outro erro não previsto
      throw DataParsingException('Erro inesperado: $e');
    }
  }

  /// Processa a resposta JSON e retorna lista de linhas
  List<LinhaPesquisa> _processarResposta(String responseBody) {
    try {
      final dynamic decoded = json.decode(responseBody);

      // Verifica se é uma lista
      if (decoded is! List) {
        throw const DataParsingException('Resposta não é uma lista válida');
      }

      final List<dynamic> jsonData = decoded;

      // Se vazio, retorna lista vazia
      if (jsonData.isEmpty) return [];

      // Remove duplicados por número, priorizando sentido IDA ou CIRCULAR
      final vistos = <String>{};
      final filtrados = <dynamic>[];

      for (final item in jsonData) {
        if (item is! Map<String, dynamic>) {
          continue; // Pula itens inválidos
        }

        final numero = item['numero']?.toString();
        final sentido = item['sentido']?.toString();

        if (numero == null || sentido == null) {
          continue; // Pula itens sem campos obrigatórios
        }

        if (!vistos.contains(numero) &&
            (sentido == 'IDA' || sentido == 'CIRCULAR')) {
          vistos.add(numero);
          filtrados.add(item);
        }
      }

      // Converte para objetos LinhaPesquisa
      final resultado = <LinhaPesquisa>[];
      for (final item in filtrados) {
        try {
          resultado.add(LinhaPesquisa.fromJson(item));
        } catch (e) {
          // Log do erro mas continua processando outros itens
          print('Erro ao converter item: $e');
          continue;
        }
      }

      return resultado;

    } on FormatException catch (e) {
      throw DataParsingException('JSON inválido: ${e.message}');
    } catch (e) {
      throw DataParsingException('Erro ao processar resposta: $e');
    }
  }

  /// Método utilitário para verificar conectividade (opcional)
  Future<bool> verificarConectividade() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// 1. Enum para representar todos os possíveis resultados da operação
enum LocalizacaoStatus {
  sucesso,
  servicoDesabilitado,
  permissaoNegada,
  permissaoNegadaPermanentemente,
  erroInesperado,
}

// 2. Classe para encapsular o resultado
class ResultadoLocalizacao {
  final LocalizacaoStatus status;
  final LatLng? localizacao; // Será nulo se o status não for 'sucesso'

  ResultadoLocalizacao(this.status, {this.localizacao});
}

// 3. Serviço refatorado para usar a nova classe de resultado
class LocalizacaoUsuarioService {
  /// Obtém a localização atual do usuário de forma segura.
  /// Retorna um objeto [ResultadoLocalizacao] com o status e os dados da localização, se houver sucesso.
  Future<ResultadoLocalizacao> obterLocalizacaoUsuario() async {
    try {
      // Verifica se o serviço de localização está habilitado no dispositivo/navegador
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return ResultadoLocalizacao(LocalizacaoStatus.servicoDesabilitado);
      }

      // Verifica o status da permissão
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Se a permissão foi negada antes, solicita novamente
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // O usuário negou a permissão na solicitação atual.
          return ResultadoLocalizacao(LocalizacaoStatus.permissaoNegada);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // O usuário bloqueou permanentemente o acesso à localização.
        // O app não pode mais solicitar a permissão.
        return ResultadoLocalizacao(LocalizacaoStatus.permissaoNegadaPermanentemente);
      }

      // Se chegamos aqui, temos permissão. Obtém a posição atual.
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Sucesso! Retorna o status e a localização.
      return ResultadoLocalizacao(
        LocalizacaoStatus.sucesso,
        localizacao: LatLng(position.latitude, position.longitude),
      );

    } catch (e) {
      // Captura qualquer outra exceção (ex: timeout, erro de plataforma)
      return ResultadoLocalizacao(LocalizacaoStatus.erroInesperado);
    }
  }
}
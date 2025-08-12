import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocalizacaoUsuarioService {
  // Método para obter a localização do usuário
  Future<LatLng?> obterLocalizacaoUsuario() async {
    // Verifica se o serviço de localização está habilitado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // Serviço de localização desativado
    }

    // Verifica as permissões de localização
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; // Permissão negada
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // O usuário bloqueou permanentemente o acesso à localização
      return null;
    }

    // Obtém a posição atual do usuário
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Retorna a localização em formato LatLng
    return LatLng(position.latitude, position.longitude);
  }
}
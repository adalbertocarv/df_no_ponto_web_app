/// Cabeçalhos (JSON) padrão usados nas chamadas HTTP da aplicação.
class ApiHeaders {
  /// Token de autenticação enviado no header **Authorization**.
  static const String bearerToken = 'kP\$7g@2n!Vx3X#wQ5^z';

  /// Cabeçalhos completos já prontos para requisições JSON.
  static Map<String, String> get json => {
    'Authorization': 'Bearer $bearerToken',
    'Content-Type': 'application/json',
  };
}

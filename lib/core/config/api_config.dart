/// Configuración del backend LLM.
class ApiConfig {
  /// URL base del backend.
  /// En desarrollo: localhost
  /// En producción: https://letmeknow-api.tacuchi.net
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://letmeknow-api.tacuchi.net',
  );

  /// Timeout para las peticiones HTTP en segundos.
  static const int timeoutSeconds = 30;

  /// Endpoint para procesar transcripciones.
  static const String processEndpoint = '/api/v1/process';

  /// Endpoint de health check.
  static const String healthEndpoint = '/health';
}

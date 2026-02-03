import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import 'models/assistant_request.dart';
import 'models/assistant_response.dart';

/// Excepciones del cliente API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException() : super('La solicitud tardó demasiado');
}

class ApiConnectionException extends ApiException {
  const ApiConnectionException() : super('No se pudo conectar al servidor');
}

/// Cliente HTTP para comunicarse con el backend LLM.
class AssistantApiClient {
  final http.Client _client;
  final String _baseUrl;

  AssistantApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  /// Procesa una transcripción y retorna la respuesta del LLM.
  Future<AssistantResponse> process(AssistantRequest request) async {
    final url = Uri.parse('$_baseUrl${ApiConfig.processEndpoint}');

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AssistantResponse.fromJson(json);
      } else {
        throw ApiException(
          'Error del servidor: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const ApiConnectionException();
    } on http.ClientException {
      throw const ApiConnectionException();
    } on FormatException catch (e) {
      throw ApiException('Respuesta inválida del servidor: $e');
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e.toString().contains('TimeoutException')) {
        throw const ApiTimeoutException();
      }
      throw ApiException('Error inesperado: $e');
    }
  }

  /// Verifica si el backend está disponible.
  Future<bool> healthCheck() async {
    final url = Uri.parse('$_baseUrl${ApiConfig.healthEndpoint}');

    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

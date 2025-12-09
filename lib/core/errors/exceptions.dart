/// Clase base para excepciones de la aplicación
sealed class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Excepción de servidor o API
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    this.statusCode,
  });
}

/// Excepción de caché o almacenamiento local
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
  });
}

/// Excepción de red/conexión
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Sin conexión a internet',
    super.code,
  });
}

/// Excepción de validación
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
  });
}

/// Excepción de permisos
class PermissionException extends AppException {
  final String permission;

  const PermissionException({
    required this.permission,
    required super.message,
    super.code,
  });
}


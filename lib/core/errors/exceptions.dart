sealed class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({required super.message, super.code, this.statusCode});
}

class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Sin conexión a internet',
    super.code,
  });
}

class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});
}

class PermissionException extends AppException {
  final String permission;

  const PermissionException({
    required this.permission,
    required super.message,
    super.code,
  });
}

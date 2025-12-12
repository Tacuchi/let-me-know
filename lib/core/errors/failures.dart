import 'package:equatable/equatable.dart';

/// Clase base para representar fallos en la aplicación
/// Los fallos son errores esperados que manejamos de forma controlada
sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Fallo de servidor o API
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Error del servidor. Intenta de nuevo más tarde.',
    super.code,
  });
}

/// Fallo de caché o almacenamiento local
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error al acceder a los datos locales.',
    super.code,
  });
}

/// Fallo de red/conexión
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sin conexión a internet. Verifica tu conexión.',
    super.code,
  });
}

/// Fallo de validación
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Fallo de permisos
class PermissionFailure extends Failure {
  final String permission;

  const PermissionFailure({
    required this.permission,
    super.message = 'Permiso denegado.',
    super.code,
  });

  @override
  List<Object?> get props => [message, code, permission];
}

/// Fallo desconocido/inesperado
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'Ocurrió un error inesperado.',
    super.code,
  });
}

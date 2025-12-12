import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Error del servidor. Intenta de nuevo más tarde.',
    super.code,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error al acceder a los datos locales.',
    super.code,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sin conexión a internet. Verifica tu conexión.',
    super.code,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

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

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'Ocurrió un error inesperado.',
    super.code,
  });
}

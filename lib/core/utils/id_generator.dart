import 'package:uuid/uuid.dart';

/// Generador de IDs únicos
abstract final class IdGenerator {
  static const _uuid = Uuid();

  /// Genera un UUID v4
  static String generate() => _uuid.v4();

  /// Genera un ID corto (8 caracteres)
  static String generateShort() => _uuid.v4().substring(0, 8);
}

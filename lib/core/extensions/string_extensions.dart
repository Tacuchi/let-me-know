/// Extensiones para String que facilitan validaciones y transformaciones
extension StringExtensions on String {
  /// Capitaliza la primera letra
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitaliza cada palabra
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Verifica si el string está vacío o solo tiene espacios
  bool get isBlank => trim().isEmpty;

  /// Verifica si el string no está vacío ni tiene solo espacios
  bool get isNotBlank => !isBlank;

  /// Trunca el string a un máximo de caracteres con elipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Retorna null si el string está vacío o es solo espacios
  String? get nullIfBlank => isBlank ? null : this;
}

/// Extensiones para String nullable
extension NullableStringExtensions on String? {
  /// Verifica si es null o está vacío
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Verifica si es null, está vacío o solo tiene espacios
  bool get isNullOrBlank => this == null || this!.isBlank;

  /// Retorna el valor o un string por defecto
  String orDefault([String defaultValue = '']) => this ?? defaultValue;
}

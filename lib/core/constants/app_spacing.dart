/// Espaciado consistente — "Resonant Horizon"
/// Basado en múltiplos de 4px, con screenPadding 24 del diseño Figma
abstract final class AppSpacing {
  // Espaciado base
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Padding de pantalla (24px del diseño Figma)
  static const double screenPadding = 24.0;

  // Padding interno de cards (21px del diseño Figma)
  static const double cardPadding = 21.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 999.0;

  // Radius específico para cards de lista (12px del diseño)
  static const double radiusCard = 12.0;

  // Alturas de componentes
  static const double buttonHeight = 56.0;
  static const double buttonHeightSm = 44.0;
  static const double inputHeight = 56.0; // pill-shaped search bar
  static const double appBarHeight = 56.0;
  static const double navBarHeight = 64.0;
  static const double fabSize = 64.0;
  static const double fabSizeLg = 88.0;
  static const double fabSizeSm = 56.0; // FAB cuadrado de lista

  // Touch targets (accesibilidad)
  static const double touchTargetMin = 44.0;
  static const double touchTargetRecommended = 48.0;
}

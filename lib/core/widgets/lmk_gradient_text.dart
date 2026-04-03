import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Texto con gradiente usando ShaderMask.
///
/// Usa el gradiente primario del sistema de diseño por defecto.
///
/// Ejemplos:
/// ```dart
/// LmkGradientText('Avísame', style: AppTypography.appTitle.copyWith(fontSize: 32))
/// LmkGradientText('3', style: AppTypography.number, gradient: AppColors.primaryGradient)
/// ```
class LmkGradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient? gradient;
  final TextAlign? textAlign;

  const LmkGradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppColors.primaryGradient;

    return ShaderMask(
      shaderCallback: (bounds) => effectiveGradient.createShader(bounds),
      // blendMode srcIn preserva el alpha del texto (soporta transparencia)
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

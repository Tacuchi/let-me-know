import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Avatar circular con icono o inicial.
///
/// Soporta icono, texto (inicial), o imagen de fondo.
class LmkAvatar extends StatelessWidget {
  final double radius;
  final IconData? icon;
  final String? initial;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final ImageProvider? backgroundImage;

  const LmkAvatar({
    super.key,
    this.radius = 24,
    this.icon,
    this.initial,
    this.backgroundColor,
    this.foregroundColor,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final bgColor = backgroundColor ?? primaryColor.withValues(alpha: 0.15);
    final fgColor = foregroundColor ?? primaryColor;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      backgroundImage: backgroundImage,
      child: backgroundImage == null ? _buildContent(fgColor) : null,
    );
  }

  Widget? _buildContent(Color fgColor) {
    if (icon != null) {
      return Icon(icon, size: radius * 1.1, color: fgColor);
    }
    if (initial != null) {
      return Text(
        initial!.toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: fgColor,
        ),
      );
    }
    // Default: icono de persona
    return Icon(Icons.person_rounded, size: radius * 1.1, color: fgColor);
  }
}

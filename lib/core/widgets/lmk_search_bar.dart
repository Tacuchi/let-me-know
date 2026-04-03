import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Barra de búsqueda pill-shaped — fondo blanco, sombra sutil, icono de lupa
class LmkSearchBar extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const LmkSearchBar({
    super.key,
    this.hint = 'Buscar...',
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgTertiaryDark : AppColors.bgSecondary;

    return Container(
      height: AppSpacing.inputHeight,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.helper.copyWith(
            color: isDark ? AppColors.textHelperDark : AppColors.textHelper,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? AppColors.textHelperDark : AppColors.textHelper,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          filled: false,
        ),
      ),
    );
  }
}

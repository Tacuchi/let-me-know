import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Selector segmentado — estilo theme picker (Auto / Claro / Oscuro)
/// Item activo: fondo blanco con sombra. Inactivo: transparente
class LmkToggleGroup extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const LmkToggleGroup({
    super.key,
    required this.options,
    this.selectedIndex = 0,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? AppColors.bgTertiaryDark
        : AppColors.chipInactive;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final isSelected = i == selectedIndex;
          final textColor = isSelected
              ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
              : (isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF505256));

          return GestureDetector(
            onTap: () => onChanged?.call(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.bgSecondaryDark : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 4),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                options[i],
                style: AppTypography.chipLabel.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

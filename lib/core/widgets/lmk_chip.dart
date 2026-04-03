import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Chip de filtro individual — activo con gradiente, inactivo con gris
class LmkFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const LmkFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTypography.chipLabel.copyWith(
              color: AppColors.chipActiveText,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.chipInactiveAdaptive(
            isDark ? Brightness.dark : Brightness.light,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: AppTypography.chipLabel.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF505256),
          ),
        ),
      ),
    );
  }
}

/// Fila scrollable de chips de filtro
class LmkFilterChipGroup extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelectionChanged;

  const LmkFilterChipGroup({
    super.key,
    required this.labels,
    this.selectedIndex = 0,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (i) {
          return Padding(
            padding: EdgeInsets.only(
              right: i < labels.length - 1 ? AppSpacing.sm + 4 : 0,
            ),
            child: LmkFilterChip(
              label: labels[i],
              isSelected: i == selectedIndex,
              onTap: () => onSelectionChanged?.call(i),
            ),
          );
        }),
      ),
    );
  }
}

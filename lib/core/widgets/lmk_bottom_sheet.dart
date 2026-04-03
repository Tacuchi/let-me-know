import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';

/// Handle bar reutilizable para bottom sheets.
class LmkBottomSheetHandle extends StatelessWidget {
  const LmkBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Opción individual dentro de un bottom sheet.
class LmkBottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool isDestructive;

  const LmkBottomSheetOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final destructiveColor = AppColors.errorDeep;
    final effectiveColor = isDestructive
        ? destructiveColor
        : (iconColor ??
              (isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary));

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, color: effectiveColor, size: 22),
      ),
      title: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: isDestructive ? destructiveColor : textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.caption.copyWith(color: secondaryColor),
            )
          : null,
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context);
        onTap();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
  }
}

/// Helper para mostrar un bottom sheet con handle y opciones.
Future<T?> showLmkBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  bool isScrollControlled = false,
  bool useSafeArea = true,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: true,
    useSafeArea: useSafeArea,
    backgroundColor: bgColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LmkBottomSheetHandle(),
        child,
        SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.sm),
      ],
    ),
  );
}

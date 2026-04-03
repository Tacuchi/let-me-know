import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'lmk_badge.dart';

/// Header de sección — label uppercase + badge opcional
/// Ej: "SALUD" con badge "2 Activos"
class LmkSectionHeader extends StatelessWidget {
  final String title;
  final String? badgeLabel;
  final Color? badgeColor;

  const LmkSectionHeader({
    super.key,
    required this.title,
    this.badgeLabel,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(), style: AppTypography.sectionHeader),
          if (badgeLabel != null)
            LmkInfoBadge(label: badgeLabel!, color: badgeColor),
        ],
      ),
    );
  }
}

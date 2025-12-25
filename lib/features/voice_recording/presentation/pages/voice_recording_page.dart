import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../widgets/voice_command_mode.dart';
import '../widgets/voice_query_mode.dart';

class VoiceRecordingPage extends StatefulWidget {
  const VoiceRecordingPage({super.key});

  @override
  State<VoiceRecordingPage> createState() => _VoiceRecordingPageState();
}

class _VoiceRecordingPageState extends State<VoiceRecordingPage>
    with TickerProviderStateMixin {
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Colores del modo consulta (para transición del AppBar)
  static const _queryPrimary = Color(0xFF7C4DFF);
  static const _queryBg = Color(0xFFF3E5F5);
  static const _queryBgDark = Color(0xFF1A1A2E);

    super.initState();


    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isQueryMode = _currentPage == 1;

    // Colores que cambian según el modo
    final bgColor = isQueryMode
        ? (isDark ? _queryBgDark : _queryBg)
        : (isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary);
    final appBarBgColor = isQueryMode
        ? (isDark ? _queryBgDark : _queryBg)
        : (isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary);
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final accentColor = isQueryMode
        ? _queryPrimary
        : (isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cerrar',
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: Text(
          'Asistente de Voz',
          style: AppTypography.titleMedium.copyWith(color: textColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Ayuda',
            onPressed: () {
              HapticFeedback.lightImpact();
              _showHelpSheet(context, isDark, isQueryMode);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              _buildModeToggle(isDark, isQueryMode, accentColor, textColor),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isQueryMode
                      ? VoiceQueryMode(key: const ValueKey('query'), isActive: true)
                      : VoiceCommandMode(key: const ValueKey('command'), isActive: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle(
    bool isDark,
    bool isQueryMode,
    Color accentColor,
    Color textColor,
  ) {
    final unselectedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'Crear',
              icon: Icons.mic_rounded,
              isActive: !isQueryMode,
              activeColor: AppColors.accentPrimary,
              inactiveColor: unselectedColor,
              onTap: () => setState(() => _currentPage = 0),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'Consultar',
              icon: Icons.search_rounded,
              isActive: isQueryMode,
              activeColor: const Color(0xFF7C4DFF),
              inactiveColor: unselectedColor,
              onTap: () => setState(() => _currentPage = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : inactiveColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : inactiveColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSheet(BuildContext context, bool isDark, bool isQueryMode) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final primaryColor = isQueryMode
        ? _queryPrimary
        : (isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary);

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Icon(
                  isQueryMode
                      ? Icons.search_rounded
                      : Icons.tips_and_updates_rounded,
                  size: 48,
                  color: primaryColor,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isQueryMode ? 'Cómo consultar' : 'Consejos para grabar',
                  style: AppTypography.titleMedium.copyWith(color: textColor),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (isQueryMode) ...[
                  _buildTip(
                      '🔍', '"¿Dónde dejé mis llaves?"', isDark),
                  _buildTip(
                      '📋', '"¿Qué tengo pendiente para hoy?"', isDark),
                  _buildTip(
                      '⬇️', 'Desliza hacia abajo para crear', isDark),
                ] else ...[
                  _buildTip('🎤', 'Habla claro y a velocidad normal', isDark),
                  _buildTip(
                    '📅',
                    'Incluye la fecha y hora del recordatorio',
                    isDark,
                  ),
                  _buildTip(
                      '⬆️', 'Desliza hacia arriba para consultar', isDark),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTip(String emoji, String text, bool isDark) {
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

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
  late final PageController _pageController;
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Colores del modo consulta (para transición del AppBar)
  static const _queryPrimary = Color(0xFF7C4DFF);
  static const _queryBg = Color(0xFFF3E5F5);
  static const _queryBgDark = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

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
  void dispose() {
    _pageController.dispose();
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
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            key: ValueKey(isQueryMode),
            isQueryMode ? 'Consultar' : 'Crear',
            style: AppTypography.titleMedium.copyWith(color: textColor),
          ),
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
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: (page) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentPage = page);
                },
                children: [
                  VoiceCommandMode(isActive: _currentPage == 0),
                  VoiceQueryMode(isActive: _currentPage == 1),
                ],
              ),
              // Indicador de página
              Positioned(
                right: AppSpacing.md,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildPageIndicator(isDark, accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isDark, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIndicatorDot(0, isDark, accentColor),
        const SizedBox(height: AppSpacing.sm),
        _buildIndicatorDot(1, isDark, accentColor),
      ],
    );
  }

  Widget _buildIndicatorDot(int index, bool isDark, Color accentColor) {
    final isActive = _currentPage == index;
    final inactiveColor =
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
            .withValues(alpha: 0.3);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isActive ? 10 : 8,
        height: isActive ? 10 : 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? accentColor : inactiveColor,
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

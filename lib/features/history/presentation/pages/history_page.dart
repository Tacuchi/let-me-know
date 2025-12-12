import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/core.dart';
import '../../application/cubit/history_cubit.dart';
import '../../application/cubit/history_state.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/entities/reminder_type.dart';

/// Página de historial de recordatorios
/// Muestra los recordatorios completados y pasados
/// Diseño moderno con soporte para tema oscuro (2025)
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary;

    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(isDark),

                  // Estadísticas
                  _buildStats(isDark, state),

                  // Lista de historial
                  Expanded(child: _buildHistoryList(isDark, state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historial',
                style: AppTypography.titleLarge.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tus recordatorios completados',
                style: AppTypography.bodyMedium.copyWith(color: secondaryColor),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrar',
            color: secondaryColor,
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implementar filtros
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isDark, HistoryState state) {
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final secondaryColor = isDark
        ? AppColors.accentSecondaryDark
        : AppColors.accentSecondary;
    final dividerColor = isDark ? AppColors.dividerDark : AppColors.divider;

    final monthCount = state is HistoryLoaded ? state.completedThisMonth : 0;
    final totalCount = state is HistoryLoaded ? state.completedTotal : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            secondaryColor.withValues(alpha: isDark ? 0.2 : 0.15),
            AppColors.completed.withValues(alpha: isDark ? 0.15 : 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_outline,
              value: '$monthCount',
              label: 'Este mes',
              color: secondaryColor,
              isDark: isDark,
            ),
          ),
          Container(width: 1, height: 40, color: dividerColor),
          Expanded(
            child: _buildStatItem(
              icon: Icons.emoji_events_outlined,
              value: '$totalCount',
              label: 'Total',
              color: primaryColor,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    final labelColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Text(value, style: AppTypography.number.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTypography.label.copyWith(color: labelColor)),
      ],
    );
  }

  Widget _buildHistoryList(bool isDark, HistoryState state) {
    return switch (state) {
      HistoryLoading() => const Center(child: CircularProgressIndicator()),
      HistoryError(:final message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(message),
        ),
      ),
      HistoryLoaded(:final completed) =>
        completed.isEmpty
            ? _buildEmptyState(isDark)
            : _buildList(isDark, completed),
    };
  }

  Widget _buildList(bool isDark, List<Reminder> reminders) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.lg),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final r = reminders[index];
        final completedAt = r.completedAt ?? DateTime.now();
        return HistoryItem(
          title: r.title,
          subtitle: _formatCompletedAt(completedAt),
          emoji: r.type.emoji,
          completedAt: completedAt,
          isDark: isDark,
        );
      },
    );
  }

  String _formatCompletedAt(DateTime dt) {
    final formatter = DateFormat('d MMM yyyy, h:mm a', 'es_ES');
    return 'Completado: ${formatter.format(dt)}';
  }

  Widget _buildEmptyState(bool isDark) {
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final accentColor = isDark
        ? AppColors.accentSecondaryDark
        : AppColors.accentSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.2 : 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      size: 48,
                      color: accentColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Sin historial aún',
              style: AppTypography.titleSmall.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Cuando completes recordatorios,\naparecerán aquí',
              style: AppTypography.bodyMedium.copyWith(color: helperColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar un item de historial (para uso futuro)
class HistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final DateTime completedAt;
  final bool isDark;

  const HistoryItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.completedAt,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final accentColor = isDark
        ? AppColors.accentSecondaryDark
        : AppColors.accentSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji del tipo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.completed.withValues(alpha: isDark ? 0.3 : 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.helper.copyWith(
                    color: isDark
                        ? AppColors.textHelperDark
                        : AppColors.textHelper,
                  ),
                ),
              ],
            ),
          ),

          // Checkmark
          Icon(Icons.check_circle, color: accentColor, size: 24),
        ],
      ),
    );
  }
}

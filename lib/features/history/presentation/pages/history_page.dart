import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/core.dart';
import '../../application/cubit/history_cubit.dart';
import '../../application/cubit/history_state.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/entities/reminder_type.dart';

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
        final hasFilters = state is HistoryLoaded &&
            (state.periodFilter != HistoryPeriodFilter.all ||
                state.typeFilter != null);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(isDark, hasFilters),
                  _buildStats(isDark, state),
                  if (state is HistoryLoaded) _buildFilters(isDark, state),
                  Expanded(child: _buildHistoryList(isDark, state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, bool hasFilters) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

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
          if (hasFilters)
            TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<HistoryCubit>().clearFilters();
              },
              icon: Icon(Icons.clear_all_rounded, color: primaryColor, size: 20),
              label: Text(
                'Limpiar',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark, HistoryLoaded state) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;

    return Container(
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodFilters(isDark, state),
          const SizedBox(height: AppSpacing.sm),
          _buildTypeFilters(isDark, state),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildPeriodFilters(bool isDark, HistoryLoaded state) {
    final selectedColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final unselectedBg = isDark
        ? AppColors.bgTertiaryDark
        : AppColors.bgTertiary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: HistoryPeriodFilter.values.map((filter) {
          final isSelected = state.periodFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<HistoryCubit>().setPeriodFilter(filter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : unselectedBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: selectedColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeFilters(bool isDark, HistoryLoaded state) {
    final selectedColor = isDark
        ? AppColors.accentSecondaryDark
        : AppColors.accentSecondary;
    final unselectedBg = isDark
        ? AppColors.bgTertiaryDark
        : AppColors.bgTertiary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;

    final typesInHistory = state.all.map((r) => r.type).toSet().toList();
    if (typesInHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Text(
            'Por tipo',
            style: AppTypography.label.copyWith(color: helperColor),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Row(
            children: typesInHistory.map((type) {
              final isSelected = state.typeFilter == type;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (isSelected) {
                      context.read<HistoryCubit>().setTypeFilter(null);
                    } else {
                      context.read<HistoryCubit>().setTypeFilter(type);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? selectedColor : unselectedBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: selectedColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          type.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
      HistoryLoaded() => state.filtered.isEmpty
          ? _buildEmptyState(isDark, hasFilters: state.periodFilter != HistoryPeriodFilter.all || state.typeFilter != null)
          : _buildList(isDark, state.filtered),
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

  Widget _buildEmptyState(bool isDark, {bool hasFilters = false}) {
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final accentColor = isDark
        ? AppColors.accentSecondaryDark
        : AppColors.accentSecondary;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

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
                      hasFilters ? Icons.filter_alt_off_rounded : Icons.history_rounded,
                      size: 48,
                      color: accentColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              hasFilters ? 'Sin resultados' : 'Sin historial aún',
              style: AppTypography.titleSmall.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasFilters
                  ? 'No hay recordatorios que coincidan\ncon los filtros seleccionados'
                  : 'Cuando completes recordatorios,\naparecerán aquí',
              style: AppTypography.bodyMedium.copyWith(color: helperColor),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<HistoryCubit>().clearFilters();
                },
                icon: Icon(Icons.clear_all_rounded, color: primaryColor),
                label: Text(
                  'Limpiar filtros',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
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

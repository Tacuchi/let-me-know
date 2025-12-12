import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/core.dart';
import '../../application/cubit/reminder_list_cubit.dart';
import '../../application/cubit/reminder_list_state.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/reminder_status.dart';

/// Página de lista de recordatorios
/// Muestra todos los recordatorios con filtros y búsqueda
/// Diseño moderno con gestos y animaciones (2025)
class ReminderListPage extends StatefulWidget {
  const ReminderListPage({super.key});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage>
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
    final appBarBgColor = isDark
        ? AppColors.bgSecondaryDark
        : AppColors.bgSecondary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    return BlocBuilder<ReminderListCubit, ReminderListState>(
      builder: (context, state) {
        final filter = switch (state) {
          ReminderListLoaded(:final filter) => filter,
          _ => ReminderListFilter.all,
        };

        final filtered = state is ReminderListLoaded
            ? state.filtered
            : const <Reminder>[];

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: appBarBgColor,
            title: Text(
              'Mis Recordatorios',
              style: AppTypography.titleMedium.copyWith(color: textColor),
            ),
            actions: [
              if (kDebugMode) ...[
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'DEBUG: Refrescar',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<ReminderListCubit>().refresh();
                  },
                ),
              ],
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Buscar',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showSearchSheet(context, isDark);
                },
              ),
              IconButton(
                icon: const Icon(Icons.help_outline_rounded),
                tooltip: 'Ayuda',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // TODO: Implementar guía de ayuda
                },
              ),
            ],
          ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildFilters(isDark, filter),

                  if (filter == ReminderListFilter.today)
                    _buildDaySummary(isDark, state),

                  Expanded(
                    child: switch (state) {
                      ReminderListLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      ReminderListError(:final message) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(message),
                        ),
                      ),
                      ReminderListLoaded() =>
                        filtered.isEmpty
                            ? _buildEmptyState(isDark)
                            : _buildReminderList(isDark, filtered),
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters(bool isDark, ReminderListFilter selected) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final selectedColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final unselectedBg = isDark
        ? AppColors.bgTertiaryDark
        : AppColors.bgTertiary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        child: Row(
          children: ReminderListFilter.values
              .map((filter) {
                final isSelected = selected == filter;
                return Padding(
                  padding: EdgeInsets.only(
                    right: filter != ReminderListFilter.values.last
                        ? AppSpacing.sm
                        : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<ReminderListCubit>().setFilter(filter);
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
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
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
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }

  Widget _buildDaySummary(bool isDark, ReminderListState state) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final dateFormat = DateFormat('EEEE, d MMMM', 'es_ES');
    final today = dateFormat.format(DateTime.now());
    final capitalizedDate =
        today.substring(0, 1).toUpperCase() + today.substring(1);

    final todayItems = state is ReminderListLoaded
        ? state.filtered
        : const <Reminder>[];
    final pending = todayItems
        .where((r) => r.status == ReminderStatus.pending)
        .length;
    final overdue = todayItems
        .where((r) => r.status == ReminderStatus.overdue || r.isOverdue)
        .length;
    final completed = todayItems
        .where((r) => r.status == ReminderStatus.completed)
        .length;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_rounded,
                color: isDark
                    ? AppColors.accentPrimaryDark
                    : AppColors.accentPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                capitalizedDate,
                style: AppTypography.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AnimatedCounter(
                  value: pending,
                  label: 'Pendientes',
                  color: AppColors.pending,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AnimatedCounter(
                  value: overdue,
                  label: 'Vencidos',
                  color: AppColors.overdue,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AnimatedCounter(
                  value: completed,
                  label: 'Completados',
                  color: AppColors.completed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderList(bool isDark, List<Reminder> reminders) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ReminderCard(
            reminder: reminder,
            onTap: () {
              // TODO: Mostrar detalle
            },
            onComplete: () {
              HapticFeedback.mediumImpact();
              context.read<ReminderListCubit>().markAsCompleted(reminder.id);
            },
            onDelete: () {
              HapticFeedback.mediumImpact();
              context.read<ReminderListCubit>().delete(reminder.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono animado
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
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_rounded,
                      size: 56,
                      color: primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No tienes recordatorios',
              style: AppTypography.titleSmall.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Toca el micrófono para crear\ntu primer recordatorio',
              style: AppTypography.bodyMedium.copyWith(color: helperColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            // Hint visual
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_rounded, size: 20, color: helperColor),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Desliza para gestionar',
                  style: AppTypography.helper.copyWith(color: helperColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchSheet(BuildContext context, bool isDark) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final hintColor = isDark ? AppColors.textHelperDark : AppColors.textHelper;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
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
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Buscar recordatorio...',
                      hintStyle: TextStyle(color: hintColor),
                      prefixIcon: Icon(Icons.search_rounded, color: hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.bgTertiaryDark
                          : AppColors.bgTertiary,
                    ),
                    style: TextStyle(color: textColor),
                    onChanged: (value) {
                      // TODO: Implementar búsqueda
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Búsquedas recientes
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Búsquedas recientes',
                      style: AppTypography.label.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: ['pastillas', 'doctor', 'compras'].map((term) {
                      return ActionChip(
                        label: Text(term),
                        onPressed: () {
                          // TODO: Buscar término
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

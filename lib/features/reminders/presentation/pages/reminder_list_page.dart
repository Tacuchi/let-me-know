import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/services/feedback_service.dart';
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
  late final FeedbackService _feedbackService;

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
    _feedbackService = getIt<FeedbackService>();
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
                    _feedbackService.light();
                    context.read<ReminderListCubit>().refresh();
                  },
                ),
              ],
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Buscar',
                onPressed: () {
                  _feedbackService.light();
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
                            ? _buildEmptyState(isDark, filter: filter)
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

  Widget _buildFilters(bool isDark, ReminderListFilter currentFilter) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final selectedColor = isDark 
        ? AppColors.accentPrimaryDark 
        : AppColors.accentPrimary;
    final unselectedColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    // Filtros disponibles (excluye 'notes' porque tiene su propio tab)
    const filters = [
      ReminderListFilter.all,
      ReminderListFilter.pending,
      ReminderListFilter.today,
      ReminderListFilter.completed,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) {
                _feedbackService.light();
                context.read<ReminderListCubit>().setFilter(filter);
              },
              backgroundColor: bgColor,
              selectedColor: selectedColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected ? selectedColor : Colors.transparent,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
            ),
          );
        }).toList(),
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
              _feedbackService.light();
              context.push('/reminders/${reminder.id}');
            },
            onComplete: () {
              _feedbackService.success();
              context.read<ReminderListCubit>().markAsCompleted(reminder.id);
            },
            onDelete: () {
              _feedbackService.medium();
              context.read<ReminderListCubit>().delete(reminder.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark, {ReminderListFilter filter = ReminderListFilter.all}) {
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

    // Mensajes dinámicos según filtro
    final (title, subtitle, icon) = switch (filter) {
      ReminderListFilter.completed => (
        'Sin completados',
        'Cuando marques recordatorios\ncomo completados, aparecerán aquí',
        Icons.done_all_rounded,
      ),
      ReminderListFilter.pending => (
        'Sin pendientes',
        '¡Genial! No tienes recordatorios\npendientes por atender',
        Icons.check_circle_outline_rounded,
      ),
      ReminderListFilter.today => (
        'Sin recordatorios para hoy',
        'No tienes recordatorios\nprogramados para hoy',
        Icons.today_rounded,
      ),
      _ => (
        'No tienes recordatorios',
        'Toca el micrófono para crear\ntu primer recordatorio',
        Icons.inbox_rounded,
      ),
    };

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
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 56,
                      color: primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(color: helperColor),
              textAlign: TextAlign.center,
            ),
            if (filter == ReminderListFilter.all) ...[
              const SizedBox(height: AppSpacing.xl),
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
          ],
        ),
      ),
    );
  }

  void _showSearchSheet(BuildContext outerContext, bool isDark) {
    final cubit = outerContext.read<ReminderListCubit>();

    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: _SearchSheetContent(isDark: isDark),
        );
      },
    ).whenComplete(() {
      cubit.clearSearch();
    });
  }
}

class _SearchSheetContent extends StatefulWidget {
  final bool isDark;

  const _SearchSheetContent({required this.isDark});

  @override
  State<_SearchSheetContent> createState() => _SearchSheetContentState();
}

class _SearchSheetContentState extends State<_SearchSheetContent> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final hintColor = isDark ? AppColors.textHelperDark : AppColors.textHelper;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
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
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Buscar recordatorio...',
                        hintStyle: TextStyle(color: hintColor),
                        prefixIcon: Icon(Icons.search_rounded, color: hintColor),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: hintColor),
                                onPressed: () {
                                  _controller.clear();
                                  context.read<ReminderListCubit>().clearSearch();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary,
                      ),
                      style: TextStyle(color: textColor),
                      onChanged: (value) {
                        context.read<ReminderListCubit>().search(value);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<ReminderListCubit, ReminderListState>(
                  builder: (context, state) {
                    if (state is! ReminderListLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!state.isSearching) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Escribe para buscar',
                              style: AppTypography.label.copyWith(
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Icon(
                              Icons.search_rounded,
                              size: 64,
                              color: hintColor.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      );
                    }

                    final results = state.searchResults ?? [];

                    if (results.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: hintColor,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Sin resultados para "${state.searchQuery}"',
                              style: AppTypography.bodyMedium.copyWith(
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final reminder = results[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ReminderCard(
                            reminder: reminder,
                            showProgress: false,
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/reminders/${reminder.id}');
                            },
                            onComplete: () {
                              getIt<FeedbackService>().success();
                              context
                                  .read<ReminderListCubit>()
                                  .markAsCompleted(reminder.id);
                            },
                            onDelete: () {
                              getIt<FeedbackService>().medium();
                              context.read<ReminderListCubit>().delete(reminder.id);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

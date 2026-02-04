import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app.dart';
import '../../../../core/core.dart';
import '../../../../router/app_routes.dart';
import '../../../reminders/application/cubit/reminder_summary_cubit.dart';
import '../../../reminders/application/cubit/reminder_summary_state.dart';
import '../../../reminders/domain/entities/reminder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _currentTime = DateTime.now()),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = _currentTime.hour;
    if (hour < 12) return '¡Buenos días! ☀️';
    if (hour < 18) return '¡Buenas tardes! 🌤️';
    return '¡Buenas noches! 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.md,
                      AppSpacing.screenPadding,
                      0,
                    ),
                    child: _buildHeader(isDark),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                      AppSpacing.screenPadding,
                      0,
                    ),
                    child: _buildAnimatedClock(isDark),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.xl,
                      AppSpacing.screenPadding,
                      0,
                    ),
                    child: _buildGreeting(isDark),
                  ),
                ),
                // Banner de alertas inminentes (próximas 2 horas)
                SliverToBoxAdapter(
                  child: _buildImminentAlertsBanner(isDark),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.xl,
                      AppSpacing.screenPadding,
                      0,
                    ),
                    child: _buildUpcomingSection(isDark),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Mi Asistente',
          style: AppTypography.titleMedium.copyWith(color: textColor),
        ),
        Row(
          children: [
            _ThemeToggleButton(isDark: isDark),
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, size: 24),
              tooltip: 'Ayuda',
              color: secondaryColor,
              onPressed: () {
                HapticFeedback.lightImpact();
                _showHelpDialog(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedClock(bool isDark) {
    final timeFormat = DateFormat('h:mm', 'es_ES');
    final periodFormat = DateFormat('a', 'es_ES');
    final dateFormat = DateFormat('EEEE, d \'de\' MMMM', 'es_ES');

    final time = timeFormat.format(_currentTime);
    final period = periodFormat.format(_currentTime).toUpperCase();
    final date = dateFormat.format(_currentTime);
    final capitalizedDate =
        date.substring(0, 1).toUpperCase() + date.substring(1);

    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final secondaryColor = isDark
        ? AppColors.accentSecondaryDark
        : AppColors.accentSecondary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withValues(alpha: isDark ? 0.15 : 0.12),
                secondaryColor.withValues(alpha: isDark ? 0.1 : 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.95, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    key: ValueKey(_currentTime.minute),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w200,
                            color: textColor,
                            letterSpacing: -3,
                            height: 1,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    capitalizedDate,
                    style: AppTypography.bodyLarge.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(bool isDark) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting,
          style: AppTypography.titleLarge.copyWith(color: textColor),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Toca el micrófono para hablar conmigo',
          style: AppTypography.bodyMedium.copyWith(color: secondaryTextColor),
        ),
      ],
    );
  }

  /// Banner de alertas inminentes (próximas 2 horas).
  Widget _buildImminentAlertsBanner(bool isDark) {
    final hasProvider = context
            .findAncestorWidgetOfExactType<BlocProvider<ReminderSummaryCubit>>() !=
        null;

    if (!hasProvider) return const SizedBox.shrink();

    return BlocBuilder<ReminderSummaryCubit, ReminderSummaryState>(
      builder: (context, state) {
        if (state is! ReminderSummaryLoaded) return const SizedBox.shrink();
        if (state.imminentAlerts.isEmpty) return const SizedBox.shrink();

        final alerts = state.imminentAlerts;
        final warningColor = AppColors.warning;
        final textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.lg,
            AppSpacing.screenPadding,
            0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: warningColor.withValues(alpha: isDark ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: warningColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      size: 22,
                      color: warningColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        alerts.length == 1
                            ? '¡Tienes un recordatorio pronto!'
                            : '¡Tienes ${alerts.length} recordatorios pronto!',
                        style: AppTypography.bodyLarge.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...alerts.take(3).map((alert) {
                  final timeStr = _formatAlertTime(alert.scheduledAt!);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/reminders/${alert.id}');
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: warningColor,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              '${alert.title} • $timeStr',
                              style: AppTypography.bodyMedium.copyWith(
                                color: textColor.withValues(alpha: 0.85),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (alerts.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      'y ${alerts.length - 3} más...',
                      style: AppTypography.helper.copyWith(
                        color: warningColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatAlertTime(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);

    if (diff.inMinutes < 1) {
      return '¡Ahora!';
    } else if (diff.inMinutes < 60) {
      return 'en ${diff.inMinutes} min';
    } else {
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    }
  }

  Widget _buildUpcomingSection(bool isDark) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximos recordatorios',
              style: AppTypography.titleSmall.copyWith(color: textColor),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.goNamed(AppRoutes.remindersName);
              },
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildUpcomingList(isDark),
      ],
    );
  }

  Widget _buildUpcomingList(bool isDark) {
    final hasProvider = context
            .findAncestorWidgetOfExactType<BlocProvider<ReminderSummaryCubit>>() !=
        null;

    if (!hasProvider) {
      return _buildEmptyState(isDark);
    }

    return BlocBuilder<ReminderSummaryCubit, ReminderSummaryState>(
      builder: (context, state) {
        final upcoming =
            state is ReminderSummaryLoaded ? state.upcoming : <Reminder>[];

        if (upcoming.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return Column(
          children: upcoming.map((reminder) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ReminderCard(
                reminder: reminder,
                showProgress: false,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/reminders/${reminder.id}');
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.divider;
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 40,
                    color: primaryColor.withValues(alpha: 0.7),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No tienes recordatorios aún',
            style: AppTypography.bodyLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Toca el botón del micrófono para crear\ntu primer recordatorio',
            style: AppTypography.bodySmall.copyWith(color: helperColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '¿Cómo usar la app?',
                  style: AppTypography.titleMedium.copyWith(color: textColor),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildHelpItem(
                  icon: Icons.mic_rounded,
                  title: 'Crear recordatorio',
                  description:
                      'Toca el botón del micrófono y habla para crear un recordatorio.',
                  isDark: isDark,
                ),
                _buildHelpItem(
                  icon: Icons.touch_app_rounded,
                  title: 'Opciones',
                  description:
                      'Mantén presionado un recordatorio para ver las opciones: completar, editar o eliminar.',
                  isDark: isDark,
                ),
                _buildHelpItem(
                  icon: Icons.notifications_rounded,
                  title: 'Notificaciones',
                  description:
                      'Recibirás alertas cuando sea hora de tu recordatorio.',
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(color: helperColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatefulWidget {
  final bool isDark;

  const _ThemeToggleButton({required this.isDark});

  @override
  State<_ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<_ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_ThemeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDark != oldWidget.isDark) {
      if (widget.isDark) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = widget.isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return RotationTransition(
      turns: _rotationAnimation,
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(widget.isDark),
            size: 24,
          ),
        ),
        tooltip: widget.isDark ? 'Modo claro' : 'Modo oscuro',
        color: secondaryColor,
        onPressed: () {
          HapticFeedback.lightImpact();
          LetMeKnowApp.of(context).toggleTheme();
        },
      ),
    );
  }
}

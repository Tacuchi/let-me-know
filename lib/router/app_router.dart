import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/constants.dart';
import '../di/injection_container.dart';
import '../features/alarm/presentation/pages/alarm_screen_page.dart';
import '../features/history/application/cubit/history_cubit.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/reminders/application/cubit/reminder_detail_cubit.dart';
import '../features/reminders/presentation/pages/reminder_detail_page.dart';
import '../features/reminders/presentation/pages/reminder_list_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/voice_recording/presentation/pages/voice_recording_page.dart';
import 'app_routes.dart';

/// Configuración principal del router de la aplicación
/// Material Design 3 con transiciones fluidas (2025)
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    // Shell route para la navegación con bottom bar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Rama: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: AppRoutes.homeName,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // Rama: Recordatorios
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.reminders,
              name: AppRoutes.remindersName,
              builder: (context, state) => const ReminderListPage(),
            ),
          ],
        ),
        // Rama: Historial
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.history,
              name: AppRoutes.historyName,
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<HistoryCubit>()..start(),
                child: const HistoryPage(),
              ),
            ),
          ],
        ),
        // Rama: Configuración
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              name: AppRoutes.settingsName,
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    // Ruta: Detalle de recordatorio
    GoRoute(
      path: AppRoutes.reminderDetail,
      name: AppRoutes.reminderDetailName,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<ReminderDetailCubit>()..load(id),
          child: const ReminderDetailPage(),
        );
      },
    ),
    // Ruta: Pantalla de alarma fullscreen
    GoRoute(
      path: AppRoutes.alarm,
      name: AppRoutes.alarmName,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AlarmScreenPage(reminderId: id);
      },
    ),
    // Ruta modal: Grabación de voz con transición mejorada
    GoRoute(
      path: AppRoutes.record,
      name: AppRoutes.recordName,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const VoiceRecordingPage(),
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Transición combinada: slide + fade para efecto premium
          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              );

          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            ),
          );

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
      ),
    ),
  ],
);

/// Shell principal con bottom navigation bar y FAB central
/// Diseño Material 3 con animaciones fluidas (2025)
class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: widget.navigationShell,
      extendBody: true,
      floatingActionButton: _buildAnimatedFAB(context, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildModernBottomBar(context, isDark),
    );
  }

  Widget _buildAnimatedFAB(BuildContext context, bool isDark) {
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final gradientEnd = isDark
        ? const Color(0xFFE8956A)
        : const Color(0xFFD4784A);

    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _fabController.forward(),
        onTapUp: (_) {
          _fabController.reverse();
          HapticFeedback.mediumImpact();
          context.pushNamed(AppRoutes.recordName);
        },
        onTapCancel: () => _fabController.reverse(),
        child: Semantics(
          button: true,
          label: 'Crear nuevo recordatorio por voz',
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, gradientEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.mic_rounded, size: 32, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomBar(BuildContext context, bool isDark) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final shadowColor = isDark
        ? Colors.black54
        : Colors.black.withValues(alpha: 0.1);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              // Inicio
              Expanded(
                child: _NavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Inicio',
                  isSelected: widget.navigationShell.currentIndex == 0,
                  onTap: () => _navigateTo(0),
                  isDark: isDark,
                ),
              ),
              // Tareas
              Expanded(
                child: _NavItem(
                  index: 1,
                  icon: Icons.checklist_outlined,
                  selectedIcon: Icons.checklist_rounded,
                  label: 'Tareas',
                  isSelected: widget.navigationShell.currentIndex == 1,
                  onTap: () => _navigateTo(1),
                  isDark: isDark,
                ),
              ),
              // Espacio para el FAB
              const SizedBox(width: 80),
              // Historial
              Expanded(
                child: _NavItem(
                  index: 2,
                  icon: Icons.history_outlined,
                  selectedIcon: Icons.history_rounded,
                  label: 'Historial',
                  isSelected: widget.navigationShell.currentIndex == 2,
                  onTap: () => _navigateTo(2),
                  isDark: isDark,
                ),
              ),
              // Ajustes
              Expanded(
                child: _NavItem(
                  index: 3,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: 'Ajustes',
                  isSelected: widget.navigationShell.currentIndex == 3,
                  onTap: () => _navigateTo(3),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(int index) {
    HapticFeedback.selectionClick();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

/// Item de navegación con animaciones fluidas
class _NavItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final unselectedColor = widget.isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final indicatorColor = selectedColor.withValues(
      alpha: widget.isDark ? 0.2 : 0.12,
    );

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono con indicador
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isSelected ? 16 : 12,
                    vertical: widget.isSelected ? 4 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? indicatorColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.isSelected ? widget.selectedIcon : widget.icon,
                    color: widget.isSelected ? selectedColor : unselectedColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 2),
                // Label
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: widget.isSelected ? selectedColor : unselectedColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

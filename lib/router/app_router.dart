import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/constants.dart';
import '../di/injection_container.dart';
import '../features/alarm/presentation/pages/alarm_screen_page.dart';
import '../features/reminders/application/cubit/reminder_detail_cubit.dart';
import '../features/reminders/presentation/pages/reminder_detail_page.dart';
import '../features/reminders/presentation/pages/reminder_list_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/voice_recording/application/cubit/voice_chat_cubit.dart';
import '../features/voice_recording/presentation/pages/voice_recording_page.dart';
import 'app_routes.dart';

/// GlobalKey para el Scaffold del MainShell, permite abrir el drawer desde cualquier página.
final mainShellScaffoldKey = GlobalKey<ScaffoldState>();

/// Configuración principal del router de la aplicación
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    // Shell route para la navegación con drawer
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Rama 0: Chat (pantalla principal)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: AppRoutes.chatName,
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<VoiceChatCubit>(),
                child: const VoiceRecordingPage(),
              ),
            ),
          ],
        ),
        // Rama 1: Recordatorios
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.reminders,
              name: AppRoutes.remindersName,
              builder: (context, state) => const ReminderListPage(),
            ),
          ],
        ),
        // Rama 2: Configuración
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
  ],
);

/// Shell principal con drawer lateral
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: mainShellScaffoldKey,
      drawer: _AppDrawer(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
      body: navigationShell,
    );
  }
}

/// Drawer lateral de la aplicación
class _AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const _AppDrawer({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryColor.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.account_circle_rounded,
                      size: 32,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Let Me Know',
                    style: AppTypography.titleMedium.copyWith(color: textColor),
                  ),
                ],
              ),
            ),
            Divider(
              color: isDark ? AppColors.dividerDark : AppColors.divider,
              height: 1,
            ),
            const SizedBox(height: AppSpacing.sm),
            // Opciones de navegación
            _DrawerItem(
              icon: Icons.chat_bubble_outline_rounded,
              selectedIcon: Icons.chat_bubble_rounded,
              label: 'Chat',
              isSelected: currentIndex == 0,
              primaryColor: primaryColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
              onTap: () => _selectDestination(context, 0),
            ),
            _DrawerItem(
              icon: Icons.checklist_outlined,
              selectedIcon: Icons.checklist_rounded,
              label: 'Recordatorios',
              isSelected: currentIndex == 1,
              primaryColor: primaryColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
              onTap: () => _selectDestination(context, 1),
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings_rounded,
              label: 'Ajustes',
              isSelected: currentIndex == 2,
              primaryColor: primaryColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
              onTap: () => _selectDestination(context, 2),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDestination(BuildContext context, int index) {
    HapticFeedback.selectionClick();
    Navigator.pop(context); // Cerrar drawer
    onDestinationSelected(index);
  }
}

/// Item individual del drawer
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.primaryColor,
    required this.textColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? primaryColor : secondaryColor,
        ),
        title: Text(
          label,
          style: AppTypography.bodyLarge.copyWith(
            color: isSelected ? primaryColor : textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        selected: isSelected,
        selectedTileColor: primaryColor.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app.dart';
import '../../../../core/core.dart';

/// Página de configuración
/// Permite ajustar preferencias de accesibilidad, notificaciones y más
/// Diseño moderno con soporte para tema oscuro (2025)
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  // Estados de configuración
  bool _voiceGuides = true;
  bool _vibration = true;
  bool _repeatAlert = true;
  bool _improveTranscription = true;
  int _textSizeIndex = 1; // 0: Normal, 1: Grande, 2: Muy grande

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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        title: Text(
          'Configuración',
          style: AppTypography.titleMedium.copyWith(color: textColor),
        ),
        actions: [
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
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              // Sección: Apariencia (nueva)
              _buildSection(
                context: context,
                title: 'Apariencia',
                icon: Icons.palette_outlined,
                isDark: isDark,
                children: [
                  _buildThemeTile(context, isDark),
                  _buildTextSizeTile(context, isDark),
                ],
              ),

              // Sección: Accesibilidad
              _buildSection(
                context: context,
                title: 'Accesibilidad',
                icon: Icons.accessibility_new_rounded,
                isDark: isDark,
                children: [
                  _buildSwitchTile(
                    context: context,
                    title: 'Guías de voz',
                    subtitle: 'Narrar instrucciones y confirmaciones',
                    value: _voiceGuides,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _voiceGuides = value);
                      _showSavedFeedback(context);
                    },
                    isDark: isDark,
                    icon: Icons.record_voice_over_rounded,
                  ),
                  _buildSwitchTile(
                    context: context,
                    title: 'Vibración',
                    subtitle: 'Feedback háptico en acciones',
                    value: _vibration,
                    onChanged: (value) {
                      if (value) HapticFeedback.mediumImpact();
                      setState(() => _vibration = value);
                      _showSavedFeedback(context);
                    },
                    isDark: isDark,
                    icon: Icons.vibration_rounded,
                  ),
                ],
              ),

              // Sección: Notificaciones
              _buildSection(
                context: context,
                title: 'Notificaciones',
                icon: Icons.notifications_outlined,
                isDark: isDark,
                children: [
                  _buildNavigationTile(
                    context: context,
                    title: 'Sonido de alerta',
                    subtitle: 'Campana suave',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showSoundPicker(context, isDark);
                    },
                    isDark: isDark,
                    icon: Icons.music_note_rounded,
                  ),
                  _buildSwitchTile(
                    context: context,
                    title: 'Repetir alerta',
                    subtitle: 'Si no confirmo el recordatorio',
                    value: _repeatAlert,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _repeatAlert = value);
                      _showSavedFeedback(context);
                    },
                    isDark: isDark,
                    icon: Icons.repeat_rounded,
                  ),
                  _buildNavigationTile(
                    context: context,
                    title: 'Horario silencioso',
                    subtitle: '10:00 PM - 7:00 AM',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: Implementar selector de horario
                    },
                    isDark: isDark,
                    icon: Icons.nights_stay_rounded,
                  ),
                ],
              ),

              // Sección: Voz y Transcripción
              _buildSection(
                context: context,
                title: 'Voz y Transcripción',
                icon: Icons.mic_outlined,
                isDark: isDark,
                children: [
                  _buildNavigationTile(
                    context: context,
                    title: 'Idioma de reconocimiento',
                    subtitle: 'Español (México)',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: Implementar selector de idioma
                    },
                    isDark: isDark,
                    icon: Icons.language_rounded,
                  ),
                  _buildSwitchTile(
                    context: context,
                    title: 'Mejorar transcripción',
                    subtitle: 'Usar IA para corregir errores',
                    value: _improveTranscription,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _improveTranscription = value);
                      _showSavedFeedback(context);
                    },
                    isDark: isDark,
                    icon: Icons.auto_fix_high_rounded,
                  ),
                ],
              ),

              // Sección: Acerca de
              _buildSection(
                context: context,
                title: 'Acerca de',
                icon: Icons.info_outline_rounded,
                isDark: isDark,
                children: [
                  _buildInfoTile(
                    context: context,
                    title: 'Versión',
                    subtitle: '1.0.0 (Build 1)',
                    isDark: isDark,
                    icon: Icons.verified_rounded,
                  ),
                  _buildNavigationTile(
                    context: context,
                    title: 'Tutorial',
                    subtitle: 'Ver guía de uso',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: Implementar tutorial
                    },
                    isDark: isDark,
                    icon: Icons.school_rounded,
                  ),
                  _buildNavigationTile(
                    context: context,
                    title: 'Soporte',
                    subtitle: 'Contactar ayuda',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: Implementar soporte
                    },
                    isDark: isDark,
                    icon: Icons.support_agent_rounded,
                  ),
                ],
              ),

              // Espacio para el bottom nav
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final cardColor = isDark
        ? AppColors.bgSecondaryDark
        : AppColors.bgSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: primaryColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.label.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              final isLast = index == children.length - 1;

              return Column(
                children: [
                  child,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildThemeTile(BuildContext context, bool isDark) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

    final currentThemeMode = LetMeKnowApp.of(context).themeMode;

    String themeName;
    switch (currentThemeMode) {
      case ThemeMode.light:
        themeName = 'Claro';
        break;
      case ThemeMode.dark:
        themeName = 'Oscuro';
        break;
      case ThemeMode.system:
        themeName = 'Automático';
        break;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: primaryColor,
          size: 22,
        ),
      ),
      title: Text(
        'Tema',
        style: AppTypography.bodyLarge.copyWith(color: textColor),
      ),
      subtitle: Text(
        themeName,
        style: AppTypography.helper.copyWith(color: helperColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            icon: Icons.light_mode_rounded,
            isSelected: currentThemeMode == ThemeMode.light,
            onTap: () {
              LetMeKnowApp.of(context).setThemeMode(ThemeMode.light);
            },
            isDark: isDark,
            tooltip: 'Tema claro',
          ),
          const SizedBox(width: AppSpacing.xs),
          _buildThemeOption(
            icon: Icons.phone_android_rounded,
            isSelected: currentThemeMode == ThemeMode.system,
            onTap: () {
              LetMeKnowApp.of(context).setThemeMode(ThemeMode.system);
            },
            isDark: isDark,
            tooltip: 'Automático',
          ),
          const SizedBox(width: AppSpacing.xs),
          _buildThemeOption(
            icon: Icons.dark_mode_rounded,
            isSelected: currentThemeMode == ThemeMode.dark,
            onTap: () {
              LetMeKnowApp.of(context).setThemeMode(ThemeMode.dark);
            },
            isDark: isDark,
            tooltip: 'Tema oscuro',
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    String? tooltip,
  }) {
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final unselectedColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;

    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : unselectedColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? primaryColor : unselectedColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTextSizeTile(BuildContext context, bool isDark) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final sizes = ['Normal', 'Grande', 'Muy grande'];

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.format_size_rounded, color: primaryColor, size: 22),
      ),
      title: Text(
        'Tamaño de texto',
        style: AppTypography.bodyLarge.copyWith(color: textColor),
      ),
      subtitle: Text(
        sizes[_textSizeIndex],
        style: AppTypography.helper.copyWith(color: helperColor),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: helperColor),
      onTap: () {
        HapticFeedback.lightImpact();
        _showTextSizePicker(context, isDark);
      },
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required bool isDark,
    required IconData icon,
  }) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.helper.copyWith(color: helperColor),
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: primaryColor,
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required bool isDark,
    required IconData icon,
  }) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.helper.copyWith(color: helperColor),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: helperColor),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isDark,
    required IconData icon,
  }) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.helper.copyWith(color: helperColor),
      ),
    );
  }

  void _showSavedFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: AppSpacing.sm),
            Text('Cambios guardados'),
          ],
        ),
        backgroundColor: AppColors.accentSecondary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
    );
  }

  void _showSoundPicker(BuildContext context, bool isDark) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

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
                Text(
                  'Sonido de alerta',
                  style: AppTypography.titleMedium.copyWith(color: textColor),
                ),
                const SizedBox(height: AppSpacing.md),
                ...[
                  'Campana suave',
                  'Melodía amable',
                  'Tono clásico',
                  'Sin sonido',
                ].map((sound) {
                  final isSelected = sound == 'Campana suave';
                  return ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? primaryColor
                          : (isDark
                                ? AppColors.textHelperDark
                                : AppColors.textHelper),
                    ),
                    title: Text(
                      sound,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    trailing: sound != 'Sin sonido'
                        ? IconButton(
                            icon: Icon(
                              Icons.play_circle_filled_rounded,
                              color: primaryColor,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              // TODO: Reproducir sonido
                            },
                          )
                        : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTextSizePicker(BuildContext context, bool isDark) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final sizes = ['Normal', 'Grande', 'Muy grande'];

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
                Text(
                  'Tamaño de texto',
                  style: AppTypography.titleMedium.copyWith(color: textColor),
                ),
                const SizedBox(height: AppSpacing.md),
                ...sizes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final size = entry.value;
                  final isSelected = index == _textSizeIndex;
                  final fontSize = 16.0 + (index * 2);

                  return ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? primaryColor
                          : (isDark
                                ? AppColors.textHelperDark
                                : AppColors.textHelper),
                    ),
                    title: Text(
                      size,
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _textSizeIndex = index);
                      Navigator.pop(context);
                      _showSavedFeedback(context);
                    },
                  );
                }),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app.dart';
import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../../services/tts/tts_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  bool _voiceGuides = true;
  bool _vibration = true;
  bool _repeatAlert = true;
  bool _improveTranscription = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // TTS settings
  late final TtsService _ttsService;
  List<TtsVoice> _availableVoices = [];
  TtsVoice? _selectedVoice;
  double _speechRate = 0.45;

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

    _ttsService = getIt<TtsService>();
    _loadTtsSettings();
  }

  Future<void> _loadTtsSettings() async {
    await _ttsService.initialize();
    final voices = await _ttsService.getAvailableVoices();
    if (mounted) {
      setState(() {
        _availableVoices = voices;
        _selectedVoice = _ttsService.currentVoice;
        _speechRate = _ttsService.currentSpeechRate;
      });
    }
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
                    title: 'Voz de respuesta',
                    subtitle: _selectedVoice?.displayName ?? 'Por defecto',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showVoicePicker(context, isDark);
                    },
                    isDark: isDark,
                    icon: Icons.record_voice_over_rounded,
                  ),
                  _buildSpeechRateTile(context, isDark),
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
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

    final currentThemeMode = LetMeKnowApp.of(context).themeMode;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
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
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Tema',
                  style: AppTypography.bodyLarge.copyWith(color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  label: 'Claro',
                  icon: Icons.light_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.light,
                  onTap: () => LetMeKnowApp.of(context).setThemeMode(ThemeMode.light),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildThemeOption(
                  label: 'Auto',
                  icon: Icons.phone_android_rounded,
                  isSelected: currentThemeMode == ThemeMode.system,
                  onTap: () => LetMeKnowApp.of(context).setThemeMode(ThemeMode.system),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildThemeOption(
                  label: 'Oscuro',
                  icon: Icons.dark_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  onTap: () => LetMeKnowApp.of(context).setThemeMode(ThemeMode.dark),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final unselectedColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : unselectedColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? primaryColor : unselectedColor,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? primaryColor : textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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

    final currentTextSize = LetMeKnowApp.of(context).textSize;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showTextSizePicker(context, isDark);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.format_size_rounded, color: primaryColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tamaño de texto',
                    style: AppTypography.bodyLarge.copyWith(color: textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentTextSize.label,
                    style: AppTypography.helper.copyWith(color: helperColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right_rounded, color: helperColor, size: 24),
          ],
        ),
      ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
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
                  style: AppTypography.bodyLarge.copyWith(color: textColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.helper.copyWith(color: helperColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            children: [
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: primaryColor,
              ),
              Text(
                value ? 'Activado' : 'Desactivado',
                style: TextStyle(
                  fontSize: 10,
                  color: value ? primaryColor : helperColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
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
                    style: AppTypography.bodyLarge.copyWith(color: textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.helper.copyWith(color: helperColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right_rounded, color: helperColor, size: 24),
          ],
        ),
      ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
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
                  style: AppTypography.bodyLarge.copyWith(color: textColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.helper.copyWith(color: helperColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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

  void _showTextSizePicker(BuildContext outerContext, bool isDark) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;

    final currentTextSize = LetMeKnowApp.of(outerContext).textSize;

    showModalBottomSheet(
      context: outerContext,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
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
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'El cambio se aplica a toda la app',
                      style: AppTypography.helper.copyWith(color: helperColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: TextSizeOption.values.length,
                        itemBuilder: (context, index) {
                          final option = TextSizeOption.values[index];
                          final isSelected = option == currentTextSize;
                          const baseFontSize = 16.0;
                          final previewFontSize = baseFontSize * option.scaleFactor;

                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : helperColor.withValues(alpha: 0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                LetMeKnowApp.of(outerContext).setTextSize(option);
                                Navigator.pop(context);
                                _showSavedFeedback(outerContext);
                              },
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.circle_outlined,
                                      color: isSelected ? primaryColor : helperColor,
                                      size: 28,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            option.label,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: previewFontSize,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Texto de ejemplo',
                                            style: TextStyle(
                                              color: helperColor,
                                              fontSize: previewFontSize * 0.85,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSpeechRateTile(BuildContext context, bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final helperColor = isDark ? AppColors.textHelperDark : AppColors.textHelper;
    final primaryColor = isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;

    String speedLabel;
    if (_speechRate <= 0.3) {
      speedLabel = 'Muy lenta';
    } else if (_speechRate <= 0.45) {
      speedLabel = 'Lenta';
    } else if (_speechRate <= 0.55) {
      speedLabel = 'Normal';
    } else if (_speechRate <= 0.7) {
      speedLabel = 'Rápida';
    } else {
      speedLabel = 'Muy rápida';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.speed_rounded, color: primaryColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Velocidad de voz',
                      style: AppTypography.bodyLarge.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      speedLabel,
                      style: AppTypography.helper.copyWith(color: helperColor),
                    ),
                  ],
                ),
              ),
              // Botón de prueba
              IconButton(
                icon: Icon(Icons.play_circle_outline_rounded, color: primaryColor),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _ttsService.speak('Así suena mi voz con esta velocidad');
                },
                tooltip: 'Probar voz',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.slow_motion_video_rounded, size: 16, color: helperColor),
              Expanded(
                child: Slider(
                  value: _speechRate,
                  min: 0.2,
                  max: 0.8,
                  divisions: 6,
                  activeColor: primaryColor,
                  inactiveColor: helperColor.withValues(alpha: 0.3),
                  onChanged: (value) {
                    setState(() => _speechRate = value);
                  },
                  onChangeEnd: (value) {
                    HapticFeedback.selectionClick();
                    _ttsService.setSpeechRate(value).then((_) {
                      if (mounted) _showSavedFeedback(context);
                    });
                  },
                ),
              ),
              Icon(Icons.directions_run_rounded, size: 16, color: helperColor),
            ],
          ),
        ],
      ),
    );
  }

  void _showVoicePicker(BuildContext context, bool isDark) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final helperColor = isDark ? AppColors.textHelperDark : AppColors.textHelper;
    final primaryColor = isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;

    if (_availableVoices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No hay voces disponibles en español'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
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
                    Text(
                      'Voz de respuesta',
                      style: AppTypography.titleMedium.copyWith(color: textColor),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Toca una voz para escucharla',
                      style: AppTypography.helper.copyWith(color: helperColor),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _availableVoices.length,
                        itemBuilder: (context, index) {
                          final voice = _availableVoices[index];
                          final isSelected = voice == _selectedVoice;

                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : helperColor.withValues(alpha: 0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () async {
                                HapticFeedback.selectionClick();
                                await _ttsService.setVoice(voice);
                                setState(() => _selectedVoice = voice);
                                // Reproducir muestra
                                await _ttsService.speak('Hola, esta es mi voz');
                              },
                              onLongPress: () async {
                                // Seleccionar y cerrar
                                HapticFeedback.mediumImpact();
                                await _ttsService.setVoice(voice);
                                setState(() => _selectedVoice = voice);
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  _showSavedFeedback(context);
                                }
                              },
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.circle_outlined,
                                      color: isSelected ? primaryColor : helperColor,
                                      size: 28,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            voice.displayName,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 16,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            voice.locale,
                                            style: TextStyle(
                                              color: helperColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.play_circle_outline_rounded,
                                      color: primaryColor,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Mantén presionado para confirmar',
                      style: AppTypography.helper.copyWith(
                        color: helperColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

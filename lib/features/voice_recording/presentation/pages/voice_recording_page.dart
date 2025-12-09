import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';

/// Página de grabación de voz
/// Permite grabar audio y transcribirlo para crear recordatorios
/// Diseño premium con animaciones fluidas (2025)
class VoiceRecordingPage extends StatefulWidget {
  const VoiceRecordingPage({super.key});

  @override
  State<VoiceRecordingPage> createState() => _VoiceRecordingPageState();
}

class _VoiceRecordingPageState extends State<VoiceRecordingPage>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _transcription;

  // Animaciones
  late AnimationController _fadeController;
  late AnimationController _transcriptionController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _transcriptionFadeAnimation;
  late Animation<Offset> _transcriptionSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Animación de entrada
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Animación de transcripción
    _transcriptionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _transcriptionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transcriptionController, curve: Curves.easeOut),
    );
    _transcriptionSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _transcriptionController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _transcriptionController.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cerrar',
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: Text(
          'Nuevo Recordatorio',
          style: AppTypography.titleMedium.copyWith(color: textColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Ayuda',
            onPressed: () {
              HapticFeedback.lightImpact();
              _showHelpSheet(context, isDark);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _transcription != null
              ? _buildWithTranscription(isDark)
              : _buildRecordingView(isDark),
        ),
      ),
    );
  }

  /// Vista principal de grabación - botón centrado verticalmente
  Widget _buildRecordingView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          // Área central expandida para centrar el contenido
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Instrucción animada
                  _buildInstruction(isDark),
                  const SizedBox(height: AppSpacing.xl),

                  // Botón de micrófono mejorado - centrado
                  AnimatedMicButton(
                    isRecording: _isRecording,
                    onTap: _toggleRecording,
                    size: 100,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Texto de estado
                  _buildStatusText(isDark),

                  // Indicador de procesamiento
                  if (_isProcessing) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _buildProcessingIndicator(isDark),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vista con transcripción - scroll para contenido largo
  Widget _buildWithTranscription(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Instrucción compacta
          _buildInstruction(isDark),
          const SizedBox(height: AppSpacing.lg),

          // Botón de micrófono más pequeño
          AnimatedMicButton(
            isRecording: _isRecording,
            onTap: _toggleRecording,
            size: 80,
          ),
          const SizedBox(height: AppSpacing.md),

          // Texto de estado
          _buildStatusText(isDark),
          const SizedBox(height: AppSpacing.xl),

          // Área de transcripción
          SlideTransition(
            position: _transcriptionSlideAnimation,
            child: FadeTransition(
              opacity: _transcriptionFadeAnimation,
              child: _buildTranscriptionArea(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Botones de acción
          _buildActionButtons(isDark),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildInstruction(bool isDark) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: Column(
        key: ValueKey(
          _isRecording
              ? 'recording'
              : _isProcessing
              ? 'processing'
              : 'idle',
        ),
        children: [
          Text(
            _isRecording
                ? 'Escuchando...'
                : _isProcessing
                ? 'Procesando...'
                : 'Toca el micrófono para grabar',
            style: AppTypography.titleSmall.copyWith(color: textColor),
            textAlign: TextAlign.center,
          ),
          if (!_isRecording && !_isProcessing && _transcription == null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Di tu recordatorio en voz alta',
              style: AppTypography.bodyMedium.copyWith(color: secondaryColor),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusText(bool isDark) {
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        key: ValueKey(_isRecording),
        _isRecording ? 'Toca para detener' : 'Toca para hablar',
        style: AppTypography.helper.copyWith(
          color: _isRecording ? primaryColor : helperColor,
          fontWeight: _isRecording ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator(bool isDark) {
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            backgroundColor: primaryColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(primaryColor),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Transcribiendo audio...',
          style: AppTypography.helper.copyWith(
            color: isDark ? AppColors.textHelperDark : AppColors.textHelper,
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptionArea(bool isDark) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final borderColor = isDark ? AppColors.outlineDark : AppColors.divider;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final labelColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final secondaryColor = isDark
        ? AppColors.accentSecondaryDark
        : AppColors.accentSecondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tu recordatorio',
                    style: AppTypography.label.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      '✓ Listo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Transcripción
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '"$_transcription"',
                  style: AppTypography.bodyLarge.copyWith(
                    color: textColor,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Botón editar
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // TODO: Implementar edición
                  },
                  icon: Icon(Icons.edit_rounded, size: 18, color: primaryColor),
                  label: Text('Editar', style: TextStyle(color: primaryColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // Botón principal - Confirmar
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // TODO: Implementar confirmación
              _showSuccessAndClose();
            },
            icon: const Icon(Icons.check_rounded, size: 22),
            label: const Text('Confirmar recordatorio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.accentSecondaryDark
                  : AppColors.accentSecondary,
              elevation: 3,
              shadowColor:
                  (isDark
                          ? AppColors.accentSecondaryDark
                          : AppColors.accentSecondary)
                      .withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Botón secundario - Volver a grabar
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeightSm,
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _transcription = null;
              });
              _transcriptionController.reset();
            },
            icon: const Icon(Icons.mic_rounded, size: 20),
            label: const Text('Volver a grabar'),
          ),
        ),
      ],
    );
  }

  void _toggleRecording() {
    HapticFeedback.mediumImpact();

    setState(() {
      _isRecording = !_isRecording;

      // Simular procesamiento y transcripción
      if (!_isRecording && _transcription == null) {
        _isProcessing = true;

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _transcription =
                  'Recordarme tomar las pastillas mañana a las 8 de la mañana';
            });
            _transcriptionController.forward();
          }
        });
      }
    });
  }

  void _showSuccessAndClose() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: AppSpacing.sm),
            Text('¡Recordatorio creado!'),
          ],
        ),
        backgroundColor: AppColors.accentSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.pop();
    });
  }

  void _showHelpSheet(BuildContext context, bool isDark) {
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
                Icon(
                  Icons.tips_and_updates_rounded,
                  size: 48,
                  color: primaryColor,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Consejos para grabar',
                  style: AppTypography.titleMedium.copyWith(color: textColor),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildTip('🎤', 'Habla claro y a velocidad normal', isDark),
                _buildTip(
                  '📅',
                  'Incluye la fecha y hora del recordatorio',
                  isDark,
                ),
                _buildTip('🔇', 'Busca un lugar silencioso', isDark),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTip(String emoji, String text, bool isDark) {
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

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

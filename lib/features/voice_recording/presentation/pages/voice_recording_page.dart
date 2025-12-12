import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/entities/reminder_importance.dart';
import '../../../reminders/domain/entities/reminder_source.dart';
import '../../../reminders/domain/entities/reminder_status.dart';
import '../../../reminders/domain/entities/reminder_type.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';
import '../../../../services/speech_to_text/speech_to_text_service.dart';

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
  String? _error;
  bool _isInitialized = false;
  
  late final SpeechToTextService _speechService;

  // Animaciones
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

    _fadeController.forward();
    
    // Inicializar servicio de voz
    _speechService = getIt<SpeechToTextService>();
    _initializeSpeech();
  }
  
  Future<void> _initializeSpeech() async {
    try {
      final available = await _speechService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = available;
          if (!available) {
            _error = 'Reconocimiento de voz no disponible en este dispositivo';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _error = 'Error al inicializar: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _speechService.stopListening();
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
          child: _buildMainView(isDark),
        ),
      ),
    );
  }
  
  /// Determinar qué vista mostrar basado en el estado
  Widget _buildMainView(bool isDark) {
    // Si hay transcripción final (grabación terminó), mostrar vista de confirmación
    if (_transcription != null && _transcription!.isNotEmpty && !_isRecording) {
      return _buildConfirmationView(isDark);
    }
    // Vista principal de grabación (con transcripción en tiempo real si está grabando)
    return _buildRecordingView(isDark);
  }

  /// Vista principal de grabación con transcripción en tiempo real
  Widget _buildRecordingView(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final primaryColor = isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          
          // Header con estado
          _buildStateHeader(isDark),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Área de transcripción en tiempo real (visible mientras graba)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isRecording || (_transcription != null && _transcription!.isNotEmpty)
                  ? _buildLiveTranscriptionArea(isDark)
                  : _buildIdlePrompt(isDark),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Botón de micrófono
          AnimatedMicButton(
            isRecording: _isRecording,
            onTap: _toggleRecording,
            size: 88,
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Texto de acción
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              key: ValueKey(_isRecording ? 'stop' : 'start'),
              _isRecording ? 'Toca para finalizar' : 'Toca para hablar',
              style: AppTypography.helper.copyWith(
                color: _isRecording ? primaryColor : secondaryColor,
                fontWeight: _isRecording ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
  
  /// Header que muestra el estado actual
  Widget _buildStateHeader(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final recordingColor = AppColors.recording;
    
    String title;
    IconData icon;
    Color iconColor;
    
    if (_isRecording) {
      title = 'Escuchando...';
      icon = Icons.graphic_eq_rounded;
      iconColor = recordingColor;
    } else if (_transcription != null && _transcription!.isNotEmpty) {
      title = 'Revisando texto';
      icon = Icons.edit_note_rounded;
      iconColor = isDark ? AppColors.accentSecondaryDark : AppColors.accentSecondary;
    } else {
      title = 'Nuevo recordatorio';
      icon = Icons.mic_none_rounded;
      iconColor = isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
    }
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.2),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Row(
        key: ValueKey(title),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
  
  /// Prompt cuando está idle (no grabando)
  Widget _buildIdlePrompt(bool isDark) {
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.record_voice_over_rounded,
            size: 64,
            color: secondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Di tu recordatorio en voz alta',
            style: AppTypography.bodyLarge.copyWith(color: secondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Por ejemplo: "Recordarme tomar mis pastillas a las 3 PM"',
            style: AppTypography.bodySmall.copyWith(
              color: secondaryColor.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// Área de transcripción en tiempo real
  Widget _buildLiveTranscriptionArea(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final borderColor = _isRecording 
        ? AppColors.recording.withValues(alpha: 0.5)
        : (isDark ? AppColors.outlineDark : AppColors.divider);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: borderColor,
          width: _isRecording ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador de estado
          Row(
            children: [
              if (_isRecording) ...[
                _buildPulsingDot(),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Transcribiendo...',
                  style: AppTypography.label.copyWith(
                    color: AppColors.recording,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.format_quote_rounded,
                  size: 18,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Tu recordatorio',
                  style: AppTypography.label.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Texto transcrito
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: AppTypography.bodyLarge.copyWith(
                  color: textColor,
                  height: 1.6,
                ),
                child: Text(
                  _transcription?.isNotEmpty == true 
                      ? _transcription! 
                      : (_isRecording ? 'Esperando tu voz...' : ''),
                  style: TextStyle(
                    fontStyle: _transcription?.isEmpty ?? true 
                        ? FontStyle.italic 
                        : FontStyle.normal,
                    color: _transcription?.isEmpty ?? true
                        ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
                        : textColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Punto pulsante para indicar grabación activa
  Widget _buildPulsingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.recording.withValues(alpha: value),
          ),
        );
      },
      onEnd: () {
        if (_isRecording && mounted) {
          setState(() {}); // Trigger rebuild to restart animation
        }
      },
    );
  }

  /// Vista de confirmación cuando la grabación terminó
  Widget _buildConfirmationView(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final successColor = isDark ? AppColors.accentSecondaryDark : AppColors.accentSecondary;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          
          // Icono de éxito
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: successColor.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 36,
              color: successColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Título
          Text(
            '¡Listo!',
            style: AppTypography.titleMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Revisa tu recordatorio',
            style: AppTypography.bodyMedium.copyWith(color: secondaryColor),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Tarjeta con el texto transcrito
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.divider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 20,
                      color: secondaryColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Tu recordatorio',
                      style: AppTypography.label.copyWith(color: secondaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _transcription ?? '',
                  style: AppTypography.bodyLarge.copyWith(
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Botones de acción
          _buildConfirmationButtons(isDark),
          
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
  
  /// Botones de acción para confirmación
  Widget _buildConfirmationButtons(bool isDark) {
    final primaryColor = isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    
    return Column(
      children: [
        // Botón principal de confirmar
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _showSuccessAndClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.check_rounded, size: 22),
            label: const Text(
              'Guardar recordatorio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Botón secundario para re-grabar
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _transcription = null;
                _error = null;
              });

            },
            style: OutlinedButton.styleFrom(
              foregroundColor: secondaryColor,
              side: BorderSide(color: secondaryColor.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            icon: const Icon(Icons.mic_rounded, size: 20),
            label: const Text(
              'Volver a grabar',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
      ],
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

            },
            icon: const Icon(Icons.mic_rounded, size: 20),
            label: const Text('Volver a grabar'),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleRecording() async {
    HapticFeedback.mediumImpact();
    
    // Verificar que el servicio esté inicializado
    if (!_isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error ?? 'Inicializando reconocimiento de voz...'),
            backgroundColor: const Color(0xFFE6A23C),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      // Intentar inicializar de nuevo
      await _initializeSpeech();
      return;
    }
    
    if (_isRecording) {
      // Detener grabación
      await _speechService.stopListening();
      setState(() {
        _isRecording = false;
        if (_transcription != null && _transcription!.isNotEmpty) {

        }
      });
    } else {
      // Iniciar grabación
      setState(() {
        _isRecording = true;
        _transcription = null;
        _error = null;
      });

      
      try {
        await _speechService.startListening(
          onResult: (text, isFinal) {
            if (mounted) {
              setState(() {
                _transcription = text;
              });
              if (isFinal && text.isNotEmpty) {
                setState(() {
                  _isRecording = false;
                });

              }
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _isRecording = false;
                _error = error;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $error'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          localeId: 'es_MX',
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _isRecording = false;
            _error = e.toString();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al iniciar: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _showSuccessAndClose() async {
    final repository = getIt<ReminderRepository>();
    
    final reminder = Reminder(
      id: const Uuid().v4(),
      title: 'Tomar pastillas',
      description: _transcription ?? '',
      scheduledAt: DateTime.now().add(const Duration(hours: 12)),
      type: ReminderType.medication,
      status: ReminderStatus.pending,
      importance: ReminderImportance.high,
      source: ReminderSource.voice,
      createdAt: DateTime.now(),
    );
    
    await repository.save(reminder);

    if (!mounted) return;
    
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

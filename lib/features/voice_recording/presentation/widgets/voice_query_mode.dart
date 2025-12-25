import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../../services/speech_to_text/speech_to_text_service.dart';
import '../../../../services/query/query_service.dart';

class VoiceQueryMode extends StatefulWidget {
  final bool isActive;

  const VoiceQueryMode({
    super.key,
    required this.isActive,
  });

  @override
  State<VoiceQueryMode> createState() => _VoiceQueryModeState();
}

class _VoiceQueryModeState extends State<VoiceQueryMode> {
  bool _isRecording = false;
  String? _transcription;
  String? _error;
  bool _isInitialized = false;
  bool _isProcessing = false;
  QueryResult? _queryResult;
  List<Reminder> _upcomingAlerts = [];
  bool _alertsLoaded = false;

  late final SpeechToTextService _speechService;
  late final QueryService _queryService;

  // Colores distintivos para modo consulta (violeta/morado)
  static const _queryPrimary = Color(0xFF7C4DFF);
  static const _queryPrimaryDark = Color(0xFFB388FF);
  static const _queryBg = Color(0xFFF3E5F5);
  static const _queryBgDark = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _speechService = getIt<SpeechToTextService>();
    _queryService = getIt<QueryService>();
    _initializeSpeech();
  }

  @override
  void didUpdateWidget(VoiceQueryMode oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cargar alertas cuando el modo se activa
    if (widget.isActive && !oldWidget.isActive && !_alertsLoaded) {
      _loadUpcomingAlerts();
    }
  }

  Future<void> _loadUpcomingAlerts() async {
    try {
      final alerts = await _queryService.getUpcomingAlerts();
      if (mounted) {
        setState(() {
          _upcomingAlerts = alerts;
          _alertsLoaded = true;
        });
      }
    } catch (_) {
      // Ignorar errores de carga de alertas
    }
  }

  Future<void> _initializeSpeech() async {
    try {
      final available = await _speechService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = available;
          if (!available) {
            _error = 'Reconocimiento de voz no disponible';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _queryBgDark : _queryBg;

    return Container(
      color: bgColor,
      child: _buildContent(isDark),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_queryResult != null) {
      return _buildResultView(isDark);
    }
    if (_isProcessing) {
      return _buildProcessingView(isDark);
    }
    return _buildRecordingView(isDark);
  }

  Widget _buildRecordingView(bool isDark) {
    final primaryColor = isDark ? _queryPrimaryDark : _queryPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          _buildSwipeHint(isDark, isUp: false),
          const SizedBox(height: AppSpacing.md),
          _buildModeHeader(isDark),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isRecording
                  ? _buildLiveTranscriptionArea(isDark)
                  : _buildIdlePrompt(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildQueryMicButton(isDark),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _isRecording ? 'Toca para finalizar' : 'Toca para preguntar',
            style: AppTypography.helper.copyWith(
              color: _isRecording ? primaryColor : secondaryColor,
              fontWeight: _isRecording ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSwipeHint(bool isDark, {required bool isUp}) {
    final hintColor =
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
            .withValues(alpha: 0.6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUp
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          color: hintColor,
          size: 20,
        ),
        Text(
          isUp ? 'Desliza para consultar' : 'Desliza para crear',
          style: AppTypography.helper.copyWith(
            color: hintColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildModeHeader(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final primaryColor = isDark ? _queryPrimaryDark : _queryPrimary;

    String title;
    IconData icon;

    if (_isRecording) {
      title = 'Escuchando...';
      icon = Icons.graphic_eq_rounded;
    } else {
      title = 'Hacer consulta';
      icon = Icons.search_rounded;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(color: textColor),
        ),
      ],
    );
  }

  Widget _buildIdlePrompt(bool isDark) {
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final primaryColor = isDark ? _queryPrimaryDark : _queryPrimary;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner de alertas próximas
          if (_upcomingAlerts.isNotEmpty) ...[
            _buildUpcomingAlertsBanner(isDark),
            const SizedBox(height: AppSpacing.xl),
          ],
          // Prompt principal
          Icon(
            Icons.help_outline_rounded,
            size: 64,
            color: primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Haz una pregunta',
            style: AppTypography.bodyLarge.copyWith(color: secondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '¿Dónde dejé mis llaves?\n¿Qué tengo pendiente?',
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

  Widget _buildUpcomingAlertsBanner(bool isDark) {
    final warningColor = AppColors.warning;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final count = _upcomingAlerts.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: warningColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_rounded,
                  size: 20, color: warningColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  count == 1
                      ? 'Tienes 1 recordatorio próximo'
                      : 'Tienes $count recordatorios próximos',
                  style: AppTypography.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._upcomingAlerts.take(3).map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: warningColor),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${alert.title} • ${_formatTime(alert.scheduledAt)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: textColor.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          if (_upcomingAlerts.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'y ${_upcomingAlerts.length - 3} más...',
                style: AppTypography.helper.copyWith(
                  color: warningColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLiveTranscriptionArea(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : Colors.white;
    final primaryColor = isDark ? _queryPrimaryDark : _queryPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPulsingDot(),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Escuchando tu pregunta...',
                style: AppTypography.label.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _transcription?.isNotEmpty == true
                    ? _transcription!
                    : 'Esperando tu voz...',
                style: AppTypography.bodyLarge.copyWith(
                  color: _transcription?.isEmpty ?? true
                      ? (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)
                      : textColor,
                  fontStyle: _transcription?.isEmpty ?? true
                      ? FontStyle.italic
                      : FontStyle.normal,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot() {
    final primaryColor = _queryPrimary;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withValues(alpha: value),
          ),
        );
      },
      onEnd: () {
        if (_isRecording && mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildQueryMicButton(bool isDark) {
    final primaryColor = isDark ? _queryPrimaryDark : _queryPrimary;

    return GestureDetector(
      onTap: widget.isActive ? _toggleRecording : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isRecording
              ? primaryColor
              : primaryColor.withValues(alpha: 0.15),
          border: Border.all(
            color: primaryColor,
            width: _isRecording ? 3 : 2,
          ),
          boxShadow: _isRecording
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          _isRecording ? Icons.stop_rounded : Icons.search_rounded,
          size: 40,
          color: _isRecording ? Colors.white : primaryColor,
        ),
      ),
    );
  }

  Widget _buildProcessingView(bool isDark) {
    final primaryColor = isDark ? _queryPrimaryDark : _queryPrimary;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(primaryColor),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Buscando...',
            style: AppTypography.titleSmall.copyWith(color: textColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _transcription ?? '',
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(bool isDark) {
    final result = _queryResult!;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final primaryColor = isDark ? _queryPrimaryDark : _queryPrimary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          // Icono de respuesta
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.15),
            ),
            child: Icon(
              _getResultIcon(result.type),
              size: 36,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Respuesta principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 18, color: primaryColor),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Respuesta',
                      style: AppTypography.label.copyWith(color: primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  result.response,
                  style: AppTypography.bodyLarge.copyWith(
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Items relacionados
          if (result.hasRelatedItems) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildRelatedItems(result.relatedItems!, isDark),
          ],

          // Alertas próximas
          if (result.hasUpcomingAlerts) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildUpcomingAlerts(result.upcomingAlerts!, isDark),
          ],

          const SizedBox(height: AppSpacing.xl),

          // Botones de acción
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _resetQuery,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.search_rounded, size: 22),
              label: const Text(
                'Nueva consulta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cerrar',
              style: TextStyle(color: secondaryColor, fontSize: 15),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildRelatedItems(List<Reminder> items, bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt_rounded, size: 18, color: secondaryColor),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Encontrado',
              style: AppTypography.label.copyWith(color: secondaryColor),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.map((item) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : AppColors.divider,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.location != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: 14, color: AppColors.reminderLocation),
                        const SizedBox(width: 4),
                        Text(
                          item.location!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.reminderLocation,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildUpcomingAlerts(List<Reminder> alerts, bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final warningColor = AppColors.warning;
    final bgColor = warningColor.withValues(alpha: 0.1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: warningColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_rounded,
                  size: 18, color: warningColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Próximos recordatorios',
                style: AppTypography.label.copyWith(
                  color: warningColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...alerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: warningColor),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${alert.title} - ${_formatTime(alert.scheduledAt)}',
                        style: AppTypography.bodySmall.copyWith(color: textColor),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  IconData _getResultIcon(QueryType type) {
    switch (type) {
      case QueryType.locationQuery:
        return Icons.place_rounded;
      case QueryType.reminderQuery:
        return Icons.event_note_rounded;
      case QueryType.scheduleQuery:
        return Icons.schedule_rounded;
      case QueryType.notAQuery:
        return Icons.info_outline_rounded;
      case QueryType.notUnderstood:
        return Icons.help_outline_rounded;
    }
  }

  void _resetQuery() {
    HapticFeedback.lightImpact();
    setState(() {
      _transcription = null;
      _queryResult = null;
      _isProcessing = false;
    });
  }

  Future<void> _toggleRecording() async {
    HapticFeedback.mediumImpact();

    if (!_isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error ?? 'Reconocimiento de voz no disponible'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (_isRecording) {
      await _speechService.stopListening();
      setState(() => _isRecording = false);
      _processQuery();
    } else {
      setState(() {
        _isRecording = true;
        _transcription = '';
        _queryResult = null;
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
                setState(() => _isRecording = false);
                _processQuery();
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
        }
      }
    }
  }

  Future<void> _processQuery() async {
    if (_transcription == null || _transcription!.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _queryService.processQuery(_transcription!);
      if (mounted) {
        setState(() {
          _queryResult = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _queryResult = QueryResult(
            type: QueryType.notUnderstood,
            response: 'Ocurrió un error al procesar tu consulta. Intenta de nuevo.',
          );
        });
      }
    }
  }
}

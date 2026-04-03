import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../router/app_router.dart';
import '../../application/cubit/voice_chat_cubit.dart';
import '../../application/cubit/voice_chat_state.dart';
import '../widgets/voice_chat_view.dart';

/// Página de asistente de voz unificada (pantalla principal).
/// Permite crear recordatorios, notas, consultar y más con un solo flujo.
class VoiceRecordingPage extends StatefulWidget {
  const VoiceRecordingPage({super.key});

  @override
  State<VoiceRecordingPage> createState() => _VoiceRecordingPageState();
}

class _VoiceRecordingPageState extends State<VoiceRecordingPage> {
  late final FeedbackService _feedbackService;

  @override
  void initState() {
    super.initState();
    _feedbackService = getIt<FeedbackService>();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary;
    final appBarBgColor =
        isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        leading: IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          tooltip: 'Menú',
          onPressed: () {
            _feedbackService.light();
            mainShellScaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Habla conmigo',
          style: AppTypography.titleMedium.copyWith(color: textColor),
        ),
        centerTitle: true,
        actions: [
          BlocSelector<VoiceChatCubit, VoiceChatState,
              ({bool show, bool hasPending})>(
            selector: (state) => (
              show: state is VoiceChatReady && state.hasMessages,
              hasPending: state is VoiceChatReady && state.hasPendingItems,
            ),
            builder: (context, data) {
              if (!data.show) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit_note_rounded),
                tooltip: 'Nuevo chat',
                onPressed: () {
                  _feedbackService.light();
                  _showNewChatDialog(context, isDark, data.hasPending);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Ayuda',
            onPressed: () {
              _feedbackService.light();
              _showHelpSheet(context, isDark);
            },
          ),
        ],
      ),
      body: const SafeArea(
        child: VoiceChatView(),
      ),
    );
  }

  void _showNewChatDialog(
    BuildContext context,
    bool isDark,
    bool hasPending,
  ) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: bgColor,
          title: Text(
            'Nueva conversación',
            style: AppTypography.titleSmall.copyWith(color: textColor),
          ),
          content: Text(
            hasPending
                ? 'Tienes recordatorios pendientes que no se han guardado. '
                    '¿Deseas descartarlos e iniciar una nueva conversación?'
                : '¿Iniciar una nueva conversación?',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<VoiceChatCubit>().reset();
              },
              style: hasPending
                  ? TextButton.styleFrom(foregroundColor: AppColors.error)
                  : null,
              child: Text(hasPending ? 'Descartar e iniciar' : 'Iniciar'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpSheet(BuildContext context, bool isDark) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;

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
                  '¿Qué puedo hacer?',
                  style: AppTypography.titleMedium.copyWith(color: textColor),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildTip(
                  '🔔',
                  'Crear recordatorios: "Recordarme tomar pastillas a las 3pm"',
                  isDark,
                ),
                _buildTip(
                  '📝',
                  'Guardar notas: "Dejé las llaves en la cocina"',
                  isDark,
                ),
                _buildTip(
                  '🔍',
                  'Consultar: "¿Dónde dejé mis llaves?"',
                  isDark,
                ),
                _buildTip(
                  '✅',
                  'Completar: "Marca como hecho tomar pastillas"',
                  isDark,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTip(String emoji, String text, bool isDark) {
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

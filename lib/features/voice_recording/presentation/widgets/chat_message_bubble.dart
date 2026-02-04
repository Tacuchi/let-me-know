import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/models/chat_message.dart';

/// Burbuja de mensaje en el chat de voz.
///
/// Muestra mensajes del usuario (derecha) y del sistema (izquierda)
/// con estilos diferenciados. Los mensajes del sistema reproducen TTS al tocar.
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onTapSystemMessage;
  final VoidCallback? onRetry;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onTapSystemMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return switch (message.type) {
      ChatMessageType.userMessage || ChatMessageType.userVoice => 
          _buildUserBubble(context),
      ChatMessageType.systemResponse => _buildSystemBubble(context),
      ChatMessageType.systemError => _buildErrorBubble(context),
      ChatMessageType.systemAction => _buildActionBubble(context),
    };
  }

  Widget _buildUserBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(
          left: AppSpacing.xl,
          bottom: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              message.isVoice ? Icons.mic_rounded : Icons.edit_rounded,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                message.text ?? '',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTapSystemMessage != null
            ? () {
                HapticFeedback.selectionClick();
                onTapSystemMessage!();
              }
            : null,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: const EdgeInsets.only(
            right: AppSpacing.xl,
            bottom: AppSpacing.sm,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.divider,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    size: 16,
                    color: secondaryColor,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      message.text ?? '',
                      style: AppTypography.bodyMedium.copyWith(
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              // Indicador de "toca para escuchar"
              if (onTapSystemMessage != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.volume_up_outlined,
                      size: 12,
                      color: secondaryColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Toca para escuchar',
                      style: AppTypography.helper.copyWith(
                        color: secondaryColor.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canRetry = onRetry != null && message.originalTranscription != null;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.only(
          right: AppSpacing.lg,
          bottom: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 16, color: AppColors.error),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                message.errorText ?? 'Error desconocido',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                  height: 1.4,
                ),
              ),
            ),
            if (canRetry) ...[
              const SizedBox(width: AppSpacing.sm),
              _RetryButton(onTap: onRetry!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary)
              .withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 14, color: AppColors.completed),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                message.text ?? '',
                style: AppTypography.bodySmall.copyWith(
                  color: secondaryColor,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón compacto de reintentar para mensajes de error.
class _RetryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RetryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.refresh_rounded,
                size: 14,
                color: AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                'Reintentar',
                style: AppTypography.helper.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/constants.dart';
import '../../application/cubit/voice_chat_state.dart';

/// Barra inferior del chat tipo WhatsApp.
/// TextField + botón mic/enviar + botón Finalizar (cuando hay pendientes).
class VoiceChatBottomBar extends StatefulWidget {
  final VoiceChatPhase phase;
  final int pendingCount;
  final VoidCallback onMicTap;
  final VoidCallback onFinalize;
  final ValueChanged<String> onSendText;

  const VoiceChatBottomBar({
    super.key,
    required this.phase,
    required this.pendingCount,
    required this.onMicTap,
    required this.onFinalize,
    required this.onSendText,
  });

  @override
  State<VoiceChatBottomBar> createState() => _VoiceChatBottomBarState();
}

class _VoiceChatBottomBarState extends State<VoiceChatBottomBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSendText(text);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final inputBgColor = isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final hintColor = isDark ? AppColors.textHelperDark : AppColors.textHelper;
    final primaryColor = isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;

    final hasPending = widget.pendingCount > 0;
    final isProcessing = widget.phase == VoiceChatPhase.processing;
    final isRecording = widget.phase == VoiceChatPhase.recording;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fila principal: TextField + botón mic/enviar
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // TextField expandible
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: inputBgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? primaryColor.withValues(alpha: 0.5)
                              : (isDark ? AppColors.outlineDark : AppColors.outline),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              enabled: !isProcessing && !isRecording,
                              maxLines: 4,
                              minLines: 1,
                              textCapitalization: TextCapitalization.sentences,
                              style: AppTypography.bodyMedium.copyWith(
                                color: textColor,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Escribe un mensaje...',
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: hintColor,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm + 2,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),

                  // Botón mic o enviar
                  _buildActionButton(
                    isDark: isDark,
                    primaryColor: primaryColor,
                    isProcessing: isProcessing,
                    isRecording: isRecording,
                  ),
                ],
              ),

              // Botón Finalizar (solo si hay pendientes)
              if (hasPending) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : widget.onFinalize,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentSecondary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.accentSecondary.withValues(alpha: 0.3),
                      disabledForegroundColor:
                          Colors.white.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text(
                      'Finalizar (${widget.pendingCount})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required bool isDark,
    required Color primaryColor,
    required bool isProcessing,
    required bool isRecording,
  }) {
    // Si hay texto, mostrar botón enviar
    if (_hasText) {
      return Material(
        color: primaryColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: isProcessing ? null : _sendMessage,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      );
    }

    // Sin texto: mostrar botón mic
    return Material(
      color: isRecording ? AppColors.recording : primaryColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: isProcessing ? null : () {
          HapticFeedback.mediumImpact();
          widget.onMicTap();
        },
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            isRecording ? Icons.stop_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

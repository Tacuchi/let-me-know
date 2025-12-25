import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';

class AnimatedMicButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback? onTap;
  final double size;

  const AnimatedMicButton({
    super.key,
    required this.isRecording,
    this.onTap,
    this.size = 88,
  });

  @override
  State<AnimatedMicButton> createState() => _AnimatedMicButtonState();
}

class _AnimatedMicButtonState extends State<AnimatedMicButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _scaleController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    if (widget.isRecording) _startRecordingAnimation();
  }

  @override
  void didUpdateWidget(AnimatedMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _startRecordingAnimation();
      } else {
        _stopRecordingAnimation();
      }
    }
  }

  void _startRecordingAnimation() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  void _stopRecordingAnimation() {
    _pulseController.stop();
    _pulseController.animateTo(0);
    _waveController.stop();
    _waveController.reset();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    HapticFeedback.mediumImpact();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final recordingColor = AppColors.recording;

    return Semantics(
      button: true,
      label: widget.isRecording
          ? 'Detener grabación. Toca dos veces para detener'
          : 'Iniciar grabación. Toca dos veces para grabar',
      child: SizedBox(
        width: widget.size + 60,
        height: widget.size + 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isRecording) ..._buildWaves(recordingColor),
            if (widget.isRecording)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: widget.size * _pulseAnimation.value,
                    height: widget.size * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: recordingColor.withValues(alpha: 0.3),
                        width: 3,
                      ),
                  ),
                );
              },
            ),
            ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: _handleTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isRecording
                          ? [
                              recordingColor,
                              recordingColor.withValues(alpha: 0.8),
                            ]
                          : [
                              primaryColor,
                              primaryColor.withValues(alpha: 0.85),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (widget.isRecording ? recordingColor : primaryColor)
                                .withValues(alpha: 0.4),
                        blurRadius: widget.isRecording ? 24 : 16,
                        offset: const Offset(0, 6),
                        spreadRadius: widget.isRecording ? 2 : 0,
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      widget.isRecording
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      key: ValueKey(widget.isRecording),
                      color: Colors.white,
                      size: widget.size * 0.45,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWaves(Color color) {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          final delay = index * 0.33;
          final progress = (_waveController.value + delay) % 1.0;
          final scale = 1.0 + progress * 0.8;
          final opacity = (1.0 - progress).clamp(0.0, 0.4);

          return Container(
            width: widget.size * scale,
            height: widget.size * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: opacity),
                width: 2,
              ),
            ),
          );
        },
      );
    });
  }
}

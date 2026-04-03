import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Indicador visual de onda sonora para el estado de escucha/grabación.
///
/// Muestra barras verticales animadas que forman una onda,
/// similar a un ecualizador de audio.
class SoundWaveIndicator extends StatefulWidget {
  final Color? color;
  final int barCount;
  final double width;
  final double height;

  const SoundWaveIndicator({
    super.key,
    this.color,
    this.barCount = 30,
    this.width = 200,
    this.height = 64,
  });

  @override
  State<SoundWaveIndicator> createState() => _SoundWaveIndicatorState();
}

class _SoundWaveIndicatorState extends State<SoundWaveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.color ??
        (isDark ? AppColors.accentPrimaryDark : AppColors.recording);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _SoundWavePainter(
            progress: _controller.value,
            color: color,
            barCount: widget.barCount,
          ),
        );
      },
    );
  }
}

class _SoundWavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int barCount;

  _SoundWavePainter({
    required this.progress,
    required this.color,
    required this.barCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totalBarSpace = size.width / barCount;
    final barWidth = totalBarSpace * 0.55;
    final gap = totalBarSpace * 0.45;
    final maxHeight = size.height;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final normalizedX = i / (barCount - 1);

      // Envolvente: barras más altas en el centro, más cortas en los bordes
      final envelope = math.sin(normalizedX * math.pi);

      // Onda animada con dos frecuencias para más organicidad
      final wave1 = math.sin(2 * math.pi * (progress * 2 - normalizedX * 1.8));
      final wave2 =
          math.sin(2 * math.pi * (progress * 1.3 - normalizedX * 2.5));
      final wave = (wave1 + wave2 * 0.4) / 1.4;

      // Altura final: envolvente da la forma, onda anima
      final heightFactor =
          (0.15 + 0.85 * envelope) * (0.35 + 0.65 * wave.abs());
      final barHeight = math.max(3.0, maxHeight * heightFactor);

      final x = i * (barWidth + gap);
      final top = centerY - barHeight / 2;

      final paint = Paint()
        ..color = color.withValues(alpha: 0.4 + 0.6 * envelope)
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barWidth, barHeight),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_SoundWavePainter oldDelegate) =>
      progress != oldDelegate.progress;
}

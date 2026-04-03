import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Indicador visual de "pensando" para el estado de procesamiento LLM.
///
/// Muestra un punto central con anillos concéntricos y un arco orbitando,
/// transmitiendo la idea de que el sistema está procesando la solicitud.
class ThinkingIndicator extends StatefulWidget {
  final double size;
  final Color? color;

  const ThinkingIndicator({
    super.key,
    this.size = 48,
    this.color,
  });

  @override
  State<ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
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
          size: Size(widget.size, widget.size),
          painter: _ThinkingPainter(
            progress: _controller.value,
            color: color,
          ),
        );
      },
    );
  }
}

class _ThinkingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ThinkingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Punto central con leve pulsación
    final pulseScale = 1.0 + 0.15 * math.sin(2 * math.pi * progress * 2);
    final dotRadius = radius * 0.18 * pulseScale;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, dotRadius, dotPaint);

    // Anillo interior
    final innerRingPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.45, innerRingPaint);

    // Anillo exterior
    final outerRingPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.82, outerRingPaint);

    // Arco orbitando en el anillo exterior
    final outerOrbitAngle = 2 * math.pi * progress;
    final outerArcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.82),
      outerOrbitAngle,
      math.pi * 0.35,
      false,
      outerArcPaint,
    );

    // Punto orbitando en el anillo interior (dirección opuesta)
    final innerOrbitAngle = -2 * math.pi * progress * 1.4;
    final innerOrbitRadius = radius * 0.45;
    final innerDotCenter = Offset(
      center.dx + innerOrbitRadius * math.cos(innerOrbitAngle),
      center.dy + innerOrbitRadius * math.sin(innerOrbitAngle),
    );
    final innerDotPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(innerDotCenter, 2.5, innerDotPaint);
  }

  @override
  bool shouldRepaint(_ThinkingPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

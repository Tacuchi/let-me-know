import 'package:flutter/material.dart';

/// Contenedor con animación de pulso (escala + opacidad del fondo).
///
/// Usado en alarmas activas, estados de grabación, y cualquier UI
/// que necesite llamar la atención del usuario con movimiento suave.
///
/// Ejemplos:
/// ```dart
/// LmkPulseContainer(
///   color: AppColors.error,
///   child: Icon(Icons.alarm_on_rounded, size: 32, color: AppColors.error),
/// )
/// LmkPulseContainer(
///   color: AppColors.accentPrimary,
///   minScale: 1.0,
///   maxScale: 1.08,
///   child: MyRecordingWidget(),
/// )
/// ```
class LmkPulseContainer extends StatefulWidget {
  final Widget child;

  /// Color base para el fondo animado. Si es null no anima el fondo.
  final Color? color;

  final double minScale;
  final double maxScale;
  final Duration duration;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const LmkPulseContainer({
    super.key,
    required this.child,
    this.color,
    this.minScale = 1.0,
    this.maxScale = 1.05,
    this.duration = const Duration(milliseconds: 800),
    this.padding,
    this.borderRadius,
  });

  @override
  State<LmkPulseContainer> createState() => _LmkPulseContainerState();
}

class _LmkPulseContainerState extends State<LmkPulseContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _scaleAnim = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnim = ColorTween(
      begin: widget.color?.withValues(alpha: 0.12),
      end: widget.color?.withValues(alpha: 0.24),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            padding: widget.padding,
            decoration: widget.color != null
                ? BoxDecoration(
                    color: _colorAnim.value,
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color!.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  )
                : null,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

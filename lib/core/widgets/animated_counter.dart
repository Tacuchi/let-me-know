import 'package:flutter/material.dart';

import '../constants/constants.dart';

class AnimatedCounter extends StatelessWidget {
  final int value;
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final Duration duration;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.label,
    this.color,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 500),
    this.valueStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ?? AppColors.accentPrimary;
    final effectiveBgColor =
        backgroundColor ??
        effectiveColor.withValues(alpha: isDark ? 0.2 : 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                '$animatedValue',
                style:
                    valueStyle ??
                    AppTypography.number.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style:
                labelStyle ??
                AppTypography.label.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Badge animado para mostrar notificaciones
class AnimatedBadge extends StatefulWidget {
  final int count;
  final Color? color;
  final double size;

  const AnimatedBadge({
    super.key,
    required this.count,
    this.color,
    this.size = 20,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != _previousCount) {
      _previousCount = widget.count;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count == 0) return const SizedBox.shrink();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        constraints: BoxConstraints(
          minWidth: widget.size,
          minHeight: widget.size,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.error,
          borderRadius: BorderRadius.circular(widget.size / 2),
        ),
        child: Center(
          child: Text(
            widget.count > 99 ? '99+' : '${widget.count}',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.size * 0.55,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra de progreso animada
class AnimatedProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final Duration duration;
  final BorderRadius? borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 6,
    this.duration = const Duration(milliseconds: 400),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor =
        color ??
        (isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary);
    final effectiveBgColor =
        backgroundColor ?? (isDark ? AppColors.dividerDark : AppColors.divider);
    final effectiveRadius = borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: effectiveRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: duration,
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, child) {
                return Container(
                  width: constraints.maxWidth * animatedProgress,
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    borderRadius: effectiveRadius,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Efecto shimmer para estados de carga.
///
/// Envuelve cualquier child con una animación de brillo lateral.
class LmkShimmer extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const LmkShimmer({super.key, required this.child, this.isLoading = true});

  @override
  State<LmkShimmer> createState() => _LmkShimmerState();
}

class _LmkShimmerState extends State<LmkShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LmkShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary;
    final highlightColor = isDark ? AppColors.outlineDark : AppColors.divider;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Rectángulo skeleton placeholder con shimmer integrado.
class LmkSkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const LmkSkeletonBox({
    super.key,
    this.height = 80,
    this.width,
    this.borderRadius = AppSpacing.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ghostBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.20);

    return LmkShimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: ghostBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

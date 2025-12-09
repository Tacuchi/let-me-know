import 'dart:ui';
import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Tarjeta con efecto glassmorphism (tendencia 2025)
/// Proporciona un diseño moderno y elegante
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final double blur;
  final double opacity;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppSpacing.radiusMd,
    this.backgroundColor,
    this.blur = 10,
    this.opacity = 0.7,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        (isDark
            ? AppColors.bgSecondaryDark.withValues(alpha: opacity)
            : AppColors.bgSecondary.withValues(alpha: opacity));

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border:
                border ??
                Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
            boxShadow:
                boxShadow ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Tarjeta con gradiente suave (tendencia 2025)
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final LinearGradient? gradient;
  final List<BoxShadow>? boxShadow;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppSpacing.radiusMd,
    this.gradient,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultGradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentPrimaryDark.withValues(alpha: 0.15),
              AppColors.accentSecondaryDark.withValues(alpha: 0.1),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentPrimary.withValues(alpha: 0.1),
              AppColors.accentSecondary.withValues(alpha: 0.08),
            ],
          );

    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: gradient ?? defaultGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// Tarjeta elevada con animación de hover/press
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool enabled;

  const AnimatedCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppSpacing.radiusMd,
    this.backgroundColor,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _elevationAnimation = Tween<double>(
      begin: 4,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        widget.backgroundColor ??
        (isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary);

    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: _elevationAnimation.value * 2.5,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

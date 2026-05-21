import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aura_study/core/themes/aura_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius,
    this.blurSigma = 16.0,
    this.borderColor,
    this.gradientColors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: [
          BoxShadow(
            color: AuraColors.accentIndigo.withValues(alpha: 0.03),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              gradient: LinearGradient(
                colors: gradientColors ?? [
                  Colors.white.withValues(alpha: 0.04),
                  Colors.white.withValues(alpha: 0.01),
                ],
                begin: begin,
                end: end,
              ),
              border: Border.all(
                color: borderColor ?? AuraColors.border,
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlowingGlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color glowColor;
  final List<Color>? gradientColors;

  const GlowingGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius,
    this.glowColor = AuraColors.accentCyan,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 2,
          )
        ],
      ),
      child: GlassContainer(
        padding: padding,
        borderRadius: effectiveRadius,
        borderColor: glowColor.withValues(alpha: 0.2),
        gradientColors: gradientColors,
        child: child,
      ),
    );
  }
}

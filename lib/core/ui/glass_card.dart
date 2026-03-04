import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myttmi/core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final double blur;
  final double opacity;
  final Color? tint; // opcional: para tint verde/azul

  const GlassCard({
    super.key,
    required this.child,
    this.radius = 22,
    this.padding = const EdgeInsets.all(16),
    this.blur = 18,
    this.opacity = 0.10,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final base = tint ?? Colors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          // Blur real
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(color: Colors.transparent),
          ),

          // Capa glass (no es solo opacity: es vidrio)
          Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  base.withOpacity(opacity),
                  base.withOpacity(opacity * 0.55),
                ],
              ),
              border: Border.all(
                color: AppColors.glassBorder.withOpacity(0.85),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),

          // Shine sutil (detalle pro)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: const Alignment(-1, -1),
                    end: const Alignment(1, 1),
                    colors: [
                      Colors.white.withOpacity(0.10),
                      Colors.transparent,
                      Colors.black.withOpacity(0.10),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

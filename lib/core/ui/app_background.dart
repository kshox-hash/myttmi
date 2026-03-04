import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myttmi/core/constants/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient oscuro
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.bg0, AppColors.bg1, AppColors.bg2],
            ),
          ),
        ),

        // Blobs/lights (esto da el look “premium”)
        const _GlowBlob(
          alignment: Alignment(-0.8, -0.7),
          color: Color(0x55C7F000), // verde glow
          size: 360,
        ),
        const _GlowBlob(
          alignment: Alignment(0.9, -0.3),
          color: Color(0x443E63FF), // azul glow
          size: 420,
        ),
        const _GlowBlob(
          alignment: Alignment(0.2, 0.9),
          color: Color(0x3343BFF0), // cyan glow suave
          size: 520,
        ),

        // Blur global muy suave (da sensación de profundidad)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.transparent),
        ),

        // Contenido
        child,
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double size;

  const _GlowBlob({
    required this.alignment,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

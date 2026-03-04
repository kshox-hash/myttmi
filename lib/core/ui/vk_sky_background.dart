import 'dart:ui';
import 'package:flutter/material.dart';

class VkSkyBackground extends StatelessWidget {
  final Widget child;
  const VkSkyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ Gradiente principal (cielo → blanco)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6FE0FF), // cyan cielo
                Color(0xFF66BFFF), // azul suave
                Color(0xFF8AA6FF), // toque lavanda/azul (como la imagen)
                Color(0xFFF3F6FF), // blanco/gris muy suave
              ],
              stops: [0.0, 0.35, 0.60, 1.0],
            ),
          ),
        ),

        // ✅ Glow suave arriba (sensación “soft UI”)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.9),
                  radius: 1.2,
                  colors: [
                    Colors.white.withOpacity(0.35),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),

        // ✅ Blur global MUY sutil (queda más premium)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.transparent),
        ),

        child,
      ],
    );
  }
}

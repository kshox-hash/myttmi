import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myttmi/core/constants/app_colors.dart';

class PrismBackground extends StatelessWidget {
  final Widget child;
  const PrismBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ Base deep blue (sin blanco)
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1.1),
              radius: 1.6,
              colors: [
                AppColors.skyTop,     // arriba claro
                AppColors.glowBlue,   // zona azul intensa
                AppColors.deep,       // profundo
                AppColors.dark,       // casi negro
              ],
              stops: [0.0, 0.22, 0.55, 1.0],
            ),
          ),
        ),

        // ✅ Halo cyan (como neblina luminosa)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.25),
                  radius: 1.2,
                  colors: [
                    AppColors.glowCyan.withOpacity(0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // ✅ Blur global suave (look premium)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),

        child,
      ],
    );
  }
}

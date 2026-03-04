import 'package:flutter/material.dart';

class AppColors {
  // ✅ Compatibilidad (tu app ya usa estos nombres)
  static const Color primary = Color(0xFF050814); // base oscuro
  static const Color deep    = Color(0xFF070B1E); // medio
  static const Color dark    = Color(0xFF030511); // más oscuro

  static const Color surface  = Color(0xFF0A1030); // cards generales
  static const Color surface2 = Color(0xFF08102A);

  static const Color electric = Color(0xFF6FE0FF); // cyan glow (HUD)
  static const Color accent   = Color(0xFF6FE0FF); // compatibilidad

  static const Color border = Color(0x33BFE9FF); // borde glass
  static const Color text = Color(0xFFEAF1FF);
  static const Color textMuted = Color(0xFF9AA6B2);

  // ✅ Extra: colores “prism” del concepto
  static const Color skyTop     = Color(0xFF97E8FF); // celeste arriba
  static const Color glowBlue   = Color(0xFF2D5BFF); // azul glow fuerte
  static const Color glowCyan   = Color(0xFF67D6FF); // cyan glow
  static const Color cardEdge   = Color(0x66D8F2FF); // borde más visible
  static const Color shadow     = Color(0xCC000000);
}

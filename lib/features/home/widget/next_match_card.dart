import 'package:flutter/material.dart';
import 'liquid_ticker.dart';

class NextMatchCard extends StatelessWidget {
  final String title;
  final String playerName;
  final String rankingAndPlace;
  final String meta;
  final String tickerText;
  final String nowPlayingText;
  final Duration liquidEvery;
  final VoidCallback onTap;

  const NextMatchCard({
    super.key,
    required this.title,
    required this.playerName,
    required this.rankingAndPlace,
    required this.meta,
    required this.tickerText,
    required this.nowPlayingText,
    required this.liquidEvery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = "$meta — $tickerText";
    final b = nowPlayingText;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),

            // 🔥 Azul premium profundo
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2F5BFF),
                Color(0xFF1538A6),
                Color(0xFF071A4A),
              ],
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Row(
                children: [
                  Icon(
                    Icons.sports_tennis,
                    color: Colors.white.withOpacity(0.95),
                    size: 20,
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  // BOTÓN VER
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.20),
                      ),
                    ),
                    child: Text(
                      "VER",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // INFO
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.98),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rankingAndPlace,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 🎵 BARRA DE MÚSICA PREMIUM
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  // Azul oscuro semi-transparente
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF071B44).withOpacity(0.75),
                      const Color(0xFF0B2A66).withOpacity(0.55),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                  
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LiquidTickerBar(
                          textA: a,
                          textB: b,
                          pixelsPerSecond: 26,
                          gap: 36,
                          pauseAfterA: const Duration(seconds: 2),
                          liquidEvery: liquidEvery,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

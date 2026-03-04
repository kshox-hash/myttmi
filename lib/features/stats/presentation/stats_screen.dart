import 'package:flutter/material.dart';
import 'package:myttmi/core/constants/app_colors.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary,
              AppColors.deep,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // HEADER
                Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Estadísticas",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // KPIs
                Row(
                  children: const [
                    Expanded(
                      child: _StatKpi(
                        label: "Partidos",
                        value: "128",
                        icon: Icons.sports_tennis,
                        accent: AppColors.accent,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatKpi(
                        label: "Victorias",
                        value: "78",
                        icon: Icons.emoji_events,
                        accent: Color(0xFF6EE7B7),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: const [
                    Expanded(
                      child: _StatKpi(
                        label: "Win Rate",
                        value: "61%",
                        icon: Icons.trending_up,
                        accent: Color(0xFFFFD166),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatKpi(
                        label: "Ranking",
                        value: "#60",
                        icon: Icons.leaderboard,
                        accent: Color(0xFFB388FF),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // RENDIMIENTO MENSUAL
                const _SectionTitle("Rendimiento mensual"),
                const SizedBox(height: 12),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _BarChartRow(month: "Ene", value: 0.6),
                      _BarChartRow(month: "Feb", value: 0.7),
                      _BarChartRow(month: "Mar", value: 0.5),
                      _BarChartRow(month: "Abr", value: 0.8),
                      _BarChartRow(month: "May", value: 0.65),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // RACHAS
                const _SectionTitle("Rachas"),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(
                      child: _StreakCard(
                        title: "Mejor racha",
                        value: "7",
                        subtitle: "victorias seguidas",
                        accent: Color(0xFF6EE7B7),
                        icon: Icons.local_fire_department,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StreakCard(
                        title: "Racha actual",
                        value: "3",
                        subtitle: "victorias",
                        accent: AppColors.accent,
                        icon: Icons.flash_on,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // COMPARACIÓN
                const _SectionTitle("Comparación de temporada"),
                const SizedBox(height: 12),
                _GlassCard(
                  child: Column(
                    children: const [
                      _CompareRow(
                        label: "Win Rate",
                        current: "61%",
                        previous: "55%",
                        positive: true,
                      ),
                      SizedBox(height: 10),
                      _CompareRow(
                        label: "Ranking promedio",
                        current: "62",
                        previous: "74",
                        positive: true,
                      ),
                      SizedBox(height: 10),
                      _CompareRow(
                        label: "Partidos / mes",
                        current: "10.6",
                        previous: "12.1",
                        positive: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                    UI                                     */
/* -------------------------------------------------------------------------- */

class _StatKpi extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatKpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withOpacity(0.35)),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartRow extends StatelessWidget {
  final String month;
  final double value; // 0.0 - 1.0

  const _BarChartRow({
    required this.month,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              month,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "${(value * 100).round()}%",
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData icon;

  const _StreakCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        children: [
          Icon(icon, color: accent, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String current;
  final String previous;
  final bool positive;

  const _CompareRow({
    required this.label,
    required this.current,
    required this.previous,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF6EE7B7) : const Color(0xFFF87171);
    final icon = positive ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          current,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          previous,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 14,
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

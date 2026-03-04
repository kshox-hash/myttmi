import 'package:flutter/material.dart';
import 'package:myttmi/core/constants/app_colors.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final TextEditingController _search = TextEditingController();

  final List<_RankPlayer> _players = [
    const _RankPlayer(pos: 1, name: "Ignacio Peña", club: "MyTTM Team", elo: 1682, wins: 44, losses: 12),
    const _RankPlayer(pos: 2, name: "Matías Rojas", club: "CD San Miguel", elo: 1655, wins: 41, losses: 15),
    const _RankPlayer(pos: 3, name: "Daniel Soto", club: "Butterfly Club", elo: 1628, wins: 39, losses: 16),
    const _RankPlayer(pos: 4, name: "Sebastián Díaz", club: "MyTTM Team", elo: 1591, wins: 36, losses: 18),
    const _RankPlayer(pos: 5, name: "Tomás Lagos", club: "CD San Miguel", elo: 1566, wins: 33, losses: 20),
    const _RankPlayer(pos: 6, name: "Juan Herrera", club: "Spin Masters", elo: 1542, wins: 31, losses: 22),
    const _RankPlayer(pos: 60, name: "Jose Curihual", club: "CD San Miguel", elo: 1468, wins: 28, losses: 14, isMe: true),
  ];

  String _season = "Temporada 2026";
  String _category = "Open";

  int _sumMatches(List<_RankPlayer> list) =>
      list.fold(0, (acc, p) => acc + p.wins + p.losses);

  int _sumElo(List<_RankPlayer> list) =>
      list.fold(0, (acc, p) => acc + p.elo);

  @override
  Widget build(BuildContext context) {
    final query = _search.text.toLowerCase();

    final filtered = _players
        .where((p) =>
            p.name.toLowerCase().contains(query) ||
            p.club.toLowerCase().contains(query))
        .toList()
      ..sort((a, b) => a.pos.compareTo(b.pos));

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
            child: Column(
              children: [
                _TopBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _RankingHeaderCard(
                        season: _season,
                        category: _category,
                        totalPlayers: filtered.length,
                        totalMatches: _sumMatches(filtered),
                        totalPoints: _sumElo(filtered),
                      ),
                      const SizedBox(height: 16),
                      ...filtered.map((p) => _RankRow(player: p)).toList(),
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

class _RankPlayer {
  final int pos;
  final String name;
  final String club;
  final int elo;
  final int wins;
  final int losses;
  final bool isMe;

  const _RankPlayer({
    required this.pos,
    required this.name,
    required this.club,
    required this.elo,
    required this.wins,
    required this.losses,
    this.isMe = false,
  });
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.arrow_back, color: Colors.white),
        SizedBox(width: 12),
        Text(
          "Ranking",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RankingHeaderCard extends StatelessWidget {
  final String season;
  final String category;
  final int totalPlayers;
  final int totalMatches;
  final int totalPoints;

  const _RankingHeaderCard({
    required this.season,
    required this.category,
    required this.totalPlayers,
    required this.totalMatches,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.emoji_events_rounded, color: AppColors.accent),
              SizedBox(width: 10),
              Text(
                "Ranking Nacional",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "$season • $category",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(label: "Jugadores", value: totalPlayers.toString()),
              _MiniStat(label: "Partidos", value: totalMatches.toString()),
              _MiniStat(label: "Puntos", value: totalPoints.toString()),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "VER MI POSICIÓN",
                style: TextStyle(
                  color: AppColors.dark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final _RankPlayer player;

  const _RankRow({required this.player});

  @override
  Widget build(BuildContext context) {
    final bg = player.isMe
        ? AppColors.accent.withOpacity(0.18)
        : Colors.white.withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              "#${player.pos}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  player.club,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "ELO ${player.elo}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          )
        ],
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:myttmi/core/constants/app_colors.dart";
import "package:myttmi/features/tournament/api/tournament_api.dart";
import "package:myttmi/features/tournament/models/tournament_models.dart";
import "package:myttmi/features/tournament/presentation/admin_tournament_detail_screen.dart";
import "package:myttmi/features/tournament/presentation/tournament_detail_screen.dart";


class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  late final TournamentApi api;
  late Future<List<Tournament>> future;

  String? _selectedCity; // null = todas

  static const List<String> chileCities = [
    "Santiago",
    "Valparaíso",
    "Viña del Mar",
    "Concepción",
    "Antofagasta",
    "La Serena",
    "Iquique",
    "Arica",
    "Copiapó",
    "Temuco",
    "Valdivia",
    "Osorno",
    "Puerto Montt",
    "Chillán",
    "Punta Arenas",
  ];

  @override
  void initState() {
    super.initState();
    api = TournamentApi();
    _reload();
  }

  void _reload() {
    setState(() {
      future = api.fetchTournaments(city: _selectedCity);
    });
  }

  Future<void> _refresh() async {
    _reload();
    await future;
  }

  void _clearCity() {
    setState(() => _selectedCity = null);
    _reload();
  }

  void _onSelectCity(String? city) {
    setState(() => _selectedCity = (city == "Todas") ? null : city);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text("Campeonatos"),
        backgroundColor: AppColors.deep,
        foregroundColor: AppColors.text,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Recargar",
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Tournament>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.electric),
            );
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Error: ${snap.error}",
                  style: const TextStyle(color: AppColors.text),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final list = snap.data ?? [];

          return RefreshIndicator(
            color: AppColors.electric,
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _HudCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_city_outlined, color: AppColors.electric),
                          const SizedBox(width: 10),
                          const Text(
                            "Filtrar por ciudad",
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${list.length}",
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _selectedCity ?? "Todas",
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        iconEnabledColor: AppColors.textMuted,
                        style: const TextStyle(color: AppColors.text),
                        decoration: _ddDeco("Ciudad"),
                        items: [
                          const DropdownMenuItem(value: "Todas", child: Text("Todas")),
                          ...chileCities.map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          ),
                        ],
                        onChanged: _onSelectCity,
                      ),

                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: _clearCity,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Ver todos"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.electric,
                          side: const BorderSide(color: AppColors.electric),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                if (list.isEmpty) ...[
                  const SizedBox(height: 80),
                  const Center(
                    child: Text(
                      "No hay campeonatos con ese filtro.",
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ] else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final t = list[i];

                      return _HudCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TournamentDetailScreen(tournament: t),
                            ),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: AppColors.surface2,
                                border: Border.all(color: AppColors.cardEdge),
                              ),
                              child: const Icon(
                                Icons.emoji_events_outlined,
                                color: AppColors.electric,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.tournamentName,
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    [
                                      if ((t.location ?? "").trim().isNotEmpty) "📍 ${t.location}",
                                      "Categorías: ${t.categories.length}",
                                    ].join("\n"),
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: AppColors.textMuted),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _ddDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textMuted),
      isDense: true,
      filled: true,
      fillColor: AppColors.surface2,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.electric, width: 1.4),
      ),
    );
  }
}

// ---------- HUD CARD ----------
class _HudCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _HudCard({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surface2],
        ),
        border: Border.all(color: AppColors.cardEdge),
        boxShadow: const [
          BoxShadow(
            color: AppColors.glowCyan,
            blurRadius: 14,
            spreadRadius: -10,
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
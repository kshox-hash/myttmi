import "package:flutter/material.dart";
import "package:myttmi/features/tournament/api/tournament_api.dart";
import "package:myttmi/routes/app_routes.dart";
import "package:myttmi/core/storage/session_storage.dart";

//admin
import "package:myttmi/features/admin/tournaments/models/admin_tournaments_model.dart";
class TournamentDetailScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  final TournamentApi api = TournamentApi();
  final SessionStorage session = SessionStorage();

  String _genderLabel(String g) {
    switch (g) {
      case "male":
        return "Masculino";
      case "female":
        return "Femenino";
      case "mixed":
        return "Mixto";
      default:
        return g;
    }
  }

  Future<void> _subscribe(TournamentCategory c) async {
    try {
      await api.subscribeToCategory(
        tournamentId: widget.tournament.idTournament,
        categoryId: c.idCategory,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Inscripción realizada")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _goViewGroups(TournamentCategory c) {
    Navigator.pushNamed(
      context,
      AppRoutes.groupsView,
      arguments: {
        "tournamentId": widget.tournament.idTournament,
        "categoryId": c.idCategory,
      },
    );
  }

  Future<void> _goGenerateGroups(TournamentCategory c) async {
    final adminId = await session.getUserId();
    if (adminId == null || adminId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró adminId en sesión")),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.adminGenerateGroups,
      arguments: {
        "tournamentId": widget.tournament.idTournament,
        "categoryId": c.idCategory,
        "adminId": adminId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;

    return Scaffold(
      appBar: AppBar(title: Text(t.tournamentName)),
      body: FutureBuilder<String?>(
        future: session.getRole(),
        builder: (context, snap) {
          final role = (snap.data ?? "").toString();
          final isAdmin = role == "admin";

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if ((t.location ?? "").trim().isNotEmpty)
                _InfoTile(icon: Icons.place, label: "Ubicación", value: t.location!),

              if ((t.description ?? "").trim().isNotEmpty)
                _InfoTile(icon: Icons.info_outline, label: "Descripción", value: t.description!),

              const SizedBox(height: 16),
              const Text(
                "Categorías",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (t.categories.isEmpty)
                const Text("Este campeonato no tiene categorías aún.")
              else
                ...t.categories.map((c) {
                  final enrolled = c.isEnrolled;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.categoryName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Género: ${_genderLabel(c.gender)}\n"
                            "Precio: \$${c.inscriptionPrice}  •  Cupos: ${c.quotas}",
                          ),
                          const SizedBox(height: 12),

                          // ✅ Botones acción
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _goViewGroups(c),
                                  icon: const Icon(Icons.groups_rounded),
                                  label: const Text("Ver grupos"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: enrolled ? null : () => _subscribe(c),
                                  child: Text(enrolled ? "Inscrito" : "Suscribirme"),
                                ),
                              ),
                            ],
                          ),

                          // ✅ Solo admin: Generar grupos
                          if (isAdmin) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _goGenerateGroups(c),
                                icon: const Icon(Icons.auto_fix_high_rounded),
                                label: const Text("Generar grupos (Admin)"),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}

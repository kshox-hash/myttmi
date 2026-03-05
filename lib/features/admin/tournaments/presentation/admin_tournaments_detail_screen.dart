import "package:flutter/material.dart";
import "package:myttmi/features/admin/tournaments/api/admin_tournaments_api.dart";
import "package:myttmi/features/admin/tournaments/models/admin_tournaments_model.dart";

class TournamentAdminDetailScreen extends StatefulWidget {
  final Tournament tournament;
  const TournamentAdminDetailScreen({super.key, required this.tournament});

  @override
  State<TournamentAdminDetailScreen> createState() => _TournamentAdminDetailScreenState();
}

class _TournamentAdminDetailScreenState extends State<TournamentAdminDetailScreen> {
  final _api = AdminTournamentApi();
  late final String _tid;
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _tid = widget.tournament.idTournament;
    _load();
  }

  void _load() {
    setState(() {
      _future = _api.adminGetEnrollments(tournamentId: _tid);
    });
  }

  Future<void> _remove(String userId, String catId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar jugador"),
        content: const Text("Esto cancelará la inscripción del jugador en esta categoría."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await _api.adminRemoveEnrollment(tournamentId: _tid, userId: userId, categoryId: catId);
    _load();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Inscripción cancelada")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;

    return Scaffold(
      appBar: AppBar(title: Text(t.tournamentName)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text("Error: ${snap.error}")));
          }

          final users = snap.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.tournamentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      if ((t.description ?? "").trim().isNotEmpty) Text(t.description!),
                      const SizedBox(height: 10),
                     Text("📍 ${t.location ?? "—"}"),
                      if ((t.location ?? "").trim().isNotEmpty) Text("Gym/Detalle: ${t.location}"),
                      const SizedBox(height: 10),
                      Text("Inscritos: ${users.length}", style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),
              const Text("Jugadores inscritos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),

              if (users.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: Text("No hay inscritos aún.")),
                )
              else
                ...users.map((u) {
                  final userId = (u["id_user"] ?? "").toString();
                  final catId = (u["id_category"] ?? "").toString();

                  final fullName = [
                    (u["first_name"] ?? "").toString().trim(),
                    (u["last_name"] ?? "").toString().trim(),
                  ].where((x) => x.isNotEmpty).join(" ");

                  final email = (u["email"] ?? "").toString();
                  final catName = (u["category_name"] ?? "").toString();
                  final catGender = (u["category_gender"] ?? "").toString();

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(fullName.isNotEmpty ? fullName : email),
                      subtitle: Text("$catName · $catGender"),
                      trailing: IconButton(
                        tooltip: "Eliminar",
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _remove(userId, catId),
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
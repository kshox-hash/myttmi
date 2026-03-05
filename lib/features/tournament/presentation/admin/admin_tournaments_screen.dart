import "package:flutter/material.dart";
import "package:myttmi/features/tournament/api/tournament_api.dart";
import "package:myttmi/core/storage/session_storage.dart";
import "package:myttmi/features/tournament/models/tournament_models.dart";
import "package:myttmi/routes/app_routes.dart";

class AdminTournamentsScreen extends StatefulWidget {
  const AdminTournamentsScreen({super.key});

  @override
  State<AdminTournamentsScreen> createState() => _AdminTournamentsScreenState();
}

class _AdminTournamentsScreenState extends State<AdminTournamentsScreen> {
  final _api = TournamentApi();
  Future<List<Tournament>>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await SessionStorage().getUserId();
    if (!mounted) return;

    if (id == null || id.isEmpty) {
      setState(() => _future = Future.value([]));
      return;
    }

    setState(() {
      _future = _api.fetchMyTournaments(createdBy: id);
    });
  }

  Future<void> _refresh() async {
    await _load();
    if (_future != null) await _future!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis campeonatos")),
      body: FutureBuilder<List<Tournament>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Error: ${snap.error}", textAlign: TextAlign.center),
              ),
            );
          }

          final list = snap.data ?? [];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: list.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 140),
                      Icon(Icons.emoji_events_outlined, size: 56),
                      SizedBox(height: 12),
                      Center(child: Text("Aún no has creado campeonatos.")),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final t = list[i];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.emoji_events_rounded),
                          title: Text(t.tournamentName),
                          subtitle: Text([
                            if ((t.location ?? "").trim().isNotEmpty) "📍 ${t.location}",
                            if ((t.location ?? "").trim().isNotEmpty) t.location!,
                            "Categorías: ${t.categories.length}",
                          ].join(" · ")),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.adminTournamentDetail,
                              arguments: t, // ✅ importante
                            );
                          },
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
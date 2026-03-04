import "package:flutter/material.dart";
import "package:myttmi/core/constants/app_colors.dart";

import "package:myttmi/features/competition/api/competition_api.dart";

class GroupsViewScreen extends StatefulWidget {
  final String tournamentId;
  final String categoryId;

  const GroupsViewScreen({
    super.key,
    required this.tournamentId,
    required this.categoryId,
  });

  @override
  State<GroupsViewScreen> createState() => _GroupsViewScreenState();
}

class _GroupsViewScreenState extends State<GroupsViewScreen> {
  bool loading = true;
  List groups = [];
  String? error;

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await CompetitionApi.getGroups(
        tournamentId: widget.tournamentId,
        categoryId: widget.categoryId,
      );
      setState(() => groups = data);
    } catch (e) {
      setState(() => error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text("Grupos"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text("❌ $error"))
              : groups.isEmpty
                  ? const Center(child: Text("Aún no hay grupos generados."))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: groups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final g = groups[i];
                        final players = (g["players"] as List?) ?? [];

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Grupo ${g["group_name"]}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...players.map((p) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 28,
                                          child: Text(
                                            "${p["seed"]}.",
                                            style: const TextStyle(fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        Expanded(child: Text((p["name"] ?? "Jugador").toString())),
                                        const SizedBox(width: 12),
                                        Text(
                                          (p["club"] ?? "").toString(),
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

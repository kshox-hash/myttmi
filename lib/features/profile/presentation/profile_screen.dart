import "package:flutter/material.dart";
import "package:myttmi/core/storage/session_storage.dart";
import "package:myttmi/features/profile/api/profile_api.dart";
import "package:myttmi/features/profile/models/profile_model.dart";
import "package:myttmi/features/shell/splash_gate.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final api = ProfileApi();
  late Future<UserProfile> future;

  @override
  void initState() {
    super.initState();
    future = api.getMe();
  }

  String _roleLabel(String role) {
    if (role == "admin") return "Administrador";
    return "Jugador";
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "—";
    final d = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, "0");
    return "${two(d.day)}-${two(d.month)}-${d.year}  ${two(d.hour)}:${two(d.minute)}";
  }

  Future<void> _logout() async {
    await SessionStorage().clear();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashGate()),
      (_) => false,
    );
  }

  Future<void> _refresh() async {
    setState(() => future = api.getMe());
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Error cargando perfil:\n${snap.error}"),
              ),
            );
          }

          final p = snap.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(p.email),
                    subtitle: Text(_roleLabel(p.role)),
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text("ID usuario"),
                        subtitle: Text(p.idUser),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text("Creado en"),
                        subtitle: Text(_formatDate(p.createdAt)),
                      ),
                      if ((p.displayName ?? "").trim().isNotEmpty) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text("Nombre"),
                          subtitle: Text(p.displayName!),
                        ),
                      ],
                      if ((p.club ?? "").trim().isNotEmpty) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.groups_2_outlined),
                          title: const Text("Club"),
                          subtitle: Text(p.club!),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Actualizar"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

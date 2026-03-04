import "package:flutter/material.dart";
import "package:myttmi/routes/app_routes.dart";
import "package:myttmi/core/storage/session_storage.dart";
import "package:myttmi/features/shell/splash_gate.dart";

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Quieres cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.logout),
            label: const Text("Cerrar sesión"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SessionStorage().clearAll();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashGate()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin · Panel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events_rounded),
              title: const Text("Campeonatos"),
              subtitle: const Text("Gestionar, generar grupos, llaves"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.adminTournaments,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_circle_outline_rounded),
              title: const Text("Crear campeonato"),
              subtitle: const Text("Solo administrador"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.createTournament,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

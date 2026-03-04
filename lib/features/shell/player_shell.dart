import "package:flutter/material.dart";
import "package:myttmi/core/storage/session_storage.dart";
import "package:myttmi/features/shell/splash_gate.dart";

class PlayerShell extends StatelessWidget {
  const PlayerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyTTM • Jugador"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SessionStorage().clear();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashGate()),
                  (_) => false,
                );
              }
            },
          )
        ],
      ),
      body: const Center(child: Text("Home jugador (tu UI acá)")),
    );
  }
}

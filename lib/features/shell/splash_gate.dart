import "package:flutter/material.dart";
import "package:myttmi/core/storage/session_storage.dart";
import "package:myttmi/features/auth/presentation/login_screen.dart";
import "package:myttmi/features/shell/admin_shell.dart";
import "package:myttmi/features/shell/player_shell.dart";
import "package:myttmi/features/home/presentation/home_screen.dart";


class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final storage = SessionStorage();
    final token = await storage.getToken();
    final role = await storage.getRole();

    if (!mounted) return;

    if (token == null || token.isEmpty || role == null || role.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const  LoginScreen()),
      );
      return;
    }

    if (role == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminShell()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const  HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

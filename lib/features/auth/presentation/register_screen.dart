import "package:flutter/material.dart";
import "package:myttmi/core/storage/session_storage.dart";
import "package:myttmi/features/auth/api/auth_api.dart";
import "package:myttmi/features/home/presentation/home_screen.dart";

//ADMIN
import "package:myttmi/features/admin/home/presentation/admin_home_screen.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;

  String role = "player"; // por defecto
  final api = AuthApi();
  final storage = SessionStorage();

  Future<void> _register() async {
    setState(() => loading = true);

    try {
      final resp = await api.register(email: _email.text, password: _pass.text, role: role);

      await storage.saveSession(
        token: resp.token,
        role: resp.user.role,
        userId: resp.user.idUser,
        email: resp.user.email,
      );

      if (!mounted) return;

      final next = resp.user.role == "admin" ? const AdminHomeScreen() : const HomeScreen();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => next),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Contraseña"),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: "player", child: Text("Jugador")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
              ],
              onChanged: (v) => setState(() => role = v ?? "player"),
              decoration: const InputDecoration(labelText: "Rol (demo)"),
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _register,
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Crear cuenta"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

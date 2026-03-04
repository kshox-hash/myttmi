import "dart:async";
import "dart:convert";
import "package:http/http.dart" as http;

import "package:myttmi/core/constants/app_config.dart";
import "package:myttmi/features/auth/models/auth_models.dart";

class AuthApi {
  final String baseUrl;
  AuthApi({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.baseUrl;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse("$baseUrl/api/v1/auth/login");

    final res = await http
        .post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": email.trim(), "password": password}),
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      throw Exception("Login error: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "Login inválido");
    }

    return AuthResponse.fromJson(decoded);
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    String role = "player", // por defecto player
  }) async {
    final uri = Uri.parse("$baseUrl/api/v1/auth/register");

    final res = await http
        .post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": email.trim(),
            "password": password,
            "role": role,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("Register error: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "Registro inválido");
    }

    return AuthResponse.fromJson(decoded);
  }
}

import "dart:convert";
import "package:http/http.dart" as http;

import "package:myttmi/core/constants/app_config.dart";
import "package:myttmi/core/storage/session_storage.dart";
import "package:myttmi/features/profile/models/profile_model.dart";

class ProfileApi {
  final String baseUrl;
  ProfileApi({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.baseUrl;

  Future<UserProfile> getMe() async {
    final token = await SessionStorage().getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Sin sesión (token vacío)");
    }

    final uri = Uri.parse("$baseUrl/api/v1/users/me");

    final res = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "Respuesta inválida");
    }

    return UserProfile.fromJson(decoded["data"] as Map<String, dynamic>);
  }
}

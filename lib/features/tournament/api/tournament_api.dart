import "dart:convert";
import "package:flutter/material.dart"; // TimeOfDay
import "package:http/http.dart" as http;

import "package:myttmi/core/constants/app_config.dart";
import "package:myttmi/core/storage/session_storage.dart";
import "package:myttmi/features/tournament/models/tournament_models.dart";

class TournamentApi {
  final String baseUrl;

  TournamentApi({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.baseUrl;

  // -----------------------
  // LISTAR TORNEOS (✅ filtros opcionales)
  // -----------------------
  Future<List<Tournament>> fetchTournaments({
    String? q,
    String? city, // ✅ NUEVO
  }) async {
    final params = <String, String>{};

    final qq = (q ?? "").trim();
    if (qq.isNotEmpty) params["q"] = qq;

    final cc = (city ?? "").trim();
    if (cc.isNotEmpty) params["city"] = cc;

    final uri = Uri.parse("$baseUrl/api/v1/tournament/listTournament")
        .replace(queryParameters: params.isEmpty ? null : params);

    final res = await http.get(uri, headers: {"Content-Type": "application/json"});

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "Respuesta inválida");
    }

    final data = (decoded["data"] as List).cast<Map<String, dynamic>>();
    return data.map(Tournament.fromJson).toList();
  }

  // -----------------------
  // CREAR TORNEO (✅ agrega city)
  // -----------------------
  Future<void> createTournament({
    required String createdBy,
    required String tournamentName,
    String? description,
    String? location,
    required DateTime eventDate,
    TimeOfDay? eventTime,
    required List<Map<String, dynamic>> categories,
    String? city, // ✅ NUEVO
  }) async {
    final token = await SessionStorage().getToken();

    String fmtDate(DateTime d) =>
        "${d.year.toString().padLeft(4, "0")}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}";

    String? fmtTime(TimeOfDay? t) {
      if (t == null) return null;
      return "${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}";
    }

    final uri = Uri.parse("$baseUrl/api/v1/tournament/createTournament");

    final body = {
      "tournament_name": tournamentName.trim(),
      "description": (description ?? "").trim().isEmpty ? null : description!.trim(),
      "location": (location ?? "").trim().isNotEmpty ? location!.trim() : null,
      "created_by": createdBy,
      "event_date": fmtDate(eventDate),
      "event_time": fmtTime(eventTime),
      "categories": categories,

      // ✅ NUEVO
      "city": (city ?? "").trim().isNotEmpty ? city!.trim() : null,
    };

    final res = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "No se pudo crear el torneo");
    }
  }

  // -----------------------
  // SUSCRIBIRSE A CATEGORÍA (igual)
  // -----------------------
  Future<void> subscribeToCategory({
    required String tournamentId,
    required String categoryId,
  }) async {
    final token = await SessionStorage().getToken();
    final userId = await SessionStorage().getUserId();

    if (token == null || token.isEmpty) {
      throw Exception("No hay sesión. Vuelve a iniciar sesión.");
    }
    if (userId == null || userId.isEmpty) {
      throw Exception("No se encontró id_user en sesión.");
    }

    final uri = Uri.parse("$baseUrl/api/v1/enrollments/subscribe");

    final res = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "id_user": userId,
        "id_tournament": tournamentId,
        "id_category": categoryId,
      }),
    );

    if (res.statusCode == 409) {
      throw Exception("Ya estás inscrito en esta categoría");
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "No se pudo suscribir");
    }
  }

  // ✅ Torneos creados por el admin
Future<List<Tournament>> fetchMyTournaments({required String createdBy}) async {
  final uri = Uri.parse("$baseUrl/api/v1/tournament/myTournaments")
      .replace(queryParameters: {"created_by": createdBy});

  final res = await http.get(uri, headers: {"Content-Type": "application/json"});

  if (res.statusCode != 200) {
    throw Exception("HTTP ${res.statusCode}: ${res.body}");
  }

  final decoded = jsonDecode(res.body) as Map<String, dynamic>;
  if (decoded["ok"] != true) {
    throw Exception(decoded["message"] ?? "Respuesta inválida");
  }

  final data = (decoded["data"] as List).cast<Map<String, dynamic>>();
  return data.map(Tournament.fromJson).toList();
}

// ✅ Inscritos del torneo (para admin)
Future<List<Map<String, dynamic>>> fetchTournamentEnrollments({
  required String tournamentId,
}) async {
  final uri = Uri.parse("$baseUrl/api/v1/tournament/$tournamentId/enrollments");

  final res = await http.get(uri, headers: {"Content-Type": "application/json"});

  if (res.statusCode != 200) {
    throw Exception("HTTP ${res.statusCode}: ${res.body}");
  }

  final decoded = jsonDecode(res.body) as Map<String, dynamic>;
  if (decoded["ok"] != true) {
    throw Exception(decoded["message"] ?? "Respuesta inválida");
  }

  return (decoded["data"] as List).cast<Map<String, dynamic>>();
}

// ✅ Eliminar jugador del torneo = cancelar inscripción
Future<void> removeEnrollment({
  required String tournamentId,
  required String userId,
  required String categoryId,
}) async {
  final token = await SessionStorage().getToken();

  final uri = Uri.parse("$baseUrl/api/v1/tournament/$tournamentId/enrollments/remove");

  final res = await http.post(
    uri,
    headers: {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "id_user": userId,
      "id_category": categoryId,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception("HTTP ${res.statusCode}: ${res.body}");
  }

  final decoded = jsonDecode(res.body) as Map<String, dynamic>;
  if (decoded["ok"] != true) {
    throw Exception(decoded["message"] ?? "No se pudo eliminar");
  }
}
}
import "dart:convert";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:myttmi/core/constants/app_config.dart";
import "package:myttmi/core/storage/session_storage.dart";
import "package:myttmi/features/tournament/models/tournament_models.dart";


/// ===============================================================
/// API utilizada exclusivamente por el ADMINISTRADOR del torneo
/// Permite:
/// - Crear torneos
/// - Obtener torneos creados por el admin
/// - Ver inscripciones de jugadores
/// - Eliminar inscripciones
/// ===============================================================
class AdminTournamentApi {
  final String baseUrl;

  /// Constructor que permite usar otra baseUrl si se desea,
  /// si no se usa la configurada en AppConfig
  AdminTournamentApi({String? baseUrl})
      : baseUrl = baseUrl ?? AppConfig.baseUrl;

  /// ===============================================================
  /// ADMIN: CREATE TOURNAMENT
  /// Crea un torneo con sus categorías
  /// ===============================================================
  Future<void> adminCreateTournament({
    required String createdBy,
    required String tournamentName,
    String? description,
    String? location,
    required DateTime eventDate,
    TimeOfDay? eventTime,
    required List<Map<String, dynamic>> categories,
    String? city,
  }) async {

    /// Obtiene el token guardado en sesión
    final token = await SessionStorage().getToken();

    /// Convierte DateTime a formato YYYY-MM-DD
    String formatDate(DateTime d) =>
        "${d.year.toString().padLeft(4, "0")}-"
        "${d.month.toString().padLeft(2, "0")}-"
        "${d.day.toString().padLeft(2, "0")}";

    /// Convierte TimeOfDay a HH:mm
    String? formatTime(TimeOfDay? t) {
      if (t == null) return null;
      return "${t.hour.toString().padLeft(2, "0")}:"
             "${t.minute.toString().padLeft(2, "0")}";
    }

    /// Endpoint del backend
    final uri = Uri.parse("$baseUrl/api/v1/tournament/createTournament");

    /// Body enviado al servidor
    final body = {
      "tournament_name": tournamentName.trim(),
      "description":
          (description ?? "").trim().isEmpty ? null : description!.trim(),
      "location":
          (location ?? "").trim().isNotEmpty ? location!.trim() : null,
      "created_by": createdBy,
      "event_date": formatDate(eventDate),
      "event_time": formatTime(eventTime),
      "categories": categories,
      "city":
          (city ?? "").trim().isNotEmpty ? city!.trim() : null,
    };

    /// Petición HTTP
    final res = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",

        /// Si hay token se envía para autenticación
        if (token != null && token.isNotEmpty)
          "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    /// Verifica error HTTP
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    /// Decodifica respuesta
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    /// Verifica respuesta del backend
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "Tournament creation failed");
    }
  }

  /// ===============================================================
  /// ADMIN: GET TOURNAMENTS CREATED BY ADMIN
  /// Obtiene todos los torneos creados por el administrador
  /// ===============================================================
  Future<List<Tournament>> adminGetMyTournaments({
    required String createdBy,
  }) async {

    /// Construye la URL con query parameter
    final uri = Uri.parse("$baseUrl/api/v1/tournament/myTournaments")
        .replace(queryParameters: {"created_by": createdBy});

    /// Petición GET
    final res = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    /// Verifica error HTTP
    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    /// Decodifica respuesta
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    /// Verifica respuesta del backend
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "Invalid response");
    }

    /// Convierte JSON a lista de objetos Tournament
    final data = (decoded["data"] as List)
        .cast<Map<String, dynamic>>();

    return data.map(Tournament.fromJson).toList();
  }

  /// ===============================================================
  /// ADMIN: GET ENROLLMENTS
  /// Obtiene todos los jugadores inscritos en un torneo
  /// ===============================================================
  Future<List<Map<String, dynamic>>> adminGetEnrollments({
    required String tournamentId,
  }) async {

    final uri =
        Uri.parse("$baseUrl/api/v1/tournament/$tournamentId/enrollments");

    final res = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    /// Verifica error HTTP
    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    /// Verifica respuesta backend
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "Invalid response");
    }

    /// Devuelve lista de inscripciones
    return (decoded["data"] as List)
        .cast<Map<String, dynamic>>();
  }

  /// ===============================================================
  /// ADMIN: REMOVE ENROLLMENT
  /// Permite eliminar la inscripción de un jugador
  /// ===============================================================
  Future<void> adminRemoveEnrollment({
    required String tournamentId,
    required String userId,
    required String categoryId,
  }) async {

    final token = await SessionStorage().getToken();

    final uri = Uri.parse(
      "$baseUrl/api/v1/tournament/$tournamentId/enrollments/remove",
    );

    final res = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",

        /// Token para autenticación
        if (token != null && token.isNotEmpty)
          "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "id_user": userId,
        "id_category": categoryId,
      }),
    );

    /// Verifica error HTTP
    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    /// Verifica respuesta backend
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "Failed to remove enrollment");
    }
  }
}
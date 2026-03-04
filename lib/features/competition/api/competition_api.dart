import "dart:convert";
import "package:http/http.dart" as http;
import "package:myttmi/core/constants/app_config.dart";

class CompetitionApi {
  static Future<void> generateGroups({
    required String tournamentId,
    required String categoryId,
    required String adminId,
  }) async {
    final url = Uri.parse(
      "${AppConfig.baseUrl}/tournaments/$tournamentId/categories/$categoryId/generate-groups",
    );

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"created_by": adminId}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final j = jsonDecode(res.body);
      throw Exception(j["error"] ?? "ERROR_GENERATING_GROUPS");
    }
  }

  static Future<List<dynamic>> getGroups({
    required String tournamentId,
    required String categoryId,
  }) async {
    final url = Uri.parse(
      "${AppConfig.baseUrl}/tournaments/$tournamentId/categories/$categoryId/groups",
    );

    final res = await http.get(url);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final j = jsonDecode(res.body);
      throw Exception(j["error"] ?? "ERROR_LOADING_GROUPS");
    }

    final j = jsonDecode(res.body);
    return (j["groups"] as List?) ?? [];
  }
}

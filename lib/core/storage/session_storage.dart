import "package:shared_preferences/shared_preferences.dart";

class SessionStorage {
  static const _kToken = "token";
  static const _kRole = "role";
  static const _kUserId = "user_id";
  static const _kEmail = "email";

  Future<void> saveSession({
    required String token,
    required String role,
    required String userId,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kRole, role);
    await prefs.setString(_kUserId, userId);
    if (email != null) await prefs.setString(_kEmail, email);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRole, role);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRole);
  }

  Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserId, id);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserId);
  }

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmail, email);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmail);
  }

  // ✅ método original que yo propuse
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ✅ ALIAS para tu código existente (admin_shell/player_shell/profile_screen)
  Future<void> clear() => clearAll();

  Future<bool> hasSession() async {
    final token = await getToken();
    final role = await getRole();
    final userId = await getUserId();
    return (token != null && token.isNotEmpty) &&
        (role != null && role.isNotEmpty) &&
        (userId != null && userId.isNotEmpty);
  }
}

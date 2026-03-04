class AuthUser {
  final String idUser;
  final String email;
  final String role; // "admin" | "player"

  AuthUser({
    required this.idUser,
    required this.email,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      idUser: json["id_user"] as String,
      email: json["email"] as String,
      role: (json["role"] as String).toLowerCase(),
    );
  }
}

class AuthResponse {
  final String token;
  final AuthUser user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"] as Map<String, dynamic>;
    return AuthResponse(
      token: data["token"] as String,
      user: AuthUser.fromJson(data["user"] as Map<String, dynamic>),
    );
  }
}

class UserProfile {
  final String idUser;
  final String email;
  final String role; // "admin" | "player"
  final DateTime? createdAt;

  // ✅ Campos extra opcionales (por si después los agregas en DB)
  final String? displayName;
  final String? club;
  final String? avatarUrl;

  UserProfile({
    required this.idUser,
    required this.email,
    required this.role,
    required this.createdAt,
    this.displayName,
    this.club,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    return UserProfile(
      idUser: (json["id_user"] ?? "").toString(),
      email: (json["email"] ?? "").toString(),
      role: (json["role"] ?? "player").toString().toLowerCase(),
      createdAt: parseDate(json["created_at"]),

      // opcionales
      displayName: json["display_name"]?.toString(),
      club: json["club"]?.toString(),
      avatarUrl: json["avatar_url"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_user": idUser,
      "email": email,
      "role": role,
      "created_at": createdAt?.toIso8601String(),
      "display_name": displayName,
      "club": club,
      "avatar_url": avatarUrl,
    };
  }

  UserProfile copyWith({
    String? idUser,
    String? email,
    String? role,
    DateTime? createdAt,
    String? displayName,
    String? club,
    String? avatarUrl,
  }) {
    return UserProfile(
      idUser: idUser ?? this.idUser,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
      club: club ?? this.club,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

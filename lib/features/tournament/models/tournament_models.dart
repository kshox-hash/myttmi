class TournamentCategory {
  final String idCategory;
  final String categoryName;
  final String gender;
  final int inscriptionPrice;
  final int quotas;
  final bool isEnrolled;

  TournamentCategory({
    required this.idCategory,
    required this.categoryName,
    required this.gender,
    required this.inscriptionPrice,
    required this.quotas,
    this.isEnrolled = false,
  });

  factory TournamentCategory.fromJson(Map<String, dynamic> json) {
    return TournamentCategory(
      idCategory: json["id_category"] as String,
      categoryName: json["category_name"] as String,
      gender: json["gender"] as String,
      inscriptionPrice: (json["inscription_price"] as num).toInt(),
      quotas: (json["quotas"] as num).toInt(),
      isEnrolled: json["is_enrolled"] ?? false,
    );
  }

  // 👇 Esto es MUY importante para poder actualizar el estado en la UI
  TournamentCategory copyWith({
    bool? isEnrolled,
  }) {
    return TournamentCategory(
      idCategory: idCategory,
      categoryName: categoryName,
      gender: gender,
      inscriptionPrice: inscriptionPrice,
      quotas: quotas,
      isEnrolled: isEnrolled ?? this.isEnrolled,
    );
  }
}

class Tournament {
  final String idTournament;
  final String tournamentName;
  final String? description;
  final String? location;
  final String createdBy;
  final List<TournamentCategory> categories;

  Tournament({
    required this.idTournament,
    required this.tournamentName,
    this.description,
    this.location,
    required this.createdBy,
    required this.categories,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    final cats = (json["categories"] as List? ?? [])
        .map((e) => TournamentCategory.fromJson(e as Map<String, dynamic>))
        .toList();

    return Tournament(
      idTournament: json["id_tournament"] as String,
      tournamentName: json["tournament_name"] as String,
      description: json["description"] as String?,
      location: json["location"] as String?,
      createdBy: json["created_by"] as String,
      categories: cats,
    );
  }
}

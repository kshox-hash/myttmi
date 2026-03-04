class CalendarEvent {
  final DateTime date; // solo fecha
  final String tournamentId;
  final String tournamentName;
  final String? location;

  final String categoryId;
  final String categoryName;
  final String gender;

  CalendarEvent({
    required this.date,
    required this.tournamentId,
    required this.tournamentName,
    required this.location,
    required this.categoryId,
    required this.categoryName,
    required this.gender,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json["date"].toString()); // YYYY-MM-DD
    return CalendarEvent(
      date: DateTime(date.year, date.month, date.day),
      tournamentId: json["tournament_id"].toString(),
      tournamentName: json["tournament_name"].toString(),
      location: json["location"]?.toString(),
      categoryId: json["category_id"].toString(),
      categoryName: json["category_name"].toString(),
      gender: json["gender"].toString(),
    );
  }
}

import 'package:flutter/material.dart';
import '../domain/entities/tournament.dart';
import '../data/repo/tournament_repository.dart';

class AppStore extends ChangeNotifier {
  final TournamentRepository _repo = TournamentRepository();

  List<Tournament> _tournaments = [];
  bool _loading = false;

  List<Tournament> get tournaments => _tournaments;
  bool get loadingTournaments => _loading;

  Future<void> loadTournaments() async {
    _loading = true;
    notifyListeners();

    _tournaments = await _repo.fetchTournaments();

    _loading = false;
    notifyListeners();
  }
}

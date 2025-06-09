import 'package:flutter/material.dart';
import '../models/football_models.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart';

class FavoritesProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Competition> _favoriteCompetitions = [];
  List<Map<String, dynamic>> _favoriteTeamsData = [];
  bool _isLoading = true;

  List<Competition> get favoriteCompetitions => _favoriteCompetitions;
  List<Map<String, dynamic>> get favoriteTeamsData => _favoriteTeamsData;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    _favoriteCompetitions = await _dbHelper.getAllFavoriteCompetitions();
    _favoriteTeamsData = await _dbHelper.getAllFavoriteTeamsData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCompetitionToFavorites(Competition competition) async {
    await _dbHelper.addFavoriteCompetition(competition);
    await loadFavorites();
    await NotificationHelper.showNotification(
      'Favorit Liga',
      'Liga ${competition.name} ditambahkan ke favorit!',
    );
  }

  Future<void> addTeamToFavorites(Map<String, dynamic> team) async {
    await _dbHelper.addFavoriteTeam(team);
    await loadFavorites();
    await NotificationHelper.showNotification(
      'Favorit Tim',
      'Tim ${team['name']} ditambahkan ke favorit!',
    );
  }

  Future<void> removeCompetitionFromFavorites(int competitionId, {String? name}) async {
    await _dbHelper.removeFavoriteCompetition(competitionId);
    await loadFavorites();
    await NotificationHelper.showNotification(
      'Favorit Liga',
      'Liga ${name != null ? ' $name' : ''} dihapus dari favorit!',
    );
  }

  Future<void> removeTeamFromFavorites(int teamId, {String? name}) async {
    await _dbHelper.removeFavoriteTeam(teamId);
    await loadFavorites();
    await NotificationHelper.showNotification(
      'Favorit Tim',
      'Tim${name != null ? ' $name' : ''} dihapus dari favorit!',
    );
  }
}
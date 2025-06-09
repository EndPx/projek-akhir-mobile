import 'package:flutter/material.dart';
import '../models/football_models.dart';
import '../services/football_api_service.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart';

class TeamDetailProvider extends ChangeNotifier {
  final FootballApiService _apiService = FootballApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  TeamDetailResponse? _teamDetail;
  TeamDetailResponse? get teamDetail => _teamDetail;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadTeamDetail(int teamId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _teamDetail = await _apiService.getTeamDetails(teamId);
      await checkIfFavorite(teamId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkIfFavorite(int teamId) async {
    _isFavorite = await _dbHelper.isTeamFavorite(teamId);
    notifyListeners();
  }

  Future<void> toggleFavoriteTeam(int teamId) async {
    if (_teamDetail == null) return;
    if (_isFavorite) {
      await _dbHelper.removeFavoriteTeam(teamId);
      await NotificationHelper.showNotification(
        'Favorit Tim',
        'Tim ${_teamDetail!.name} dihapus dari favorit!',
      );
    } else {
      await _dbHelper.addFavoriteTeamFromDetail(_teamDetail!);
      await NotificationHelper.showNotification(
        'Favorit Tim',
        'Tim ${_teamDetail!.name} ditambahkan ke favorit!',
      );
    }
    await checkIfFavorite(teamId);
  }
}
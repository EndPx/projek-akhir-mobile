import 'package:flutter/material.dart';
import '../models/football_models.dart';
import '../services/football_api_service.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart';

class CompetitionsProvider extends ChangeNotifier {
  final FootballApiService _apiService = FootballApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Competition> _allCompetitions = [];
  List<Competition> get allCompetitions => _allCompetitions;

  List<Competition> _filteredCompetitions = [];
  List<Competition> get filteredCompetitions => _filteredCompetitions;

  Set<int> _favoriteCompetitionIds = {};
  Set<int> get favoriteCompetitionIds => _favoriteCompetitionIds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  CompetitionsProvider() {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await loadCompetitions();
    await loadFavoriteCompetitionIds();
  }

  Future<void> loadCompetitions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.getCompetitions();
      _allCompetitions = response.competitions;
      filterCompetitions();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFavoriteCompetitionIds() async {
    final favoriteCompetitions = await _dbHelper.getAllFavoriteCompetitions();
    _favoriteCompetitionIds = favoriteCompetitions.map((comp) => comp.id).toSet();
    notifyListeners();
  }

  void filterCompetitions({String? query}) {
    _searchQuery = (query ?? _searchQuery).toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredCompetitions = List.from(_allCompetitions);
    } else {
      _filteredCompetitions = _allCompetitions
          .where((competition) =>
              competition.name.toLowerCase().contains(_searchQuery) ||
              competition.area.name.toLowerCase().contains(_searchQuery))
          .toList();
    }
    notifyListeners();
  }

    Future<void> toggleFavoriteCompetition(Competition competition) async {
    final isFavorite = _favoriteCompetitionIds.contains(competition.id);
    if (isFavorite) {
      await _dbHelper.removeFavoriteCompetition(competition.id);
      await NotificationHelper.showNotification(
        'Favorit Liga',
        'Liga ${competition.name} dihapus dari favorit!',
      );
    } else {
      await _dbHelper.addFavoriteCompetition(competition);
      await NotificationHelper.showNotification(
        'Favorit Liga',
        'Liga ${competition.name} ditambahkan ke favorit!',
      );
    }
    await loadFavoriteCompetitionIds();
  }
}
import 'package:flutter/material.dart';
import '../models/football_models.dart';
import '../services/football_api_service.dart';

class StandingsProvider extends ChangeNotifier {
  final FootballApiService _apiService = FootballApiService();

  StandingsResponse? _standings;
  StandingsResponse? get standings => _standings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadStandings(int competitionId, {String? season}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _standings = await _apiService.getStandings(competitionId, season: season);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
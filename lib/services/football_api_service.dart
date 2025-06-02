import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/football_models.dart';

class FootballApiService {
  final String _baseUrl = 'https://api.football-data.org/v4';
  final String _apiKey = 'ceca8ed0ecd6406798e9c3a8f8c293e0';

  Future<CompetitionListResponse> getCompetitions() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/competitions'),
      headers: {
        'X-Auth-Token': _apiKey,
      },
    );

    if (kDebugMode) {
      print('GetCompetitions URL: ${Uri.parse('$_baseUrl/competitions')}');
      print('GetCompetitions Status: ${response.statusCode}');
      // print('GetCompetitions Body: ${response.body.substring(0, (response.body.length > 500 ? 500 : response.body.length))}...');
    }

    if (response.statusCode == 200) {
      return CompetitionListResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load competitions (Status: ${response.statusCode})');
    }
  }

  Future<StandingsResponse> getStandings(int competitionId, {String? season}) async {
    String url = '$_baseUrl/competitions/$competitionId/standings';
    Map<String, String> queryParams = {};
    if (season != null && season.isNotEmpty) {
      queryParams['season'] = season;
    }
    
    final uri = Uri.parse(url).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: {
        'X-Auth-Token': _apiKey,
      },
    );

    if (kDebugMode) {
      print('GetStandings URL: $uri');
      print('GetStandings Status: ${response.statusCode}');
      // print('GetStandings Body: ${response.body.substring(0, (response.body.length > 500 ? 500 : response.body.length))}...');
    }
    
    if (response.statusCode == 200) {
      return StandingsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load standings (Status: ${response.statusCode})');
    }
  }

  Future<TeamDetailResponse> getTeamDetails(int teamId) async {
    final String url = '$_baseUrl/teams/$teamId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-Auth-Token': _apiKey,
      },
    );

    if (kDebugMode) {
      print('GetTeamDetails URL: $url');
      print('GetTeamDetails Status: ${response.statusCode}');
      // print('GetTeamDetails Body: ${response.body.substring(0, (response.body.length > 500 ? 500 : response.body.length))}...');
    }

    if (response.statusCode == 200) {
      return TeamDetailResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load team details (Status: ${response.statusCode})');
    }
  }
}
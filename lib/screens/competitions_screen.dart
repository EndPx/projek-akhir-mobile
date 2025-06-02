import 'package:flutter/material.dart';
import '../models/football_models.dart';
import '../services/football_api_service.dart';
import '../helpers/database_helper.dart';
import '../screens/standings_screen.dart'; // Pastikan import ini benar

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  final FootballApiService _apiService = FootballApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Competition> _allCompetitions = [];
  List<Competition> _filteredCompetitions = [];
  String _searchQuery = '';
  bool _isLoadingCompetitions = true;
  String? _competitionsError;
  final TextEditingController _searchController = TextEditingController();

  Set<int> _favoriteCompetitionIds = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_filterCompetitionsListener);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCompetitionsListener);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadCompetitions();
    await _loadFavoriteCompetitionIds();
  }

  Future<void> _loadFavoriteCompetitionIds() async {
    final favoriteCompetitions = await _dbHelper.getAllFavoriteCompetitions();
    if (mounted) {
      setState(() {
        _favoriteCompetitionIds = favoriteCompetitions.map((comp) => comp.id).toSet();
      });
    }
  }

  Future<void> _loadCompetitions() async {
    setState(() {
      _isLoadingCompetitions = true;
      _competitionsError = null;
    });
    try {
      final response = await _apiService.getCompetitions();
      if (mounted) {
        setState(() {
          _allCompetitions = response.competitions
              .where((c) => c.plan == "TIER_ONE" && c.type != "CUP")
              .toList();
          _filterCompetitions();
          _isLoadingCompetitions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _competitionsError = 'Gagal memuat data kompetisi: ${e.toString()}';
          _isLoadingCompetitions = false;
        });
      }
    }
  }

  void _filterCompetitionsListener() {
    _filterCompetitions(query: _searchController.text);
  }

  void _filterCompetitions({String? query}) {
    final currentQuery = query ?? _searchQuery;
    setState(() {
      _searchQuery = currentQuery.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCompetitions = List.from(_allCompetitions);
      } else {
        _filteredCompetitions = _allCompetitions
            .where((competition) =>
                competition.name.toLowerCase().contains(_searchQuery) ||
                (competition.area.name.toLowerCase().contains(_searchQuery)))
            .toList();
      }
    });
  }
  
  Widget _buildTeamCrestImage(String? crestUrl, {double width = 24, double height = 24}) {
    if (crestUrl == null || crestUrl.isEmpty) {
      return SizedBox(width: width, height: height, child: Icon(Icons.shield_outlined, size: width * 0.8, color: Colors.grey.shade400));
    }
    return Image.network(
      crestUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(width: width, height: height, child: Icon(Icons.shield_outlined, size: width * 0.8, color: Colors.grey.shade400)),
    );
  }

  Future<void> _toggleFavoriteCompetition(Competition competition) async {
    final isCurrentlyFavorite = _favoriteCompetitionIds.contains(competition.id);
    if (isCurrentlyFavorite) {
      await _dbHelper.removeFavoriteCompetition(competition.id);
    } else {
      await _dbHelper.addFavoriteCompetition(competition);
    }
    await _loadFavoriteCompetitionIds();
  }
  
  Widget _buildErrorView(String message, VoidCallback onRetry) {
     return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(String message) {
     return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kompetisi atau negara...',
                prefixIcon: const Icon(Icons.search, size: 22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        // _filterCompetitions(); // Listener akan otomatis memanggil ini
                      }
                    )
                  : null,
              ),
            ),
          ),
          Expanded(
            child: _isLoadingCompetitions
                ? const Center(child: CircularProgressIndicator())
                : _competitionsError != null
                    ? _buildErrorView(_competitionsError!, _loadCompetitions)
                    : _allCompetitions.isEmpty && _searchQuery.isEmpty
                        ? _buildEmptyView('Tidak ada kompetisi Liga (TIER_ONE) yang tersedia saat ini.')
                        : _filteredCompetitions.isEmpty && _searchQuery.isNotEmpty
                            ? _buildEmptyView('Tidak ada kompetisi yang cocok dengan "$_searchQuery".')
                            : RefreshIndicator(
                                onRefresh: _loadInitialData,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                                  itemCount: _filteredCompetitions.length,
                                  itemBuilder: (context, index) {
                                    final competition = _filteredCompetitions[index];
                                    final bool isFavorite = _favoriteCompetitionIds.contains(competition.id);
                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                      elevation: 1.5,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.only(left: 16.0, right: 0, top: 8.0, bottom: 8.0),
                                        leading: _buildTeamCrestImage(competition.emblem, width: 40, height: 40),
                                        title: Text(competition.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        subtitle: Text('${competition.area.name} (${competition.type ?? 'N/A'})'),
                                        trailing: IconButton(
                                          icon: Icon(
                                            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                                            color: isFavorite ? Colors.amber.shade600 : Colors.grey,
                                            size: 28,
                                          ),
                                          onPressed: () => _toggleFavoriteCompetition(competition),
                                          tooltip: isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                                        ),
                                        onTap: () {
                                          String? seasonYear;
                                          if (competition.currentSeason?.startDate != null &&
                                              competition.currentSeason!.startDate.length >= 4) {
                                            seasonYear = competition.currentSeason!.startDate.substring(0, 4);
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => StandingsScreen(
                                                competitionId: competition.id,
                                                competitionName: competition.name,
                                                season: seasonYear,
                                              ),
                                            ),
                                          ).then((_) {
                                            _loadFavoriteCompetitionIds();
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
          ),
        ],
      ),
    );
  }
}
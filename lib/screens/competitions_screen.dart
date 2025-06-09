import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/competitions_provider.dart';
import '../screens/standings_screen.dart';

class CompetitionsScreen extends StatelessWidget {
  const CompetitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompetitionsProvider>(
      builder: (context, provider, _) {
        final leagueCompetitions = provider.filteredCompetitions
            .where((c) => c.plan == "TIER_ONE" && c.type != "CUP")
            .toList();

        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: TextField(
                  controller: TextEditingController(text: provider.searchQuery),
                  onChanged: (value) => provider.filterCompetitions(query: value),
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
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => provider.filterCompetitions(query: ''),
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                        ? _buildErrorView(context, provider.error!, provider.loadCompetitions)
                        : provider.allCompetitions.isEmpty && provider.searchQuery.isEmpty
                            ? _buildEmptyView('Tidak ada kompetisi Liga (TIER_ONE) yang tersedia saat ini.')
                            : leagueCompetitions.isEmpty && provider.searchQuery.isNotEmpty
                                ? _buildEmptyView('Tidak ada kompetisi yang cocok dengan "${provider.searchQuery}".')
                                : RefreshIndicator(
                                    onRefresh: provider.loadInitialData,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                                      itemCount: leagueCompetitions.length,
                                      itemBuilder: (context, index) {
                                        final competition = leagueCompetitions[index];
                                        final isFavorite = provider.favoriteCompetitionIds.contains(competition.id);
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
                                              onPressed: () => provider.toggleFavoriteCompetition(competition),
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
                                                provider.loadFavoriteCompetitionIds();
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
      },
    );
  }

  Widget _buildTeamCrestImage(String? crestUrl, {double width = 24, double height = 24}) {
    if (crestUrl == null || crestUrl.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: Icon(Icons.shield_outlined, size: width * 0.8, color: Colors.grey.shade400),
      );
    }
    return Image.network(
      crestUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: width,
        height: height,
        child: Icon(Icons.shield_outlined, size: width * 0.8, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message, VoidCallback onRetry) {
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
}
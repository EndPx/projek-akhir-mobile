import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/favorites_provider.dart';
import '../screens/team_detail_screen.dart';
import '../screens/standings_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Widget _buildCrestImage(String? crestUrl, {double width = 24, double height = 24}) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: provider.loadFavorites,
                  child: (provider.favoriteCompetitions.isEmpty && provider.favoriteTeamsData.isEmpty)
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                const Text(
                                  'Belum Ada Favorit',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tambahkan kompetisi atau tim ke favorit Anda untuk melihatnya di sini.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(8.0),
                          children: [
                            if (provider.favoriteCompetitions.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0).copyWith(bottom: 4.0),
                                child: Text(
                                  'Kompetisi Favorit',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...provider.favoriteCompetitions.map((competition) {
                                String? seasonYearForStandings;
                                if (competition.currentSeason?.startDate != null &&
                                    competition.currentSeason!.startDate.length >= 4) {
                                  seasonYearForStandings = competition.currentSeason!.startDate.substring(0, 4);
                                }
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  elevation: 1.5,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.only(left: 16.0, right: 0, top: 8.0, bottom: 8.0),
                                    leading: _buildCrestImage(competition.emblem, width: 36, height: 36),
                                    title: Text(competition.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                    subtitle: Text('${competition.area.name} (${competition.type ?? 'N/A'})'),
                                    trailing: IconButton(
                                      icon: Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 28),
                                      tooltip: 'Hapus dari Favorit',
                                      onPressed: () async {
                                        await provider.removeCompetitionFromFavorites(competition.id, name: competition.name);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Kompetisi dihapus dari favorit.')),
                                          );
                                        }
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StandingsScreen(
                                            competitionId: competition.id,
                                            competitionName: competition.name,
                                            season: seasonYearForStandings,
                                          ),
                                        ),
                                      ).then((_) => provider.loadFavorites());
                                    },
                                  ),
                                );
                              }).toList(),
                              if (provider.favoriteTeamsData.isNotEmpty)
                                const Divider(height: 24, thickness: 1, indent: 16, endIndent: 16),
                            ],
                            if (provider.favoriteTeamsData.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0)
                                    .copyWith(bottom: 4.0, top: provider.favoriteCompetitions.isNotEmpty ? 0 : 16.0),
                                child: Text(
                                  'Tim Favorit',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...provider.favoriteTeamsData.map((teamData) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  elevation: 1.5,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.only(left: 16.0, right: 0, top: 8.0, bottom: 8.0),
                                    leading: _buildCrestImage(teamData['crest'], width: 36, height: 36),
                                    title: Text(teamData['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                                    subtitle: teamData['areaName'] != null ? Text(teamData['areaName']) : null,
                                    trailing: IconButton(
                                      icon: Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 28),
                                      tooltip: 'Hapus dari Favorit',
                                      onPressed: () async {
                                        await provider.removeTeamFromFavorites(teamData['id'], name: teamData['name']);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Tim dihapus dari favorit.')),
                                          );
                                        }
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TeamDetailScreen(
                                            teamId: teamData['id'],
                                            teamName: teamData['name'],
                                          ),
                                        ),
                                      ).then((_) => provider.loadFavorites());
                                    },
                                  ),
                                );
                              }).toList(),
                            ]
                          ],
                        ),
                ),
        );
      },
    );
  }
}
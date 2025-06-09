import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/standings_provider.dart';
import '../models/football_models.dart';
import 'team_detail_screen.dart';

class StandingsScreen extends StatelessWidget {
  final int competitionId;
  final String competitionName;
  final String? season;

  const StandingsScreen({
    super.key,
    required this.competitionId,
    required this.competitionName,
    this.season,
  });

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

  Widget _buildCompetitionInfoInBody(BuildContext context, StandingsResponse response) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 10.0),
      child: Column(
        children: [
          if (response.season?.startDate != null)
            Text(
              'Musim: ${season ?? response.season!.startDate.substring(0, 4)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
          if (response.standings.isNotEmpty) ...[
            if (response.standings.first.group != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  'Grup: ${response.standings.first.group}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              )
            else if (response.standings.first.stage != "REGULAR_SEASON" && response.standings.first.stage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  'Stage: ${response.standings.first.stage}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
          ]
        ],
      ),
    );
  }

  Widget _buildStandingsListHeader(BuildContext context) {
    TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 11,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('#', style: headerStyle, textAlign: TextAlign.center)),
          const SizedBox(width: 8),
          Expanded(flex: 5, child: Text('Tim', style: headerStyle)),
          SizedBox(width: 24, child: Text('M', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 24, child: Text('W', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 24, child: Text('D', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 24, child: Text('L', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 30, child: Text('SG', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 30, child: Text('Poin', textAlign: TextAlign.center, style: headerStyle)),
        ],
      ),
    );
  }

  Widget _buildStandingsRow(BuildContext context, TableEntry entry, int index, bool isEvenRow) {
    TextStyle dataStyle = TextStyle(fontSize: 12.5, color: Theme.of(context).textTheme.bodyMedium?.color);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamDetailScreen(
              teamId: entry.team.id,
              teamName: entry.team.name,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        color: isEvenRow ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.15) : null,
        child: Row(
          children: [
            SizedBox(width: 24, child: Text(entry.position.toString(), textAlign: TextAlign.center, style: dataStyle.copyWith(fontWeight: FontWeight.w500))),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  _buildTeamCrestImage(entry.team.crest, width: 20, height: 20),
                  const SizedBox(width: 8),
                  Flexible(child: Text(entry.team.shortName ?? entry.team.name, overflow: TextOverflow.ellipsis, style: dataStyle)),
                ],
              ),
            ),
            SizedBox(width: 24, child: Text(entry.playedGames.toString(), textAlign: TextAlign.center, style: dataStyle)),
            SizedBox(width: 24, child: Text(entry.won.toString(), textAlign: TextAlign.center, style: dataStyle)),
            SizedBox(width: 24, child: Text(entry.draw.toString(), textAlign: TextAlign.center, style: dataStyle)),
            SizedBox(width: 24, child: Text(entry.lost.toString(), textAlign: TextAlign.center, style: dataStyle)),
            SizedBox(width: 30, child: Text(entry.goalDifference.toString(), textAlign: TextAlign.center, style: dataStyle)),
            SizedBox(width: 30, child: Text(entry.points.toString(), textAlign: TextAlign.center, style: dataStyle.copyWith(fontWeight: FontWeight.bold))),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StandingsProvider()..loadStandings(competitionId, season: season),
      child: Consumer<StandingsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: Builder(
                builder: (context) {
                  String titleText = competitionName;
                  Widget? leadingImage;
                  if (!provider.isLoading &&
                      provider.standings?.competition?.emblem != null) {
                    leadingImage = Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildTeamCrestImage(provider.standings!.competition!.emblem, height: 28, width: 28),
                    );
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leadingImage != null) leadingImage,
                      Flexible(child: Text(titleText, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18))),
                    ],
                  );
                },
              ),
              elevation: 1,
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? _buildErrorView(context, 'Gagal memuat klasemen: ${provider.error}', () => provider.loadStandings(competitionId, season: season))
                    : provider.standings == null || provider.standings!.standings.isEmpty
                        ? _buildEmptyView('Tidak ada data klasemen tersedia untuk kompetisi "$competitionName".')
                        : Builder(
                            builder: (context) {
                              final standingsResponse = provider.standings!;
                              StandingGroup? displayGroup;
                              try {
                                displayGroup = standingsResponse.standings.firstWhere((s) => s.type == 'TOTAL');
                              } catch (e) {
                                if (standingsResponse.standings.isNotEmpty) {
                                  displayGroup = standingsResponse.standings.first;
                                }
                              }
                              if (displayGroup == null || displayGroup.table.isEmpty) {
                                return _buildEmptyView("Tidak ada data klasemen (TOTAL) untuk ditampilkan pada kompetisi \"$competitionName\".");
                              }
                              return Column(
                                children: [
                                  _buildCompetitionInfoInBody(context, standingsResponse),
                                  _buildStandingsListHeader(context),
                                  Expanded(
                                    child: RefreshIndicator(
                                      onRefresh: () async => provider.loadStandings(competitionId, season: season),
                                      child: ListView.separated(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        itemCount: displayGroup!.table.length,
                                        itemBuilder: (context, index) {
                                          return _buildStandingsRow(context, displayGroup!.table[index], index, index % 2 == 0);
                                        },
                                        separatorBuilder: (context, index) => const Divider(height: 0.5, thickness: 0.5, indent: 16, endIndent: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
          );
        },
      ),
    );
  }
}
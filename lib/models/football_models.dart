class Area {
  final int id;
  final String name;
  final String? code;
  final String? flag;

  Area({
    required this.id,
    required this.name,
    this.code,
    this.flag,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
      flag: json['flag'] as String?,
    );
  }
}

class Competition {
  final int id;
  final Area area;
  final String name;
  final String? code;
  final String? type;
  final String? emblem;
  final String? plan;
  final CurrentSeason? currentSeason;

  Competition({
    required this.id,
    required this.area,
    required this.name,
    this.code,
    this.type,
    this.emblem,
    this.plan,
    this.currentSeason,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'] as int,
      area: Area.fromJson(json['area'] as Map<String, dynamic>),
      name: json['name'] as String,
      code: json['code'] as String?,
      type: json['type'] as String?,
      emblem: json['emblem'] as String?,
      plan: json['plan'] as String?,
      currentSeason: json['currentSeason'] != null
          ? CurrentSeason.fromJson(json['currentSeason'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CurrentSeason {
  final int id;
  final String startDate;

  CurrentSeason({
    required this.id,
    required this.startDate,
  });

  factory CurrentSeason.fromJson(Map<String, dynamic> json) {
    return CurrentSeason(
      id: json['id'] as int,
      startDate: json['startDate'] as String,
    );
  }
}

class CompetitionListResponse {
  final int count;
  final List<Competition> competitions;

  CompetitionListResponse({
    required this.count,
    required this.competitions,
  });

  factory CompetitionListResponse.fromJson(Map<String, dynamic> json) {
    return CompetitionListResponse(
      count: json['count'] ?? 0,
      competitions: (json['competitions'] as List<dynamic>? ?? [])
          .map((e) => Competition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TeamInfo {
  final int id;
  final String name;
  final String? shortName;
  final String? tla;
  final String? crest;

  TeamInfo({
    required this.id,
    required this.name,
    this.shortName,
    this.tla,
    this.crest,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      tla: json['tla'] as String?,
      crest: json['crest'] as String?,
    );
  }
}

class TableEntry {
  final int position;
  final TeamInfo team;
  final int playedGames;
  final int won;
  final int draw;
  final int lost;
  final int points;
  final int goalDifference;

  TableEntry({
    required this.position,
    required this.team,
    required this.playedGames,
    required this.won,
    required this.draw,
    required this.lost,
    required this.points,
    required this.goalDifference,
  });

  factory TableEntry.fromJson(Map<String, dynamic> json) {
    return TableEntry(
      position: json['position'] as int,
      team: TeamInfo.fromJson(json['team'] as Map<String, dynamic>),
      playedGames: json['playedGames'] as int,
      won: json['won'] as int,
      draw: json['draw'] as int,
      lost: json['lost'] as int,
      points: json['points'] as int,
      goalDifference: json['goalDifference'] as int,
    );
  }
}

class StandingGroup {
  final String stage;
  final String type;
  final String? group;
  final List<TableEntry> table;

  StandingGroup({
    required this.stage,
    required this.type,
    this.group,
    required this.table,
  });

  factory StandingGroup.fromJson(Map<String, dynamic> json) {
    return StandingGroup(
      stage: json['stage'] as String,
      type: json['type'] as String,
      group: json['group'] as String?,
      table: (json['table'] as List<dynamic>? ?? [])
          .map((e) => TableEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StandingsResponse {
  final List<StandingGroup> standings;
  final SeasonInfo? season;
  final CompetitionInfo? competition;

  StandingsResponse({
    required this.standings,
    this.season,
    this.competition,
  });

  factory StandingsResponse.fromJson(Map<String, dynamic> json) {
    return StandingsResponse(
      standings: (json['standings'] as List<dynamic>? ?? [])
          .map((e) => StandingGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      season: json['season'] != null ? SeasonInfo.fromJson(json['season']) : null,
      competition: json['competition'] != null ? CompetitionInfo.fromJson(json['competition']) : null,
    );
  }
}

class SeasonInfo {
  final String startDate;

  SeasonInfo({
    required this.startDate,
  });

  factory SeasonInfo.fromJson(Map<String, dynamic> json) {
    return SeasonInfo(
      startDate: json['startDate'] as String,
    );
  }
}

class CompetitionInfo {
  final int id;
  final String name;
  final String? emblem;

  CompetitionInfo({
    required this.id,
    required this.name,
    this.emblem,
  });

  factory CompetitionInfo.fromJson(Map<String, dynamic> json) {
    return CompetitionInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      emblem: json['emblem'] as String?,
    );
  }
}

class RunningCompetition {
  final int id;
  final String name;
  final String? code;
  final String? type;
  final String? emblem;

  RunningCompetition({
    required this.id,
    required this.name,
    this.code,
    this.type,
    this.emblem,
  });

  factory RunningCompetition.fromJson(Map<String, dynamic> json) {
    return RunningCompetition(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
      type: json['type'] as String?,
      emblem: json['emblem'] as String?,
    );
  }
}

class Contract {
  final String? start;
  final String? until;

  Contract({this.start, this.until});

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      start: json['start'] as String?,
      until: json['until'] as String?,
    );
  }
}

class Coach {
  final String? name;
  final String? dateOfBirth;
  final String? nationality;
  final Contract? contract;

  Coach({
    this.name,
    this.dateOfBirth,
    this.nationality,
    this.contract,
  });

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      name: json['name'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      nationality: json['nationality'] as String?,
      contract: json['contract'] != null ? Contract.fromJson(json['contract']) : null,
    );
  }
}

class Player {
  final int id;
  final String name;
  final String? position;
  final String? dateOfBirth;
  final String? nationality;
  final int? shirtNumber;
  final int? marketValue;

  Player({
    required this.id,
    required this.name,
    this.position,
    this.dateOfBirth,
    this.nationality,
    this.shirtNumber,
    this.marketValue,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as int,
      name: json['name'] as String,
      position: json['position'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      nationality: json['nationality'] as String?,
      shirtNumber: json['shirtNumber'] as int?,
      marketValue: json['marketValue'] as int?,
    );
  }
}

class TeamDetailResponse {
  final Area? area;
  final int id;
  final String name;
  final String? shortName;
  final String? tla;
  final String? crest;
  final String? address;
  final String? website;
  final int? founded;
  final String? clubColors;
  final String? venue;
  final List<RunningCompetition> runningCompetitions;
  final Coach? coach;
  final int? marketValue;
  final List<Player> squad;
  final String? lastUpdated;

  TeamDetailResponse({
    this.area,
    required this.id,
    required this.name,
    this.shortName,
    this.tla,
    this.crest,
    this.address,
    this.website,
    this.founded,
    this.clubColors,
    this.venue,
    required this.runningCompetitions,
    this.coach,
    this.marketValue,
    required this.squad,
    this.lastUpdated,
  });

  factory TeamDetailResponse.fromJson(Map<String, dynamic> json) {
    return TeamDetailResponse(
      area: json['area'] != null ? Area.fromJson(json['area']) : null,
      id: json['id'] as int,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      tla: json['tla'] as String?,
      crest: json['crest'] as String?,
      address: json['address'] as String?,
      website: json['website'] as String?,
      founded: json['founded'] as int?,
      clubColors: json['clubColors'] as String?,
      venue: json['venue'] as String?,
      runningCompetitions: (json['runningCompetitions'] as List<dynamic>? ?? [])
          .map((e) => RunningCompetition.fromJson(e as Map<String, dynamic>))
          .toList(),
      coach: json['coach'] != null ? Coach.fromJson(json['coach']) : null,
      marketValue: json['marketValue'] as int?,
      squad: (json['squad'] as List<dynamic>? ?? [])
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['lastUpdated'] as String?,
    );
  }
}
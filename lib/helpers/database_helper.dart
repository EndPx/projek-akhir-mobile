import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/football_models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _dbName = 'app_local_database.db';
  static const int _dbVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel User
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT, 
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');
    // Tabel kompetisi favorit
    await db.execute('''
      CREATE TABLE favorite_competitions(
        id INTEGER PRIMARY KEY, 
        name TEXT,
        areaName TEXT,
        emblem TEXT,
        type TEXT 
      )
    ''');
    // Tabel tim favorit
    await db.execute('''
      CREATE TABLE favorite_teams(
        id INTEGER PRIMARY KEY,
        name TEXT,
        shortName TEXT,
        tla TEXT,
        crest TEXT,
        areaName TEXT 
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('''
          CREATE TABLE favorite_competitions(
            id INTEGER PRIMARY KEY,
            name TEXT,
            areaName TEXT,
            emblem TEXT,
            type TEXT
          )
        ''');
      } catch (e) {
        print("Error creating favorite_competitions on upgrade (maybe already exists): $e");
      }
      try {
        await db.execute('''
          CREATE TABLE favorite_teams(
            id INTEGER PRIMARY KEY,
            name TEXT,
            shortName TEXT,
            tla TEXT,
            crest TEXT,
            areaName TEXT
          )
        ''');
      } catch (e) {
         print("Error creating favorite_teams on upgrade (maybe already exists): $e");
      }
    }
    // Tambahkan blok if lain untuk migrasi versi berikutnya (oldVersion < 3, dst.)
  }

  // --- Metode untuk User ---
  Future<int> registerUser(User user) async {
    final db = await database;
    try {
      Map<String, dynamic> userMap = user.toMap();
      if (user.id == null) {
        userMap.remove('id');
      }
      return await db.insert('users', userMap, conflictAlgorithm: ConflictAlgorithm.abort);
    } catch (e) {
      print('Error registering user: $e');
      return -1;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUsername(String email, String newUsername) async {
    final db = await database;
    return await db.update(
      'users',
      {'username': newUsername},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // --- METODE UNTUK KOMPETISI FAVORIT ---
  Future<void> addFavoriteCompetition(Competition competition) async {
    final db = await database;
    await db.insert(
      'favorite_competitions',
      {
        'id': competition.id,
        'name': competition.name,
        'areaName': competition.area.name,
        'emblem': competition.emblem,
        'type': competition.type,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavoriteCompetition(int competitionId) async {
    final db = await database;
    await db.delete(
      'favorite_competitions',
      where: 'id = ?',
      whereArgs: [competitionId],
    );
  }

  Future<bool> isCompetitionFavorite(int competitionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorite_competitions',
      where: 'id = ?',
      whereArgs: [competitionId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<List<Competition>> getAllFavoriteCompetitions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorite_competitions');
    return List.generate(maps.length, (i) {
      return Competition(
        id: maps[i]['id'],
        name: maps[i]['name'],
        area: Area(id: 0, name: maps[i]['areaName']),
        emblem: maps[i]['emblem'],
        type: maps[i]['type'],
      );
    });
  }

  // --- METODE UNTUK TIM FAVORIT ---
  // Menyimpan dari objek TeamInfo (misalnya dari klasemen)
  Future<void> addFavoriteTeamFromInfo(TeamInfo team, String? teamAreaName) async {
    final db = await database;
    await db.insert(
      'favorite_teams',
      {
        'id': team.id,
        'name': team.name,
        'shortName': team.shortName,
        'tla': team.tla,
        'crest': team.crest,
        'areaName': teamAreaName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Menyimpan dari objek TeamDetailResponse (jika Anda memiliki detail lengkapnya)
  Future<void> addFavoriteTeamFromDetail(TeamDetailResponse team) async {
    final db = await database;
    await db.insert(
      'favorite_teams',
      {
        'id': team.id,
        'name': team.name,
        'shortName': team.shortName,
        'tla': team.tla,
        'crest': team.crest,
        'areaName': team.area?.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Menyimpan tim favorit dari Map (untuk kebutuhan Provider)
  Future<void> addFavoriteTeam(Map<String, dynamic> team) async {
    final db = await database;
    await db.insert(
      'favorite_teams',
      team,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavoriteTeam(int teamId) async {
    final db = await database;
    await db.delete(
      'favorite_teams',
      where: 'id = ?',
      whereArgs: [teamId],
    );
  }

  Future<bool> isTeamFavorite(int teamId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorite_teams',
      where: 'id = ?',
      whereArgs: [teamId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAllFavoriteTeamsData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorite_teams');
    return maps;
  }
}
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:teeoffclub/data/models/sports/golf_game.dart';
import 'package:teeoffclub/data/models/sports/golf_course.dart';

/// [DatabaseHelper] provides a centralized service for SQLite data persistence.
/// It manages the lifecycle of the local database and handles CRUD operations
/// for golf games, players, and golf course metadata.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Returns the singleton database instance, initializing it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('teeoffclub.db');
    return _database!;
  }

  /// Initializes the local SQLite database at the specified [filePath].
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Upgraded version for new table
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Handles schema migrations when the database [version] increases.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createCoursesTable(db);
    }
  }

  /// Defines the initial structure of the standard database tables.
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id TEXT,
        course_name TEXT NOT NULL,
        date_created TEXT NOT NULL,
        players TEXT NOT NULL,
        format TEXT NOT NULL,
        total_holes INTEGER NOT NULL,
        is_live INTEGER NOT NULL
      )
    ''');
    await _createCoursesTable(db);
  }

  /// Specifically creates the metadata table for golf courses.
  Future _createCoursesTable(Database db) async {
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        total_holes INTEGER NOT NULL,
        holes TEXT NOT NULL,
        difficulty TEXT,
        rating REAL,
        slope REAL
      )
    ''');
  }

  /// Inserts a new game record or updates an existing one based on the presence of an ID.
  /// Returns the assigned unique ID for the game.
  Future<int> insertGame(GolfGame game) async {
    final db = await instance.database;
    final jsonPlayers = jsonEncode(game.players.map((e) => e.toJson()).toList());
    
    final values = {
      'course_id': game.courseId,
      'course_name': game.courseName,
      'date_created': game.dateCreated.toIso8601String(),
      'players': jsonPlayers,
      'format': game.format.name,
      'total_holes': game.totalHoles,
      'is_live': game.isLive ? 1 : 0,
    };

    if (game.id != null) {
      await db.update('games', values, where: 'id = ?', whereArgs: [game.id]);
      return game.id!;
    } else {
      return await db.insert('games', values);
    }
  }

  /// Permanently removes all saved game history from the local storage.
  Future<void> deleteAllGames() async {
    final db = await database;
    await db.delete('games');
  }

  /// Deletes a specific game record from the database by its unique [id].
  Future<void> deleteGame(int id) async {
    final db = await database;
    await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  // COURSE METHODS

  /// Performs a batch insertion of multiple [GolfCourse] records into the database.
  /// Replaces existing records if an ID conflict occurs.
  Future<void> insertCourses(List<GolfCourse> courses) async {
    final db = await database;
    final batch = db.batch();
    for (var course in courses) {
      batch.insert('courses', {
        'id': course.id,
        'name': course.name,
        'location': course.location,
        'total_holes': course.totalHoles,
        'holes': jsonEncode(course.holes.map((h) => h.toJson()).toList()),
        'difficulty': course.difficulty,
        'rating': course.rating,
        'slope': course.slope,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  /// Retrieves the list of all available [GolfCourse] records stored in the database.
  Future<List<GolfCourse>> getCourses() async {
    final db = await database;
    final result = await db.query('courses');
    
    return result.map((map) {
      final jsonHoles = jsonDecode(map['holes'] as String) as List;
      final holes = jsonHoles.map((h) => HoleData.fromJson(h as Map<String, dynamic>)).toList();

      return GolfCourse(
        id: map['id'] as String,
        name: map['name'] as String,
        location: map['location'] as String,
        totalHoles: map['total_holes'] as int,
        holes: holes,
        difficulty: map['difficulty'] as String?,
        rating: map['rating'] as double?,
        slope: map['slope'] as double?,
      );
    }).toList();
  }

  /// Fetches all previously saved rounds, converting them from SQLite format to [GolfGame] objects.
  Future<List<GolfGame>> getAllGames() async {
    final db = await database;
    final query = await db.query('games');

    return query.map((map) {
      final List<dynamic> jsonPlayersList = jsonDecode(map['players'] as String);
      final players = jsonPlayersList.map((p) => Player.fromJson(p)).toList();

      return GolfGame(
        id: map['id'] as int?,
        courseId: map['course_id'] as String?,
        courseName: map['course_name'] as String,
        dateCreated: DateTime.parse(map['date_created'] as String),
        players: players,
        format: GameFormat.values.byName(map['format'] as String),
        totalHoles: map['total_holes'] as int,
        isLive: (map['is_live'] as int) == 1,
      );
    }).toList();
  }

  /// Closes the database connection to release system resources.
  Future close() async {
    final db = await database;
    db.close();
  }
}


import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/study_session.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // Get database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB();
    return _database!;
  }

  // Create database
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'studytrack.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create study sessions table
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE study_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        study_type TEXT NOT NULL,
        study_date TEXT NOT NULL,
        duration INTEGER NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Insert new study session
  Future<int> insertSession(StudySession session) async {
    final db = await instance.database;

    return await db.insert(
      'study_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get total number of sessions
  Future<int> getSessionCount() async {
    final db = await instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM study_sessions'
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get sessions with pagination
  Future<List<StudySession>> getSessions(int limit, int offset) async {
    final db = await instance.database;

    final result = await db.query(
      'study_sessions',
      orderBy: 'created_at DESC, id DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((map) => StudySession.fromMap(map)).toList();
  }

  // Update existing study session
  Future<int> updateSession(StudySession session) async {
    final db = await instance.database;

    return await db.update(
      'study_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  // Delete study session
  Future<int> deleteSession(int id) async {
    final db = await instance.database;

    return await db.delete(
      'study_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete multiple study sessions
  Future<int> deleteMultipleSessions(List<int> ids) async {
    if (ids.isEmpty) {
      return 0;
    }

    final db = await instance.database;

    final placeholders = List.filled(ids.length, '?').join(',');

    return await db.delete(
      'study_sessions',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  // Get IDs of all study sessions
  Future<List<int>> getAllSessionIds() async {
    final db = await instance.database;

    final result = await db.query(
      'study_sessions',
      columns: ['id'],
    );

    return result.map((row) => row['id'] as int).toList();
  }
}

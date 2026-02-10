import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/disaster_warning.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('meshcue_connect.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE warnings (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        severity TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        expiresAt TEXT,
        radiusKm REAL NOT NULL,
        reportedBy TEXT,
        source TEXT,
        upvotes INTEGER NOT NULL DEFAULT 0,
        isVerified INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_warnings_location ON warnings(latitude, longitude)
    ''');

    await db.execute('''
        CREATE INDEX idx_warnings_timestamp ON warnings(timestamp DESC)
    ''');
  }

  Future<void> insertWarning(DisasterWarning warning) async {
    final db = await database;
    await db.insert(
      'warnings',
      warning.toJSON(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DisasterWarning>> getActiveWarnings() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'warnings',
      where: 'expiresAt IS NULL OR expiresAt > ?',
      whereArgs: [now],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => DisasterWarning.fromJSON(map)).toList();
  }

  Future<List<DisasterWarning>> getWarningsInArea({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) async {
    final db = await database;

    final latDelta = radiusKm / 111.0;
    final lngDelta = radiusKm / (111.0 * cos(centerLat * pi / 180));

    final List<Map<String, dynamic>> maps = await db.query(
      'warnings',
      where: '''
        latitude BETWEEN ? AND ?
        AND longitude BETWEEN ? AND ?
        AND (expiresAt IS NULL OR expiresAt > ?)
      ''',
      whereArgs: [
        centerLat - latDelta,
        centerLat + latDelta,
        centerLng - lngDelta,
        centerLng + lngDelta,
        DateTime.now().toIso8601String(),
      ],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => DisasterWarning.fromJSON(map)).toList();
  }

  Future<DisasterWarning?> getWarningById (String id) async {
    final db = await database;
    final maps = await db.query(
      'warnings',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return DisasterWarning.fromJSON(maps.first);
  }

  Future<void> deleteWarning (String id) async {
    final db = await database;
    await db.delete(
      'warnings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExpiredWarnings() async {
    final db = await database;

    return await db.delete(
      'warnings',
      where: 'expiresAt is NOT NULL AND expiresAt < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }

  Future<void> upvoteWarning (String id) async {
    final db = await database;

    await db.rawUpdate(
      'UPDATE warnings SET upvotes = upvotes + 1 WHERE id = ?',
      [id],
    );
  }

  Future<int> getWarningCount() async {
    final db = await database;
    final result = await db.query('SELECT COUNT(*) FROM warnings');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
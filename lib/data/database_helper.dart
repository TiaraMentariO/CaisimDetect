import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    await Permission.manageExternalStorage.request();
    final dbPath = await getDownloadsDirectory();

    Directory(dbPath!.path).create(recursive: true);

    final path = join(dbPath.path, 'hama.db');

    print('Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE PrediksiHama (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jenis_hama TEXT,
        nama_latin TEXT,
        persentase REAL,
        ciri_ciri TEXT,
        cara_penanganan TEXT,
        path TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<int> insertData(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> getPrediksiHama() async {
    final db = await database;
    return await db.query('PrediksiHama');
  }

  Future<Map<String, int>> getDetectionCountsByJenisHamaInRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'PrediksiHama',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    Map<String, int> detectionCounts = {};
    for (var map in maps) {
      String jenisHama = map['jenis_hama'];
      if (detectionCounts.containsKey(jenisHama)) {
        detectionCounts[jenisHama] = detectionCounts[jenisHama]! + 1;
      } else {
        detectionCounts[jenisHama] = 1;
      }
    }
    return detectionCounts;
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._();

  static Database? _database;
  final String _dbPath = '/storage/emulated/0/Download/mudabbir_models/mudabbir.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    return await openDatabase(_dbPath, readOnly: true);
  }

  String get databasePath => _dbPath;
}

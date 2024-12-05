import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDb();
    }
    return _database!;
  }

  Future<Database> _initDb() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'fdo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fdo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        color TEXT,
        size TEXT,
        image_path TEXT
      )
    ''');
  }

  Future<int> updateFDO(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update(
      'fdo',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._privateConstructor();

  static Database? _database;

  static const String _databaseName = 'todo.db';
  static const int _databaseVersion = 1;

  DbHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    print(databasesPath);
    String path = join(databasesPath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS todo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        completed INTEGER
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await database;
    try {
      return await db.query('todo');
    } catch (e) {
      await _onCreate(db, _databaseVersion);
      return [];
    }
  }

  Future<void> insert(Map<String, dynamic> row) async {
    Database db = await database;
    await db.insert('todo', row);
  }

  Future<void> update(int id, Map<String, dynamic> row) async {
    Database db = await database;
    await db.update('todo', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete('todo', where: 'id = ?', whereArgs: [id]);
  }
}

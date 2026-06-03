import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/subscriber.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'generator.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE subscribers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT,
            category TEXT,
            pricePerAmpere REAL,
            amperes REAL,
            amountReceived REAL,
            previousDebt REAL,
            cabinet TEXT,
            fuse TEXT,
            expiryDate TEXT,
            notes TEXT
          )
        ''');
      },
    );
  }

  Future<List<Subscriber>> getAll() async {
    final db = await database;
    final rows = await db.query('subscribers', orderBy: 'name COLLATE NOCASE');
    return rows.map((e) => Subscriber.fromMap(e)).toList();
  }

  Future<int> insert(Subscriber s) async {
    final db = await database;
    final map = s.toMap()..remove('id');
    return db.insert('subscribers', map);
  }

  Future<int> update(Subscriber s) async {
    final db = await database;
    return db.update('subscribers', s.toMap(),
        where: 'id = ?', whereArgs: [s.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('subscribers', where: 'id = ?', whereArgs: [id]);
  }
}

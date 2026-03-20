import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;
  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('serene_log.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        time TEXT,
        color INTEGER DEFAULT 0xFF6B9E78
      )
    ''');
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE journals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        mood TEXT DEFAULT 'neutral'
      )
    ''');
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        links TEXT,
        notes TEXT
      )
    ''');
  }

  // ── EVENTS ──
  Future<int> insertEvent(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('events', row);
  }
  Future<List<Map<String, dynamic>>> getEventsByDate(String date) async {
    final db = await database;
    return await db.query('events', where: 'date = ?', whereArgs: [date]);
  }
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final db = await database;
    return await db.query('events', orderBy: 'date ASC');
  }
  Future<int> updateEvent(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('events', row, where: 'id = ?', whereArgs: [row['id']]);
  }
  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // ── TODOS ──
  Future<int> insertTodo(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('todos', row);
  }
  Future<List<Map<String, dynamic>>> getTodosByDate(String date) async {
    final db = await database;
    return await db.query('todos', where: 'date = ?', whereArgs: [date]);
  }
  Future<int> updateTodo(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('todos', row, where: 'id = ?', whereArgs: [row['id']]);
  }
  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  // ── JOURNALS ──
  Future<int> insertJournal(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('journals', row);
  }
  Future<List<Map<String, dynamic>>> getAllJournals() async {
    final db = await database;
    return await db.query('journals', orderBy: 'date DESC, time DESC');
  }
  Future<int> updateJournal(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('journals', row, where: 'id = ?', whereArgs: [row['id']]);
  }
  Future<int> deleteJournal(int id) async {
    final db = await database;
    return await db.delete('journals', where: 'id = ?', whereArgs: [id]);
  }

  // ── CONTACTS ──
  Future<int> insertContact(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('contacts', row);
  }
  Future<List<Map<String, dynamic>>> getAllContacts() async {
    final db = await database;
    return await db.query('contacts', orderBy: 'name ASC');
  }
  Future<int> updateContact(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('contacts', row, where: 'id = ?', whereArgs: [row['id']]);
  }
  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}
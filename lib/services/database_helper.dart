import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local relational storage for student records on native platforms.
/// On web, ProfileScreen falls back to SharedPreferences since sqflite
/// has no file system to write to in a browser.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_portal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        admission_no TEXT NOT NULL,
        course TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertStudent(Map<String, dynamic> row) async {
    final db = await instance.database;
    return db.insert('students', row);
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await instance.database;
    return db.query('students');
  }

  Future<int> deleteAllStudents() async {
    final db = await instance.database;
    return db.delete('students');
  }
}

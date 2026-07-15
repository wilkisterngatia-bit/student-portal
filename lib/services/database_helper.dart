import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  /// CREATE — inserts a new student record, returns the new row's id.
  Future<int> insertStudent(Map<String, dynamic> row) async {
    final db = await instance.database;
    return db.insert('students', row);
  }

  /// READ — returns every student record.
  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await instance.database;
    return db.query('students');
  }

  /// READ — returns a single student record by id, or null if not found.
  /// Useful for pre-filling an edit form before calling updateStudent().
  Future<Map<String, dynamic>?> getStudentById(int id) async {
    final db = await instance.database;
    final results = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// UPDATE — modifies an existing student record by id. Returns the
  /// number of rows affected (1 if the id existed, 0 otherwise).
  Future<int> updateStudent(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return db.update(
      'students',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// DELETE — removes a single student record by id. Returns the
  /// number of rows affected. This is the targeted delete the CRUD
  /// requirement asks for, as opposed to wiping the whole table.
  Future<int> deleteStudent(int id) async {
    final db = await instance.database;
    return db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Bulk delete — kept for cases like "reset local cache", but this
  /// is NOT the CRUD "Delete" operation itself; deleteStudent(id) is.
  Future<int> deleteAllStudents() async {
    final db = await instance.database;
    return db.delete('students');
  }
}
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'cotab.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  // Opens the database the first time it is needed and reuses it afterwards.
  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
    );
    return _database!;
  }

  // Runs only once, when the database file is created for the first time.
  // IDs are TEXT because they will come from Firebase.
  // updated_at and deleted_at are milliseconds since epoch. They are used for
  // syncing: the newer updated_at wins, and a row with deleted_at set counts
  // as deleted (it is not removed, so the deletion can be synced too).
  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        avatar_url TEXT,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        currency TEXT NOT NULL,
        invite_code TEXT NOT NULL UNIQUE,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');
  }
}

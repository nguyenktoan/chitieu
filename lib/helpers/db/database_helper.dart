import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'migrations/migration_v1.dart';

class DatabaseHelper {
  static Database? _database;

  // Hàm mở hoặc tạo mới database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Khởi tạo database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transactions.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await MigrationV1.createTables(db); // Tạo các bảng
        await MigrationV1.insertSampleData(db); // Chèn dữ liệu mẫu
      },
    );
  }

  // Hàm đóng database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

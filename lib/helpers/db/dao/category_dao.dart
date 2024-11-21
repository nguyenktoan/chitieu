import 'package:chitieu/helpers/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class CategoryDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Thêm danh mục vào bảng
  Future<void> insertCategory(Database db, Map<String, dynamic> category) async {
    await db.insert(
      'categories',
      category,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Lấy tất cả danh mục lọc theo category_type (income hoặc expense)
  Future<List<Map<String, dynamic>>> fetchCategories(Database db, String categoryType) async {
    return await db.query(
      'categories',
      where: 'category_type = ?',
      whereArgs: [categoryType],  // Lọc theo category_type (income hoặc expense)
    );
  }
}

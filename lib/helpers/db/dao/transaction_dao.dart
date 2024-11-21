import 'package:chitieu/helpers/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class TransactionDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Thêm giao dịch vào bảng
  Future<void> insertTransaction(Database db, Map<String, dynamic> transaction) async {
    await db.insert(
      'transactions',
      transaction,
      conflictAlgorithm: ConflictAlgorithm.replace, // Thay thế nếu xung đột
    );
  }

  // Lấy tất cả giao dịch, sắp xếp theo ngày giảm dần
  Future<List<Map<String, dynamic>>> fetchTransactions(Database db) async {
    return await db.rawQuery('''
      SELECT 
        t.id, t.amount, t.note, t.date, 
        LOWER(c.category_type) AS category_type, 
        c.name AS category_name, 
        c.icon, c.color
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      ORDER BY t.date DESC  
    ''');
  }

  // Lấy 5 giao dịch gần nhất
  Future<List<Map<String, dynamic>>> fetchRecentTransactions(Database db) async {
    return await db.rawQuery('''
      SELECT 
        t.id, t.amount, t.note, t.date, 
        LOWER(c.category_type) AS category_type, 
        c.name AS category_name, 
        c.icon, c.color
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      ORDER BY t.date DESC  
      LIMIT 5  
    ''');
  }

  // Cập nhật giao dịch
  Future<void> updateTransaction(Database db, Map<String, dynamic> transaction) async {
    await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [transaction['id']],
    );
  }


  // Cập nhật giao dịch với dữ liệu cụ thể (số tiền và loại giao dịch)
  Future<int> updateTransactionInDatabase(Database db, int transactionId, int amount, String type) async {
    return await db.update(
      'transactions',
      {'amount': amount, 'category_type': type.toLowerCase()},
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }

  // Tính tổng thu nhập, chi tiêu và số dư
  Future<Map<String, int>> calculateBalance(Database db) async {
    // Tính tổng thu nhập
    final incomeResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total_income
      FROM transactions
      WHERE LOWER(category_type) = 'income'
    ''');
    final income = (incomeResult[0]['total_income'] as int?) ?? 0;

    // Tính tổng chi tiêu
    final expenseResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total_expense
      FROM transactions
      WHERE LOWER(category_type) = 'expense'
    ''');
    final expense = (expenseResult[0]['total_expense'] as int?) ?? 0;

    // Tính số dư
    final balance = income - expense;

    return {
      'income': income,
      'expense': expense,
      'balance': balance,
    };
  }



  // Xóa giao dịch
  Future<int> deleteTransaction(Database db, int transactionId) async {
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }


}



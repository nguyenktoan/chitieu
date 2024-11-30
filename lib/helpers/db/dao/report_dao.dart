import 'package:sqflite/sqflite.dart';
import 'package:chitieu/helpers/db/database_helper.dart';
import 'package:chitieu/helpers/db/models/transaction_model.dart';

class ReportDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Calculate total balance, income, and expenses with filters
  Future<Map<String, int>> calculateFilteredBalance({
    String? categoryName,
    String? categoryType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;

    // Calculate total income with filters
    final incomeQuery = StringBuffer('''
      SELECT COALESCE(SUM(amount), 0) AS total_income
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      WHERE LOWER(c.category_type) = 'income'
    ''');

    if (categoryName != null) {
      incomeQuery.write(" AND c.name LIKE '%$categoryName%'");
    }
    if (startDate != null && endDate != null) {
      incomeQuery.write(" AND t.date BETWEEN '${startDate.toIso8601String()}' AND '${endDate.toIso8601String()}'");
    }

    final incomeResult = await db.rawQuery(incomeQuery.toString());
    final income = (incomeResult[0]['total_income'] as int?) ?? 0;

    // Calculate total expenses with filters
    final expenseQuery = StringBuffer('''
      SELECT COALESCE(SUM(amount), 0) AS total_expense
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      WHERE LOWER(c.category_type) = 'expense'
    ''');

    if (categoryName != null) {
      expenseQuery.write(" AND c.name LIKE '%$categoryName%'");
    }
    if (startDate != null && endDate != null) {
      expenseQuery.write(" AND t.date BETWEEN '${startDate.toIso8601String()}' AND '${endDate.toIso8601String()}'");
    }

    final expenseResult = await db.rawQuery(expenseQuery.toString());
    final expense = (expenseResult[0]['total_expense'] as int?) ?? 0;

    // Calculate total balance
    final balance = income - expense;

    return {
      'income': income,
      'expense': expense,
      'balance': balance,
    };
  }

  // Calculate the amount of each category with filters
  Future<Map<String, Map<String, dynamic>>> calculateCategoryAmount({
    String? categoryType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;

    final query = StringBuffer(''' 
    SELECT 
      c.id AS category_id, 
      c.name AS category_name, 
      c.icon, 
      c.color, 
      c.category_type, 
      COALESCE(SUM(t.amount), 0) AS total_amount
    FROM transactions t
    INNER JOIN categories c ON t.category_id = c.id
    WHERE LOWER(c.category_type) = ?
  ''');

    if (startDate != null && endDate != null) {
      query.write(" AND t.date BETWEEN '${startDate.toIso8601String()}' AND '${endDate.toIso8601String()}'");
    }

    query.write(' GROUP BY c.id');

    final result = await db.rawQuery(query.toString(), [categoryType!.toLowerCase()]);

    // Map to store the results with additional category data
    Map<String, Map<String, dynamic>> categoryAmounts = {};

    for (var row in result) {
      final categoryId = row['category_id'] as int;
      final categoryName = row['category_name'] as String;
      final icon = row['icon'] as String;
      final color = row['color'] as String;
      final categoryType = row['category_type'] as String;
      final totalAmount = (row['total_amount'] as int?) ?? 0;

      categoryAmounts[categoryName] = {
        'category_id': categoryId,
        'category_name': categoryName,
        'icon': icon,
        'color': color,
        'category_type': categoryType,
        'total_amount': totalAmount,
      };
    }

    return categoryAmounts;
  }

  // // Calculate percentage of each category compared to the total
  // Future<Map<String, double>> calculateCategoryPercentage({
  //   String? categoryType,
  //   DateTime? startDate,
  //   DateTime? endDate,
  // }) async {
  //   final categoryAmount = await calculateCategoryAmount(
  //     categoryType: categoryType,
  //     startDate: startDate,
  //     endDate: endDate,
  //   );
  //
  //   final balanceData = await calculateFilteredBalance(
  //     categoryType: categoryType,
  //     startDate: startDate,
  //     endDate: endDate,
  //   );
  //
  //   // Ensure the totalAmount is not null before calculating percentages
  //   final totalAmount = categoryType == 'income'
  //       ? (balanceData['income'] ?? 0)
  //       : (balanceData['expense'] ?? 0);
  //
  //   Map<String, double> categoryPercentages = {};
  //   if (totalAmount > 0) {
  //     categoryAmount.forEach((categoryName, categoryData) {
  //       final totalAmountForCategory = categoryData['total_amount'] as int? ?? 0;
  //
  //       // Avoid division by zero and calculate percentage
  //       if (totalAmountForCategory > 0) {
  //         categoryPercentages[categoryName] = (totalAmountForCategory / totalAmount) * 100;
  //       } else {
  //         categoryPercentages[categoryName] = 0; // Set to 0 if the category's total amount is 0
  //       }
  //     });
  //   } else {
  //     // If totalAmount is zero, set all percentages to 0
  //     categoryAmount.forEach((categoryName, categoryData) {
  //       categoryPercentages[categoryName] = 0;
  //     });
  //   }
  //
  //   return categoryPercentages;
  // }

  // Calculate growth (current month vs previous month or current week vs previous week)
  // Future<Map<String, int>> calculateGrowth({
  //   required String periodType, // "month" or "week"
  //   required DateTime currentPeriod,
  // }) async {
  //   final db = await _databaseHelper.database;
  //
  //   DateTime startDateCurrentPeriod;
  //   DateTime endDateCurrentPeriod;
  //   DateTime startDatePreviousPeriod;
  //   DateTime endDatePreviousPeriod;
  //
  //   if (periodType == 'month') {
  //     startDateCurrentPeriod = DateTime(currentPeriod.year, currentPeriod.month, 1);
  //     endDateCurrentPeriod = DateTime(currentPeriod.year, currentPeriod.month + 1, 0);
  //     startDatePreviousPeriod = DateTime(currentPeriod.year, currentPeriod.month - 1, 1);
  //     endDatePreviousPeriod = DateTime(currentPeriod.year, currentPeriod.month, 0);
  //   } else if (periodType == 'week') {
  //     startDateCurrentPeriod = currentPeriod.subtract(Duration(days: currentPeriod.weekday - 1));
  //     endDateCurrentPeriod = startDateCurrentPeriod.add(Duration(days: 6));
  //     startDatePreviousPeriod = startDateCurrentPeriod.subtract(Duration(days: 7));
  //     endDatePreviousPeriod = endDateCurrentPeriod.subtract(Duration(days: 7));
  //   } else {
  //     throw ArgumentError('Invalid period type');
  //   }
  //
  //   final currentPeriodData = await calculateFilteredBalance(
  //     startDate: startDateCurrentPeriod,
  //     endDate: endDateCurrentPeriod,
  //   );
  //
  //   final previousPeriodData = await calculateFilteredBalance(
  //     startDate: startDatePreviousPeriod,
  //     endDate: endDatePreviousPeriod,
  //   );
  //
  //   final incomeGrowth = (currentPeriodData['income'] ?? 0) - (previousPeriodData['income'] ?? 0);
  //   final expenseGrowth = (currentPeriodData['expense'] ?? 0) - (previousPeriodData['expense'] ?? 0);
  //
  //   return {
  //     'incomeGrowth': incomeGrowth,
  //     'expenseGrowth': expenseGrowth,
  //   };
  // }
  Future<List<Map<String, dynamic>>> getTransactions(
      Database db, {
        DateTime? startDate,
        DateTime? endDate,
        String? categoryType,
        String? categoryName,
      }) async {
    String whereClause = '';
    List<dynamic> whereArgs = [];

    // Filter theo ngày
    if (startDate != null && endDate != null) {
      whereClause = 'WHERE t.date BETWEEN ? AND ?';
      whereArgs.addAll([startDate.toIso8601String(), endDate.toIso8601String()]);
    }

    // Filter theo categoryType
    if (categoryType != null) {
      if (whereClause.isEmpty) {
        whereClause = 'WHERE LOWER(c.category_type) = ?';
      } else {
        whereClause += ' AND LOWER(c.category_type) = ?';
      }
      whereArgs.add(categoryType.toLowerCase());
    }

    return await db.rawQuery('''
    SELECT 
      t.id, t.amount, t.note, t.date, t.category_id,
      LOWER(c.category_type) AS category_type, 
      c.name AS category_name, 
      c.icon, c.color
    FROM transactions t
    INNER JOIN categories c ON t.category_id = c.id
    $whereClause
    ORDER BY t.date DESC
  ''', whereArgs);
  }
}
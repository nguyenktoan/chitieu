import 'package:chitieu/helpers/db/dao/category_dao.dart';
import 'package:chitieu/helpers/db/database_helper.dart';
import 'package:chitieu/helpers/db/models/transaction_model.dart';  // Import UserTransaction model
import 'package:flutter/material.dart';


class CategoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories(String transactionType) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper().database;
      _categories = await CategoryDao().fetchCategories(db, transactionType);
    } catch (e) {
      // Log lỗi nếu cần thiết
      print("Error fetching categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

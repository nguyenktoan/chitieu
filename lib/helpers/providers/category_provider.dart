import 'package:chitieu/helpers/db/dao/category_dao.dart';
import 'package:chitieu/helpers/db/database_helper.dart';
import 'package:chitieu/helpers/db/models/transaction_model.dart';  // Import UserTransaction model
import 'package:flutter/material.dart';


class CategoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _categories = [];

  List<Map<String, dynamic>> get categories => _categories;

  Future<void> fetchCategories(String transactionType) async {
    final db = await DatabaseHelper().database;
    _categories = await CategoryDao().fetchCategories(db, transactionType);
    notifyListeners();
  }
}

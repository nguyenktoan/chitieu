import 'package:flutter/material.dart';
import '../db/dao/report_dao.dart';
import '../db/database_helper.dart';
import '../db/models/transaction_model.dart';
import 'transaction_provider.dart';

class ReportProvider with ChangeNotifier {
  final ReportDao _reportDao = ReportDao();
  List<UserTransaction> _transactions = [];
  Map<String, Map<String, dynamic>> _categoryData = {};
  int _income = 0;
  int _expense = 0;
  int _balance = 0;
  bool _isLoading = false;
  Map<String, double> _categoryPercentages = {};
  Map<String, Map<String, dynamic>> _categoryAmounts = {};

  // Getters
  Map<String, Map<String, dynamic>> get categoryData => _categoryData;
  int get income => _income;
  int get expense => _expense;
  int get balance => _balance;
  bool get isLoading => _isLoading;
  Map<String, double> get categoryPercentages => _categoryPercentages;
  Map<String, Map<String, dynamic>> get categoryAmounts => _categoryAmounts;
  List<UserTransaction> get transactions => _transactions;

  // Set loading state
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  // Listen to changes from TransactionProvider
  void listenToTransactions(TransactionProvider transactionProvider) {
    transactionProvider.addListener(() {
      _updateReportData(transactionProvider.transactions);
    });
  }

  // Update report data when transactions change
  void _updateReportData(List<UserTransaction> transactions) async {
    _transactions = transactions;
    await fetchFilteredBalance();
    await fetchCategoryAmount();
  }

  // Fetch and calculate balance, income, and expense
  Future<void> fetchFilteredBalance({
    String? categoryName,
    String? categoryType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    try {
      final balanceData = await _reportDao.calculateFilteredBalance(
        categoryName: categoryName,
        categoryType: categoryType,
        startDate: startDate,
        endDate: endDate,
      );

      _income = balanceData['income'] ?? 0;
      _expense = balanceData['expense'] ?? 0;
      _balance = balanceData['balance'] ?? 0;

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Fetch category percentages


  // Fetch category amounts
  Future<void> fetchCategoryAmount({
    String? categoryType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    try {
      final result = await _reportDao.calculateCategoryAmount(
        categoryType: categoryType,
        startDate: startDate,
        endDate: endDate,
      );

      if (result.isNotEmpty) {
        _categoryAmounts = result;
      } else {
        _categoryAmounts.clear();
      }

      notifyListeners();
    } finally {
      _setLoading(false);
    }
    print("CategoryAmounts: $_categoryAmounts");
  }

  // Fetch growth data
  // Future<void> fetchGrowth({
  //   required String periodType,
  //   required DateTime currentPeriod,
  // }) async {
  //   _setLoading(true);
  //   try {
  //     final growthData = await _reportDao.calculateGrowth(
  //       periodType: periodType,
  //       currentPeriod: currentPeriod,
  //     );
  //
  //     _income += growthData['incomeGrowth'] ?? 0;
  //     _expense += growthData['expenseGrowth'] ?? 0;
  //     _balance = _income - _expense;
  //
  //     notifyListeners();
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Fetch transactions
  Future<void> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    required String categoryType,
  }) async {
    _setLoading(true);
    try {
      final db = await DatabaseHelper().database;
      final transactionData = await _reportDao.getTransactions(
        db,
        startDate: startDate,
        endDate: endDate,
        categoryType: categoryType,
      );

      _transactions = transactionData
          .map((tx) => UserTransaction.fromMap(tx))
          .toList();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
}

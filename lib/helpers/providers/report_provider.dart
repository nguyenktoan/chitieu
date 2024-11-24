import 'package:flutter/material.dart';
import '../db/dao/report_dao.dart';
import '../db/database_helper.dart';
import '../db/models/transaction_model.dart';

class ReportProvider with ChangeNotifier {
  final ReportDao _reportDao = ReportDao();
  List<UserTransaction> _transactions = []; // Danh sách các giao dịch
  Map<String, Map<String, dynamic>> _categoryData = {};
  Map<String, Map<String, dynamic>> get categoryData => _categoryData;

  // Biến để lưu trữ tổng thu nhập, chi phí và số dư
  int _income = 0;
  int _expense = 0;
  int _balance = 0;

  // Trạng thái đang tải
  bool _isLoading = false;

  // Biến cho phần trăm của các danh mục
  Map<String, double> _categoryPercentages = {};

  // Biến cho số tiền của các danh mục
  Map<String, Map<String, dynamic>> _categoryAmounts = {};

  // Getters
  int get income => _income;
  int get expense => _expense;
  int get balance => _balance;
  bool get isLoading => _isLoading; // Getter cho trạng thái tải
  Map<String, double> get categoryPercentages => _categoryPercentages; // Getter cho phần trăm các danh mục
  Map<String, Map<String, dynamic>> get categoryAmounts => _categoryAmounts; // Getter cho số tiền các danh mục
  List<UserTransaction> get transactions => _transactions; // Getter cho danh sách giao dịch

  // Set trạng thái đang tải
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners(); // Thông báo UI cập nhật trạng thái
  }

  // Fetch và tính toán số dư, thu nhập và chi phí
  Future<void> fetchFilteredBalance({
    String? categoryName,
    String? categoryType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true); // Đánh dấu trạng thái đang tải
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

      notifyListeners(); // Cập nhật UI
    } finally {
      _setLoading(false); // Kết thúc trạng thái tải
    }
  }

  // Fetch phần trăm của các danh mục
  Future<void> fetchCategoryPercentages({
    String? categoryType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true); // Đánh dấu trạng thái đang tải
    try {
      _categoryPercentages = await _reportDao.calculateCategoryPercentage(
        categoryType: categoryType,
        startDate: startDate,
        endDate: endDate,
      );

      notifyListeners(); // Cập nhật UI
    } finally {
      _setLoading(false); // Kết thúc trạng thái tải
    }
  }

  // Fetch số tiền của các danh mục
  Future<void> fetchCategoryAmount({
    String? categoryType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true); // Đánh dấu trạng thái đang tải
    try {
      final result = await _reportDao.calculateCategoryAmount(
        categoryType: categoryType,
        startDate: startDate,
        endDate: endDate,
      );

      if (result.isNotEmpty) {
        _categoryAmounts = result; // Cập nhật số tiền các danh mục
      } else {
        _categoryAmounts.clear(); // Nếu không có dữ liệu, làm trống
      }

      notifyListeners(); // Cập nhật UI
    } finally {
      _setLoading(false); // Kết thúc trạng thái tải
    }
    print("CategoryAmounts: $_categoryAmounts");
  }

  // Fetch growth (tăng trưởng) thu nhập và chi phí cho kỳ hiện tại và kỳ trước
  Future<void> fetchGrowth({
    required String periodType, // "month" hoặc "week"
    required DateTime currentPeriod,
  }) async {
    _setLoading(true); // Đánh dấu trạng thái đang tải
    try {
      final growthData = await _reportDao.calculateGrowth(
        periodType: periodType,
        currentPeriod: currentPeriod,
      );

      // Cập nhật dữ liệu tăng trưởng (growth)
      _income += growthData['incomeGrowth'] ?? 0;
      _expense += growthData['expenseGrowth'] ?? 0;
      _balance = _income - _expense;

      notifyListeners(); // Cập nhật UI
    } finally {
      _setLoading(false); // Kết thúc trạng thái tải
    }
  }

  // Lấy giao dịch từ cơ sở dữ liệu
  Future<void> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    required String categoryType,
  }) async {
    _setLoading(true); // Đánh dấu trạng thái đang tải
    try {
      final db = await DatabaseHelper().database; // Lấy cơ sở dữ liệu
      final transactionData = await _reportDao.getTransactions(
        db,
        startDate: startDate,
        endDate: endDate,
        categoryType: categoryType,
      );

      // Chuyển đổi danh sách giao dịch từ Map sang UserTransaction
      _transactions = transactionData
          .map((tx) => UserTransaction.fromMap(tx)) // Tạo UserTransaction từ Map
          .toList();

      notifyListeners(); // Cập nhật UI
    } finally {
      _setLoading(false); // Kết thúc trạng thái tải
    }
  }
}

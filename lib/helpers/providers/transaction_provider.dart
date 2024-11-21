import 'package:chitieu/helpers/db/database_helper.dart';
import 'package:chitieu/helpers/db/models/transaction_model.dart';  // Import UserTransaction model
import 'package:chitieu/helpers/db/models/update_transaction.dart';
import 'package:flutter/material.dart';

import '../db/dao/transaction_dao.dart';
import '../db/models/insert_transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionDao _transactionDao = TransactionDao();  // DAO để giao tiếp với cơ sở dữ liệu
  List<UserTransaction> _transactions = [];  // Danh sách các giao dịch
  int _totalBalance = 0;  // Tổng số dư
  int _income = 0;  // Tổng thu nhập
  int _expense = 0;  // Tổng chi tiêu
  bool _isLoading = false;  // Trạng thái tải

  // Lấy tất cả giao dịch từ cơ sở dữ liệu và cập nhật danh sách giao dịch
  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper().database;  // Lấy cơ sở dữ liệu
    final transactionData = await _transactionDao.fetchTransactions(db);  // Lấy danh sách giao dịch từ DAO

    // Chuyển đổi danh sách giao dịch từ Map sang UserTransaction
    _transactions = transactionData
        .map((tx) => UserTransaction.fromMap(tx))  // Tạo UserTransaction từ Map
        .toList();

    await calculateBalance();  // Tính toán số dư sau khi lấy giao dịch
    _isLoading = false;
    notifyListeners();  // Cập nhật UI khi có thay đổi
  }

  // Tính toán tổng số dư, thu nhập và chi tiêu
  Future<void> calculateBalance() async {
    _income = 0;
    _expense = 0;
    _totalBalance = 0;

    for (var transaction in _transactions) {
      if (transaction.categoryType == 'income') {
        _income += transaction.amount;  // Cộng thu nhập
      } else if (transaction.categoryType == 'expense') {
        _expense += transaction.amount;  // Cộng chi tiêu
      }
    }

    _totalBalance = _income - _expense;  // Tổng số dư = Thu nhập - Chi tiêu
    notifyListeners();  // Cập nhật UI
  }

  // Trả về danh sách giao dịch
  List<UserTransaction> get transactions => _transactions;

  // Trả về tổng số dư
  int get totalBalance => _totalBalance;

  // Trả về thu nhập
  int get income => _income;

  // Trả về chi tiêu
  int get expense => _expense;

  // Trả về trạng thái tải (loading)
  bool get isLoading => _isLoading;

  // Thêm một giao dịch mới vào cơ sở dữ liệu
  Future<void> addTransaction(InsertTransactionModel transaction) async {
    final db = await DatabaseHelper().database;

    // Thêm giao dịch vào cơ sở dữ liệu
    await _transactionDao.insertTransaction(db, transaction.toMap());
    // Sau khi thêm, lấy lại danh sách giao dịch để cập nhật UI
    await fetchTransactions();
  }

  // Cập nhật giao dịch
// Cập nhật giao dịch trong TransactionProvider
  Future<void> updateTransaction(UpdateTransactionModel updatedTransaction) async {
    final db = await DatabaseHelper().database;

    // Cập nhật giao dịch trong cơ sở dữ liệu
    await _transactionDao.updateTransaction(db, updatedTransaction.toMap());

    // Sau khi cập nhật giao dịch, tải lại danh sách giao dịch
    await fetchTransactions();
  }


  // Xóa giao dịch
  Future<void> deleteTransaction(int transactionId) async {
    final db = await DatabaseHelper().database;  // Lấy cơ sở dữ liệu
    await _transactionDao.deleteTransaction(db, transactionId);  // Xóa giao dịch khỏi cơ sở dữ liệu
    await fetchTransactions();  // Cập nhật lại danh sách giao dịch sau khi xóa
  }
}
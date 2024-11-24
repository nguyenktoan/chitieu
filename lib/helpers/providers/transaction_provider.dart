import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../db/dao/transaction_dao.dart';
import '../db/models/transaction_model.dart';
import '../db/models/insert_transaction_model.dart';
import '../db/models/update_transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionDao _transactionDao = TransactionDao();
  List<UserTransaction> _transactions = [];
  int _totalBalance = 0;
  int _income = 0;
  int _expense = 0;
  bool _isLoading = false;

  // Getters
  List<UserTransaction> get transactions => _transactions;
  int get totalBalance => _totalBalance;
  int get income => _income;
  int get expense => _expense;
  bool get isLoading => _isLoading;

  // Fetch all transactions
  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper().database;
    final transactionData = await _transactionDao.fetchTransactions(db);

    _transactions = transactionData
        .map((tx) => UserTransaction.fromMap(tx))
        .toList();

    await calculateBalance();
    _isLoading = false;
    notifyListeners();
  }

  // Calculate balance, income, and expense
  Future<void> calculateBalance() async {
    _income = 0;
    _expense = 0;
    _totalBalance = 0;

    for (var transaction in _transactions) {
      if (transaction.categoryType == 'income') {
        _income += transaction.amount;
      } else if (transaction.categoryType == 'expense') {
        _expense += transaction.amount;
      }
    }

    _totalBalance = _income - _expense;
    notifyListeners();
  }

  // Add a new transaction
  Future<void> addTransaction(InsertTransactionModel transaction) async {
    final db = await DatabaseHelper().database;
    await _transactionDao.insertTransaction(db, transaction.toMap());
    await fetchTransactions();
  }

  // Update an existing transaction
  Future<void> updateTransaction(UpdateTransactionModel updatedTransaction) async {
    final db = await DatabaseHelper().database;
    await _transactionDao.updateTransaction(db, updatedTransaction.toMap());
    await fetchTransactions();
  }

  // Delete a transaction
  Future<void> deleteTransaction(int transactionId) async {
    final db = await DatabaseHelper().database;
    await _transactionDao.deleteTransaction(db, transactionId);
    await fetchTransactions();
  }

  // Fetch a single transaction by ID
  Future<UserTransaction?> fetchTransaction(int transactionId) async {
    final db = await DatabaseHelper().database;
    return await _transactionDao.getTransactionById(transactionId);
  }
}

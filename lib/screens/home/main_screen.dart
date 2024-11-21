import 'dart:math';
import 'package:chitieu/screens/add_expense/add_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:chitieu/components/transaction_items/transaction_item.dart';
import 'package:chitieu/helpers/db/database_helper.dart';
import 'package:chitieu/helpers/db/dao/transaction_dao.dart';
import 'package:chitieu/screens/all_transactions/all_transactions.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TransactionDao _transactionDao = TransactionDao();

  List<Map<String, dynamic>> _transactions = [];
  int _totalBalance = 0;
  int _income = 0;
  int _expense = 0;
  bool _isLoading = true;

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadTransactions();
    await _fetchBalanceData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadTransactions() async {
    final db = await _databaseHelper.database;
    final transactions = await _transactionDao.fetchTransactions(db);

    setState(() {
      _transactions = transactions;
    });
  }

  Future<void> _fetchBalanceData() async {
    final db = await _databaseHelper.database;
    final balanceData = await _transactionDao.calculateBalance(db);

    setState(() {
      _income = balanceData['income']!;
      _expense = balanceData['expense']!;
      _totalBalance = balanceData['balance']!;
    });
  }

  String formatCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(amount);
  }

  Widget _buildCustomShimmer({
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
              stops: [
                _shimmerAnimation.value - 0.2,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.2,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserHeader(),
                  const SizedBox(height: 20),
                  _isLoading ? _buildLoadingBalanceCard() : _buildBalanceCard(),
                  const SizedBox(height: 20),
                  _buildTransactionsHeader(),
                  const SizedBox(height: 10),
                  _isLoading ? _buildTransactionsLoading() : _buildRecentTransactionsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade200,
                    Colors.blue.shade400
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(
                Icons.person_outline,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  "Hứa Tuấn Vĩ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            // TODO: Implement settings screen
          },
          icon: Icon(
            Icons.settings,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingBalanceCard() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey[200],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCustomShimmer(
              width: 200,
              height: 40,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomShimmer(
                  width: 100,
                  height: 30,
                  borderRadius: BorderRadius.circular(8),
                ),
                _buildCustomShimmer(
                  width: 100,
                  height: 30,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formatCurrency(_totalBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBalanceInfoItem(

                    label: 'Income',
                    amount: _income,
                    color: Colors.green,
                    icon: Icons.trending_up
                ),
                Container(
                    height: 50,
                    width: 1,
                    color: Colors.white24
                ),
                _buildBalanceInfoItem(
                    label: 'Expenses',
                    amount: _expense,
                    color: Colors.red,
                    icon: Icons.trending_down
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfoItem({
    required String label,
    required int amount,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white70.withOpacity(0.3),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              formatCurrency(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Recent Transactions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AllTransactionsScreen(),
              ),
            );
          },
          child: Text(
            "View all",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsLoading() {
    return Expanded(
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildCustomShimmer(
              width: double.infinity,
              height: 60,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactionsList() {
    return Expanded(
      child: _transactions.isEmpty
          ? _buildEmptyTransactionState()
          : ListView.builder(
        itemCount: min(5, _transactions.length),
        itemBuilder: (context, index) {
          return TransactionItem(
            transaction: _transactions[index],
          );
        },
      ),
    );
  }


  Widget _buildEmptyTransactionState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              Icons.wallet_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddExpense(),
                ),
              );
            },
            child: const Text('Add First Transaction'),
          ),
        ],
      ),
    );
  }


}
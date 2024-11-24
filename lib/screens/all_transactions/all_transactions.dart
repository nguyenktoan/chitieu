import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helpers/db/dao/transaction_dao.dart';
import '../../helpers/db/database_helper.dart';
import 'package:chitieu/components/transaction_item.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final _databaseHelper = DatabaseHelper();
  final _transactionDao = TransactionDao();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  String _selectedType = 'all';
  late String _selectedMonth;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final db = await _databaseHelper.database;
      final transactions = await _transactionDao.fetchTransactions(db);
      setState(() {
        _transactions = transactions;
        _filteredTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      _showError("Không thể tải giao dịch: $e");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Lỗi"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _filterTransactions(String? searchQuery) {
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        final query = (searchQuery ?? "").toLowerCase();
        final categoryName = (transaction['category_name'] ?? "").toLowerCase();
        final note = (transaction['note'] ?? "").toLowerCase();
        final amount = transaction['amount'].toString();

        bool matchesSearch = query.isEmpty ||
            categoryName.contains(query) ||
            amount.contains(query) ||
            note.contains(query);

        final matchesType = _selectedType == 'all' ||
            transaction['category_type'].toString().toLowerCase() == _selectedType;

        final transactionDate = DateFormat('yyyy-MM')
            .format(DateTime.parse(transaction['date']))
            .toString();
        final matchesMonth = _selectedMonth.isEmpty ||
            transactionDate == _selectedMonth;

        return matchesSearch && matchesType && matchesMonth;
      }).toList();
    });
  }

  List<String> _getRecentMonths() {
    return List.generate(6, (index) {
      final date = DateTime.now().subtract(Duration(days: index * 30));
      return DateFormat('yyyy-MM').format(date);
    })..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Danh sách Giao dịch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  _buildTypeFilter(),
                  const SizedBox(height: 16),
                  _buildMonthFilter(),
                ],
              ),
            ),
          ),
          _buildTransactionsList()
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterTransactions,
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm giao dịch...',
          prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    final types = [
      {'value': 'all', 'label': 'Tất cả'},
      {'value': 'income', 'label': 'Khoản Thu'},
      {'value': 'expense', 'label': 'Khoản Chi'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((type) {
          final isSelected = _selectedType == type['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedType = type['value']!);
                _filterTransactions(_searchController.text);
              },
              label: Text(type['label']!),
              backgroundColor: Colors.white,
              selectedColor: Colors.deepPurple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _getRecentMonths().map((month) {
          final isSelected = _selectedMonth == month;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedMonth = month);
                _filterTransactions(_searchController.text);
              },
              label: Text(
                DateFormat('MM/yyyy').format(DateTime.parse('$month-01')),
              ),
              backgroundColor: Colors.white,
              selectedColor: Colors.deepPurple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    if (_filteredTransactions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                "Không có giao dịch",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) => TransactionItem(
          transaction: _filteredTransactions[index],
        ),
        childCount: _filteredTransactions.length,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
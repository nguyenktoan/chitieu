import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helpers/db/dao/transaction_dao.dart';
import '../../helpers/db/database_helper.dart';
import 'package:chitieu/components/transaction_items/transaction_item.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TransactionDao _transactionDao = TransactionDao();

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  String _searchQuery = '';
  String _selectedType = 'all';
  String _selectedMonth = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final db = await _databaseHelper.database;
    final transactions = await _transactionDao.fetchTransactions(db);

    setState(() {
      _transactions = transactions;
      _filteredTransactions = transactions;
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Lỗi"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        final matchesSearch = _searchQuery.isEmpty ||
            (transaction['category_name'] != null &&
                transaction['category_name']
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())) ||
            transaction['amount'].toString().contains(_searchQuery) ||
            (transaction['note'] != null &&
                transaction['note']
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()));

        final matchesType = _selectedType == 'all' ||
            transaction['category_type'].toString().toLowerCase() == _selectedType;

        final matchesMonth = _selectedMonth.isEmpty ||
            DateFormat('yyyy-MM')
                .format(DateTime.parse(transaction['date']))
                .toString() == _selectedMonth;

        return matchesSearch && matchesType && matchesMonth;
      }).toList();
    });
  }

  List<String> _generateMonths() {
    final List<String> months = [];
    for (int i = 0; i < 6; i++) {
      final date = DateTime.now().subtract(Duration(days: i * 30));
      final monthString = DateFormat('yyyy-MM').format(date);
      months.add(monthString);
    }
    months.sort((a, b) => a.compareTo(b));
    return months;
  }

  String formatCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Danh sách Giao dịch',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tìm kiếm
            _buildSearchBar(),
            SizedBox(height: 16),

            // Lọc theo loại giao dịch
            _buildTransactionTypeFilter(),
            SizedBox(height: 16),

            // Lọc theo tháng
            _buildMonthFilter(),
            SizedBox(height: 16),

            // Danh sách giao dịch
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  // Thanh tìm kiếm
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
          _filterTransactions();
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm giao dịch...',
          prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }

  // Bộ lọc loại giao dịch
  Widget _buildTransactionTypeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('all', 'Tất cả'),
          SizedBox(width: 10),
          _buildFilterChip('income', 'Khoản Thu'),
          SizedBox(width: 10),
          _buildFilterChip('expense', 'Khoản Chi'),
        ],
      ),
    );
  }

  // Filter Chip tùy chỉnh
  Widget _buildFilterChip(String value, String label) {
    bool isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
        _filterTransactions();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Bộ lọc tháng
  Widget _buildMonthFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _generateMonths().map((month) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMonth = month;
              });
              _filterTransactions();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: _selectedMonth == month
                    ? Colors.deepPurple
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedMonth == month
                      ? Colors.deepPurple
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                DateFormat('MM/yyyy').format(DateTime.parse('$month-01')),
                style: TextStyle(
                  color: _selectedMonth == month
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Danh sách giao dịch
  Widget _buildTransactionList() {
    return Expanded(
      child: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurple,
        ),
      )
          : _filteredTransactions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16),
            Text(
              "Không có giao dịch",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
        itemCount: _filteredTransactions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade300,
        ),
        itemBuilder: (context, index) {
          return TransactionItem(
            transaction: _filteredTransactions[index],
          );
        },
      ),
    );
  }
}
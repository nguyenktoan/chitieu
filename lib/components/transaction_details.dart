import 'package:chitieu/screens/home/home_screen.dart';
import 'package:chitieu/screens/home/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../helpers/providers/transaction_provider.dart';
import 'edit_transaction_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailScreen({required this.transaction, super.key});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  // Color scheme
  static const primary = Color(0xFF00B2E7);
  static const secondary = Color(0xFFE064F7);
  static const tertiary = Color(0xFFFF8D6C);

  Future<void> _deleteTransaction(int? transactionId) async {
    if (transactionId == null) return;
    await Provider.of<TransactionProvider>(context, listen: false)
        .deleteTransaction(transactionId);
    Navigator.pop(context, true);
  }

  Future<void> _reloadTransaction() async {
    await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
    setState(() {});
  }

  String resolveDate(String? date) {
    if (date == null || date.isEmpty) {
      return "Ngày không xác định";
    }

    try {
      DateTime parsedDate = DateTime.parse(date); // Giả sử date là một chuỗi ISO 8601
      return DateFormat('dd/MM/yyyy').format(parsedDate); // Định dạng ngày tháng theo kiểu dd/MM/yyyy
    } catch (e) {
      return "Ngày không hợp lệ"; // Nếu không thể parse ngày, trả về thông báo lỗi
    }
  }

  IconData resolveIcon(String iconKey) {
    final iconMap = const {
      "attach_money": Icons.attach_money,
      "card_giftcard": Icons.card_giftcard,
      "business_center": Icons.business_center,
      "redeem": Icons.redeem,
      "restaurant": Icons.restaurant,
      "directions_car": Icons.directions_car,
      "shopping_cart": Icons.shopping_cart,
      "receipt": Icons.receipt,
      "theaters": Icons.theaters,
      "home": Icons.home,
      "shopping_bag": Icons.shopping_bag,
    };
    return iconMap[iconKey] ?? Icons.error;
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final String categoryName = transaction["category_name"] ?? "Unknown";
    final String categoryType = transaction["category_type"] ?? "Unknown Type"; // Using category_type here
    final int amount = transaction["amount"] ?? 0;
    final String date = transaction["date"] ?? "Unknown Date";
    final String note = transaction["note"] ?? "";
    final String iconKey = transaction["icon"] ?? "";
    final IconData icon = resolveIcon(iconKey);
    final int? categoryId = transaction["category_id"]; // Lấy categoryId từ transaction

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text(
          "Chi tiết Giao dịch",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: primary),
            onPressed: () async {
              final shouldReload = await _editTransaction(transaction);
              if (shouldReload == true) {
                _reloadTransaction();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMainCard(categoryName, categoryType, categoryId, amount, icon), // Updated to use both category_name and category_type
              const SizedBox(height: 16),
              _buildDetailsCard(date, note),
              const SizedBox(height: 24),
              _buildDeleteButton(transaction),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(String categoryName, String categoryType, int? categoryId, int amount, IconData icon) {
    return Card(
      elevation: 8,
      shadowColor: primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, primary.withOpacity(0.8)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName, // Displaying category_name
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Text(
                      //   categoryType, // Displaying category_type as subtitle
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w400,
                      //     color: Colors.white.withOpacity(0.8),
                      //   ),
                      // ),
                      // Text(
                      //   categoryId != null ? 'ID: $categoryId' : "ID không xác định", // Fix lỗi ép kiểu
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w400,
                      //     color: Colors.white.withOpacity(0.8),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              formatCurrency(amount),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(String date, String note) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField(
              Icons.calendar_today,
              "Ngày",
              resolveDate(date),
              secondary,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              Icons.note,
              "Ghi chú",
              note,
              tertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      IconData icon,
      String label,
      String value,
      Color iconColor,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(Map<String, dynamic> transaction) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _deleteTransaction(transaction['id']),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: tertiary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: tertiary.withOpacity(0.4),
        ),
        child: const Text(
          'Xóa giao dịch',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String formatCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(amount);
  }

  Future<bool?> _editTransaction(Map<String, dynamic> transaction) async {
    final shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );

    if (shouldReload == true) {
      _reloadTransaction();
    }

    return shouldReload;
  }
}

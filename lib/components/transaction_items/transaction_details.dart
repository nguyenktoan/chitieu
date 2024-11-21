import 'package:chitieu/screens/home/home_screen.dart';
import 'package:chitieu/screens/home/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../helpers/providers/transaction_provider.dart';
import 'edit_transaction_screen.dart';  // Đảm bảo bạn đã cài đặt Provider

class TransactionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailScreen({required this.transaction, super.key});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {

  // Tạo một hàm để xử lý việc xóa giao dịch qua Provider
  Future<void> _deleteTransaction(int? transactionId) async {
    if (transactionId == null) return;

    // Sử dụng Provider để xóa giao dịch
    await Provider.of<TransactionProvider>(context, listen: false)
        .deleteTransaction(transactionId);

    // Quay lại màn hình trước đó sau khi xóa
    Navigator.pop(context, true);
  }

  // Cập nhật giao dịch mới nhất từ Provider
  Future<void> _reloadTransaction() async {
    await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
    setState(() {});
  }

  // Hàm chuyển đổi biểu tượng
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
    final String category = transaction["category_name"] ?? "Unnamed";
    final int amount = transaction["amount"] ?? 0;
    final String date = transaction["date"] ?? "Unknown Date";
    final String note = transaction["note"] ?? "";
    final String iconKey = transaction["icon"] ?? "";
    final IconData icon = resolveIcon(iconKey);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("Chi tiết Giao dịch", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Đợi kết quả trả về khi quay lại từ trang chỉnh sửa
              final shouldReload = await _editTransaction(transaction);
              if (shouldReload == true) {
                // Nếu có thay đổi, reload lại dữ liệu
                _reloadTransaction();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    icon: icon,
                    iconColor: Colors.blue,
                    label: category,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(height: 30, color: Colors.grey),
                  _buildDetailRow(
                    icon: Icons.attach_money,
                    iconColor: Colors.red,
                    label: formatCurrency(amount),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const Divider(height: 30, color: Colors.grey),
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    iconColor: Colors.green,
                    label: date,
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                  const Divider(height: 30, color: Colors.grey),
                  _buildDetailRow(
                    icon: Icons.note,
                    iconColor: Colors.orange,
                    label: note,
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _deleteTransaction(transaction['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Xóa giao dịch',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget dùng để tạo các dòng chi tiết
  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    TextStyle? style,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 30),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            label,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Hàm định dạng tiền tệ
  String formatCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(amount);
  }

  // Hàm chỉnh sửa giao dịch và chuyển hướng về MainScreen sau khi hoàn thành
  Future<bool?> _editTransaction(Map<String, dynamic> transaction) async {
    final shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );

    if (shouldReload == true) {
      // Quay về MainScreen sau khi chỉnh sửa thành công
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),  // Đảm bảo MainScreen được import
        ),
      );
    }

    return shouldReload;
  }
}

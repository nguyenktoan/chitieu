import 'package:chitieu/components/transaction_items/transaction_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Dùng để định dạng tiền tệ

class TransactionItem extends StatefulWidget {
  final Map<String, dynamic> transaction; // Đảm bảo rằng mỗi giao dịch là một map

  TransactionItem({required this.transaction, Key? key}) : super(key: key);

  @override
  _TransactionItemState createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  final Map<String, IconData> iconMap = const {
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

  String formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(amount);
  }

  Color resolveColor(String? colorString) {
    try {
      return Color(int.parse(colorString ?? "0xFF888888"));
    } catch (_) {
      return Colors.grey; // Màu mặc định
    }
  }

  IconData resolveIcon(String? iconKey) {
    return iconMap[iconKey] ?? Icons.error;
  }

  String truncatedNoteText(String note) {
    return note.isEmpty
        ? "Không có ghi chú"
        : (note.length > 30 ? "${note.substring(0, 30)}..." : note);
  }

  String resolveDate(String? date) {
    return date ?? "Ngày không xác định";
  }

  // Điều hướng đến màn hình chi tiết giao dịch
  void _navigateToDetails(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(transaction: widget.transaction),
      ),
    );

    if (result != null) {
      setState(() {
        widget.transaction.addAll(result); // Giả sử result là Map chứa dữ liệu cập nhật
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String note = widget.transaction["note"] ?? "";
    String truncatedNote = truncatedNoteText(note);

    int amount = widget.transaction["amount"] ?? 0;
    String date = resolveDate(widget.transaction["date"]);

    Color color = resolveColor(widget.transaction["color"]);
    IconData icon = resolveIcon(widget.transaction["icon"]);

    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.transaction["category_name"] ?? "Không có tên",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      truncatedNote,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

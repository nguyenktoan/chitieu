import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_details.dart';

class TransactionItem extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const TransactionItem({required this.transaction, Key? key}) : super(key: key);

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
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  Color resolveColor(String? colorString) {
    try {
      return Color(int.parse(colorString ?? "0xFF888888"));
    } catch (_) {
      return Colors.grey;
    }
  }

  IconData resolveIcon(String? iconKey) {
    return iconMap[iconKey] ?? Icons.error;
  }

  String truncatedNoteText(String note) {
    if (note.isEmpty) {
      return "Không có ghi chú";
    }
    return note.length > 25 ? "${note.substring(0, 25)}..." : note;
  }

  String resolveDate(String? date) {
    if (date == null || date.isEmpty) {
      return "Ngày không xác định";
    }

    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return "Ngày không hợp lệ";
    }
  }

  void _navigateToDetails(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(transaction: widget.transaction),
      ),
    );

    if (result != null) {
      setState(() {
        widget.transaction.addAll(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    String note = widget.transaction["note"] ?? "";
    String truncatedNote = truncatedNoteText(note);
    int amount = widget.transaction["amount"] ?? 0;
    String date = resolveDate(widget.transaction["date"]);
    Color categoryColor = resolveColor(widget.transaction["color"]);
    IconData icon = resolveIcon(widget.transaction["icon"]);
    String categoryName = widget.transaction["category_name"] ?? "Chưa phân loại";
    bool isExpense = widget.transaction["category_type"] == "expense";

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Category Name
                        Expanded(
                          child: Text(
                            categoryName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Amount
                        Text(
                          formatCurrency(amount),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isExpense ? theme.tertiary : theme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Note
                        Expanded(
                          child: Text(
                            truncatedNote,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Date
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
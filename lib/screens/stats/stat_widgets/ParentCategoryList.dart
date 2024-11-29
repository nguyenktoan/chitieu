import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParentCategoryList extends StatelessWidget {
  final Future<Map<String, Map<String, dynamic>>> categoryAmounts;

  const ParentCategoryList({required this.categoryAmounts, Key? key}) : super(key: key);

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

  // Bản đồ icon
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

  // Hàm lấy IconData từ tên icon
  IconData getIcon(String iconName) {
    return iconMap[iconName] ?? Icons.help; // Trả về Icon mặc định nếu không tìm thấy
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return FutureBuilder<Map<String, Map<String, dynamic>>>(  // Đang sử dụng FutureBuilder
      future: categoryAmounts,
      builder: (context, snapshot) {
        // Trạng thái loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Trạng thái lỗi
        else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // Nếu không có dữ liệu
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon không có dữ liệu
                Icon(
                  Icons.inbox,
                  size: 50,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                // Thông báo không có danh mục
                Text(
                  "Chưa có danh mục nào.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        // Khi có dữ liệu danh mục
        final categories = snapshot.data!;

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories.values.toList()[index];
            final categoryName = category["category_name"] ?? "Unknown Category";
            final totalAmount = category["total_amount"] ?? 0;
            final iconName = category["icon"] ?? "";  // Lấy tên icon từ dữ liệu
            final color = category["color"] ?? "0xFFFFFFFF"; // Default color
            Color categoryColor = resolveColor(category["color"]);

            final iconData = getIcon(iconName); // Sử dụng iconMap để lấy IconData

            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  // Handle tap (for example, navigate to category details)
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
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
                          iconData, // Sử dụng iconData đã xử lý từ iconMap
                          color: categoryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Category Details
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
                                // Total Amount
                                Text(
                                  formatCurrency(totalAmount),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
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
          },
        );
      },
    );
  }
}

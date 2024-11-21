class UserTransaction {
  final int id;
  final int amount;
  final String note;
  final String categoryType;
  final String categoryName;
  final String icon;
  final String color;
  final DateTime date;

  // Constructor
  UserTransaction({
    required this.id,
    required this.amount,
    required this.note,
    required this.categoryType,
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.date,
  }) {
    if (amount <= 0) {
      throw ArgumentError('Amount should be greater than zero');
    }
    if (!['income', 'expense'].contains(categoryType.toLowerCase())) {
      throw ArgumentError('Category type should be either "income" or "expense"');
    }
  }

  // Factory constructor để khởi tạo đối tượng từ Map
  factory UserTransaction.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      throw ArgumentError('Map cannot be empty');
    }

    // Kiểm tra giá trị ngày tháng hợp lệ
    DateTime parsedDate = DateTime.tryParse(map['date']) ?? DateTime.now();

    // Nếu ngày không hợp lệ, ta sẽ trả về DateTime.now() làm giá trị mặc định.
    if (parsedDate.year == 1970) {
      parsedDate = DateTime.now();
    }

    return UserTransaction(
      id: map['id'] ?? 0,
      amount: map['amount'] ?? 0,
      note: map['note'] ?? '',
      categoryType: map['category_type'] ?? 'income',
      categoryName: map['category_name'] ?? 'Uncategorized',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '',
      date: parsedDate, // Gán ngày đã xử lý
    );
  }

  // Phương thức chuyển đối tượng thành Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'category_type': categoryType,
      'category_name': categoryName,
      'icon': icon,
      'color': color,
      'date': date.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Transaction{id: $id, amount: $amount, note: $note, categoryType: $categoryType, categoryName: $categoryName, date: $date}';
  }

}

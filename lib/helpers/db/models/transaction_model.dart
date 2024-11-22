class UserTransaction {
  final int id;
  final int amount;
  final String note;
  final String categoryType;
  final String categoryName;
  final String icon;
  final String color;
  final DateTime date;
  final int categoryId; // Thêm thuộc tính categoryId

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
    required this.categoryId, // Khởi tạo categoryId
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

    DateTime parsedDate = DateTime.tryParse(map['date']) ?? DateTime.now();

    return UserTransaction(
      id: map['id'] ?? 0,
      amount: map['amount'] ?? 0,
      note: map['note'] ?? '',
      categoryType: map['category_type'] ?? 'income',
      categoryName: map['category_name'] ?? 'Uncategorized',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '',
      date: parsedDate,
      categoryId: map['category_id'] ?? 0, // Thêm ánh xạ cho categoryId
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
      'category_id': categoryId, // Thêm categoryId vào Map
    };
  }

  @override
  String toString() {
    return 'Transaction{id: $id, amount: $amount, note: $note, categoryType: $categoryType, categoryName: $categoryName, categoryId: $categoryId, date: $date}';
  }
}

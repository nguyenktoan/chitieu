class InsertTransactionModel {
  final int amount;
  final String note;
  final String categoryType;
  final int categoryId;
  final DateTime date;

  // Constructor
  InsertTransactionModel({
    required this.amount,
    required this.note,
    required this.categoryType,
    required this.categoryId,
    required this.date,
  });

  // Factory constructor để khởi tạo đối tượng từ Map
  factory InsertTransactionModel.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      throw ArgumentError('Map cannot be empty');
    }

    DateTime parsedDate = DateTime.tryParse(map['date']) ?? DateTime.now();

    if (parsedDate.year == 1970) {
      parsedDate = DateTime.now();
    }

    return InsertTransactionModel(
      amount: map['amount'] ?? 0,
      note: map['note'] ?? '',
      categoryType: map['category_type'] ?? 'income',
      categoryId: map['category_id'] ?? 0,
      date: parsedDate,
    );
  }

  // Phương thức chuyển đối tượng thành Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'note': note,
      'category_type': categoryType,
      'category_id': categoryId,
      'date': date.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'InsertTransactionModel{amount: $amount, note: $note, categoryType: $categoryType, categoryId: $categoryId, date: $date}';
  }
}

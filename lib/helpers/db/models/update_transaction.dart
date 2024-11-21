class UpdateTransactionModel {
  final int id;
  final int amount;
  final String note;
  final String categoryType;
  final int categoryId;
  final DateTime date;

  // Constructor
  UpdateTransactionModel({
    required this.id,
    required this.amount,
    required this.note,
    required this.categoryType,
    required this.categoryId,
    required this.date,
  });

  // Factory constructor để khởi tạo đối tượng từ Map
  factory UpdateTransactionModel.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      throw ArgumentError('Map cannot be empty');
    }

    DateTime parsedDate = DateTime.tryParse(map['date']) ?? DateTime.now();

    if (parsedDate.year == 1970) {
      parsedDate = DateTime.now();
    }

    return UpdateTransactionModel(
      id: map['id'] ?? 0,  // id là trường bắt buộc khi cập nhật
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
      'id': id,  // Cần có id để xác định bản ghi cần cập nhật
      'amount': amount,
      'note': note,
      'category_type': categoryType,
      'category_id': categoryId,
      'date': date.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UpdateTransactionModel{id: $id, amount: $amount, note: $note, categoryType: $categoryType, categoryId: $categoryId, date: $date}';
  }
}

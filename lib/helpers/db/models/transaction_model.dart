class Transaction {
  final int? id;
  final int amount;
  final int categoryId;
  final String categoryType;
  final String note;
  final String date;

  Transaction({
    this.id,
    required this.amount,
    required this.categoryId,
    required this.categoryType,
    required this.note,
    required this.date,
  });

  // Chuyển đổi Transaction thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category_id': categoryId,
      'category_type': categoryType,
      'note': note,
      'date': date,
    };
  }

  // Chuyển đổi Map thành Transaction
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      categoryId: map['category_id'],
      categoryType: map['category_type'],
      note: map['note'],
      date: map['date'],
    );
  }
}

import 'package:sqflite/sqflite.dart';

class MigrationV1 {
  // Tạo các bảng cần thiết
  static Future<void> createTables(Database db) async {
    await db.execute('''  
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        icon TEXT,
        color TEXT,
        category_type TEXT
      )
    ''');

    await db.execute('''  
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER,
        category_id INTEGER,
        category_type TEXT,
        note TEXT,
        date TEXT, 
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');
  }

  // Chèn dữ liệu mẫu vào các bảng
  static Future<void> insertSampleData(Database db) async {
    await insertSampleCategories(db);
    await insertSampleTransactions(db);
  }

  // Chèn danh mục mẫu
  static Future<void> insertSampleCategories(Database db) async {
    final List<Map<String, dynamic>> categories = [
      {"name": "Lương", "icon": "attach_money", "color": "0xFF4CAF50", "category_type": "income"},
      {"name": "Tiền thưởng", "icon": "card_giftcard", "color": "0xFF4CAF50", "category_type": "income"},
      {"name": "Lợi nhuận kinh doanh", "icon": "business_center", "color": "0xFF4CAF50", "category_type": "income"},
      {"name": "Quà tặng", "icon": "redeem", "color": "0xFF4CAF50", "category_type": "income"},
      {"name": "Ăn uống", "icon": "restaurant", "color": "0xFFF44336", "category_type": "expense"},
      {"name": "Di chuyển", "icon": "directions_car", "color": "0xFFF44336", "category_type": "expense"},
      {"name": "Mua sắm", "icon": "shopping_cart", "color": "0xFFF44336", "category_type": "expense"},
      {"name": "Hóa đơn", "icon": "receipt", "color": "0xFFF44336", "category_type": "expense"},
      {"name": "Giải trí", "icon": "theaters", "color": "0xFFF44336", "category_type": "expense"},
    ];

    for (var category in categories) {
      await db.insert('categories', category, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // Chèn giao dịch mẫu
  static Future<void> insertSampleTransactions(Database db) async {
    final List<Map<String, dynamic>> transactions = [
      {"amount": 5000000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 3", "date": "2024-11-01"},
      {"amount": 1500000, "category_id": 2, "category_type": "income", "note": "Tiền thưởng Tết", "date": "2024-11-02"},
      {"amount": 200000, "category_id": 6, "category_type": "expense", "note": "Đi Grab", "date": "2024-11-03"},
      {"amount": 1200000, "category_id": 7, "category_type": "expense", "note": "Mua đồ gia dụng", "date": "2024-11-04"},
      {"amount": 300000, "category_id": 8, "category_type": "expense", "note": "Thanh toán hóa đơn điện", "date": "2024-11-05"},
      {"amount": 250000, "category_id": 5, "category_type": "expense", "note": "Ăn tối với bạn", "date": "2024-11-06"},
      {"amount": 1000000, "category_id": 3, "category_type": "income", "note": "Lợi nhuận bán hàng", "date": "2024-11-07"},
      {"amount": 450000, "category_id": 9, "category_type": "expense", "note": "Xem phim", "date": "2024-11-08"},
      {"amount": 50000, "category_id": 6, "category_type": "expense", "note": "Gửi xe", "date": "2024-11-09"},
      {"amount": 200000, "category_id": 5, "category_type": "expense", "note": "Ăn sáng", "date": "2024-11-10"},
    ];

    for (var transaction in transactions) {
      await db.insert('transactions', transaction, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}

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
      {"amount": 1500000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 9", "date": "2024-09-01"},
      {"amount": 500000, "category_id": 2, "category_type": "income", "note": "Tiền thưởng Trung thu", "date": "2024-09-02"},
      {"amount": 200000, "category_id": 6, "category_type": "expense", "note": "Đi Grab", "date": "2024-09-03"},
      {"amount": 800000, "category_id": 7, "category_type": "expense", "note": "Mua đồ gia dụng", "date": "2024-09-04"},
      {"amount": 50000, "category_id": 8, "category_type": "expense", "note": "Thanh toán hóa đơn điện", "date": "2024-09-05"},
      {"amount": 300000, "category_id": 5, "category_type": "expense", "note": "Ăn tối với bạn", "date": "2024-09-06"},
      {"amount": 1000000, "category_id": 3, "category_type": "income", "note": "Lợi nhuận bán hàng", "date": "2024-09-07"},
      {"amount": 200000, "category_id": 9, "category_type": "expense", "note": "Xem phim", "date": "2024-09-08"},
      {"amount": 50000, "category_id": 6, "category_type": "expense", "note": "Gửi xe", "date": "2024-09-09"},
      {"amount": 250000, "category_id": 5, "category_type": "expense", "note": "Ăn sáng", "date": "2024-09-10"},
      {"amount": 1500000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 9", "date": "2024-09-11"},
      {"amount": 1000000, "category_id": 2, "category_type": "income", "note": "Tiền thưởng Trung thu", "date": "2024-09-12"},
      {"amount": 500000, "category_id": 7, "category_type": "expense", "note": "Mua sắm quần áo", "date": "2024-09-13"},
      {"amount": 200000, "category_id": 6, "category_type": "expense", "note": "Đi Taxi", "date": "2024-09-14"},
      {"amount": 1200000, "category_id": 8, "category_type": "expense", "note": "Thanh toán hóa đơn internet", "date": "2024-09-15"},
      {"amount": 1000000, "category_id": 3, "category_type": "income", "note": "Lợi nhuận bán hàng", "date": "2024-09-16"},
      {"amount": 450000, "category_id": 9, "category_type": "expense", "note": "Xem phim", "date": "2024-09-17"},
      {"amount": 300000, "category_id": 5, "category_type": "expense", "note": "Ăn sáng tại quán", "date": "2024-09-18"},
      {"amount": 1500000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 9", "date": "2024-09-19"},
      {"amount": 500000, "category_id": 6, "category_type": "expense", "note": "Di chuyển công tác", "date": "2024-09-20"},
      {"amount": 1000000, "category_id": 4, "category_type": "income", "note": "Lợi nhuận kinh doanh", "date": "2024-09-21"},
      {"amount": 100000, "category_id": 8, "category_type": "expense", "note": "Thanh toán tiền điện thoại", "date": "2024-09-22"},
      {"amount": 1200000, "category_id": 7, "category_type": "expense", "note": "Mua đồ gia dụng", "date": "2024-09-23"},
      {"amount": 1000000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 9", "date": "2024-09-24"},
      {"amount": 200000, "category_id": 6, "category_type": "expense", "note": "Đi Grab", "date": "2024-09-25"},
      {"amount": 250000, "category_id": 5, "category_type": "expense", "note": "Ăn tối tại nhà", "date": "2024-09-26"},
      {"amount": 300000, "category_id": 9, "category_type": "expense", "note": "Xem phim với bạn bè", "date": "2024-09-27"},
      {"amount": 400000, "category_id": 6, "category_type": "expense", "note": "Đi công tác Hà Nội", "date": "2024-09-28"},
      {"amount": 1500000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 9", "date": "2024-09-29"},
      {"amount": 200000, "category_id": 7, "category_type": "expense", "note": "Mua đồ ăn sáng", "date": "2024-09-30"},

      {"amount": 1500000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 10", "date": "2024-10-01"},
      {"amount": 800000, "category_id": 2, "category_type": "income", "note": "Tiền thưởng tháng 10", "date": "2024-10-02"},
      {"amount": 150000, "category_id": 6, "category_type": "expense", "note": "Ăn sáng", "date": "2024-10-03"},
      {"amount": 1200000, "category_id": 5, "category_type": "expense", "note": "Thanh toán hóa đơn điện", "date": "2024-10-04"},
      {"amount": 500000, "category_id": 9, "category_type": "expense", "note": "Xem phim", "date": "2024-10-05"},
      {"amount": 600000, "category_id": 3, "category_type": "income", "note": "Lợi nhuận từ bán hàng", "date": "2024-10-06"},
      {"amount": 1000000, "category_id": 8, "category_type": "expense", "note": "Mua sắm trực tuyến", "date": "2024-10-07"},
      {"amount": 1500000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 10", "date": "2024-10-08"},
      {"amount": 200000, "category_id": 6, "category_type": "expense", "note": "Gửi xe", "date": "2024-10-09"},
      {"amount": 300000, "category_id": 7, "category_type": "expense", "note": "Mua quần áo", "date": "2024-10-10"},
      {"amount": 1000000, "category_id": 3, "category_type": "income", "note": "Lợi nhuận tháng 10", "date": "2024-10-11"},
      {"amount": 500000, "category_id": 9, "category_type": "expense", "note": "Gọi Taxi", "date": "2024-10-12"},
      {"amount": 1500000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 10", "date": "2024-10-13"},
      {"amount": 1200000, "category_id": 5, "category_type": "expense", "note": "Mua đồ gia dụng", "date": "2024-10-14"},
      {"amount": 500000, "category_id": 6, "category_type": "expense", "note": "Ăn sáng tại nhà", "date": "2024-10-15"},
      {"amount": 2000000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 10", "date": "2024-10-16"},
      {"amount": 600000, "category_id": 9, "category_type": "expense", "note": "Mua vé xem phim", "date": "2024-10-17"},
      {"amount": 250000, "category_id": 7, "category_type": "expense", "note": "Đi mua sắm", "date": "2024-10-18"},
      {"amount": 1000000, "category_id": 1, "category_type": "income", "note": "Tiền thưởng tháng 10", "date": "2024-10-19"},
      {"amount": 500000, "category_id": 3, "category_type": "income", "note": "Lợi nhuận bán hàng", "date": "2024-10-20"},
      {"amount": 800000, "category_id": 6, "category_type": "expense", "note": "Thanh toán hóa đơn", "date": "2024-10-21"},
      {"amount": 600000, "category_id": 9, "category_type": "expense", "note": "Đi chơi giải trí", "date": "2024-10-22"},
      {"amount": 700000, "category_id": 5, "category_type": "expense", "note": "Ăn sáng ngoài", "date": "2024-10-23"},
      {"amount": 1200000, "category_id": 1, "category_type": "income", "note": "Tiền thưởng tháng 10", "date": "2024-10-24"},
      {"amount": 300000, "category_id": 3, "category_type": "income", "note": "Lợi nhuận từ kinh doanh", "date": "2024-10-25"},
      {"amount": 1000000, "category_id": 6, "category_type": "expense", "note": "Di chuyển công tác", "date": "2024-10-26"},
      {"amount": 200000, "category_id": 8, "category_type": "expense", "note": "Thanh toán tiền điện thoại", "date": "2024-10-27"},
      {"amount": 1500000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 10", "date": "2024-10-28"},
      {"amount": 250000, "category_id": 9, "category_type": "expense", "note": "Ăn tối tại nhà", "date": "2024-10-29"},
      {"amount": 1200000, "category_id": 7, "category_type": "expense", "note": "Mua đồ gia dụng", "date": "2024-10-30"},
      {"amount": 500000, "category_id": 1, "category_type": "income", "note": "Lương tháng 11", "date": "2024-11-01"},
      {"amount": 300000, "category_id": 8, "category_type": "expense", "note": "Thanh toán hóa đơn internet", "date": "2024-11-02"},
      {"amount": 1000000, "category_id": 2, "category_type": "income", "note": "Tiền thưởng tháng 11", "date": "2024-11-03"},
      {"amount": 500000, "category_id": 9, "category_type": "expense", "note": "Đi xem phim", "date": "2024-11-04"},
      {"amount": 700000, "category_id": 6, "category_type": "expense", "note": "Di chuyển công tác", "date": "2024-11-05"},
      {"amount": 200000, "category_id": 7, "category_type": "expense", "note": "Mua đồ ăn sáng", "date": "2024-11-06"},
      {"amount": 1200000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 11", "date": "2024-11-07"},
      {"amount": 500000, "category_id": 5, "category_type": "expense", "note": "Thanh toán hóa đơn điện", "date": "2024-11-08"},
      {"amount": 200000, "category_id": 3, "category_type": "income", "note": "Lợi nhuận từ kinh doanh", "date": "2024-11-09"},
      {"amount": 400000, "category_id": 6, "category_type": "expense", "note": "Đi Taxi", "date": "2024-11-10"},
      {"amount": 1500000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 11", "date": "2024-11-11"},
      {"amount": 1000000, "category_id": 7, "category_type": "expense", "note": "Mua sắm điện thoại", "date": "2024-11-12"},
      {"amount": 500000, "category_id": 9, "category_type": "expense", "note": "Đi chơi giải trí", "date": "2024-11-13"},
      {"amount": 700000, "category_id": 1, "category_type": "income", "note": "Tiền thưởng tháng 11", "date": "2024-11-14"},
      {"amount": 100000, "category_id": 3, "category_type": "income", "note": "Lợi nhuận từ bán hàng", "date": "2024-11-15"},
      {"amount": 250000, "category_id": 8, "category_type": "expense", "note": "Thanh toán hóa đơn internet", "date": "2024-11-16"},
      {"amount": 200000, "category_id": 9, "category_type": "expense", "note": "Mua sắm quần áo", "date": "2024-11-17"},
      {"amount": 1500000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 11", "date": "2024-11-18"},
      {"amount": 200000, "category_id": 3, "category_type": "income", "note": "Lợi nhuận từ kinh doanh", "date": "2024-11-19"},
      {"amount": 1000000, "category_id": 5, "category_type": "expense", "note": "Mua đồ gia dụng", "date": "2024-11-20"},
      {"amount": 300000, "category_id": 7, "category_type": "expense", "note": "Mua sắm quần áo", "date": "2024-11-21"},
      {"amount": 500000, "category_id": 8, "category_type": "expense", "note": "Thanh toán tiền điện thoại", "date": "2024-11-22"},
      {"amount": 1500000, "category_id": 1, "category_type": "income", "note": "Tiền lương tháng 11", "date": "2024-11-23"},
      {"amount": 600000, "category_id": 6, "category_type": "expense", "note": "Ăn sáng tại nhà", "date": "2024-11-24"}
    ]
    ;

    for (var transaction in transactions) {
      await db.insert('transactions', transaction, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}

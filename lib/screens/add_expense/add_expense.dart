import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../helpers/db/database_helper.dart';
import '../../helpers/db/dao/category_dao.dart';
import '../../helpers/db/models/insert_transaction_model.dart';
import '../../helpers/providers/transaction_provider.dart';

class AddExpense extends StatefulWidget {
  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _transactionType = "expense";
  int _categoryId = 0;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _categories = [];

  Future<void> _loadCategories() async {
    final db = await DatabaseHelper().database;
    final categoryDao = CategoryDao();
    final categoryData = await categoryDao.fetchCategories(db, _transactionType);

    setState(() {
      _categories = categoryData;
      if (_categories.isNotEmpty) {
        _categoryId = _categories[0]['id'];
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() async {
    if (_amountController.text.isEmpty || _categoryId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Vui lòng nhập đủ thông tin giao dịch"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final insertTransactionData = InsertTransactionModel(
      amount: int.parse(_amountController.text.replaceAll(',', '')),
      note: _noteController.text,
      categoryType: _transactionType,
      categoryId: _categoryId,
      date: _selectedDate,
    );

    // Thêm giao dịch mới vào provider
    await context.read<TransactionProvider>().addTransaction(insertTransactionData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Giao dịch đã được lưu!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Thêm Giao Dịch",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Chọn loại giao dịch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTransactionTypeButton("Khoản Thu", "income"),
                      SizedBox(width: 16),
                      _buildTransactionTypeButton("Khoản Chi", "expense"),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Nhập số tiền
                  _buildAmountInput(),
                  SizedBox(height: 20),

                  // Chọn danh mục
                  _buildCategoryDropdown(),
                  SizedBox(height: 20),

                  // Chọn ngày
                  _buildDatePicker(),
                  SizedBox(height: 20),

                  // Nhập ghi chú
                  _buildNoteInput(),
                  SizedBox(height: 30),

                  // Nút lưu giao dịch
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget cho nút chọn loại giao dịch
  Widget _buildTransactionTypeButton(String text, String type) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _transactionType = type;
            _loadCategories();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _transactionType == type
              ? (type == "income" ? Colors.green : Colors.red)
              : Colors.grey.shade300,
          foregroundColor: _transactionType == type ? Colors.white : Colors.black,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Widget nhập số tiền
  Widget _buildAmountInput() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        // Định dạng số tiền với dấu phẩy
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text;
          return TextEditingValue(
            text: text.isNotEmpty
                ? NumberFormat('#,###').format(int.parse(text.replaceAll(',', '')))
                : '',
            selection: TextSelection.collapsed(offset: text.length),
          );
        }),
      ],
      decoration: InputDecoration(
        labelText: "Số Tiền",
        prefixText: "₫ ",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Widget chọn danh mục
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _categoryId,
      hint: Text("Chọn danh mục"),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      onChanged: (int? newValue) {
        setState(() {
          _categoryId = newValue!;
        });
      },
      items: _categories.map<DropdownMenuItem<int>>((category) {
        return DropdownMenuItem<int>(
          value: category['id'],
          child: Row(
            children: [
              Icon(Icons.category, color: Colors.deepPurple),
              SizedBox(width: 10),
              Text(category['name'] ?? 'Không có tên'),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Widget chọn ngày
  Widget _buildDatePicker() {
    return ElevatedButton(
      onPressed: _selectDate,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, color: Colors.deepPurple),
          SizedBox(width: 10),
          Text(
            "Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget nhập ghi chú
  Widget _buildNoteInput() {
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText: "Ghi Chú (Tùy chọn)",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        prefixIcon: Icon(Icons.notes, color: Colors.deepPurple),
      ),
      maxLines: 2,
    );
  }

  // Nút lưu giao dịch
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save),
          SizedBox(width: 10),
          Text(
            "Lưu Giao Dịch",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
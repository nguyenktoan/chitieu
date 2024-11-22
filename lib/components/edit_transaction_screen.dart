import 'package:chitieu/helpers/providers/category_provider.dart';
import 'package:chitieu/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chitieu/helpers/db/models/update_transaction.dart';
import 'package:chitieu/helpers/providers/transaction_provider.dart';

// Định nghĩa theme colors - giữ nhất quán với AddExpense
class AppColors {
  static const primary = Color(0xFF00B2E7);
  static const secondary = Color(0xFFE064F7);
  static const tertiary = Color(0xFFFF8D6C);
  static final surface = Colors.grey.shade100;
  static const onSurface = Colors.black;
  static final outline = Colors.grey.shade400;
}

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const EditTransactionScreen({required this.transaction, super.key});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _selectedDate;
  int? _categoryId;
  String _transactionType = "expense";

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.transaction["amount"].toString();
    _noteController.text = widget.transaction["note"] ?? "";
    _selectedDate = DateTime.tryParse(widget.transaction["date"]) ?? DateTime.now();
    _categoryId = widget.transaction["category_id"];
    _transactionType = widget.transaction["category_type"] ?? "expense";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories(_transactionType);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Chỉnh Sửa Giao Dịch',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.onSurface),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.outline.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTransactionTypeSegment(),
                  SizedBox(height: 24),
                  _buildAmountInput(),
                  SizedBox(height: 20),
                  _buildCategoryDropdown(categoryProvider.categories),
                  SizedBox(height: 20),
                  _buildDatePicker(),
                  SizedBox(height: 20),
                  _buildNoteInput(),
                  SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSegment() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTransactionTypeButton(
              "Khoản Thu",
              "income",
              AppColors.secondary,
            ),
          ),
          Expanded(
            child: _buildTransactionTypeButton(
              "Khoản Chi",
              "expense",
              AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeButton(String text, String type, Color activeColor) {
    final isSelected = _transactionType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _transactionType = type;
          _categoryId = null;
          context.read<CategoryProvider>().fetchCategories(_transactionType);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Số Tiền",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
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
            prefixText: "₫ ",
            prefixStyle: TextStyle(color: AppColors.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(List<Map<String, dynamic>> categories) {
    final validCategoryIds = categories.map((category) => category['id']).toList();
    if (!validCategoryIds.contains(_categoryId)) {
      _categoryId = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Danh Mục",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _categoryId, // Giá trị hiện tại của dropdown
          hint: Text(_categoryId != null ? 'ID: $_categoryId' : 'Chọn danh mục'), // Hiển thị hint nếu chưa chọn
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (int? newValue) {
            setState(() {
              _categoryId = newValue!; // Chỉ thay đổi giá trị khi người dùng chọn một mục
            });
          },
          items: categories.map<DropdownMenuItem<int>>((category) {
            return DropdownMenuItem<int>(
              value: category['id'],
              child: Row(
                children: [
                  Icon(Icons.category, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text(
                    category['name'],
                    style: TextStyle(color: AppColors.onSurface),
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ngày Giao Dịch",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ghi Chú",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: "Nhập ghi chú (tùy chọn)",
            prefixIcon: Icon(Icons.notes, color: AppColors.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 3,
          style: TextStyle(color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final primaryColor = Theme.of(context).colorScheme.primary;  // Lấy màu primary từ Theme
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    return ElevatedButton(
      onPressed: _saveTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,  // Dùng màu primary từ Theme
        foregroundColor: onPrimaryColor,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save),
          SizedBox(width: 12),
          Text(
            "Lưu Chỉnh Sửa",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
              secondary: AppColors.secondary,
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

  void _saveTransaction() {
    final updatedTransaction = UpdateTransactionModel(
      id: widget.transaction["id"],
      amount: int.parse(_amountController.text.replaceAll(',', '')),
      note: _noteController.text,
      categoryId: _categoryId!,
      categoryType: _transactionType,
      date: _selectedDate!,
    );

    context.read<TransactionProvider>().updateTransaction(updatedTransaction);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cập nhật giao dịch thành công!'),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}
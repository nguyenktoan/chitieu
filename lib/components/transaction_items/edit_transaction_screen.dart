import 'package:chitieu/helpers/db/models/update_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'package:chitieu/helpers/db/models/transaction_model.dart'; // Import UserTransaction model

import '../../helpers/db/models/insert_transaction_model.dart';
import '../../helpers/providers/transaction_provider.dart'; // Import the TransactionProvider

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const EditTransactionScreen({required this.transaction, super.key});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.transaction["amount"].toString();
    _noteController.text = widget.transaction["note"] ?? "";
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chỉnh Sửa Giao Dịch',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildAmountField(),
                const SizedBox(height: 20),
                _buildNoteField(),
                const SizedBox(height: 20),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: 'Số tiền',
        prefixIcon: const Icon(Icons.monetization_on_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số tiền';
        }
        if (int.tryParse(value) == null) {
          return 'Vui lòng nhập số tiền hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Ghi chú',
        prefixIcon: const Icon(Icons.notes),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: const Text(
        'Lưu Thay Đổi',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      // Chuyển giá trị ngày từ String sang DateTime nếu cần
      final date = DateTime.tryParse(widget.transaction["date"]) ?? DateTime.now();

      final updatedTransaction = UpdateTransactionModel(
        id: widget.transaction["id"],  // Lấy id từ giao dịch hiện tại
        amount: int.parse(_amountController.text),
        note: _noteController.text,
        categoryType: widget.transaction["categoryType"] ?? "default_category",
        categoryId: widget.transaction["categoryId"] ?? 1,
        date: date,
      );

      try {
        // Sử dụng Provider để cập nhật giao dịch
        await context.read<TransactionProvider>().updateTransaction(updatedTransaction);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giao dịch đã được cập nhật'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);  // Trở lại màn hình trước với kết quả thành công
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

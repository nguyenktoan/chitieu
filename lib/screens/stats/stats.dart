import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../../components/IncomeExpenseSummaryCard.dart';
import '../../components/ParentCategoryList.dart';
import '../../components/transaction_item.dart';
import '../../helpers/providers/report_provider.dart';

class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  _StatScreenState createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? selectedDateRange;
  DateTimeRange? selectedWeekRange; // Thêm biến này để lưu tuần đã chọn
  ValueNotifier<String> selectedCategoryType = ValueNotifier('expense');
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(_fetchData);
  }

  @override
  void dispose() {
    _tabController.dispose();
    selectedCategoryType.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final startDate = selectedDateRange?.start;
    final endDate = selectedDateRange?.end;
    final categoryType = selectedCategoryType.value;

    await Future.wait([
      reportProvider.fetchFilteredBalance(startDate: startDate, endDate: endDate, categoryType: categoryType),
      reportProvider.fetchCategoryAmount(startDate: startDate, endDate: endDate, categoryType: categoryType),
      reportProvider.getTransactions(startDate: startDate, endDate: endDate, categoryType: categoryType),
    ]);
    setState(() => _refreshKey++);
  }

  // Hàm tính tuần chứa ngày đã chọn
  DateTimeRange _getWeekRange(DateTime selectedDate) {
    DateTime startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - DateTime.monday));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6)); // Chủ Nhật

    return DateTimeRange(start: startOfWeek, end: endOfWeek);
  }

  // Hàm chọn tuần: hiển thị lịch của tháng hiện tại
  Future<void> _selectWeekRange(BuildContext context) async {
    DateTime? selectedDay = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDay != null) {
      // Lấy phạm vi tuần từ ngày đã chọn
      DateTimeRange selectedWeek = _getWeekRange(selectedDay);

      setState(() {
        selectedWeekRange = selectedWeek;
      });

      await _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final reportProvider = Provider.of<ReportProvider>(context);

    if (reportProvider.isLoading) return const Center(child: CircularProgressIndicator());

    // Cập nhật logic hiển thị ngày tháng năm tùy thuộc vào chọn tháng hay tuần
    String dateRangeText = '';
    if (selectedWeekRange != null) {
      // Nếu đã chọn tuần, hiển thị ngày bắt đầu và kết thúc tuần
      dateRangeText = "${selectedWeekRange!.start.day}/${selectedWeekRange!.start.month}/${selectedWeekRange!.start.year} - "
          "${selectedWeekRange!.end.day}/${selectedWeekRange!.end.month}/${selectedWeekRange!.end.year}";
    } else if (selectedDateRange != null) {
      // Nếu đã chọn tháng, hiển thị tháng và năm
      dateRangeText = "${selectedDateRange!.start.month}/${selectedDateRange!.start.year} - "
          "${selectedDateRange!.end.month}/${selectedDateRange!.end.year}";
    } else {
      // Nếu chưa chọn gì, hiển thị tháng hiện tại
      DateTime now = DateTime.now();
      dateRangeText = "${now.month}/${now.year}";
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateRangeText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.onSurface)),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.calendar_today, color: theme.primary),
                    onSelected: (value) {
                      if (value == 'month') {
                        _selectDateRange(context);  // Chọn tháng
                      } else {
                        _selectWeekRange(context);  // Chọn tuần
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'month', 'week'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice == 'month' ? 'Chọn tháng' : 'Chọn tuần'),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IncomeExpenseSummaryCard(income: reportProvider.income, expense: reportProvider.expense, balance: reportProvider.balance, theme: theme),
            const SizedBox(height: 20),
            ValueListenableBuilder<String>(
              valueListenable: selectedCategoryType,
              builder: (context, value, child) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: value == 'expense' ? theme.primary : theme.surface),
                    onPressed: () {
                      selectedCategoryType.value = 'expense';
                      _fetchData();
                    },
                    child: Text('Chi tiêu', style: TextStyle(color: value == 'expense' ? Colors.white : theme.onSurface)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: value == 'income' ? theme.primary : theme.surface),
                    onPressed: () {
                      selectedCategoryType.value = 'income';
                      _fetchData();
                    },
                    child: Text('Thu nhập', style: TextStyle(color: value == 'income' ? Colors.white : theme.onSurface)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TabBar(controller: _tabController, tabs: const [Tab(text: 'Tất cả'), Tab(text: 'Danh mục')]),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(itemCount: reportProvider.transactions.length, itemBuilder: (context, index) => TransactionItem(transaction: reportProvider.transactions[index].toMap())),
                  _buildParentCategoryList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentCategoryList() {
    final reportProvider = Provider.of<ReportProvider>(context);
    return ParentCategoryList(categoryAmounts: Future.value(reportProvider.categoryAmounts));
  }

  // Hàm chọn tháng thay vì ngày
  Future<void> _selectDateRange(BuildContext context) async {
    DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: selectedDateRange?.start ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = DateTimeRange(
          start: picked,
          end: DateTime(picked.year, picked.month + 1, 0).subtract(const Duration(days: 1)),  // Chỉnh lại ngày cuối cùng trong tháng
        );
      });
      await _fetchData();
    }
  }
}

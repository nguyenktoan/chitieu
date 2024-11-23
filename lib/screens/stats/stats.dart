import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  ValueNotifier<String> selectedCategoryType = ValueNotifier('expense'); // Sử dụng ValueNotifier
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => _fetchData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    selectedCategoryType.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    await reportProvider.fetchFilteredBalance(
      startDate: selectedDateRange?.start,
      endDate: selectedDateRange?.end,
      categoryType: selectedCategoryType.value,
    );
    await reportProvider.fetchCategoryAmount(
      startDate: selectedDateRange?.start,
      endDate: selectedDateRange?.end,
      categoryType: selectedCategoryType.value,
    );
    await reportProvider.getTransactions(
      startDate: selectedDateRange?.start,
      endDate: selectedDateRange?.end,
      categoryType: selectedCategoryType.value,
    );

    setState(() {
      _refreshKey++; // Trigger UI update
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
      await _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final reportProvider = Provider.of<ReportProvider>(context);

    if (reportProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    String dateRangeText = selectedDateRange != null
        ? "${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}"
        : "Chọn khoảng thời gian";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Picker
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateRangeText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: theme.primary),
                    onPressed: () => _selectDateRange(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Income and Expense Summary
            IncomeExpenseSummaryCard(
              income: reportProvider.income,
              expense: reportProvider.expense,
              balance: reportProvider.balance,
              theme: theme,
            ),
            const SizedBox(height: 20),

            // Nút chuyển đổi giữa Chi tiêu và Thu nhập
            ValueListenableBuilder<String>(
              valueListenable: selectedCategoryType,
              builder: (context, value, child) { // 'value' chính là .value của ValueNotifier
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: value == 'expense'
                            ? theme.primary
                            : theme.surface,
                      ),
                      onPressed: () {
                        selectedCategoryType.value = 'expense'; // Thay đổi giá trị ValueNotifier
                        _fetchData(); // Gọi fetchData khi giá trị thay đổi
                      },
                      child: Text(
                        'Chi tiêu',
                        style: TextStyle(
                          color: value == 'expense'
                              ? Colors.white
                              : theme.onSurface,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: value == 'income'
                            ? theme.primary
                            : theme.surface,
                      ),
                      onPressed: () {
                        selectedCategoryType.value = 'income'; // Thay đổi giá trị
                        _fetchData();
                      },
                      child: Text(
                        'Thu nhập',
                        style: TextStyle(
                          color: value == 'income'
                              ? Colors.white
                              : theme.onSurface,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Tất cả'),
                Tab(text: 'Danh mục'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Giao dịch
                  ListView.builder(
                    itemCount: reportProvider.transactions.length,
                    itemBuilder: (context, index) {
                      return TransactionItem(transaction: reportProvider.transactions[index].toMap());
                    },
                  ),
                  // Danh mục
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
    // Fake data
    Future<Map<String, Map<String, dynamic>>> fakeData = Future.delayed(
      Duration(seconds: 2), // Giả lập thời gian chờ dữ liệu
          () => {
        'Food': {
          'category_name': 'Ăn uống',
          'total_amount': 1500000,
          'icon': Icons.restaurant.codePoint,
          'color': '0xFF00FF00', // Green
        },
        'Transport': {
          'category_name': 'Di chuyển',
          'total_amount': 500000,
          'icon': Icons.directions_car.codePoint,
          'color': '0xFF0000FF', // Blue
        },
        'Shopping': {
          'category_name': 'Mua sắm',
          'total_amount': 1200000,
          'icon': Icons.shopping_cart.codePoint,
          'color': '0xFFFF0000', // Red
        },
      },
    );

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: ParentCategoryList(
        categoryAmounts: fakeData,
      ),
    );
  }
}

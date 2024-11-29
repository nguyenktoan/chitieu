import 'package:chitieu/screens/stats/stat_widgets/tabSection.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';
import 'stat_widgets/IncomeExpenseSummaryCard.dart';
import 'stat_widgets/ParentCategoryList.dart';
import '../../components/transaction_item.dart';
import '../../helpers/providers/report_provider.dart';
import '../../helpers/providers/transaction_provider.dart';
import 'stat_widgets/pie_chart.dart';

class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  _StatScreenState createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? selectedDateRange;
  DateTimeRange? selectedWeekRange;
  ValueNotifier<String> selectedCategoryType = ValueNotifier('expense');
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Lắng nghe thay đổi từ TransactionProvider
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    reportProvider.listenToTransactions(transactionProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    selectedCategoryType.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    DateTime? startDate;
    DateTime? endDate;
    if (selectedWeekRange != null) {
      startDate = selectedWeekRange!.start;
      endDate = selectedWeekRange!.end;
    } else if (selectedDateRange != null) {
      startDate = selectedDateRange!.start;
      endDate = selectedDateRange!.end;
    }

    final categoryType = selectedCategoryType.value;

    await Future.wait([
      reportProvider.fetchFilteredBalance(
          startDate: startDate, endDate: endDate, categoryType: categoryType),
      reportProvider.fetchCategoryAmount(
          startDate: startDate, endDate: endDate, categoryType: categoryType),
      reportProvider.getTransactions(
          startDate: startDate, endDate: endDate, categoryType: categoryType),
      reportProvider.getTransactions(
          startDate: startDate, endDate: endDate, categoryType: categoryType),
    ]);
    setState(() => _refreshKey++);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        if (reportProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.primary,
              backgroundColor: theme.primary.withOpacity(0.2),
            ),
          );
        }

        String dateRangeText = _getFormattedDateRange();

        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.surface,
                  Colors.white,
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateRangeSelector(theme, dateRangeText),
                    const SizedBox(height: 16),
                    IncomeExpenseSummaryCard(
                      income: reportProvider.income,
                      expense: reportProvider.expense,
                      balance: reportProvider.balance,
                      theme: theme,
                    ),
                    const SizedBox(height: 24),
                    _buildCategoryTypeSelector(theme),
                    const SizedBox(height: 24),
                    _buildPieChartSection(reportProvider, theme),
                    const SizedBox(height: 24),
                    _buildTabSection(reportProvider, theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateRangeSelector(ColorScheme theme, String dateRangeText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              fontWeight: FontWeight.w600,
              color: theme.onSurface,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.calendar_today, color: theme.primary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            offset: const Offset(0, 40),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'month',
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: theme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text('Chọn tháng'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'week',
                child: Row(
                  children: [
                    Icon(Icons.view_week, color: theme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text('Chọn tuần'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'month') {
                _selectDateRange(context);
              } else {
                _selectWeekRange(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTypeSelector(ColorScheme theme) {
    return ValueListenableBuilder<String>(

      valueListenable: selectedCategoryType,
      builder: (context, value, child) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildCategoryButton(
                'Chi tiêu',
                value == 'expense',
                () {
                  selectedCategoryType.value = 'expense';
                  _fetchData();
                },
                theme,

              ),
            ),
            Expanded(
              child: _buildCategoryButton(
                'Thu nhập',
                value == 'income',
                () {
                  selectedCategoryType.value = 'income';
                  _fetchData();
                },
                theme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
      String text, bool isSelected, VoidCallback onPressed, ColorScheme theme) {
    // Define colors for each category type
    Color buttonColor = (text == 'Chi tiêu')
        ? (isSelected ? theme.tertiary : Colors.white) // Red color for "Chi tiêu"
        : (text == 'Thu nhập')
        ? (isSelected ? theme.primary : Colors.white) // Green color for "Thu nhập"
        : Colors.white; // Default color for others

    Color textColor = (text == 'Chi tiêu')
        ? (isSelected ? Colors.white : theme.onSurface) // White text when selected, else theme's surface text color
        : (text == 'Thu nhập')
        ? (isSelected ? Colors.white : theme.onSurface)
        : theme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          elevation: isSelected ? 4 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }


  Widget _buildPieChartSection(
      ReportProvider reportProvider, ColorScheme theme) {
    final categoryAmounts = reportProvider.categoryAmounts;
    if (categoryAmounts.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.pie_chart_outline, size: 48, color: theme.outline),
            const SizedBox(height: 8),
            Text(
              "Không có dữ liệu",
              style: TextStyle(color: theme.outline, fontSize: 16),
            ),
          ],
        ),
      );
    }

    Map<String, double> dataMap = {};
    categoryAmounts.forEach((key, value) {
      dataMap[key] = value['total_amount']?.toDouble() ?? 0.0;
    });

    List<Color> colorList = [
      theme.primary,
      theme.secondary,
      theme.tertiary,
      theme.primary.withOpacity(0.7),
      theme.secondary.withOpacity(0.7),
      theme.tertiary.withOpacity(0.7),
    ];

    return PieChartSection(
      dataMap: dataMap,
      centerText:
          selectedCategoryType.value == 'expense' ? 'Chi tiêu' : 'Thu nhập',
      colorList: colorList,
    );
  }

  Widget _buildTabSection(ReportProvider reportProvider, ColorScheme theme) {
    return TabSection(
      tabController: _tabController,
      reportProvider: reportProvider,
      theme: theme,
    );
  }

  String _getFormattedDateRange() {
    if (selectedWeekRange != null) {
      return "${selectedWeekRange!.start.day}/${selectedWeekRange!.start.month} - "
          "${selectedWeekRange!.end.day}/${selectedWeekRange!.end.month}/${selectedWeekRange!.end.year}";
    } else if (selectedDateRange != null) {
      return "Tháng ${selectedDateRange!.start.month}/${selectedDateRange!.start.year}";
    } else {
      DateTime now = DateTime.now();
      return "Tháng ${now.month}/${now.year}";
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    // Mở hộp thoại chọn tháng
    DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: selectedDateRange?.start ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        // Chỉ cập nhật selectedDateRange và xóa selectedWeekRange
        selectedDateRange = DateTimeRange(
          start: picked,
          end: DateTime(picked.year, picked.month + 1, 0)
              .subtract(const Duration(days: 1)),
        );
        selectedWeekRange = null;
      });

      await _fetchData();
    }
  }

  Future<void> _selectWeekRange(BuildContext context) async {
    // Hiển thị hộp thoại chọn ngày
    DateTime? selectedDay = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDay != null) {
      // Tính toán khoảng thời gian tuần từ ngày đã chọn
      DateTimeRange selectedWeek = _getWeekRange(selectedDay);
      setState(() {
        // Cập nhật selectedWeekRange và xóa selectedDateRange
        selectedWeekRange = selectedWeek;
        selectedDateRange = null; // Xóa selectedDateRange khi chuyển về tuần
      });

      // Gọi lại _fetchData() để tải lại dữ liệu cho tuần đã chọn
      await _fetchData();
    }
  }

// Hàm tính toán khoảng thời gian tuần từ một ngày đã chọn
  DateTimeRange _getWeekRange(DateTime selectedDate) {
    // Tính ngày bắt đầu tuần (Thứ Hai)
    DateTime startOfWeek = selectedDate
        .subtract(Duration(days: selectedDate.weekday - DateTime.monday));
    startOfWeek =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    // Tính ngày kết thúc tuần (Chủ Nhật)
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    endOfWeek = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59,
        59, 999); // Bao gồm hết ngày Chủ Nhật

    return DateTimeRange(start: startOfWeek, end: endOfWeek);
  }
}

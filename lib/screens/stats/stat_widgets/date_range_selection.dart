import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class DateRangeSelector extends StatelessWidget {
  final String dateRangeText;
  final Function onSelectDateRange;
  final Function onSelectWeekRange;
  final ColorScheme theme;

  const DateRangeSelector({
    Key? key,
    required this.dateRangeText,
    required this.onSelectDateRange,
    required this.onSelectWeekRange,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                onSelectDateRange(context);
              } else {
                onSelectWeekRange(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

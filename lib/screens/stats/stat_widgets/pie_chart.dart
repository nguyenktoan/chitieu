import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartSection extends StatefulWidget {
  final Map<String, double> dataMap;
  final String centerText;
  final List<Color> colorList;

  const PieChartSection({
    Key? key,
    required this.dataMap,
    required this.centerText,
    required this.colorList,
  }) : super(key: key);

  @override
  State<PieChartSection> createState() => _PieChartSectionState();
}

class _PieChartSectionState extends State<PieChartSection> {
  int touchedIndex = -1;

  // Tính tổng các giá trị trong dataMap
  double get totalValue {
    return widget.dataMap.values.reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                color: theme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Phân bổ chi tiêu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: screenWidth * 0.15,
                sections: _generateSections(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          EnhancedGridLegend(
            dataMap: widget.dataMap,
            colorList: widget.colorList,
            touchedIndex: touchedIndex,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateSections() {
    return List.generate(widget.dataMap.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final value = widget.dataMap.values.elementAt(i);

      // Tính phần trăm cho mỗi phần
      final percentage = (value / totalValue) * 100;

      return PieChartSectionData(
        color: widget.colorList[i % widget.colorList.length],
        value: value,
        title: '${percentage.toStringAsFixed(1)}%', // Hiển thị phần trăm
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
      );
    });
  }
}

class EnhancedGridLegend extends StatelessWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;
  final int touchedIndex;
  final int columnsCount;

  const EnhancedGridLegend({
    Key? key,
    required this.dataMap,
    required this.colorList,
    required this.touchedIndex,
    this.columnsCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      dataMap.length,
          (index) => EnhancedLegendItem(
        color: colorList[index % colorList.length],
        title: dataMap.keys.elementAt(index),
        value: dataMap.values.elementAt(index),
        isSelected: index == touchedIndex,
      ),
    );

    final int itemCount = dataMap.length;
    final int rowCount = (itemCount / columnsCount).ceil();

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: List.generate(rowCount, (rowIndex) {
        return TableRow(
          children: List.generate(columnsCount, (colIndex) {
            final itemIndex = rowIndex * columnsCount + colIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: itemIndex < itemCount
                  ? items[itemIndex]
                  : const SizedBox(),
            );
          }),
        );
      }),
    );
  }
}

class EnhancedLegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final double value;
  final bool isSelected;

  const EnhancedLegendItem({
    Key? key,
    required this.color,
    required this.title,
    required this.value,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

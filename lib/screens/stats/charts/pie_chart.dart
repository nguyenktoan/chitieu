// PieChartSection.dart
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Text(
            'Phân bổ chi tiêu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          PieChart(
            dataMap: dataMap,
            chartType: ChartType.ring,
            ringStrokeWidth: 50,
            chartRadius: MediaQuery.of(context).size.width * 0.5,
            centerText: centerText,
            colorList: colorList,
            chartValuesOptions: ChartValuesOptions(
              showChartValues: true,
              showChartValuesInPercentage: true,
              showChartValuesOutside: true,
              showChartValueBackground: true,
              chartValueStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            legendOptions: const LegendOptions(
              showLegends: true,
              legendPosition: LegendPosition.bottom,
            ),
          ),
        ],
      ),
    );
  }
}

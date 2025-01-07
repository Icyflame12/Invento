import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesTrendChart extends StatelessWidget {
  final List<BarChartGroupData> chartData;

  const SalesTrendChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: chartData,
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: true),
          barTouchData: BarTouchData(enabled: false),
        ),
      ),
    );
  }
}

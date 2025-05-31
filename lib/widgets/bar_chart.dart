import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/summary.dart';

class SummaryBarChart extends StatelessWidget {
  final List<Summary> summaries;
  final Color accent;

  const SummaryBarChart({
    super.key,
    required this.summaries,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = summaries.where((s) => s.category.isNotEmpty).toList();
    if (filtered.isEmpty) {
      return const SizedBox(
        height: 260,
        child: Center(child: Text('No data for chart')),
      );
    }
    return SizedBox(
      height: 260,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: (filtered.length * 48).toDouble().clamp(320, double.infinity),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: _getYAxisInterval(summaries),
                    getTitlesWidget: (value, meta) {
                      if (value % _getYAxisInterval(summaries) != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= filtered.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          filtered[idx].category.length > 7
                              ? '${filtered[idx].category.substring(0, 7)}…'
                              : filtered[idx].category,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                    reservedSize: 48,
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true, horizontalInterval: _getYAxisInterval(summaries)),
              barGroups: [
                for (final entry in filtered.asMap().entries)
                  BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.budget,
                        color: accent,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: entry.value.expenditure,
                        color: Colors.red[400],
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
              ],
              groupsSpace: 18,
              maxY: _getMaxY(summaries),
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY(List<Summary> summaries) {
    final maxVal = summaries
        .where((s) => s.category.isNotEmpty)
        .expand((s) => [s.budget, s.expenditure])
        .fold<double>(0, (prev, el) => el > prev ? el : prev);
    return (maxVal / 1000.0).ceil() * 1000.0 + 1000;
  }

  double _getYAxisInterval(List<Summary> summaries) {
    final maxY = _getMaxY(summaries);
    if (maxY <= 2000) return 500;
    if (maxY <= 5000) return 1000;
    if (maxY <= 10000) return 2000;
    return 5000;
  }
}

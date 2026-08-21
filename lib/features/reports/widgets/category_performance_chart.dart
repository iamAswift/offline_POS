// lib/features/reports/widgets/category_performance_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryPerformanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> categorySummary;

  const CategoryPerformanceChart({
    super.key,
    required this.categorySummary,
  });

  @override
  Widget build(BuildContext context) {
    if (categorySummary.isEmpty) {
      return const Center(
        child: Text(
          "No category sales data",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 500;

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,

            maxY: _calculateMaxY(),

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calculateInterval(),
            ),

            borderData: FlBorderData(
              show: false,
            ),

            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),

              rightTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: compact ? 40 : 50,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _formatValue(value),
                      style: TextStyle(
                        fontSize: compact ? 8 : 9,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
              ),

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: compact ? 42 : 48,
                  getTitlesWidget: (value, meta) {
                    final index = value.round();

                    if (index < 0 ||
                        index >= categorySummary.length) {
                      return const SizedBox.shrink();
                    }

                    final name =
                        categorySummary[index]["categoryName"]
                            ?.toString() ??
                        "";

                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 6),
                      child: SizedBox(
                        width: compact ? 55 : 75,
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: compact ? 8 : 9,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            barGroups: [
              for (int i = 0;
                  i < categorySummary.length;
                  i++)
                BarChartGroupData(
                  x: i,

                  barRods: [
                    BarChartRodData(
                      toY: _toDouble(
                        categorySummary[i]["totalSales"],
                      ),
                      color: Colors.indigo,
                      width: compact ? 12 : 18,
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                    ),
                  ],
                ),
            ],

            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData:
                  BarTouchTooltipData(
                tooltipRoundedRadius: 8,
                getTooltipItem:
                    (group, groupIndex, rod, rodIndex) {
                  final name = categorySummary[
                              group.x.toInt()]
                          ["categoryName"]
                      ?.toString() ??
                      "";

                  return BarTooltipItem(
                    "$name\n₦${rod.toY.toStringAsFixed(0)}",
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? "",
        ) ??
        0.0;
  }

  double _calculateMaxY() {
    double maxValue = 0;

    for (final item in categorySummary) {
      final value = _toDouble(item["totalSales"]);

      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue <= 0) return 100;

    return maxValue * 1.2;
  }

  double _calculateInterval() {
    double maxValue = 0;

    for (final item in categorySummary) {
      final value = _toDouble(item["totalSales"]);

      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue <= 1000) return 200;
    if (maxValue <= 10000) return 2000;
    if (maxValue <= 100000) return 20000;
    if (maxValue <= 1000000) return 200000;

    return maxValue / 5;
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return "₦${(value / 1000000).toStringAsFixed(1)}M";
    }

    if (value >= 1000) {
      return "₦${(value / 1000).toStringAsFixed(0)}K";
    }

    return "₦${value.toStringAsFixed(0)}";
  }
}
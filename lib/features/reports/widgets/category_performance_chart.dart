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
      return const SizedBox(
        height: 190,
        child: Center(
          child: Text(
            'No category sales data',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 500;

        return SizedBox(
          height: 190,
          width: double.infinity,
          child: BarChart(
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
                    reservedSize: compact ? 34 : 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatValue(value),
                        style: TextStyle(
                          fontSize: compact ? 7 : 8,
                          color: Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: compact ? 34 : 38,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();

                      if (index < 0 ||
                          index >= categorySummary.length) {
                        return const SizedBox.shrink();
                      }

                      final name =
                          categorySummary[index]['categoryName']
                                  ?.toString() ??
                              '';

                      return Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: SizedBox(
                          width: compact ? 48 : 65,
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: compact ? 7 : 8,
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
                          categorySummary[i]['totalSales'],
                        ),
                        color: Colors.indigo,
                        width: compact ? 9 : 13,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ],
                  ),
              ],

              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 6,
                  getTooltipItem:
                      (group, groupIndex, rod, rodIndex) {
                    final index = group.x.toInt();

                    if (index < 0 ||
                        index >= categorySummary.length) {
                      return null;
                    }

                    final name =
                        categorySummary[index]['categoryName']
                                ?.toString() ??
                            '';

                    return BarTooltipItem(
                      '$name\n₦${rod.toY.toStringAsFixed(0)}',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CONVERT VALUE
  // ============================================================

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  // ============================================================
  // MAX Y
  // ============================================================

  double _calculateMaxY() {
    double maxValue = 0;

    for (final item in categorySummary) {
      final value = _toDouble(
        item['totalSales'],
      );

      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue <= 0) {
      return 100;
    }

    return maxValue * 1.15;
  }

  // ============================================================
  // GRID INTERVAL
  // ============================================================

  double _calculateInterval() {
    double maxValue = 0;

    for (final item in categorySummary) {
      final value = _toDouble(
        item['totalSales'],
      );

      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue <= 1000) {
      return 200;
    }

    if (maxValue <= 10000) {
      return 2000;
    }

    if (maxValue <= 100000) {
      return 20000;
    }

    if (maxValue <= 1000000) {
      return 200000;
    }

    return maxValue / 5;
  }

  // ============================================================
  // FORMAT VALUE
  // ============================================================

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '₦${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '₦${(value / 1000).toStringAsFixed(0)}K';
    }

    return '₦${value.toStringAsFixed(0)}';
  }
}
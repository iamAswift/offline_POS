// lib/features/reports/widgets/sales_trend_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/styles.dart';

class SalesTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> salesTrend;

  const SalesTrendChart({super.key, required this.salesTrend});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d');

    // ============================================================
    // EMPTY STATE
    // ============================================================

    if (salesTrend.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No sales data for this period',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
          ),
        ),
      );
    }

    // ============================================================
    // CHART
    // ============================================================

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 500;

        // Keep the complete widget comfortably below the
        // 228px height currently supplied by the dashboard card.
        final chartHeight = isCompact ? 165.0 : 180.0;

        return SizedBox(
          width: double.infinity,
          height: chartHeight + 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // LINE CHART
              // ==================================================
              SizedBox(
                height: chartHeight,
                width: double.infinity,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: salesTrend.length > 1
                        ? (salesTrend.length - 1).toDouble()
                        : 1,
                    minY: 0,

                    // ==================================================
                    // GRID
                    // ==================================================
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _calculateInterval(),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: AppColors.divider, strokeWidth: 1);
                      },
                    ),

                    // ==================================================
                    // BORDER
                    // ==================================================
                    borderData: FlBorderData(show: false),

                    // ==================================================
                    // TITLES
                    // ==================================================
                    titlesData: FlTitlesData(
                      // ------------------------------
                      // TOP
                      // ------------------------------
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      // ------------------------------
                      // RIGHT
                      // ------------------------------
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      // ------------------------------
                      // LEFT
                      // ------------------------------
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: isCompact ? 38 : 46,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: Text(
                                _formatAxisValue(value),
                                style: AppTextStyles.small.copyWith(
                                  fontSize: isCompact ? 8 : 9,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ------------------------------
                      // BOTTOM
                      // ------------------------------
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: isCompact ? 22 : 24,
                          interval: _bottomTitleInterval(),
                          getTitlesWidget: (value, meta) {
                            final index = value.round();

                            if (index < 0 || index >= salesTrend.length) {
                              return const SizedBox.shrink();
                            }

                            final rawDate = salesTrend[index]['date'];

                            final date = DateTime.tryParse(
                              rawDate?.toString() ?? '',
                            );

                            if (date == null) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                formatter.format(date),
                                style: AppTextStyles.small.copyWith(
                                  fontSize: isCompact ? 7 : 8,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // ==================================================
                    // SALES LINE
                    // ==================================================
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (int i = 0; i < salesTrend.length; i++)
                            FlSpot(
                              i.toDouble(),
                              _toDouble(salesTrend[i]['totalSales']),
                            ),
                        ],

                        isCurved: true,

                        color: AppColors.primary,

                        barWidth: isCompact ? 2 : 2.5,

                        isStrokeCapRound: true,

                        dotData: FlDotData(
                          show: salesTrend.length <= 14,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: isCompact ? 2.5 : 3,
                              color: AppColors.surface,
                              strokeWidth: 1.5,
                              strokeColor: AppColors.primary,
                            );
                          },
                        ),

                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.07),
                        ),
                      ),
                    ],

                    // ==================================================
                    // TOUCH / TOOLTIP
                    // ==================================================
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,

                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 6,

                        tooltipPadding: const EdgeInsets.all(6),

                        tooltipMargin: 6,

                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            final index = spot.x.round();

                            if (index < 0 || index >= salesTrend.length) {
                              return null;
                            }

                            final rawDate = salesTrend[index]['date'];

                            final date = DateTime.tryParse(
                              rawDate?.toString() ?? '',
                            );

                            final label = date != null
                                ? formatter.format(date)
                                : '';

                            final value = spot.y.toStringAsFixed(0);

                            return LineTooltipItem(
                              '$label\n₦$value',
                              const TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // ========================================================
              // LEGEND
              // ========================================================
              const SizedBox(height: 2),

              const SizedBox(
                height: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 7,
                      height: 7,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    SizedBox(width: 5),

                    Text(
                      'Total Sales',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // VALUE CONVERSION
  // ============================================================

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  // ============================================================
  // GRID INTERVAL
  // ============================================================

  double _calculateInterval() {
    if (salesTrend.isEmpty) {
      return 1;
    }

    double maxValue = 0;

    for (final item in salesTrend) {
      final value = _toDouble(item['totalSales']);

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
  // BOTTOM TITLE INTERVAL
  // ============================================================

  double _bottomTitleInterval() {
    if (salesTrend.length <= 7) {
      return 1;
    }

    if (salesTrend.length <= 14) {
      return 2;
    }

    if (salesTrend.length <= 30) {
      return 5;
    }

    return (salesTrend.length / 6).ceilToDouble();
  }

  // ============================================================
  // AXIS FORMATTING
  // ============================================================

  String _formatAxisValue(double value) {
    if (value >= 1000000) {
      return '₦${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '₦${(value / 1000).toStringAsFixed(0)}K';
    }

    return '₦${value.toStringAsFixed(0)}';
  }
}

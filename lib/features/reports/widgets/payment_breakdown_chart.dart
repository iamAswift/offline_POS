// lib/features/reports/widgets/payment_breakdown_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PaymentBreakdownChart extends StatelessWidget {
  final Map<String, double> paymentBreakdown;

  const PaymentBreakdownChart({
    super.key,
    required this.paymentBreakdown,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out zero values.
    final nonZeroEntries = paymentBreakdown.entries
        .where((entry) => entry.value > 0)
        .toList();

    // Empty state.
    if (nonZeroEntries.isEmpty) {
      return const SizedBox(
        height: 224,
        width: double.infinity,
        child: Center(
          child: Text(
            'No payment data available',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    // Build pie chart sections.
    final sections = nonZeroEntries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '₦${entry.value.toStringAsFixed(0)}',
        color: _paymentColor(entry.key),
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SizedBox(
      width: double.infinity,
      height: 224,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title.
          const SizedBox(
            height: 26,
            child: Text(
              '💳 Payment Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Pie chart.
          SizedBox(
            height: 150,
            width: double.infinity,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (response == null) {
                      return;
                    }

                    final touchedSection =
                        response.touchedSection;

                    if (touchedSection == null) {
                      return;
                    }

                    final sectionIndex =
                        touchedSection.touchedSectionIndex;

                    if (sectionIndex < 0 ||
                        sectionIndex >= nonZeroEntries.length) {
                      return;
                    }

                    final entry =
                        nonZeroEntries[sectionIndex];

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_displayPaymentMethod(entry.key)}: '
                          '₦${entry.value.toStringAsFixed(2)}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Legend.
          SizedBox(
            height: 36,
            child: Wrap(
              spacing: 14,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_hasPaymentMethod('cash'))
                  _legendItem(
                    'Cash',
                    Colors.green,
                  ),
                if (_hasPaymentMethod('transfer'))
                  _legendItem(
                    'Transfer',
                    Colors.blue,
                  ),
                if (_hasPaymentMethod('split'))
                  _legendItem(
                    'Split',
                    Colors.orange,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHECK PAYMENT METHOD
  // ============================================================

  bool _hasPaymentMethod(String method) {
    final value = paymentBreakdown[method];

    return value != null && value > 0;
  }

  // ============================================================
  // PAYMENT COLOR
  // ============================================================

  Color _paymentColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;

      case 'transfer':
        return Colors.blue;

      case 'split':
        return Colors.orange;

      default:
        return Colors.indigo;
    }
  }

  // ============================================================
  // DISPLAY PAYMENT METHOD
  // ============================================================

  String _displayPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';

      case 'transfer':
        return 'Transfer';

      case 'split':
        return 'Split';

      default:
        return method;
    }
  }

  // ============================================================
  // LEGEND ITEM
  // ============================================================

  Widget _legendItem(
    String label,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

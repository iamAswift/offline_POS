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
    final nonZeroEntries = paymentBreakdown.entries
        .where((entry) => entry.value > 0)
        .toList();

    // ============================================================
    // EMPTY STATE
    // ============================================================

    if (nonZeroEntries.isEmpty) {
      return const SizedBox(
        height: 190,
        width: double.infinity,
        child: Center(
          child: Text(
            'No payment data available',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    // ============================================================
    // PIE SECTIONS
    // ============================================================

    final sections = nonZeroEntries.map((entry) {
      return PieChartSectionData(
        value: entry.value,

        title: '₦${entry.value.toStringAsFixed(0)}',

        color: _paymentColor(entry.key),

        radius: 43,

        titleStyle: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    // ============================================================
    // MAIN WIDGET
    // ============================================================

    return SizedBox(
      width: double.infinity,
      height: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ========================================================
          // TITLE
          // ========================================================

          const SizedBox(
            height: 22,
            child: Text(
              '💳 Payment Breakdown',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 2),

          // ========================================================
          // PIE CHART
          // ========================================================

          SizedBox(
            height: 130,
            width: double.infinity,
            child: PieChart(
              PieChartData(
                sections: sections,

                sectionsSpace: 1,

                centerSpaceRadius: 25,

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
                        duration:
                            const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 2),

          // ========================================================
          // LEGEND
          // ========================================================

          SizedBox(
            height: 30,
            child: Wrap(
              spacing: 10,
              runSpacing: 3,
              crossAxisAlignment:
                  WrapCrossAlignment.center,
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                BorderRadius.circular(2),
          ),
        ),

        const SizedBox(width: 3),

        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
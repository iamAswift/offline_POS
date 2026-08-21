// lib/features/reports/models/reconciliation_row.dart

class ReconciliationRow {
  final String productName;

  final int openingStock;
  final int received;
  final int sold;
  final int expectedClosing;
  final int physicalCount;
  final int difference;

  const ReconciliationRow({
    required this.productName,
    required this.openingStock,
    required this.received,
    required this.sold,
    required this.expectedClosing,
    required this.physicalCount,
    required this.difference,
  });
}
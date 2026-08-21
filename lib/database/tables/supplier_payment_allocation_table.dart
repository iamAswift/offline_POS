import 'package:drift/drift.dart';

import 'supplier_payment_table.dart';
import 'supplier_delivery_table.dart';

class SupplierPaymentAllocations extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Payment being allocated.
  IntColumn get paymentId =>
      integer().references(SupplierPayments, #id)();

  /// Delivery/invoice receiving this payment.
  IntColumn get deliveryId =>
      integer().references(SupplierDeliveries, #id)();

  /// Amount of the payment applied to this delivery.
  RealColumn get amount => real()();
}
//lib/database/daos/supplier_payment_dao.dart


import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/supplier_payment_table.dart';
import '../tables/supplier_table.dart';

part 'supplier_payment_dao.g.dart';

@DriftAccessor(
  tables: [
    SupplierPayments,
    Suppliers,
  ],
)
class SupplierPaymentDao
    extends DatabaseAccessor<AppDatabase>
    with _$SupplierPaymentDaoMixin {
  SupplierPaymentDao(super.db);

  // ============================================================
  // INSERT PAYMENT
  // ============================================================

  Future<int> insertPayment(
    SupplierPaymentsCompanion payment,
  ) async {
    if (payment.amount.present &&
        payment.amount.value <= 0) {
      throw Exception(
        'Supplier payment amount must be greater than zero.',
      );
    }

    return into(supplierPayments).insert(payment);
  }

  // ============================================================
  // GET PAYMENT BY ID
  // ============================================================

  Future<SupplierPayment?> getPaymentById(
    int id,
  ) {
    return (select(supplierPayments)
          ..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  // ============================================================
  // ALL PAYMENTS
  // ============================================================

  Future<List<SupplierPayment>> getAllPayments() {
    return (select(supplierPayments)
          ..orderBy([
            (p) => OrderingTerm(
                  expression: p.paymentDate,
                  mode: OrderingMode.desc,
                ),
            (p) => OrderingTerm(
                  expression: p.id,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // PAYMENTS FOR SUPPLIER
  // ============================================================

  Future<List<SupplierPayment>>
      getPaymentsForSupplier(
    int supplierId,
  ) {
    return (select(supplierPayments)
          ..where(
            (p) => p.supplierId.equals(
              supplierId,
            ),
          )
          ..orderBy([
            (p) => OrderingTerm(
                  expression: p.paymentDate,
                  mode: OrderingMode.desc,
                ),
            (p) => OrderingTerm(
                  expression: p.id,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // PAYMENTS WITH SUPPLIER
  // ============================================================

  Future<List<SupplierPaymentWithSupplier>>
      getPaymentsWithSuppliers() {
    final query =
        select(supplierPayments).join([
      innerJoin(
        suppliers,
        suppliers.id.equalsExp(
          supplierPayments.supplierId,
        ),
      ),
    ])
      ..orderBy([
        OrderingTerm(
          expression: supplierPayments.paymentDate,
          mode: OrderingMode.desc,
        ),
        OrderingTerm(
          expression: supplierPayments.id,
          mode: OrderingMode.desc,
        ),
      ]);

    return query.map((row) {
      return SupplierPaymentWithSupplier(
        payment:
            row.readTable(supplierPayments),
        supplier:
            row.readTable(suppliers),
      );
    }).get();
  }

  // ============================================================
  // UPDATE PAYMENT
  // ============================================================

  Future<bool> updatePayment(
    SupplierPayment payment,
  ) {
    if (payment.amount <= 0) {
      throw Exception(
        'Supplier payment amount must be greater than zero.',
      );
    }

    return update(
      supplierPayments,
    ).replace(payment);
  }

  // ============================================================
  // DELETE PAYMENT
  // ============================================================

  Future<int> deletePayment(
    int id,
  ) {
    return (delete(supplierPayments)
          ..where((p) => p.id.equals(id)))
        .go();
  }

  // ============================================================
  // TOTAL PAID TO SUPPLIER
  // ============================================================

  Future<double> getSupplierPaymentTotal(
    int supplierId,
  ) async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(SUM(amount), 0)
        AS total_paid
      FROM supplier_payments
      WHERE supplier_id = ?
      ''',
      variables: [
        Variable.withInt(supplierId),
      ],
      readsFrom: {
        supplierPayments,
      },
    ).getSingle();

    final value =
        result.data['total_paid'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // TOTAL PAID TO ALL SUPPLIERS
  // ============================================================

  Future<double> getAllPaymentTotal() async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(SUM(amount), 0)
        AS total_paid
      FROM supplier_payments
      ''',
      readsFrom: {
        supplierPayments,
      },
    ).getSingle();

    final value =
        result.data['total_paid'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

// ============================================================
// PAYMENT + SUPPLIER
// ============================================================

class SupplierPaymentWithSupplier {
  final SupplierPayment payment;
  final Supplier supplier;

  const SupplierPaymentWithSupplier({
    required this.payment,
    required this.supplier,
  });
}
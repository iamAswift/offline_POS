// lib/database/daos/supplier_payment_allocation_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';

import '../tables/supplier_payment_allocation_table.dart';
import '../tables/supplier_payment_table.dart';
import '../tables/supplier_delivery_table.dart';
import '../tables/supplier_table.dart';

import '../models/supplier_payment_allocation_model.dart';

part 'supplier_payment_allocation_dao.g.dart';

@DriftAccessor(
  tables: [
    SupplierPaymentAllocations,
    SupplierPayments,
    SupplierDeliveries,
    Suppliers,
  ],
)
class SupplierPaymentAllocationDao extends DatabaseAccessor<AppDatabase>
    with _$SupplierPaymentAllocationDaoMixin {
  SupplierPaymentAllocationDao(super.db);

  // ============================================================
  // GET ALL ALLOCATIONS FOR SNAPSHOT
  // ============================================================
  Future<List<SupplierPaymentAllocationModel>>
  getAllSupplierPaymentAllocationsForSnapshot() async {
    final rows = await select(supplierPaymentAllocations).get();

    return rows
        .map(
          (row) => SupplierPaymentAllocationModel(
            id: row.id,
            paymentId: row.paymentId,
            deliveryId: row.deliveryId,
            amount: row.amount,
          ),
        )
        .toList();
  }

  // ============================================================
  // INSERT RAW ALLOCATION
  // ============================================================

  Future<int> insertAllocation(SupplierPaymentAllocationsCompanion allocation) {
    if (!allocation.amount.present) {
      throw Exception('Allocation amount is required.');
    }

    if (allocation.amount.value <= 0) {
      throw Exception('Allocation amount must be greater than zero.');
    }

    return into(supplierPaymentAllocations).insert(allocation);
  }

  // ============================================================
  // GET ALLOCATION BY ID
  // ============================================================

  Future<SupplierPaymentAllocation?> getAllocationById(int id) {
    return (select(
      supplierPaymentAllocations,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  // ============================================================
  // GET ALLOCATIONS FOR PAYMENT
  // ============================================================

  Future<List<SupplierPaymentAllocation>> getAllocationsForPayment(
    int paymentId,
  ) {
    return (select(supplierPaymentAllocations)
          ..where((a) => a.paymentId.equals(paymentId))
          ..orderBy([
            (a) => OrderingTerm(expression: a.id, mode: OrderingMode.asc),
          ]))
        .get();
  }

  // ============================================================
  // GET ALLOCATIONS FOR DELIVERY
  // ============================================================

  Future<List<SupplierPaymentAllocation>> getAllocationsForDelivery(
    int deliveryId,
  ) {
    return (select(supplierPaymentAllocations)
          ..where((a) => a.deliveryId.equals(deliveryId))
          ..orderBy([
            (a) => OrderingTerm(expression: a.id, mode: OrderingMode.asc),
          ]))
        .get();
  }

  // ============================================================
  // TOTAL ALLOCATED FOR PAYMENT
  // ============================================================

  Future<double> getAllocatedAmountForPayment(int paymentId) async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(SUM(amount), 0)
          AS allocated_amount
      FROM supplier_payment_allocations
      WHERE payment_id = ?
      ''',
      variables: [Variable.withInt(paymentId)],
      readsFrom: {supplierPaymentAllocations},
    ).getSingle();

    return _readDouble(result.data['allocated_amount']);
  }

  // ============================================================
  // TOTAL ALLOCATED FOR DELIVERY
  // ============================================================

  Future<double> getAllocatedAmountForDelivery(int deliveryId) async {
    final result = await customSelect(
      '''
      SELECT
        COALESCE(SUM(amount), 0)
          AS allocated_amount
      FROM supplier_payment_allocations
      WHERE delivery_id = ?
      ''',
      variables: [Variable.withInt(deliveryId)],
      readsFrom: {supplierPaymentAllocations},
    ).getSingle();

    return _readDouble(result.data['allocated_amount']);
  }

  // ============================================================
  // PAYMENT OUTSTANDING
  // ============================================================

  Future<double> getPaymentUnallocatedAmount(int paymentId) async {
    final payment = await (select(
      supplierPayments,
    )..where((p) => p.id.equals(paymentId))).getSingleOrNull();

    if (payment == null) {
      throw Exception('Supplier payment with ID $paymentId was not found.');
    }

    final allocated = await getAllocatedAmountForPayment(paymentId);

    final outstanding = payment.amount - allocated;

    return outstanding > 0 ? outstanding : 0;
  }

  // ============================================================
  // DELIVERY OUTSTANDING
  // ============================================================

  Future<double> getDeliveryOutstandingAmount(int deliveryId) async {
    final delivery = await (select(
      supplierDeliveries,
    )..where((d) => d.id.equals(deliveryId))).getSingleOrNull();

    if (delivery == null) {
      throw Exception('Supplier delivery with ID $deliveryId was not found.');
    }

    final allocated = await getAllocatedAmountForDelivery(deliveryId);

    final outstanding = delivery.totalAmount - allocated;

    return outstanding > 0 ? outstanding : 0;
  }

  // ============================================================
  // ALLOCATE PAYMENT TO DELIVERY
  // ============================================================
  //
  // This is the main accounting operation.
  //
  // It guarantees:
  //
  // 1. Payment exists.
  // 2. Delivery exists.
  // 3. Both belong to the same supplier.
  // 4. Amount > 0.
  // 5. Payment is not over-allocated.
  // 6. Delivery is not over-paid.
  //
  // ============================================================

  Future<int> allocatePayment({
    required int paymentId,
    required int deliveryId,
    required double amount,
  }) async {
    if (paymentId <= 0) {
      throw Exception('Invalid payment.');
    }

    if (deliveryId <= 0) {
      throw Exception('Invalid delivery.');
    }

    if (amount <= 0) {
      throw Exception('Allocation amount must be greater than zero.');
    }

    return transaction(() async {
      // ----------------------------------------------------------
      // LOAD PAYMENT
      // ----------------------------------------------------------

      final payment = await (select(
        supplierPayments,
      )..where((p) => p.id.equals(paymentId))).getSingleOrNull();

      if (payment == null) {
        throw Exception('Supplier payment with ID $paymentId was not found.');
      }

      // ----------------------------------------------------------
      // LOAD DELIVERY
      // ----------------------------------------------------------

      final delivery = await (select(
        supplierDeliveries,
      )..where((d) => d.id.equals(deliveryId))).getSingleOrNull();

      if (delivery == null) {
        throw Exception('Supplier delivery with ID $deliveryId was not found.');
      }

      // ----------------------------------------------------------
      // SUPPLIER OWNERSHIP CHECK
      // ----------------------------------------------------------

      if (payment.supplierId != delivery.supplierId) {
        throw Exception('Payment and delivery belong to different suppliers.');
      }

      // ----------------------------------------------------------
      // PAYMENT REMAINING
      // ----------------------------------------------------------

      final allocatedToPayment = await getAllocatedAmountForPayment(paymentId);

      final paymentRemaining = payment.amount - allocatedToPayment;

      if (amount > paymentRemaining + 0.000001) {
        throw Exception(
          'Allocation exceeds the unallocated payment amount. '
          'Remaining payment: ${paymentRemaining.toStringAsFixed(2)}.',
        );
      }

      // ----------------------------------------------------------
      // DELIVERY REMAINING
      // ----------------------------------------------------------

      final allocatedToDelivery = await getAllocatedAmountForDelivery(
        deliveryId,
      );

      final deliveryRemaining = delivery.totalAmount - allocatedToDelivery;

      if (amount > deliveryRemaining + 0.000001) {
        throw Exception(
          'Allocation exceeds the outstanding delivery amount. '
          'Outstanding delivery balance: '
          '${deliveryRemaining.toStringAsFixed(2)}.',
        );
      }

      // ----------------------------------------------------------
      // INSERT
      // ----------------------------------------------------------

      return into(supplierPaymentAllocations).insert(
        SupplierPaymentAllocationsCompanion(
          paymentId: Value(paymentId),
          deliveryId: Value(deliveryId),
          amount: Value(amount),
        ),
      );
    });
  }

  // ============================================================
  // UPDATE ALLOCATION
  // ============================================================

  Future<bool> updateAllocation({
    required int allocationId,
    required double amount,
  }) async {
    if (allocationId <= 0) {
      throw Exception('Invalid allocation.');
    }

    if (amount <= 0) {
      throw Exception('Allocation amount must be greater than zero.');
    }

    return transaction(() async {
      final existing = await getAllocationById(allocationId);

      if (existing == null) {
        throw Exception(
          'Payment allocation with ID $allocationId '
          'was not found.',
        );
      }

      final payment = await (select(
        supplierPayments,
      )..where((p) => p.id.equals(existing.paymentId))).getSingleOrNull();

      if (payment == null) {
        throw Exception(
          'The payment linked to this allocation no longer exists.',
        );
      }

      final delivery = await (select(
        supplierDeliveries,
      )..where((d) => d.id.equals(existing.deliveryId))).getSingleOrNull();

      if (delivery == null) {
        throw Exception(
          'The delivery linked to this allocation no longer exists.',
        );
      }

      if (payment.supplierId != delivery.supplierId) {
        throw Exception('Payment and delivery belong to different suppliers.');
      }

      // ----------------------------------------------------------
      // EXISTING ALLOCATION IS EXCLUDED FROM BOTH TOTALS
      // ----------------------------------------------------------

      final paymentAllocatedExcludingCurrent =
          await _getAllocatedAmountExcluding(
            paymentId: existing.paymentId,
            allocationId: allocationId,
          );

      final paymentRemaining =
          payment.amount - paymentAllocatedExcludingCurrent;

      if (amount > paymentRemaining + 0.000001) {
        throw Exception(
          'Allocation exceeds the available payment amount. '
          'Available: '
          '${paymentRemaining.toStringAsFixed(2)}.',
        );
      }

      final deliveryAllocatedExcludingCurrent =
          await _getAllocatedAmountExcluding(
            deliveryId: existing.deliveryId,
            allocationId: allocationId,
          );

      final deliveryRemaining =
          delivery.totalAmount - deliveryAllocatedExcludingCurrent;

      if (amount > deliveryRemaining + 0.000001) {
        throw Exception(
          'Allocation exceeds the delivery balance. '
          'Available: '
          '${deliveryRemaining.toStringAsFixed(2)}.',
        );
      }

      final updated =
          await (update(
            supplierPaymentAllocations,
          )..where((a) => a.id.equals(allocationId))).write(
            SupplierPaymentAllocationsCompanion(amount: Value(amount)),
          );
      return updated > 0;
    });
  }

  // ============================================================
  // DELETE ALLOCATION
  // ============================================================

  Future<int> deleteAllocation(int allocationId) {
    return (delete(
      supplierPaymentAllocations,
    )..where((a) => a.id.equals(allocationId))).go();
  }

  // ============================================================
  // DELETE ALL ALLOCATIONS FOR PAYMENT
  // ============================================================

  Future<int> deleteAllocationsForPayment(int paymentId) {
    return (delete(
      supplierPaymentAllocations,
    )..where((a) => a.paymentId.equals(paymentId))).go();
  }

  // ============================================================
  // DELETE ALL ALLOCATIONS FOR DELIVERY
  // ============================================================

  Future<int> deleteAllocationsForDelivery(int deliveryId) {
    return (delete(
      supplierPaymentAllocations,
    )..where((a) => a.deliveryId.equals(deliveryId))).go();
  }

  // ============================================================
  // PAYMENT ALLOCATION HISTORY
  // ============================================================

  Future<List<SupplierPaymentAllocationWithDelivery>>
  getPaymentAllocationsWithDeliveries(int paymentId) async {
    final query =
        select(supplierPaymentAllocations).join([
            innerJoin(
              supplierDeliveries,
              supplierDeliveries.id.equalsExp(
                supplierPaymentAllocations.deliveryId,
              ),
            ),
          ])
          ..where(supplierPaymentAllocations.paymentId.equals(paymentId))
          ..orderBy([
            OrderingTerm(
              expression: supplierPaymentAllocations.id,
              mode: OrderingMode.asc,
            ),
          ]);

    return query.map((row) {
      return SupplierPaymentAllocationWithDelivery(
        allocation: row.readTable(supplierPaymentAllocations),
        delivery: row.readTable(supplierDeliveries),
      );
    }).get();
  }

  // ============================================================
  // DELIVERY PAYMENT HISTORY
  // ============================================================

  Future<List<SupplierPaymentAllocationWithPayment>>
  getDeliveryAllocationsWithPayments(int deliveryId) async {
    final query =
        select(supplierPaymentAllocations).join([
            innerJoin(
              supplierPayments,
              supplierPayments.id.equalsExp(
                supplierPaymentAllocations.paymentId,
              ),
            ),
          ])
          ..where(supplierPaymentAllocations.deliveryId.equals(deliveryId))
          ..orderBy([
            OrderingTerm(
              expression: supplierPaymentAllocations.id,
              mode: OrderingMode.asc,
            ),
          ]);

    return query.map((row) {
      return SupplierPaymentAllocationWithPayment(
        allocation: row.readTable(supplierPaymentAllocations),
        payment: row.readTable(supplierPayments),
      );
    }).get();
  }

  // ============================================================
  // SUPPLIER ALLOCATIONS
  // ============================================================

  Future<List<SupplierPaymentAllocation>> getAllocationsForSupplier(
    int supplierId,
  ) async {
    final query =
        select(supplierPaymentAllocations).join([
            innerJoin(
              supplierPayments,
              supplierPayments.id.equalsExp(
                supplierPaymentAllocations.paymentId,
              ),
            ),
          ])
          ..where(supplierPayments.supplierId.equals(supplierId))
          ..orderBy([
            OrderingTerm(
              expression: supplierPaymentAllocations.id,
              mode: OrderingMode.desc,
            ),
          ]);

    return query.map((row) => row.readTable(supplierPaymentAllocations)).get();
  }

  // ============================================================
  // PRIVATE: PAYMENT TOTAL EXCLUDING ALLOCATION
  // ============================================================

  Future<double> _getAllocatedAmountExcluding({
    int? paymentId,
    int? deliveryId,
    required int allocationId,
  }) async {
    final conditions = <String>[];
    final variables = <Variable<Object>>[];

    if (paymentId != null) {
      conditions.add('payment_id = ?');
      variables.add(Variable.withInt(paymentId));
    }

    if (deliveryId != null) {
      conditions.add('delivery_id = ?');
      variables.add(Variable.withInt(deliveryId));
    }

    final result = await customSelect(
      '''
      SELECT
        COALESCE(SUM(amount), 0)
          AS allocated_amount
      FROM supplier_payment_allocations
      WHERE ${conditions.join(' AND ')}
        AND id != ?
      ''',
      variables: [...variables, Variable.withInt(allocationId)],
      readsFrom: {supplierPaymentAllocations},
    ).getSingle();

    return _readDouble(result.data['allocated_amount']);
  }

  // ============================================================
  // HELPER
  // ============================================================

  double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// ================================================================
// ALLOCATION + DELIVERY
// ================================================================

class SupplierPaymentAllocationWithDelivery {
  final SupplierPaymentAllocation allocation;
  final SupplierDelivery delivery;

  const SupplierPaymentAllocationWithDelivery({
    required this.allocation,
    required this.delivery,
  });
}

// ================================================================
// ALLOCATION + PAYMENT
// ================================================================

class SupplierPaymentAllocationWithPayment {
  final SupplierPaymentAllocation allocation;
  final SupplierPayment payment;

  const SupplierPaymentAllocationWithPayment({
    required this.allocation,
    required this.payment,
  });
}

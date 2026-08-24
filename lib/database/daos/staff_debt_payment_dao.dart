// lib/database/daos/staff_debt_payment_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/staff_debt_payment_table.dart';
import '../tables/staff_purchase_table.dart';
import '../tables/user_table.dart';

import '../models/staff_debt_payment_model.dart';


part 'staff_debt_payment_dao.g.dart';

@DriftAccessor(
  tables: [
    StaffDebtPayments,
    StaffPurchases,
    Users,
  ],
)
class StaffDebtPaymentDao
    extends DatabaseAccessor<AppDatabase>
    with _$StaffDebtPaymentDaoMixin {
  StaffDebtPaymentDao(super.db);

  // ============================================================
  // GET ALL STAFF DEBT PAYMENTS FOR SNAPSHOT
  // ============================================================
  Future<List<StaffDebtPaymentModel>> getAllStaffDebtPaymentsForSnapshot() async {
    final rows = await select(staffDebtPayments).get();
    final result = rows.map((row) => StaffDebtPaymentModel(
      id: row.id,
      staffId: row.staffId,
      amount: row.amount,
      paymentMethod: row.paymentMethod,
      note: row.note,
      recordedBy: row.recordedBy,
      createdAt: row.createdAt,
    )).toList();

    // ✅ Explicitly declare as non-nullable list
    return List<StaffDebtPaymentModel>.from(result);
  }


  // ============================================================
  // RECORD DEBT PAYMENT
  // ============================================================
  //
  // Records money paid toward a staff member's outstanding debt.
  //
  // The original staff purchase is NEVER modified.
  //
  // Example:
  //
  // Existing debt: ₦4,000
  // Payment:       ₦1,500
  // New balance:   ₦2,500
  //
  // ============================================================

  Future<int> recordDebtPayment({
    required int staffId,
    required double amount,
    required String paymentMethod,
    required int recordedBy,
    String? note,
  }) async {
    return transaction(() async {
      // ========================================================
      // 1. VALIDATE AMOUNT
      // ========================================================

      if (amount <= 0) {
        throw Exception(
          'Payment amount must be greater than zero.',
        );
      }

      // ========================================================
      // 2. VALIDATE PAYMENT METHOD
      // ========================================================

      final normalizedPaymentMethod =
          paymentMethod.trim().toLowerCase();

      const allowedMethods = {
        'cash',
        'pos',
        'transfer',
        'payroll',
      };

      if (!allowedMethods.contains(
        normalizedPaymentMethod,
      )) {
        throw Exception(
          'Invalid payment method.',
        );
      }

      // ========================================================
      // 3. GET STAFF
      // ========================================================

      final staff = await (select(users)
            ..where(
              (u) => u.id.equals(staffId),
            ))
          .getSingleOrNull();

      if (staff == null) {
        throw Exception(
          'Staff member not found.',
        );
      }

      if (staff.role.trim().toLowerCase() != 'staff') {
        throw Exception(
          'Selected user is not a staff member.',
        );
      }

      // ========================================================
      // 4. VALIDATE RECORDING USER
      // ========================================================

      final recorder = await (select(users)
            ..where(
              (u) => u.id.equals(recordedBy),
            ))
          .getSingleOrNull();

      if (recorder == null) {
        throw Exception(
          'Recording user not found.',
        );
      }

      // ========================================================
      // 5. GET TOTAL STAFF DEBT
      // ========================================================

      final debtResult = await customSelect(
        '''
        SELECT COALESCE(
          SUM(debt_amount),
          0
        ) AS total_debt
        FROM staff_purchases
        WHERE staff_id = ?
        ''',
        variables: [
          Variable.withInt(staffId),
        ],
        readsFrom: {
          staffPurchases,
        },
      ).getSingle();

      final totalDebt =
          (debtResult.data['total_debt'] as num?)
                  ?.toDouble() ??
              0.0;

      // ========================================================
      // 6. GET TOTAL PAYMENTS ALREADY MADE
      // ========================================================

      final paymentResult = await customSelect(
        '''
        SELECT COALESCE(
          SUM(amount),
          0
        ) AS total_paid
        FROM staff_debt_payments
        WHERE staff_id = ?
        ''',
        variables: [
          Variable.withInt(staffId),
        ],
        readsFrom: {
          staffDebtPayments,
        },
      ).getSingle();

      final totalPaid =
          (paymentResult.data['total_paid'] as num?)
                  ?.toDouble() ??
              0.0;

      // ========================================================
      // 7. CALCULATE CURRENT BALANCE
      // ========================================================

      final currentBalance =
          totalDebt - totalPaid;

      // ========================================================
      // 8. PREVENT OVERPAYMENT
      // ========================================================

      if (currentBalance <= 0) {
        throw Exception(
          '${staff.name} has no outstanding debt.',
        );
      }

      if (amount > currentBalance) {
        throw Exception(
          'Payment exceeds outstanding debt.\n\n'
          'Outstanding debt: '
          '₦${currentBalance.toStringAsFixed(2)}\n'
          'Payment amount: '
          '₦${amount.toStringAsFixed(2)}',
        );
      }

      // ========================================================
      // 9. INSERT PAYMENT
      // ========================================================

      final paymentId =
          await into(staffDebtPayments).insert(
        StaffDebtPaymentsCompanion(
          staffId: Value(staffId),
          amount: Value(amount),
          paymentMethod: Value(
            normalizedPaymentMethod,
          ),
          note: Value(
            note?.trim().isEmpty == true
                ? null
                : note?.trim(),
          ),
          recordedBy: Value(recordedBy),
          createdAt: Value(
            DateTime.now(),
          ),
        ),
      );

      return paymentId;
    });
  }

  // ============================================================
  // TOTAL PAYMENTS MADE BY STAFF
  // ============================================================

  Future<double> getTotalDebtPayments(
    int staffId,
  ) async {
    final result = await customSelect(
      '''
      SELECT COALESCE(
        SUM(amount),
        0
      ) AS total_paid
      FROM staff_debt_payments
      WHERE staff_id = ?
      ''',
      variables: [
        Variable.withInt(staffId),
      ],
      readsFrom: {
        staffDebtPayments,
      },
    ).getSingle();

    return (result.data['total_paid'] as num?)
            ?.toDouble() ??
        0.0;
  }

  // ============================================================
  // TOTAL DEBT CREATED
  // ============================================================

  Future<double> getTotalDebtCreated(
    int staffId,
  ) async {
    final result = await customSelect(
      '''
      SELECT COALESCE(
        SUM(debt_amount),
        0
      ) AS total_debt
      FROM staff_purchases
      WHERE staff_id = ?
      ''',
      variables: [
        Variable.withInt(staffId),
      ],
      readsFrom: {
        staffPurchases,
      },
    ).getSingle();

    return (result.data['total_debt'] as num?)
            ?.toDouble() ??
        0.0;
  }

  // ============================================================
  // CURRENT STAFF DEBT BALANCE
  // ============================================================

  Future<double> getStaffDebtBalance(
    int staffId,
  ) async {
    final totalDebt =
        await getTotalDebtCreated(staffId);

    final totalPaid =
        await getTotalDebtPayments(staffId);

    final balance =
        totalDebt - totalPaid;

    return balance < 0 ? 0.0 : balance;
  }

  // ============================================================
  // ALL DEBT PAYMENTS FOR STAFF
  // ============================================================

  Future<List<StaffDebtPayment>>
      getStaffDebtPaymentHistory(
    int staffId,
  ) {
    return (select(staffDebtPayments)
          ..where(
            (p) => p.staffId.equals(staffId),
          )
          ..orderBy([
            (p) => OrderingTerm(
                  expression: p.createdAt,
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
  // ALL DEBT PAYMENTS
  // ============================================================

  Future<List<StaffDebtPayment>>
      getAllDebtPayments() {
    return (select(staffDebtPayments)
          ..orderBy([
            (p) => OrderingTerm(
                  expression: p.createdAt,
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
  // DELETE PAYMENT
  // ============================================================
  //
  // We should NOT expose this casually from the UI.
  //
  // If implemented later, deletion should be restricted to
  // owner/admin and preferably require confirmation.
  //
  // ============================================================

  Future<void> deleteDebtPayment(
    int paymentId,
  ) async {
    await (delete(staffDebtPayments)
          ..where(
            (p) => p.id.equals(paymentId),
          ))
        .go();
  }
}
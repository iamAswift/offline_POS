// lib/database/daos/staff_purchase_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../business_settings.dart';
import '../tables/staff_purchase_table.dart';
import '../tables/product_table.dart';
import '../tables/user_table.dart';
import '../tables/sales_table.dart';
import '../tables/stock_movement_table.dart';
import '../tables/settings_table.dart';
import '../tables/staff_debt_payment_table.dart';

import '../models/staff_purchase_model.dart';
part 'staff_purchase_dao.g.dart';

@DriftAccessor(
  tables: [
    StaffPurchases,
    Products,
    Users,
    Sales,
    StockMovements,
    Settings,
    StaffDebtPayments,
  ],
)
class StaffPurchaseDao extends DatabaseAccessor<AppDatabase>
    with _$StaffPurchaseDaoMixin {
  StaffPurchaseDao(super.db);

  // ============================================================
  // GET ALL STAFF PURCHASES FOR SNAPSHOT
  // ============================================================

  Future<List<StaffPurchaseModel>> getAllStaffPurchasesForSnapshot() async {
    final rows = await select(staffPurchases).get();

    return rows.map((row) => StaffPurchaseModel(
          id: row.id,
          staffId: row.staffId,
          productId: row.productId,
          quantity: row.quantity,
          unitPrice: row.unitPrice,
          totalAmount: row.totalAmount,
          paymentType: row.paymentType,
          amountPaid: row.amountPaid,
          debtAmount: row.debtAmount,
          saleId: row.saleId,
          note: row.note,
          createdAt: row.createdAt,
        )).toList();
  }

  // ============================================================
  // DEFAULT STAFF DEBT LIMIT
  // ============================================================

  static const double defaultMaxStaffDebt = 50000.0;

  


  // ============================================================
  // GET MAXIMUM STAFF DEBT
  // ============================================================

  Future<double> getMaxStaffDebt() async {
    final result = await (select(settings)
          ..where(
            (s) => s.key.equals(
              BusinessSettings.maxStaffDebt,
            ),
          ))
        .getSingleOrNull();

    if (result == null) {
      return defaultMaxStaffDebt;
    }

    return double.tryParse(result.value) ??
        defaultMaxStaffDebt;
  }

  // ============================================================
  // SET MAXIMUM STAFF DEBT
  // ============================================================

  Future<void> setMaxStaffDebt(double amount) async {
    if (amount < 0) {
      throw Exception(
        'Maximum staff debt cannot be negative.',
      );
    }

    final existing = await (select(settings)
          ..where(
            (s) => s.key.equals(
              BusinessSettings.maxStaffDebt,
            ),
          ))
        .getSingleOrNull();

    if (existing != null) {
      await (update(settings)
            ..where(
              (s) => s.id.equals(existing.id),
            ))
          .write(
        SettingsCompanion(
          value: Value(
            amount.toString(),
          ),
        ),
      );

      return;
    }

    await into(settings).insert(
      SettingsCompanion.insert(
        key: BusinessSettings.maxStaffDebt,
        value: amount.toString(),
      ),
    );
  }

  // ============================================================
  // GET STAFF TOTAL DEBT
  // ============================================================
  //
  // Calculates:
  //
  // Total credit debt from staff purchases
  // MINUS
  // Payments already made by the staff member.
  //
  // Cash purchases have debt_amount = 0.
  //
  // ============================================================

  Future<double> getStaffDebt(int staffId) async {
    final purchaseResult = await customSelect(
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

    final totalDebt =
        (purchaseResult.data['total_debt'] as num?)
                ?.toDouble() ??
            0.0;

    final totalPaid =
        (paymentResult.data['total_paid'] as num?)
                ?.toDouble() ??
            0.0;

    final outstandingDebt =
        totalDebt - totalPaid;

    return outstandingDebt < 0
        ? 0.0
        : outstandingDebt;
  }

  // ============================================================
  // GET STAFF PURCHASES
  // ============================================================

  Future<List<StaffPurchase>> getStaffPurchases(
    int staffId,
  ) {
    return (select(staffPurchases)
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
  // GET ALL STAFF PURCHASES
  // ============================================================

  Future<List<StaffPurchase>> getAllStaffPurchases() {
    return (select(staffPurchases)
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
  // CREATE STAFF PURCHASE
  // ============================================================
  //
  // CASH:
  //   Stock decreases
  //   Sale created
  //   Staff debt = 0
  //
  // CREDIT:
  //   Stock decreases
  //   Sale created
  //   Staff debt increases
  //   Debt limit checked
  //
  // EVERYTHING happens inside ONE transaction.
  //
  // ============================================================

  Future<int> createStaffPurchase({
    required int staffId,
    required int productId,
    required int quantity,
    required String paymentType,
    double? amountPaid,
    String? note,
  }) async {
    return transaction(() async {
      // ========================================================
      // 1. VALIDATE PAYMENT TYPE
      // ========================================================

      final normalizedPaymentType =
          paymentType.trim().toLowerCase();

      if (normalizedPaymentType != 'cash' &&
          normalizedPaymentType != 'credit') {
        throw Exception(
          'Payment type must be cash or credit.',
        );
      }

      // ========================================================
      // 2. VALIDATE QUANTITY
      // ========================================================

      if (quantity <= 0) {
        throw Exception(
          'Quantity must be greater than zero.',
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

      if (!staff.isActive) {
        throw Exception(
          'This staff account is inactive.',
        );
      }

      if (staff.role.trim().toLowerCase() != 'staff') {
        throw Exception(
          'Selected user is not a staff member.',
        );
      }

      // ========================================================
      // 4. GET PRODUCT
      // ========================================================

      final product = await (select(products)
            ..where(
              (p) => p.id.equals(productId),
            ))
          .getSingleOrNull();

      if (product == null) {
        throw Exception(
          'Product not found.',
        );
      }

      // ========================================================
      // 5. CHECK STOCK
      // ========================================================

      if (product.stock < quantity) {
        throw Exception(
          'Insufficient stock for ${product.name}. '
          'Available: ${product.stock}, '
          'requested: $quantity.',
        );
      }

      // ========================================================
      // 6. CALCULATE TOTAL
      // ========================================================

      final unitPrice =
          product.sellingPrice.toDouble();

      final totalAmount =
          unitPrice * quantity;

      // ========================================================
      // 7. PAYMENT CALCULATION
      // ========================================================

      double paid;

      if (normalizedPaymentType == 'cash') {
        paid = totalAmount;
      } else {
        paid = amountPaid ?? 0.0;

        if (paid < 0) {
          throw Exception(
            'Amount paid cannot be negative.',
          );
        }

        if (paid > totalAmount) {
          throw Exception(
            'Amount paid cannot be greater than '
            'the purchase total.',
          );
        }
      }

      final debtAmount =
          totalAmount - paid;

      // ========================================================
      // 8. CHECK STAFF DEBT LIMIT
      // ========================================================

      if (normalizedPaymentType == 'credit') {
        final currentDebt =
            await getStaffDebt(staffId);

        final maxDebt =
            await getMaxStaffDebt();

        final newDebt =
            currentDebt + debtAmount;

        if (newDebt > maxDebt) {
          final remainingLimit =
              maxDebt - currentDebt;

          throw Exception(
            'Staff debt limit exceeded.\n\n'
            'Current debt: '
            '₦${currentDebt.toStringAsFixed(2)}\n'
            'New debt: '
            '₦${debtAmount.toStringAsFixed(2)}\n'
            'Maximum allowed: '
            '₦${maxDebt.toStringAsFixed(2)}\n'
            'Remaining limit: '
            '₦${remainingLimit.clamp(0, double.infinity).toStringAsFixed(2)}',
          );
        }
      }

      // ========================================================
      // 9. CREATE SALES RECORD
      // ========================================================

      final saleId = await into(sales).insert(
        SalesCompanion(
          productId: Value(productId),
          quantity: Value(quantity),

          // Sales.unitPrice is currently an IntColumn.
          unitPrice: Value(
            product.sellingPrice.round(),
          ),

          costPriceAtSale: Value(
            product.costPrice,
          ),

          totalPrice: Value(
            totalAmount.round(),
          ),

          paymentMethod: Value(
            normalizedPaymentType,
          ),

          cashAmount: Value(
            normalizedPaymentType == 'cash'
                ? totalAmount
                : paid,
          ),

          posAmount: const Value(0.0),

          transferAmount: const Value(0.0),

          status: const Value('completed'),

          staffId: Value(staffId),

          createdAt: Value(
            DateTime.now(),
          ),
        ),
      );

      // ========================================================
      // 10. REDUCE PRODUCT STOCK
      // ========================================================

      await (update(products)
            ..where(
              (p) => p.id.equals(productId),
            ))
          .write(
        ProductsCompanion(
          stock: Value(
            product.stock - quantity,
          ),
        ),
      );

      // ========================================================
      // 11. CREATE STOCK MOVEMENT
      // ========================================================

      await into(stockMovements).insert(
        StockMovementsCompanion(
          productId: Value(productId),

          supplierId: const Value(null),

          type: const Value('sale'),

          quantity: Value(quantity),

          unitPrice: Value(unitPrice),

          date: Value(
            DateTime.now(),
          ),
        ),
      );

      // ========================================================
      // 12. CREATE STAFF PURCHASE RECORD
      // ========================================================

      final staffPurchaseId =
          await into(staffPurchases).insert(
        StaffPurchasesCompanion(
          staffId: Value(staffId),

          productId: Value(productId),

          quantity: Value(quantity),

          unitPrice: Value(unitPrice),

          totalAmount: Value(totalAmount),

          paymentType: Value(
            normalizedPaymentType,
          ),

          amountPaid: Value(paid),

          debtAmount: Value(debtAmount),

          saleId: Value(saleId),

          note: Value(note),

          createdAt: Value(
            DateTime.now(),
          ),
        ),
      );

      // ========================================================
      // 13. RETURN STAFF PURCHASE ID
      // ========================================================

      return staffPurchaseId;
    });
  }

  // ============================================================
  // STAFF DEBT SUMMARY
  // ============================================================
  //
  // Returns every staff member who has created credit debt.
  //
  // IMPORTANT:
  // - debt_amount represents debt originally created by purchases.
  // - repayments are stored separately in staff_debt_payments.
  // - This method returns ORIGINAL CREDIT CREATED.
  // - Current balance is calculated separately by subtracting repayments.
  //
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getStaffDebtSummary() async {
    final result = await customSelect(
      '''
      SELECT
        u.id AS staff_id,
        u.name AS staff_name,
        COALESCE(
          SUM(sp.debt_amount),
          0.0
        ) AS total_debt
      FROM users u
      INNER JOIN staff_purchases sp
        ON sp.staff_id = u.id
      WHERE LOWER(TRIM(u.role)) = 'staff'
        AND sp.debt_amount > 0
      GROUP BY
        u.id,
        u.name
      ORDER BY
        u.name ASC
      ''',
      readsFrom: {
        users,
        staffPurchases,
      },
    ).get();

    return result.map((row) {
      final int staffId =
          row.read<int>('staff_id');

      final String staffName =
          row.read<String>('staff_name');

      final double totalDebt =
          row.read<double>('total_debt');

      return {
        'staffId': staffId,
        'staffName': staffName,
        'totalDebt': totalDebt,
      };
    }).toList();
  }

  // ============================================================
  // STAFF DEBT REMAINING
  // ============================================================

  Future<double> getStaffDebtRemaining(
    int staffId,
  ) async {
    final currentDebt =
        await getStaffDebt(staffId);

    final maxDebt =
        await getMaxStaffDebt();

    final remaining =
        maxDebt - currentDebt;

    return remaining < 0
        ? 0.0
        : remaining;
  }
}
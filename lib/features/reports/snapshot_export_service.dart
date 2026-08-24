// lib/features/reports/snapshot_export_service.dart

import 'dart:convert';
import 'dart:io';

import '../../database/daos/sales_dao.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/supplier_dao.dart';
import '../../database/daos/supplier_delivery_dao.dart';
import '../../database/daos/supplier_delivery_item_dao.dart';
import '../../database/daos/supplier_payment_dao.dart';
import '../../database/daos/supplier_payment_allocation_dao.dart';
import '../../database/daos/staff_purchase_dao.dart';
import '../../database/daos/staff_debt_payment_dao.dart';
import '../../database/daos/stock_movement_dao.dart';
import '../../database/daos/user_profile_dao.dart';
import '../../database/daos/settings_dao.dart';
import '../../database/models/staff_debt_payment_model.dart';

import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart'; // ✅ add logging

class SnapshotExportService {
  final SalesDao salesDao;
  final ProductDao productDao;
  final SupplierDao supplierDao;
  final SupplierDeliveryDao supplierDeliveryDao;
  final SupplierDeliveryItemDao supplierDeliveryItemDao;
  final SupplierPaymentDao supplierPaymentDao;
  final SupplierPaymentAllocationDao supplierPaymentAllocationDao;
  final StaffPurchaseDao staffPurchaseDao;
  final StaffDebtPaymentDao staffDebtPaymentDao;
  final StockMovementDao stockMovementDao;
  final UserProfileDao userProfileDao;
  final SettingsDao settingsDao;

  final _logger = Logger('SnapshotExportService'); // ✅ logger instance

  SnapshotExportService({
    required this.salesDao,
    required this.productDao,
    required this.supplierDao,
    required this.supplierDeliveryDao,
    required this.supplierDeliveryItemDao,
    required this.supplierPaymentDao,
    required this.supplierPaymentAllocationDao,
    required this.staffPurchaseDao,
    required this.staffDebtPaymentDao,
    required this.stockMovementDao,
    required this.userProfileDao,
    required this.settingsDao,
  });

  Future<File> exportSnapshot() async {
    final snapshot = {
      "date": DateTime.now().toIso8601String(),
      "sales": (await salesDao.getAllSalesForSnapshot()).map((s) => s.toJson()).toList(),
      "products": (await productDao.getAllProductsForSnapshot()).map((p) => p.toJson()).toList(),
      "suppliers": (await supplierDao.getAllSuppliersForSnapshot()).map((s) => s.toJson()).toList(),
      "deliveries": (await supplierDeliveryDao.getAllSupplierDeliveriesForSnapshot()).map((d) => d.toJson()).toList(),
      "delivery_items": (await supplierDeliveryItemDao.getAllSupplierDeliveryItemsForSnapshot()).map((i) => i.toJson()).toList(),
      "payments": (await supplierPaymentDao.getAllSupplierPaymentsForSnapshot()).map((p) => p.toJson()).toList(),
      "payment_allocations": (await supplierPaymentAllocationDao.getAllSupplierPaymentAllocationsForSnapshot()).map((a) => a.toJson()).toList(),
      "staff_purchases": (await staffPurchaseDao.getAllStaffPurchasesForSnapshot()).map((p) => p.toJson()).toList(),
      "staff_debt_payments": List<StaffDebtPaymentModel>.from(
        await staffDebtPaymentDao.getAllStaffDebtPaymentsForSnapshot()
      ).map((p) => p.toJson()).toList(),
      "stock_movements": (await stockMovementDao.getAllStockMovementsForSnapshot()).map((m) => m.toJson()).toList(),
      "user_profiles": (await userProfileDao.getAllUserProfilesForSnapshot()).map((u) => u.toJson()).toList(),
      "settings": (await settingsDao.getAllSettingsForSnapshot()).map((s) => s.toJson()).toList(),
    };

    final fileName = "snapshot_${DateTime.now().toIso8601String().split('T').first}.json";
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");

    await file.writeAsString(jsonEncode(snapshot));

    // ✅ Use logger instead of print
    _logger.info("Snapshot exported to: ${file.path}");

    return file;
  }
}

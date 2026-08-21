// lib/database/tables/supplier_delivery_item_table.dart

import 'package:drift/drift.dart';

import 'supplier_delivery_table.dart';
import 'product_table.dart';

class SupplierDeliveryItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The supplier delivery this item belongs to.
  IntColumn get deliveryId =>
      integer().references(SupplierDeliveries, #id)();

  /// Existing product being received.
  IntColumn get productId =>
      integer().references(Products, #id)();

  /// Quantity received.
  IntColumn get quantity => integer()();

  /// Actual supplier purchase price at the time of delivery.
  ///
  /// Preserved historically even if the product's current
  /// costPrice changes later.
  RealColumn get unitCost => real()();

  /// quantity × unitCost
  RealColumn get totalCost => real()();

  /// Optional expiry date for this specific received batch.
  DateTimeColumn get expiryDate =>
      dateTime().nullable()();
}
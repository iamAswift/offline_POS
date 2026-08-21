//lib/database/daos/supplier_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/supplier_table.dart';

part 'supplier_dao.g.dart';

@DriftAccessor(tables: [Suppliers])
class SupplierDao extends DatabaseAccessor<AppDatabase>
    with _$SupplierDaoMixin {
  SupplierDao(super.db);

  Future<int> insertSupplier(SuppliersCompanion supplier) =>
      into(suppliers).insert(supplier);

  Future<List<Supplier>> getAllSuppliers() => select(suppliers).get();

  Future<Supplier?> getSupplierById(int id) =>
      (select(suppliers)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<bool> updateSupplier(Supplier supplier) =>
      update(suppliers).replace(supplier);

  Future<int> deleteSupplier(int id) =>
      (delete(suppliers)..where((s) => s.id.equals(id))).go();
}

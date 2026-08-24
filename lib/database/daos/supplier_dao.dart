//lib/database/daos/supplier_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/supplier_table.dart';

import '../models/supplier_model.dart';
part 'supplier_dao.g.dart';

@DriftAccessor(tables: [Suppliers])
class SupplierDao extends DatabaseAccessor<AppDatabase>
    with _$SupplierDaoMixin {
  SupplierDao(super.db);

  //============================================================
  // GET ALL SUPPLIERS FOR SNAPSHOT
  //============================================================

  Future<List<SupplierModel>> getAllSuppliersForSnapshot() async {
  final rows = await select(suppliers).get();
    return rows.map((row) => SupplierModel(
      id: row.id,
      name: row.name,
      contact: row.contact,
      address: row.address,
      notes: row.notes,
    )).toList();
  }


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

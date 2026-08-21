// lib/database/daos/settings_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  // ============================================================
  // GET ALL SETTINGS
  // ============================================================

  Future<List<Setting>> getAllSettings() {
    return select(settings).get();
  }

  // ============================================================
  // SET SETTING
  // ============================================================
  //
  // Updates an existing key.
  // If the key does not exist, creates it.
  //
  // This deliberately does NOT rely on a UNIQUE constraint
  // because the current database schema does not have one.
  // ============================================================

  Future<void> setSetting(
    String key,
    String value,
  ) async {
    final existing = await (select(settings)
          ..where(
            (s) => s.key.equals(key),
          ))
        .getSingleOrNull();

    if (existing != null) {
      await (update(settings)
            ..where(
              (s) => s.id.equals(existing.id),
            ))
          .write(
        SettingsCompanion(
          value: Value(value),
        ),
      );

      return;
    }

    await into(settings).insert(
      SettingsCompanion.insert(
        key: key,
        value: value,
      ),
    );
  }

  // ============================================================
  // GET SETTING
  // ============================================================

  Future<String?> getSetting(
    String key,
  ) async {
    final result = await (select(settings)
          ..where(
            (s) => s.key.equals(key),
          ))
        .getSingleOrNull();

    return result?.value;
  }

  // ============================================================
  // GET INTEGER SETTING
  // ============================================================

  Future<int?> getIntSetting(
    String key,
  ) async {
    final value = await getSetting(key);

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  // ============================================================
  // GET DOUBLE SETTING
  // ============================================================

  Future<double?> getDoubleSetting(
    String key,
  ) async {
    final value = await getSetting(key);

    if (value == null) {
      return null;
    }

    return double.tryParse(value);
  }

  // ============================================================
  // DELETE SETTING
  // ============================================================

  Future<void> deleteSetting(
    String key,
  ) async {
    await (delete(settings)
          ..where(
            (s) => s.key.equals(key),
          ))
        .go();
  }
}

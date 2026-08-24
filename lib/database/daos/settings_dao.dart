// lib/database/daos/settings_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/settings_table.dart';

import '../models/settings_model.dart'; 

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
  // GET ALL SETTINGS FOR SNAPSHOT
  // ============================================================

  Future<List<SettingsModel>> getAllSettingsForSnapshot() async {
    final rows = await select(settings).get();

    return rows.map((row) => SettingsModel(
          id: row.id,
          key: row.key,
          value: row.value,
        )).toList();
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


  // GET BOOLEAN SETTING
  // ============================================================

  Future<bool?> getBoolSetting(
    String key,
  ) async {
    final value = await getSetting(key);

    if (value == null) {
      return null;
    }

    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'on':
        return true;

      case 'false':
      case '0':
      case 'no':
      case 'off':
        return false;

      default:
        return null;
    }
  }

  // ============================================================
  // GET BOOLEAN WITH DEFAULT
  // ============================================================

  Future<bool> getBoolSettingOrDefault(
    String key, {
    required bool defaultValue,
  }) async {
    return await getBoolSetting(key) ?? defaultValue;
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
  // GET INTEGER WITH DEFAULT
  // ============================================================

  Future<int> getIntSettingOrDefault(
    String key, {
    required int defaultValue,
  }) async {
    return await getIntSetting(key) ?? defaultValue;
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
  // GET DOUBLE WITH DEFAULT
  // ============================================================

  Future<double> getDoubleSettingOrDefault(
    String key, {
    required double defaultValue,
  }) async {
    return await getDoubleSetting(key) ?? defaultValue;
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

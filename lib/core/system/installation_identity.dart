//lib/core/system/installation_identity.dart

import 'package:uuid/uuid.dart';

import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

class InstallationIdentity {
  InstallationIdentity._();

  static const Uuid _uuid = Uuid();

  /// Returns the permanent unique ID for this Creator Yard installation.
  ///
  /// The ID is generated only once and then stored in the existing
  /// Settings table. It survives app restarts and does not require
  /// a database schema migration.
  static Future<String> getInstallationId(SettingsDao settingsDao) async {
    final existing = await settingsDao.getSetting(
      BusinessSettings.installationId,
    );

    if (existing != null && existing.trim().isNotEmpty) {
      return existing.trim();
    }

    final installationId = _uuid.v4();

    await settingsDao.setSetting(
      BusinessSettings.installationId,
      installationId,
    );

    return installationId;
  }
}

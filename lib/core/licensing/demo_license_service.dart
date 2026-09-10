// lib/core/licensing/demo_license_service.dart

import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';
import '../system/installation_identity.dart';
import 'license_provider.dart';
import 'license_state.dart';

/// Client-side 14-day demo/licensing persistence service.
///
/// IMPORTANT:
///
/// This service is intentionally NOT the commercial licensing authority.
///
/// Anything in this class is part of the public Flutter application and
/// must therefore be treated as inspectable and modifiable.
///
/// A future commercial licensing system can use this service as the local
/// client while the authoritative license validation/signing remains on a
/// private server.
class DemoLicenseService implements LicenseProvider {
  DemoLicenseService({required this.settingsDao});

  static const Duration demoDuration = Duration(days: 14);

  static const Duration allowedClockRollback = Duration(minutes: 5);

  final SettingsDao settingsDao;

  // ============================================================
  // PUBLIC API
  // ============================================================

  /// Initializes the local demo state if this installation has never
  /// initialized licensing before.
  ///
  /// Existing installations are not restarted or given a new demo period.
  @override
  Future<LicenseState> initialize() async {
    final now = DateTime.now().toUtc();

    // ----------------------------------------------------------
    // Use the application's canonical installation identity.
    // ----------------------------------------------------------

    final installationId = await InstallationIdentity.getInstallationId(
      settingsDao,
    );

    // Keep the licensing-specific setting synchronized with the
    // canonical application installation ID.
    await settingsDao.setSetting(
      BusinessSettings.licenseInstallationId,
      installationId,
    );

    final existingStatus = await settingsDao.getSetting(
      BusinessSettings.licenseStatus,
    );

    final existingDemoStartedAt = await settingsDao.getSetting(
      BusinessSettings.demoStartedAt,
    );

    final existingDemoExpiresAt = await settingsDao.getSetting(
      BusinessSettings.demoExpiresAt,
    );

    final existingLastSeenAt = await settingsDao.getSetting(
      BusinessSettings.licenseLastSeenAt,
    );

    final demoStartedAt = _parseDate(existingDemoStartedAt);

    final demoExpiresAt = _parseDate(existingDemoExpiresAt);

    final lastSeenAt = _parseDate(existingLastSeenAt);

    // ----------------------------------------------------------
    // First initialization
    // ----------------------------------------------------------

    if (demoStartedAt == null || demoExpiresAt == null) {
      final expiresAt = now.add(demoDuration);

      await settingsDao.setSetting(BusinessSettings.licenseStatus, 'demo');

      await settingsDao.setSetting(
        BusinessSettings.demoStartedAt,
        now.toIso8601String(),
      );

      await settingsDao.setSetting(
        BusinessSettings.demoExpiresAt,
        expiresAt.toIso8601String(),
      );

      await settingsDao.setSetting(
        BusinessSettings.licenseLastSeenAt,
        now.toIso8601String(),
      );

      return LicenseState(
        status: LicenseStatus.demo,
        installationId: installationId,
        demoStartedAt: now,
        demoExpiresAt: expiresAt,
        lastSeenAt: now,
      );
    }

    // ----------------------------------------------------------
    // Clock rollback detection
    // ----------------------------------------------------------

    if (lastSeenAt != null &&
        now.isBefore(lastSeenAt.subtract(allowedClockRollback))) {
      await settingsDao.setSetting(
        BusinessSettings.licenseStatus,
        'clock_tampered',
      );

      return LicenseState(
        status: LicenseStatus.clockTampered,
        installationId: installationId,
        demoStartedAt: demoStartedAt,
        demoExpiresAt: demoExpiresAt,
        lastSeenAt: lastSeenAt,
      );
    }

    // ----------------------------------------------------------
    // Commercial license state
    //
    // The actual commercial license validation will be introduced
    // later through another LicenseProvider implementation.
    // ----------------------------------------------------------

    if (existingStatus == 'licensed') {
      await settingsDao.setSetting(
        BusinessSettings.licenseLastSeenAt,
        now.toIso8601String(),
      );

      return LicenseState(
        status: LicenseStatus.licensed,
        installationId: installationId,
        demoStartedAt: demoStartedAt,
        demoExpiresAt: demoExpiresAt,
        lastSeenAt: now,
      );
    }

    // ----------------------------------------------------------
    // Demo expiration
    // ----------------------------------------------------------

    if (!now.isBefore(demoExpiresAt)) {
      await settingsDao.setSetting(BusinessSettings.licenseStatus, 'expired');

      await settingsDao.setSetting(
        BusinessSettings.licenseLastSeenAt,
        now.toIso8601String(),
      );

      return LicenseState(
        status: LicenseStatus.expired,
        installationId: installationId,
        demoStartedAt: demoStartedAt,
        demoExpiresAt: demoExpiresAt,
        lastSeenAt: now,
      );
    }

    // ----------------------------------------------------------
    // Demo still active
    // ----------------------------------------------------------

    await settingsDao.setSetting(BusinessSettings.licenseStatus, 'demo');

    await settingsDao.setSetting(
      BusinessSettings.licenseLastSeenAt,
      now.toIso8601String(),
    );

    return LicenseState(
      status: LicenseStatus.demo,
      installationId: installationId,
      demoStartedAt: demoStartedAt,
      demoExpiresAt: demoExpiresAt,
      lastSeenAt: now,
    );
  }

  /// Returns the current licensing state.
  Future<LicenseState> getState() {
    return initialize();
  }

  /// Returns true when the installation currently has access.
  @override
  Future<bool> hasAccess() async {
    final state = await getState();

    return state.hasAccess;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }
}

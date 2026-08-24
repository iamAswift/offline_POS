// lib/database/default_settings.dart

import 'business_settings.dart';
import 'daos/settings_dao.dart';

class DefaultSettings {
  DefaultSettings._();

  static Future<void> initialize(SettingsDao settingsDao) async {
    // ============================================================
    // SUPPLIER MANAGEMENT
    // ============================================================

    await _setIfMissing(settingsDao, BusinessSettings.suppliersEnabled, 'true');

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierDeliveriesEnabled,
      'true',
    );

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierPaymentsEnabled,
      'true',
    );

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierPaymentAllocationEnabled,
      'true',
    );

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierCreditEnabled,
      'true',
    );

    // ============================================================
    // SUPPLIER VALIDATION
    // ============================================================

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierRequireContact,
      'false',
    );

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierRequireAddress,
      'false',
    );

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierRequireInvoiceNumber,
      'false',
    );

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierRequirePaymentAllocation,
      'false',
    );

    // ============================================================
    // SUPPLIER PAYMENTS
    // ============================================================

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierAllowPartialPayment,
      'true',
    );

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierAllowOverpayment,
      'false',
    );

    // ============================================================
    // DELIVERY / NOTES
    // ============================================================

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierAllowDeliveryNotes,
      'true',
    );

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierAllowNotes,
      'true',
    );

    // ============================================================
    // DELETION CONTROLS
    // ============================================================

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierAllowDeletion,
      'false',
    );

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierAllowDeliveryDeletion,
      'false',
    );

    await _setIfMissing(
      settingsDao,
      BusinessSettings.supplierAllowPaymentDeletion,
      'false',
    );
  }

  // ============================================================
  // SET ONLY IF MISSING
  // ============================================================

  static Future<void> _setIfMissing(
    SettingsDao settingsDao,
    String key,
    String value,
  ) async {
    final existing = await settingsDao.getSetting(key);

    if (existing == null) {
      await settingsDao.setSetting(key, value);
    }
  }
}

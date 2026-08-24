// lib/database/supplier_settings.dart

import 'business_settings.dart';
import 'daos/settings_dao.dart';

class SupplierSettings {
  final SettingsDao settingsDao;

  SupplierSettings(this.settingsDao);

  // ============================================================
  // MASTER SUPPLIER SETTINGS
  // ============================================================

  Future<bool> get suppliersEnabled async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.suppliersEnabled,
      defaultValue: true,
    );
  }

  Future<bool> get deliveriesEnabled async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierDeliveriesEnabled,
      defaultValue: true,
    );
  }

  Future<bool> get paymentsEnabled async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierPaymentsEnabled,
      defaultValue: true,
    );
  }

  Future<bool> get paymentAllocationEnabled async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierPaymentAllocationEnabled,
      defaultValue: true,
    );
  }

  Future<bool> get creditEnabled async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierCreditEnabled,
      defaultValue: true,
    );
  }

  // ============================================================
  // SUPPLIER VALIDATION
  // ============================================================

  Future<bool> get requireContact async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierRequireContact,
      defaultValue: false,
    );
  }

  Future<bool> get requireAddress async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierRequireAddress,
      defaultValue: false,
    );
  }

  Future<bool> get requireInvoiceNumber async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierRequireInvoiceNumber,
      defaultValue: false,
    );
  }

  Future<bool> get requirePaymentAllocation async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierRequirePaymentAllocation,
      defaultValue: false,
    );
  }

  // ============================================================
  // PAYMENT RULES
  // ============================================================

  Future<bool> get allowPartialPayment async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierAllowPartialPayment,
      defaultValue: true,
    );
  }

  Future<bool> get allowOverpayment async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierAllowOverpayment,
      defaultValue: false,
    );
  }

  // ============================================================
  // DELIVERY / NOTES
  // ============================================================

  Future<bool> get allowDeliveryNotes async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierAllowDeliveryNotes,
      defaultValue: true,
    );
  }

  Future<bool> get allowNotes async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierAllowNotes,
      defaultValue: true,
    );
  }

  // ============================================================
  // DELETION
  // ============================================================

  Future<bool> get allowSupplierDeletion async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierAllowDeletion,
      defaultValue: false,
    );
  }

  Future<bool> get allowDeliveryDeletion async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierAllowDeliveryDeletion,
      defaultValue: false,
    );
  }

  Future<bool> get allowPaymentDeletion async {
    return settingsDao.getBoolSettingOrDefault(
      BusinessSettings.supplierAllowPaymentDeletion,
      defaultValue: false,
    );
  }
}
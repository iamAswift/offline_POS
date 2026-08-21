// lib/core/business/business_identity.dart

import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

class BusinessIdentity {
  BusinessIdentity._();

  // ============================================================
  // DEFAULT SOFTWARE BRANDING
  // ============================================================

  static const String defaultBusinessName = 'Creator Yard';

  static const String defaultBusinessTagline = 'Business & Creator Solutions';

  // ============================================================
  // BUSINESS NAME
  // ============================================================

  static Future<String> getBusinessName(SettingsDao settingsDao) async {
    final value = await settingsDao.getSetting(BusinessSettings.businessName);

    if (value == null || value.trim().isEmpty) {
      return defaultBusinessName;
    }

    return value.trim();
  }

  //BUSINESS LOGO

  static Future<String?> getBusinessLogo(
    SettingsDao settingsDao,
  ) async {
    final value = await settingsDao.getSetting(
      BusinessSettings.businessLogo,
    );

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  // ============================================================
  // TAGLINE
  // ============================================================

  static Future<String> getBusinessTagline(SettingsDao settingsDao) async {
    final value = await settingsDao.getSetting(
      BusinessSettings.businessTagline,
    );

    if (value == null || value.trim().isEmpty) {
      return defaultBusinessTagline;
    }

    return value.trim();
  }

  // ============================================================
  // PHONE
  // ============================================================

  static Future<String> getBusinessPhone(SettingsDao settingsDao) async {
    final value = await settingsDao.getSetting(BusinessSettings.businessPhone);

    return value?.trim() ?? '';
  }

  // ============================================================
  // EMAIL
  // ============================================================

  static Future<String> getBusinessEmail(SettingsDao settingsDao) async {
    final value = await settingsDao.getSetting(BusinessSettings.businessEmail);

    return value?.trim() ?? '';
  }

  // ============================================================
  // ADDRESS
  // ============================================================

  static Future<String> getBusinessAddress(SettingsDao settingsDao) async {
    final value = await settingsDao.getSetting(
      BusinessSettings.businessAddress,
    );

    return value?.trim() ?? '';
  }

  // ============================================================
  // BUSINESS TYPE
  // ============================================================

  static Future<String> getBusinessType(SettingsDao settingsDao) async {
    final value = await settingsDao.getSetting(BusinessSettings.businessType);

    if (value == null || value.trim().isEmpty) {
      return 'General Retail';
    }

    return value.trim();
  }
}

// lib/core/pos/pos_settings_service.dart

import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';
import '../../models/pos_settings.dart';

class PosSettingsService {
  final SettingsDao settingsDao;

  const PosSettingsService({
    required this.settingsDao,
  });

  // ============================================================
  // DEFAULTS
  // ============================================================

  static const String defaultPaymentMethod = 'cash';

  static const bool defaultPaymentCash = true;

  static const bool defaultPaymentPos = true;

  static const bool defaultPaymentTransfer = true;

  static const bool defaultAllowDiscount = true;

  static const double defaultMaximumDiscount = 20.0;

  static const bool defaultAllowPriceEditing = false;

  static const bool defaultRequireDiscountApproval = true;

  static const bool defaultRequireCustomerName = false;

  static const bool defaultRequireCustomerPhone = false;

  static const bool defaultAutomaticallyPrintReceipt = false;

  static const bool defaultShowCustomerDisplay = false;

  static const String defaultCustomerDisplayDevice = 'iPad';

  // ============================================================
  // LOAD
  // ============================================================

  Future<PosSettings> load() async {
    // ------------------------------------------------------------
    // PAYMENT
    // ------------------------------------------------------------

    final storedDefaultPaymentMethod =
        await settingsDao.getSetting(
          BusinessSettings.defaultPaymentMethod,
        ) ??
        PosSettingsService.defaultPaymentMethod;

    final paymentCash =
        await settingsDao.getSetting(
          BusinessSettings.paymentCash,
        ) ??
        defaultPaymentCash.toString();

    final paymentPos =
        await settingsDao.getSetting(
          BusinessSettings.paymentPos,
        ) ??
        defaultPaymentPos.toString();

    final paymentTransfer =
        await settingsDao.getSetting(
          BusinessSettings.paymentTransfer,
        ) ??
        defaultPaymentTransfer.toString();

    // ------------------------------------------------------------
    // DISCOUNTS
    // ------------------------------------------------------------

    final allowDiscount =
        await settingsDao.getSetting(
          BusinessSettings.allowDiscount,
        ) ??
        defaultAllowDiscount.toString();

    final maximumDiscount =
        await settingsDao.getDoubleSetting(
          BusinessSettings.maximumDiscount,
        ) ??
        defaultMaximumDiscount;

    final allowPriceEditing =
        await settingsDao.getSetting(
          BusinessSettings.allowPriceEditing,
        ) ??
        defaultAllowPriceEditing.toString();

    final requireDiscountApproval =
        await settingsDao.getSetting(
          BusinessSettings.requireDiscountApproval,
        ) ??
        defaultRequireDiscountApproval.toString();

    // ------------------------------------------------------------
    // CUSTOMER
    // ------------------------------------------------------------

    final requireCustomerName =
        await settingsDao.getSetting(
          BusinessSettings.requireCustomerName,
        ) ??
        defaultRequireCustomerName.toString();

    final requireCustomerPhone =
        await settingsDao.getSetting(
          BusinessSettings.requireCustomerPhone,
        ) ??
        defaultRequireCustomerPhone.toString();

    // ------------------------------------------------------------
    // RECEIPT
    // ------------------------------------------------------------

    final automaticallyPrintReceipt =
        await settingsDao.getSetting(
          BusinessSettings.automaticallyPrintReceipt,
        ) ??
        defaultAutomaticallyPrintReceipt.toString();

    // ------------------------------------------------------------
    // CUSTOMER DISPLAY
    // ------------------------------------------------------------

    final showCustomerDisplay =
        await settingsDao.getSetting(
          BusinessSettings.showCustomerDisplay,
        ) ??
        defaultShowCustomerDisplay.toString();

    final customerDisplayDevice =
        await settingsDao.getSetting(
          BusinessSettings.customerDisplayDevice,
        ) ??
        defaultCustomerDisplayDevice;

    // ============================================================
    // BUILD SETTINGS
    // ============================================================

    var settings = PosSettings(
      defaultPaymentMethod:
          _normalizePaymentMethod(
        storedDefaultPaymentMethod,
      ),

      paymentCash:
          _parseBool(paymentCash),

      paymentPos:
          _parseBool(paymentPos),

      paymentTransfer:
          _parseBool(paymentTransfer),

      allowDiscount:
          _parseBool(allowDiscount),

      maximumDiscount:
          _normalizeDiscount(
        maximumDiscount,
      ),

      allowPriceEditing:
          _parseBool(allowPriceEditing),

      requireDiscountApproval:
          _parseBool(requireDiscountApproval),

      requireCustomerName:
          _parseBool(requireCustomerName),

      requireCustomerPhone:
          _parseBool(requireCustomerPhone),

      automaticallyPrintReceipt:
          _parseBool(
        automaticallyPrintReceipt,
      ),

      showCustomerDisplay:
          _parseBool(showCustomerDisplay),

      customerDisplayDevice:
          _normalizeDisplayDevice(
        customerDisplayDevice,
      ),
    );

    // ============================================================
    // SELF-HEAL INVALID DEFAULT PAYMENT
    // ============================================================

    if (!settings.isPaymentMethodEnabled(
      settings.defaultPaymentMethod,
    )) {
      settings = settings.copyWith(
        defaultPaymentMethod:
            _firstEnabledPaymentMethod(
          settings,
        ),
      );
    }

    // ============================================================
    // SAFETY FALLBACK
    // ============================================================

    if (!settings.hasPaymentMethodEnabled) {
      settings = settings.copyWith(
        paymentCash: true,
        defaultPaymentMethod: 'cash',
      );
    }

    return settings;
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> save(
    PosSettings settings,
  ) async {
    // ------------------------------------------------------------
    // Make sure the object is valid before saving.
    // ------------------------------------------------------------

    if (!settings.isValid) {
      throw Exception(
        'Invalid POS settings.',
      );
    }

    final safeDefault =
        settings.safeDefaultPaymentMethod;

    // ------------------------------------------------------------
    // PAYMENT
    // ------------------------------------------------------------

    await settingsDao.setSetting(
      BusinessSettings.defaultPaymentMethod,
      safeDefault,
    );

    await settingsDao.setSetting(
      BusinessSettings.paymentCash,
      settings.paymentCash.toString(),
    );

    await settingsDao.setSetting(
      BusinessSettings.paymentPos,
      settings.paymentPos.toString(),
    );

    await settingsDao.setSetting(
      BusinessSettings.paymentTransfer,
      settings.paymentTransfer.toString(),
    );

    // ------------------------------------------------------------
    // DISCOUNTS
    // ------------------------------------------------------------

    await settingsDao.setSetting(
      BusinessSettings.allowDiscount,
      settings.allowDiscount.toString(),
    );

    await settingsDao.setSetting(
      BusinessSettings.maximumDiscount,
      settings.maximumDiscount.toString(),
    );

    await settingsDao.setSetting(
      BusinessSettings.allowPriceEditing,
      settings.allowPriceEditing.toString(),
    );

    await settingsDao.setSetting(
      BusinessSettings.requireDiscountApproval,
      settings.requireDiscountApproval.toString(),
    );

    // ------------------------------------------------------------
    // CUSTOMER
    // ------------------------------------------------------------

    await settingsDao.setSetting(
      BusinessSettings.requireCustomerName,
      settings.requireCustomerName.toString(),
    );

    await settingsDao.setSetting(
      BusinessSettings.requireCustomerPhone,
      settings.requireCustomerPhone.toString(),
    );

    // ------------------------------------------------------------
    // RECEIPT
    // ------------------------------------------------------------

    await settingsDao.setSetting(
      BusinessSettings.automaticallyPrintReceipt,
      settings.automaticallyPrintReceipt.toString(),
    );

    // ------------------------------------------------------------
    // CUSTOMER DISPLAY
    // ------------------------------------------------------------

    await settingsDao.setSetting(
      BusinessSettings.showCustomerDisplay,
      settings.showCustomerDisplay.toString(),
    );

    await settingsDao.setSetting(
      BusinessSettings.customerDisplayDevice,
      settings.customerDisplayDevice,
    );
  }

  // ============================================================
  // BOOLEAN
  // ============================================================

  bool _parseBool(
    String value,
  ) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
        return true;

      case 'false':
      case '0':
      case 'no':
        return false;

      default:
        return false;
    }
  }

  // ============================================================
  // PAYMENT NORMALIZER
  // ============================================================

  String _normalizePaymentMethod(
    String value,
  ) {
    switch (value.trim().toLowerCase()) {
      case 'cash':
        return 'cash';

      case 'pos':
        return 'pos';

      case 'transfer':
      case 'bank transfer':
        return 'transfer';

      default:
        return PosSettingsService.defaultPaymentMethod;
    }
  }

  // ============================================================
  // DISPLAY NORMALIZER
  // ============================================================

  String _normalizeDisplayDevice(
    String value,
  ) {
    switch (value.trim().toLowerCase()) {
      case 'ipad':
        return 'iPad';

      case 'external display':
        return 'External Display';

      default:
        return defaultCustomerDisplayDevice;
    }
  }

  // ============================================================
  // DISCOUNT NORMALIZER
  // ============================================================

  double _normalizeDiscount(
    double value,
  ) {
    if (value < 0) {
      return 0;
    }

    if (value > 100) {
      return 100;
    }

    return value;
  }

  // ============================================================
  // FIRST ENABLED PAYMENT METHOD
  // ============================================================

  String _firstEnabledPaymentMethod(
    PosSettings settings,
  ) {
    if (settings.paymentCash) {
      return 'cash';
    }

    if (settings.paymentPos) {
      return 'pos';
    }

    if (settings.paymentTransfer) {
      return 'transfer';
    }

    return PosSettingsService.defaultPaymentMethod;
  }
}
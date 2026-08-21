// lib/models/pos_settings.dart

class PosSettings {
  // ============================================================
  // PAYMENT
  // ============================================================

  final String defaultPaymentMethod;

  final bool paymentCash;
  final bool paymentPos;
  final bool paymentTransfer;

  // ============================================================
  // DISCOUNTS / PRICING
  // ============================================================

  final bool allowDiscount;
  final double maximumDiscount;
  final bool allowPriceEditing;
  final bool requireDiscountApproval;

  // ============================================================
  // CUSTOMER
  // ============================================================

  final bool requireCustomerName;
  final bool requireCustomerPhone;

  // ============================================================
  // RECEIPT
  // ============================================================

  final bool automaticallyPrintReceipt;

  // ============================================================
  // CUSTOMER DISPLAY
  // ============================================================

  final bool showCustomerDisplay;
  final String customerDisplayDevice;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  const PosSettings({
    this.defaultPaymentMethod = 'cash',

    this.paymentCash = true,
    this.paymentPos = true,
    this.paymentTransfer = true,

    this.allowDiscount = true,
    this.maximumDiscount = 20.0,
    this.allowPriceEditing = false,
    this.requireDiscountApproval = true,

    this.requireCustomerName = false,
    this.requireCustomerPhone = false,

    this.automaticallyPrintReceipt = false,

    this.showCustomerDisplay = false,
    this.customerDisplayDevice = 'iPad',
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  PosSettings copyWith({
    String? defaultPaymentMethod,

    bool? paymentCash,
    bool? paymentPos,
    bool? paymentTransfer,

    bool? allowDiscount,
    double? maximumDiscount,
    bool? allowPriceEditing,
    bool? requireDiscountApproval,

    bool? requireCustomerName,
    bool? requireCustomerPhone,

    bool? automaticallyPrintReceipt,

    bool? showCustomerDisplay,
    String? customerDisplayDevice,
  }) {
    return PosSettings(
      defaultPaymentMethod:
          defaultPaymentMethod ?? this.defaultPaymentMethod,

      paymentCash:
          paymentCash ?? this.paymentCash,

      paymentPos:
          paymentPos ?? this.paymentPos,

      paymentTransfer:
          paymentTransfer ?? this.paymentTransfer,

      allowDiscount:
          allowDiscount ?? this.allowDiscount,

      maximumDiscount:
          maximumDiscount ?? this.maximumDiscount,

      allowPriceEditing:
          allowPriceEditing ?? this.allowPriceEditing,

      requireDiscountApproval:
          requireDiscountApproval ??
          this.requireDiscountApproval,

      requireCustomerName:
          requireCustomerName ??
          this.requireCustomerName,

      requireCustomerPhone:
          requireCustomerPhone ??
          this.requireCustomerPhone,

      automaticallyPrintReceipt:
          automaticallyPrintReceipt ??
          this.automaticallyPrintReceipt,

      showCustomerDisplay:
          showCustomerDisplay ??
          this.showCustomerDisplay,

      customerDisplayDevice:
          customerDisplayDevice ??
          this.customerDisplayDevice,
    );
  }

  // ============================================================
  // PAYMENT METHODS
  // ============================================================

  bool isPaymentMethodEnabled(
    String method,
  ) {
    switch (method.trim().toLowerCase()) {
      case 'cash':
        return paymentCash;

      case 'pos':
        return paymentPos;

      case 'transfer':
        return paymentTransfer;

      default:
        return false;
    }
  }

  bool get hasPaymentMethodEnabled {
    return paymentCash ||
        paymentPos ||
        paymentTransfer;
  }

  int get enabledPaymentMethodCount {
    int count = 0;

    if (paymentCash) count++;
    if (paymentPos) count++;
    if (paymentTransfer) count++;

    return count;
  }

  // ============================================================
  // ENABLED PAYMENT METHODS
  // ============================================================

  List<String> get enabledPaymentMethods {
    final methods = <String>[];

    if (paymentCash) {
      methods.add('cash');
    }

    if (paymentPos) {
      methods.add('pos');
    }

    if (paymentTransfer) {
      methods.add('transfer');
    }

    return methods;
  }

  // ============================================================
  // PAYMENT LABEL
  // ============================================================

  static String paymentMethodLabel(
    String method,
  ) {
    switch (method.trim().toLowerCase()) {
      case 'cash':
        return 'Cash';

      case 'pos':
        return 'POS';

      case 'transfer':
        return 'Transfer';

      default:
        return method;
    }
  }

  // ============================================================
  // DEFAULT PAYMENT
  // ============================================================

  String get safeDefaultPaymentMethod {
    if (isPaymentMethodEnabled(
      defaultPaymentMethod,
    )) {
      return defaultPaymentMethod;
    }

    if (paymentCash) {
      return 'cash';
    }

    if (paymentPos) {
      return 'pos';
    }

    if (paymentTransfer) {
      return 'transfer';
    }

    return 'cash';
  }

  // ============================================================
  // DISCOUNT
  // ============================================================

  bool get canUseDiscounts {
    return allowDiscount &&
        maximumDiscount > 0;
  }

  bool get discountsRequireApproval {
    return canUseDiscounts &&
        requireDiscountApproval;
  }

  // ============================================================
  // CUSTOMER INFORMATION
  // ============================================================

  bool get requiresCustomerInformation {
    return requireCustomerName ||
        requireCustomerPhone;
  }

  // ============================================================
  // CUSTOMER DISPLAY
  // ============================================================

  bool get customerDisplayEnabled {
    return showCustomerDisplay;
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool get isValid {
    // At least one payment method.
    if (!hasPaymentMethodEnabled) {
      return false;
    }

    // Default must be enabled.
    if (!isPaymentMethodEnabled(
      defaultPaymentMethod,
    )) {
      return false;
    }

    // Discount must be within range.
    if (maximumDiscount < 0 ||
        maximumDiscount > 100) {
      return false;
    }

    // If discounts are disabled, approval has no meaning,
    // but it is not considered invalid.
    if (customerDisplayDevice.trim().isEmpty) {
      return false;
    }

    return true;
  }

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'PosSettings('
        'defaultPaymentMethod: $defaultPaymentMethod, '
        'paymentCash: $paymentCash, '
        'paymentPos: $paymentPos, '
        'paymentTransfer: $paymentTransfer, '
        'allowDiscount: $allowDiscount, '
        'maximumDiscount: $maximumDiscount, '
        'allowPriceEditing: $allowPriceEditing, '
        'requireDiscountApproval: $requireDiscountApproval, '
        'requireCustomerName: $requireCustomerName, '
        'requireCustomerPhone: $requireCustomerPhone, '
        'automaticallyPrintReceipt: $automaticallyPrintReceipt, '
        'showCustomerDisplay: $showCustomerDisplay, '
        'customerDisplayDevice: $customerDisplayDevice'
        ')';
  }
}
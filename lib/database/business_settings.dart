// lib/database/business_settings.dart

class BusinessSettings {
  BusinessSettings._();

  // ============================================================
  // BUSINESS PROFILE
  // ============================================================

  static const String businessName =
      'business_name';

  static const String businessLogo =
      'business_logo';

  static const String businessPhone =
      'business_phone';

  static const String businessEmail =
      'business_email';

  static const String businessAddress =
      'business_address';

  static const String businessTagline =
      'business_tagline';
  static const String businessType =
      'business_type';

  

  // ============================================================
  // APPEARANCE
  // ============================================================

    static const String themeMode =
        'theme_mode';

    static const String accentColor =
        'accent_color';

    static const String compactMode =
        'compact_mode';

    static const String largePosButtons =
        'large_pos_buttons';

    static const String showProductImages =
        'show_product_images';

  // ============================================================
  // CURRENCY / REGIONAL
  // ============================================================

  static const String currency =
      'currency';

  static const String currencyPosition =
      'currency_position';


  static const String currencyCode =
    'currency_code';

  static const String decimalPlaces =
    'decimal_places';

  // ============================================================
  // INVENTORY
  // ============================================================

  static const String lowStockThreshold =
      'low_stock_threshold';

  static const String allowNegativeStock =
      'allow_negative_stock';

  static const String requireBarcode =
      'require_barcode';

  // ============================================================
  // POS
  // ============================================================

  static const String allowDiscount =
      'allow_discount';
    
  static const String maximumDiscount =
    'maximum_discount';

  static const String defaultPaymentMethod =
    'default_payment_method';

  static const String paymentCash =
      'payment_cash';

  static const String paymentPos =
      'payment_pos';

  static const String paymentTransfer =
      'payment_transfer';

  static const String paymentCredit =
      'payment_credit';

  static const String paymentCheque =
      'payment_cheque';

  static const String requireCustomerName =
      'require_customer_name';

  static const String requireCustomerPhone =
      'require_customer_phone';

  static const String allowPriceEditing =
      'allow_price_editing';

  static const String requireDiscountApproval =
      'require_discount_approval';

  static const String automaticallyPrintReceipt =
      'automatically_print_receipt';

  static const String showCustomerDisplay =
      'show_customer_display';

  static const String customerDisplayDevice =
      'customer_display_device';


  // ============================================================
  // RECEIPT
  // ============================================================

  static const String receiptFooter =
      'receipt_footer';

  static const String receiptLogo =
    'receipt_logo';

  static const String receiptBusinessName =
      'receipt_business_name';

  static const String receiptAddress =
      'receipt_address';

  static const String receiptPhone =
      'receipt_phone';

  static const String showCashierName =
      'show_cashier_name';

  static const String showReceiptDateTime =
      'show_receipt_date_time';

  static const String showReceiptNumber =
      'show_receipt_number';

  static const String showReceiptTax =
      'show_receipt_tax';

  static const String showReceiptDiscount =
      'show_receipt_discount';

  static const String receiptPaperSize =
      'receipt_paper_size';

  // ============================================================
  // STAFF
  // ============================================================

  static const String maxStaffDebt =
      'max_staff_debt';

  // ============================================================
  // SECURITY
  // ============================================================

  static const String requireLogin =
      'require_login';

  static const String autoLogout =
      'auto_logout';

  static const String logoutAfterMinutes =
      'logout_after_minutes';

  static const String requirePasswordStockAdjustment =
      'require_password_stock_adjustment';

  static const String requirePasswordDeleteProduct =
      'require_password_delete_product';

  static const String requirePasswordCancelSale =
      'require_password_cancel_sale';

  static const String requirePasswordLargeDiscount =
      'require_password_large_discount';

  static const String requirePasswordChangeStaffDebtLimit =
      'require_password_change_staff_debt_limit';

  static const String requirePasswordViewProfit =
      'require_password_view_profit';

    // ============================================================
    // REPORTS
    // ============================================================

    static const String reportDefaultPeriod =
        'report_default_period';

    static const String reportShowProfit =
        'report_show_profit';

    static const String reportShowStockValue =
        'report_show_stock_value';

    static const String reportShowCharts =
        'report_show_charts';

    static const String reportShowSalesTrend =
        'report_show_sales_trend';

    static const String reportShowPaymentBreakdown =
        'report_show_payment_breakdown';

    static const String reportShowCategoryPerformance =
        'report_show_category_performance';

    static const String reportShowExport =
        'report_show_export';
}
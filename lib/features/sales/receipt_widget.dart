// lib/features/sales/receipt_widget.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/business/business_identity.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

class ReceiptWidget extends StatefulWidget {
  final List sales;
  final User cashier;
  final List products;
  final SettingsDao settingsDao;

  const ReceiptWidget({
    super.key,
    required this.sales,
    required this.cashier,
    required this.products,
    required this.settingsDao,
  });

  @override
  State<ReceiptWidget> createState() => _ReceiptWidgetState();
}

class _ReceiptWidgetState extends State<ReceiptWidget> {
  // ============================================================
  // BUSINESS IDENTITY
  //
  // BusinessIdentity is the SINGLE source of truth.
  // ============================================================

  String _businessName =
      BusinessIdentity.defaultBusinessName;

  String _businessTagline =
      BusinessIdentity.defaultBusinessTagline;

  String _businessPhone = '';

  String _businessEmail = '';

  String _businessAddress = '';

  String _businessType = '';

  String? _businessLogo;

  // ============================================================
  // RECEIPT SETTINGS
  // ============================================================

  String _footer =
      'Thank you for your patronage.';

  bool _showCashierName = true;

  bool _showReceiptDateTime = true;

  bool _showReceiptNumber = true;

  bool _showReceiptTax = false;

  bool _showReceiptDiscount = true;

  String _paperSize = '80mm';

  bool _isLoadingSettings = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> _loadSettings() async {
    try {
      // ========================================================
      // BUSINESS IDENTITY
      //
      // ALWAYS use BusinessIdentity.
      // ========================================================

      final businessName =
          await BusinessIdentity.getBusinessName(
        widget.settingsDao,
      );

      final businessTagline =
          await BusinessIdentity.getBusinessTagline(
        widget.settingsDao,
      );

      final businessPhone =
          await BusinessIdentity.getBusinessPhone(
        widget.settingsDao,
      );

      final businessEmail =
          await BusinessIdentity.getBusinessEmail(
        widget.settingsDao,
      );

      final businessAddress =
          await BusinessIdentity.getBusinessAddress(
        widget.settingsDao,
      );

      final businessType =
          await BusinessIdentity.getBusinessType(
        widget.settingsDao,
      );

      final businessLogo =
          await BusinessIdentity.getBusinessLogo(
        widget.settingsDao,
      );

      // ========================================================
      // RECEIPT-SPECIFIC SETTINGS
      // ========================================================

      final footer =
          await widget.settingsDao.getSetting(
        BusinessSettings.receiptFooter,
      );

      final showCashier =
          await widget.settingsDao.getSetting(
        BusinessSettings.showCashierName,
      );

      final showDateTime =
          await widget.settingsDao.getSetting(
        BusinessSettings.showReceiptDateTime,
      );

      final showNumber =
          await widget.settingsDao.getSetting(
        BusinessSettings.showReceiptNumber,
      );

      final showTax =
          await widget.settingsDao.getSetting(
        BusinessSettings.showReceiptTax,
      );

      final showDiscount =
          await widget.settingsDao.getSetting(
        BusinessSettings.showReceiptDiscount,
      );

      final paperSize =
          await widget.settingsDao.getSetting(
        BusinessSettings.receiptPaperSize,
      );

      if (!mounted) return;

      setState(() {
        // ======================================================
        // BUSINESS IDENTITY
        // ======================================================

        _businessName = businessName;

        _businessTagline = businessTagline;

        _businessPhone = businessPhone;

        _businessEmail = businessEmail;

        _businessAddress = businessAddress;

        _businessType = businessType;

        _businessLogo = businessLogo;

        // ======================================================
        // RECEIPT SETTINGS
        // ======================================================

        _footer =
            footer?.trim().isNotEmpty == true
                ? footer!.trim()
                : 'Thank you for your patronage.';

        _showCashierName = _parseBool(
          showCashier,
          defaultValue: true,
        );

        _showReceiptDateTime = _parseBool(
          showDateTime,
          defaultValue: true,
        );

        _showReceiptNumber = _parseBool(
          showNumber,
          defaultValue: true,
        );

        _showReceiptTax = _parseBool(
          showTax,
          defaultValue: false,
        );

        _showReceiptDiscount = _parseBool(
          showDiscount,
          defaultValue: true,
        );

        if (paperSize == '58mm' ||
            paperSize == '80mm' ||
            paperSize == 'A4') {
          _paperSize = paperSize!;
        }

        _isLoadingSettings = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingSettings = false;
      });

      _showMessage(
        'Failed to load receipt settings: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // BOOLEAN
  // ============================================================

  bool _parseBool(
    String? value, {
    required bool defaultValue,
  }) {
    if (value == null) {
      return defaultValue;
    }

    return value.trim().toLowerCase() == 'true';
  }

  // ============================================================
  // TOTAL
  // ============================================================

  int get total {
    int result = 0;

    for (final sale in widget.sales) {
      result +=
          (sale.totalPrice as num).toInt();
    }

    return result;
  }

  // ============================================================
  // PAYMENT TOTALS
  // ============================================================

  double get cashTotal {
    return widget.sales.fold(
      0.0,
      (sum, sale) =>
          sum +
          ((sale.cashAmount ?? 0) as num)
              .toDouble(),
    );
  }

  double get posTotal {
    return widget.sales.fold(
      0.0,
      (sum, sale) =>
          sum +
          ((sale.posAmount ?? 0) as num)
              .toDouble(),
    );
  }

  double get transferTotal {
    return widget.sales.fold(
      0.0,
      (sum, sale) =>
          sum +
          ((sale.transferAmount ?? 0) as num)
              .toDouble(),
    );
  }

  // ============================================================
  // PRODUCT LOOKUP
  // ============================================================

  dynamic _findProduct(int productId) {
    for (final product in widget.products) {
      if (product.id == productId) {
        return product;
      }
    }

    return null;
  }

  // ============================================================
  // MONEY
  // ============================================================

  String _formatMoney(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo() {
    if (_businessLogo == null ||
        _businessLogo!.trim().isEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.storefront_outlined,
          color: AppColors.primary,
          size: 32,
        ),
      );
    }

    final file =
        File(_businessLogo!.trim());

    if (!file.existsSync()) {
      return Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.storefront_outlined,
          color: AppColors.primary,
          size: 32,
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(10),
      child: Image.file(
        file,
        width: 80,
        height: 64,
        fit: BoxFit.contain,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (widget.sales.isEmpty) {
      return Scaffold(
        backgroundColor:
            AppColors.background,
        appBar: AppBar(
          title:
              const Text('Receipt'),
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
        ),
        body: const Center(
          child: Text(
            'No receipt information available.',
          ),
        ),
      );
    }

    if (_isLoadingSettings) {
      return Scaffold(
        backgroundColor:
            AppColors.background,
        appBar: AppBar(
          title:
              const Text('Sale Receipt'),
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
        ),
        body: const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final firstSale =
        widget.sales.first;

    return Scaffold(
      backgroundColor:
          AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        elevation: 0,

        title: const Text(
          'Sale Receipt',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip:
                'Print Receipt',
            icon: const Icon(
              Icons.print_outlined,
            ),
            onPressed:
                _printReceipt,
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),

            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 600,
              ),

              child: Container(
                width: double.infinity,

                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 12,
                      offset:
                          const Offset(0, 4),
                    ),
                  ],
                ),

                padding:
                    const EdgeInsets.all(
                  24,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // BUSINESS HEADER
                    // ==================================================

                    Center(
                      child: Column(
                        children: [
                          _buildLogo(),

                          const SizedBox(
                            height: 12,
                          ),

                          Text(
                            _businessName,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          if (_businessTagline
                              .isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                top: 4,
                              ),
                              child: Text(
                                _businessTagline,
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ),

                          if (_businessAddress
                              .isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                top: 4,
                              ),
                              child: Text(
                                _businessAddress,
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ),

                          if (_businessPhone
                              .isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                top: 3,
                              ),
                              child: Text(
                                _businessPhone,
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            'SALES RECEIPT',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing:
                                  1.5,
                              fontWeight:
                                  FontWeight.w600,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Divider(),

                    // ==================================================
                    // SALE INFORMATION
                    // ==================================================

                    if (_showCashierName)
                      _infoRow(
                        'Cashier',
                        widget.cashier.name,
                      ),

                    if (_showReceiptDateTime)
                      Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          top: 6,
                        ),
                        child: _infoRow(
                          'Date',
                          _formatDateTime(
                            firstSale.createdAt,
                          ),
                        ),
                      ),

                    if (_showReceiptNumber)
                      Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          top: 6,
                        ),
                        child: _infoRow(
                          'Receipt No.',
                          '#${firstSale.id}',
                        ),
                      ),

                    const Divider(
                      height: 28,
                    ),

                    // ==================================================
                    // ITEMS
                    // ==================================================

                    const Text(
                      'ITEMS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.bold,
                        letterSpacing: 1.2,
                        color:
                            Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    ...widget.sales.map(
                      (sale) {
                        final product =
                            _findProduct(
                          sale.productId,
                        );

                        final productName =
                            product?.name ??
                                'Product #${sale.productId}';

                        return Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 7,
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Expanded(
                                child:
                                    Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      productName,
                                      maxLines:
                                          2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                        fontSize:
                                            14,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      '${sale.quantity} × ₦${_formatMoney(sale.unitPrice)}',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            12,
                                        color: Colors
                                            .grey
                                            .shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Text(
                                '₦${_formatMoney(sale.totalPrice)}',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  fontSize:
                                      14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const Divider(
                      height: 28,
                    ),

                    // ==================================================
                    // DISCOUNT
                    // ==================================================

                    if (_showReceiptDiscount)
                      _infoRow(
                        'Discount',
                        '₦0',
                      ),

                    // ==================================================
                    // TAX
                    // ==================================================

                    if (_showReceiptTax)
                      Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          top: 6,
                        ),
                        child: _infoRow(
                          'Tax',
                          '₦0',
                        ),
                      ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // TOTAL
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text(
                          'TOTAL',
                          style:
                              TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        Text(
                          '₦${_formatMoney(total)}',
                          style:
                              const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                AppColors
                                    .primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // PAYMENT
                    // ==================================================

                    const Text(
                      'PAYMENT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.bold,
                        letterSpacing: 1.2,
                        color:
                            Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    if (cashTotal > 0)
                      _paymentRow(
                        'Cash',
                        cashTotal,
                        Icons
                            .payments_outlined,
                        Colors.green,
                      ),

                    if (posTotal > 0)
                      _paymentRow(
                        'POS',
                        posTotal,
                        Icons.credit_card,
                        Colors.purple,
                      ),

                    if (transferTotal > 0)
                      _paymentRow(
                        'Transfer',
                        transferTotal,
                        Icons
                            .account_balance_outlined,
                        Colors.blue,
                      ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================================================
                    // STATUS
                    // ==================================================

                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.green
                            .withValues(
                          alpha: 0.08,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          const Icon(
                            Icons
                                .check_circle_outline,
                            color:
                                Colors.green,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            firstSale.status
                                .toString()
                                .toUpperCase(),
                            style:
                                const TextStyle(
                              color:
                                  Colors.green,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              letterSpacing:
                                  0.8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==================================================
                    // FOOTER
                    // ==================================================

                    if (_footer.isNotEmpty)
                      Center(
                        child: Text(
                          _footer,
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color: Colors
                                .grey
                                .shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // PRINT
                    // ==================================================

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          ElevatedButton.icon(
                        icon: const Icon(
                          Icons
                              .print_outlined,
                        ),
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              AppColors
                                  .primary,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 15,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),
                        onPressed:
                            _printReceipt,
                        label:
                            const Text(
                          'PRINT RECEIPT',
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color:
                Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT ROW
  // ============================================================

  Widget _paymentRow(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding:
          const EdgeInsets
              .symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration:
                BoxDecoration(
              color: color.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              label,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          Text(
            '₦${_formatMoney(amount)}',
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDateTime(
    dynamic date,
  ) {
    if (date == null) {
      return 'N/A';
    }

    final value =
        date is DateTime
            ? date
            : DateTime.tryParse(
                date.toString(),
              );

    if (value == null) {
      return date.toString();
    }

    final day =
        value.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        value.month.toString().padLeft(
              2,
              '0',
            );

    final year =
        value.year.toString();

    final hour =
        value.hour.toString().padLeft(
              2,
              '0',
            );

    final minute =
        value.minute.toString().padLeft(
              2,
              '0',
            );

    return '$day/$month/$year $hour:$minute';
  }

  // ============================================================
  // PRINT
  // ============================================================

  Future<void> _printReceipt() async {
    if (widget.sales.isEmpty) {
      return;
    }

    await Printing.layoutPdf(
      onLayout: (format) {
        return _generatePdf(
          format,
          widget.sales,
          widget.cashier,
          widget.products,
          businessName: _businessName,
          businessTagline:
              _businessTagline,
          address: _businessAddress,
          phone: _businessPhone,
          footer: _footer,
          receiptLogo: _businessLogo,
          showCashierName:
              _showCashierName,
          showReceiptDateTime:
              _showReceiptDateTime,
          showReceiptNumber:
              _showReceiptNumber,
          showReceiptTax:
              _showReceiptTax,
          showReceiptDiscount:
              _showReceiptDiscount,
          paperSize: _paperSize,
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        backgroundColor:
            isError
                ? AppColors.danger
                : null,
      ),
    );
  }
}

// ==================================================================
// PDF GENERATION
// ==================================================================

Future<Uint8List> _generatePdf(
  PdfPageFormat format,
  List sales,
  User cashier,
  List products, {
  required String businessName,
  required String businessTagline,
  required String address,
  required String phone,
  required String footer,
  required String? receiptLogo,
  required bool showCashierName,
  required bool showReceiptDateTime,
  required bool showReceiptNumber,
  required bool showReceiptTax,
  required bool showReceiptDiscount,
  required String paperSize,
}) async {
  final pdf = pw.Document();

  // ================================================================
  // TOTALS
  // ================================================================

  int total = 0;

  double cashTotal = 0;

  double posTotal = 0;

  double transferTotal = 0;

  for (final sale in sales) {
    total +=
        (sale.totalPrice as num).toInt();

    cashTotal +=
        ((sale.cashAmount ?? 0) as num)
            .toDouble();

    posTotal +=
        ((sale.posAmount ?? 0) as num)
            .toDouble();

    transferTotal +=
        ((sale.transferAmount ?? 0) as num)
            .toDouble();
  }

  // ================================================================
  // PRODUCT LOOKUP
  // ================================================================

  dynamic findProduct(
    int productId,
  ) {
    for (final product in products) {
      if (product.id == productId) {
        return product;
      }
    }

    return null;
  }

  // ================================================================
  // MONEY
  // ================================================================

  String formatMoney(
    num value,
  ) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(
            r'\B(?=(\d{3})+(?!\d))',
          ),
          (match) => ',',
        );
  }

  // ================================================================
  // DATE
  // ================================================================

  String formatDate(
    dynamic date,
  ) {
    if (date == null) {
      return 'N/A';
    }

    final value =
        date is DateTime
            ? date
            : DateTime.tryParse(
                date.toString(),
              );

    if (value == null) {
      return date.toString();
    }

    final day =
        value.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        value.month.toString().padLeft(
              2,
              '0',
            );

    final year =
        value.year.toString();

    final hour =
        value.hour.toString().padLeft(
              2,
              '0',
            );

    final minute =
        value.minute.toString().padLeft(
              2,
              '0',
            );

    return '$day/$month/$year $hour:$minute';
  }

  // ================================================================
  // PAPER SIZE
  // ================================================================

  PdfPageFormat selectedFormat;

  switch (paperSize) {
    case '58mm':
      selectedFormat =
          const PdfPageFormat(
        58 * PdfPageFormat.mm,
        297 * PdfPageFormat.mm,
        marginAll: 12,
      );
      break;

    case 'A4':
      selectedFormat =
          PdfPageFormat.a4;
      break;

    case '80mm':
    default:
      selectedFormat =
          const PdfPageFormat(
        80 * PdfPageFormat.mm,
        297 * PdfPageFormat.mm,
        marginAll: 14,
      );
      break;
  }

  // ================================================================
  // LOGO
  // ================================================================

  pw.MemoryImage? logoImage;

  if (receiptLogo != null &&
      receiptLogo.trim().isNotEmpty) {
    try {
      final file =
          File(receiptLogo);

      if (file.existsSync()) {
        final bytes =
            await file.readAsBytes();

        logoImage =
            pw.MemoryImage(bytes);
      }
    } catch (_) {
      logoImage = null;
    }
  }

  final firstSale =
      sales.first;

  // ================================================================
  // PDF
  // ================================================================

  pdf.addPage(
    pw.Page(
      pageFormat:
          selectedFormat,

      margin:
          selectedFormat.marginLeft >
                  0
              ? pw.EdgeInsets.fromLTRB(
                  selectedFormat
                      .marginLeft,
                  selectedFormat
                      .marginTop,
                  selectedFormat
                      .marginRight,
                  selectedFormat
                      .marginBottom,
                )
              : const pw.EdgeInsets.all(
                  14,
                ),

      build: (context) {
        return pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment
                  .start,

          children: [
            // ======================================================
            // BUSINESS HEADER
            // ======================================================

            pw.Center(
              child:
                  pw.Column(
                children: [
                  if (logoImage !=
                      null)
                    pw.Container(
                      width: 55,
                      height: 55,
                      margin:
                          const pw.EdgeInsets
                              .only(
                        bottom: 8,
                      ),
                      child:
                          pw.Image(
                        logoImage!,
                        fit:
                            pw.BoxFit
                                .contain,
                      ),
                    ),

                  pw.Text(
                    businessName,
                    textAlign:
                        pw.TextAlign
                            .center,
                    style:
                        pw.TextStyle(
                      fontSize:
                          paperSize ==
                                  'A4'
                              ? 20
                              : 16,
                      fontWeight:
                          pw.FontWeight
                              .bold,
                    ),
                  ),

                  if (businessTagline
                      .trim()
                      .isNotEmpty)
                    pw.Padding(
                      padding:
                          const pw.EdgeInsets
                              .only(
                        top: 3,
                      ),
                      child:
                          pw.Text(
                        businessTagline,
                        textAlign:
                            pw.TextAlign
                                .center,
                        style:
                            const pw.TextStyle(
                          fontSize: 8,
                          color:
                              PdfColors
                                  .grey,
                        ),
                      ),
                    ),

                  if (address
                      .trim()
                      .isNotEmpty)
                    pw.Padding(
                      padding:
                          const pw.EdgeInsets
                              .only(
                        top: 3,
                      ),
                      child:
                          pw.Text(
                        address,
                        textAlign:
                            pw.TextAlign
                                .center,
                        style:
                            const pw.TextStyle(
                          fontSize: 8,
                          color:
                              PdfColors
                                  .grey,
                        ),
                      ),
                    ),

                  if (phone
                      .trim()
                      .isNotEmpty)
                    pw.Padding(
                      padding:
                          const pw.EdgeInsets
                              .only(
                        top: 2,
                      ),
                      child:
                          pw.Text(
                        phone,
                        textAlign:
                            pw.TextAlign
                                .center,
                        style:
                            const pw.TextStyle(
                          fontSize: 8,
                          color:
                              PdfColors
                                  .grey,
                        ),
                      ),
                    ),

                  pw.SizedBox(
                    height: 6,
                  ),

                  pw.Text(
                    'SALES RECEIPT',
                    style:
                        const pw.TextStyle(
                      fontSize: 8,
                      fontWeight:
                          pw.FontWeight
                              .bold,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(
              height: 10,
            ),

            pw.Divider(),

            // ======================================================
            // SALE INFORMATION
            // ======================================================

            if (showCashierName)
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceBetween,
                children: [
                  pw.Text(
                    'Cashier',
                    style:
                        const pw.TextStyle(
                      fontSize: 8,
                      color:
                          PdfColors
                              .grey,
                    ),
                  ),
                  pw.Text(
                    cashier.name,
                    style:
                        const pw.TextStyle(
                      fontSize: 8,
                      fontWeight:
                          pw.FontWeight
                              .bold,
                    ),
                  ),
                ],
              ),

            if (showReceiptDateTime)
              pw.Padding(
                padding:
                    const pw.EdgeInsets
                        .only(
                  top: 4,
                ),
                child:
                    pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment
                          .spaceBetween,
                  children: [
                    pw.Text(
                      'Date',
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                        color:
                            PdfColors
                                .grey,
                      ),
                    ),
                    pw.Text(
                      formatDate(
                        firstSale
                            .createdAt,
                      ),
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),

            if (showReceiptNumber)
              pw.Padding(
                padding:
                    const pw.EdgeInsets
                        .only(
                  top: 4,
                ),
                child:
                    pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment
                          .spaceBetween,
                  children: [
                    pw.Text(
                      'Receipt No.',
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                        color:
                            PdfColors
                                .grey,
                      ),
                    ),
                    pw.Text(
                      '#${firstSale.id}',
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),

            pw.Divider(),

            // ======================================================
            // ITEMS
            // ======================================================

            pw.Text(
              'ITEMS',
              style:
                  const pw.TextStyle(
                fontSize: 8,
                fontWeight:
                    pw.FontWeight
                        .bold,
              ),
            ),

            pw.SizedBox(
              height: 5,
            ),

            ...sales.map(
              (sale) {
                final product =
                    findProduct(
                  sale.productId,
                );

                final productName =
                    product?.name ??
                        'Product #${sale.productId}';

                return pw.Padding(
                  padding:
                      const pw.EdgeInsets
                          .symmetric(
                    vertical: 4,
                  ),
                  child:
                      pw.Row(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment
                            .start,
                    children: [
                      pw.Expanded(
                        child:
                            pw.Column(
                          crossAxisAlignment:
                              pw.CrossAxisAlignment
                                  .start,
                          children: [
                            pw.Text(
                              productName,
                              style:
                                  const pw.TextStyle(
                                fontSize:
                                    9,
                                fontWeight:
                                    pw.FontWeight
                                        .bold,
                              ),
                            ),
                            pw.SizedBox(
                              height: 2,
                            ),
                            pw.Text(
                              '${sale.quantity} × ₦${formatMoney(sale.unitPrice)}',
                              style:
                                  const pw.TextStyle(
                                fontSize:
                                    7,
                                color:
                                    PdfColors
                                        .grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Text(
                        '₦${formatMoney(sale.totalPrice)}',
                        style:
                            const pw.TextStyle(
                          fontSize: 9,
                          fontWeight:
                              pw.FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            pw.Divider(),

            // ======================================================
            // DISCOUNT
            // ======================================================

            if (showReceiptDiscount)
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceBetween,
                children: [
                  pw.Text(
                    'Discount',
                    style:
                        const pw.TextStyle(
                      fontSize: 8,
                      color:
                          PdfColors
                              .grey,
                    ),
                  ),
                  pw.Text(
                    '₦0',
                    style:
                        const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ],
              ),

            // ======================================================
            // TAX
            // ======================================================

            if (showReceiptTax)
              pw.Padding(
                padding:
                    const pw.EdgeInsets
                        .only(
                  top: 4,
                ),
                child:
                    pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment
                          .spaceBetween,
                  children: [
                    pw.Text(
                      'Tax',
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                        color:
                            PdfColors
                                .grey,
                      ),
                    ),
                    pw.Text(
                      '₦0',
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),

            pw.SizedBox(
              height: 7,
            ),

            // ======================================================
            // TOTAL
            // ======================================================

            pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment
                      .spaceBetween,
              children: [
                pw.Text(
                  'TOTAL',
                  style:
                      const pw.TextStyle(
                    fontSize: 13,
                    fontWeight:
                        pw.FontWeight
                            .bold,
                  ),
                ),
                pw.Text(
                  '₦${formatMoney(total)}',
                  style:
                      const pw.TextStyle(
                    fontSize: 14,
                    fontWeight:
                        pw.FontWeight
                            .bold,
                  ),
                ),
              ],
            ),

            pw.SizedBox(
              height: 10,
            ),

            // ======================================================
            // PAYMENT
            // ======================================================

            pw.Text(
              'PAYMENT',
              style:
                  const pw.TextStyle(
                fontSize: 8,
                fontWeight:
                    pw.FontWeight
                        .bold,
              ),
            ),

            pw.SizedBox(
              height: 5,
            ),

            if (cashTotal > 0)
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceBetween,
                children: [
                  pw.Text(
                    'Cash',
                    style:
                        const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                  pw.Text(
                    '₦${formatMoney(cashTotal)}',
                    style:
                        const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ],
              ),

            if (posTotal > 0)
              pw.Padding(
                padding:
                    const pw.EdgeInsets
                        .only(
                  top: 4,
                ),
                child:
                    pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment
                          .spaceBetween,
                  children: [
                    pw.Text(
                      'POS',
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                    pw.Text(
                      '₦${formatMoney(posTotal)}',
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),

            if (transferTotal > 0)
              pw.Padding(
                padding:
                    const pw.EdgeInsets
                        .only(
                  top: 4,
                ),
                child:
                    pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment
                          .spaceBetween,
                  children: [
                    pw.Text(
                      'Transfer',
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                    pw.Text(
                      '₦${formatMoney(transferTotal)}',
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),

            pw.SizedBox(
              height: 8,
            ),

            pw.Divider(),

            // ======================================================
            // STATUS
            // ======================================================

            pw.Center(
              child:
                  pw.Text(
                firstSale.status
                    .toString()
                    .toUpperCase(),
                style:
                    const pw.TextStyle(
                  color:
                      PdfColors.green,
                  fontSize: 8,
                  fontWeight:
                      pw.FontWeight
                          .bold,
                ),
              ),
            ),

            pw.SizedBox(
              height: 10,
            ),

            // ======================================================
            // FOOTER
            // ======================================================

            if (footer.trim().isNotEmpty)
              pw.Center(
                child:
                    pw.Text(
                  footer,
                  textAlign:
                      pw.TextAlign
                          .center,
                  style:
                      const pw.TextStyle(
                    fontSize: 8,
                    color:
                        PdfColors.grey,
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
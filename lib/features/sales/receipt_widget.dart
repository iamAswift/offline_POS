// lib/features/sales/receipt_widget.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/business/business_identity.dart';
import '../../core/responsive/responsive.dart';
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
  // BusinessIdentity remains the SINGLE source of truth.
  // ============================================================

  String _businessName = BusinessIdentity.defaultBusinessName;

  String _businessTagline = BusinessIdentity.defaultBusinessTagline;

  String _businessPhone = '';

  String _businessEmail = '';

  String _businessAddress = '';

  String _businessType = '';

  String? _businessLogo;

  // ============================================================
  // RECEIPT SETTINGS
  // ============================================================

  String _footer = 'Thank you for your patronage.';

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
      result += (sale.totalPrice as num).toInt();
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
          ((sale.cashAmount ?? 0) as num).toDouble(),
    );
  }

  double get posTotal {
    return widget.sales.fold(
      0.0,
      (sum, sale) =>
          sum +
          ((sale.posAmount ?? 0) as num).toDouble(),
    );
  }

  double get transferTotal {
    return widget.sales.fold(
      0.0,
      (sum, sale) =>
          sum +
          ((sale.transferAmount ?? 0) as num).toDouble(),
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
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo({
    required Responsive responsive,
  }) {
    final size = responsive.value<double>(
      compact: 52,
      tablet: 56,
      desktop: 58,
    );

    final logoWidth = responsive.value<double>(
      compact: 68,
      tablet: 72,
      desktop: 76,
    );

    if (_businessLogo == null ||
        _businessLogo!.trim().isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.storefront_outlined,
          color: AppColors.primary,
          size: size * 0.48,
        ),
      );
    }

    final file = File(_businessLogo!.trim());

    if (!file.existsSync()) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.storefront_outlined,
          color: AppColors.primary,
          size: size * 0.48,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.file(
        file,
        width: logoWidth,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    if (widget.sales.isEmpty) {
      return _buildEmptyState(responsive);
    }

    if (_isLoadingSettings) {
      return _buildLoadingState(responsive);
    }

    final firstSale = widget.sales.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.horizontalPadding,
            vertical: responsive.verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: responsive.contentMaxWidth,
              ),
              child: _buildReceiptPreview(
                context,
                responsive,
                firstSale,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: AppSpacing.lg,
      title: const Text(
        'Sale Receipt',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Print Receipt',
          icon: const Icon(
            Icons.print_outlined,
          ),
          onPressed: _printReceipt,
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(Responsive responsive) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Receipt',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(
            responsive.horizontalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'No receipt information available.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING STATE
  // ============================================================

  Widget _buildLoadingState(Responsive responsive) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sale Receipt',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Loading receipt...',
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: responsive.isCompact ? 12 : 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RECEIPT PREVIEW
  // ============================================================

  Widget _buildReceiptPreview(
    BuildContext context,
    Responsive responsive,
    dynamic firstSale,
  ) {
    final receiptWidth = responsive.value<double>(
      compact: double.infinity,
      tablet: 440,
      desktop: 460,
    );

    final receiptPadding = responsive.value<double>(
      compact: AppSpacing.lg,
      tablet: AppSpacing.xl,
      desktop: AppSpacing.xl,
    );

    return Column(
      children: [
        Container(
          width: receiptWidth,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppRadius.lg,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.all(receiptPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBusinessHeader(responsive),
              SizedBox(
                height: responsive.value<double>(
                  compact: AppSpacing.lg,
                  tablet: AppSpacing.xl,
                  desktop: AppSpacing.xl,
                ),
              ),
              _buildReceiptInformation(
                responsive,
                firstSale,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildItemsSection(responsive),
              const SizedBox(height: AppSpacing.md),
              _buildTotalsSection(responsive),
              const SizedBox(height: AppSpacing.lg),
              _buildPaymentSection(responsive),
              const SizedBox(height: AppSpacing.md),
              _buildStatus(firstSale),
              const SizedBox(height: AppSpacing.lg),
              _buildFooter(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: receiptWidth,
          height: responsive.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: _printReceipt,
            icon: const Icon(
              Icons.print_outlined,
              size: 19,
            ),
            label: const Text(
              'PRINT RECEIPT',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppRadius.md,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUSINESS HEADER
  // ============================================================

  Widget _buildBusinessHeader(
    Responsive responsive,
  ) {
    final businessNameSize = responsive.value<double>(
      compact: 18,
      tablet: 19,
      desktop: 20,
    );

    final secondarySize = responsive.value<double>(
      compact: 11,
      tablet: 12,
      desktop: 12,
    );

    return Center(
      child: Column(
        children: [
          _buildLogo(
            responsive: responsive,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _businessName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.heading.copyWith(
              fontSize: businessNameSize,
            ),
          ),
          if (_businessTagline.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
              ),
              child: Text(
                _businessTagline,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.small.copyWith(
                  fontSize: secondarySize,
                ),
              ),
            ),
          if (_businessAddress.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
              ),
              child: Text(
                _businessAddress,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.small.copyWith(
                  fontSize: secondarySize,
                ),
              ),
            ),
          if (_businessPhone.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: 2,
              ),
              child: Text(
                _businessPhone,
                textAlign: TextAlign.center,
                style: AppTextStyles.small.copyWith(
                  fontSize: secondarySize,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(
                AppRadius.round,
              ),
            ),
            child: Text(
              'SALES RECEIPT',
              style: AppTextStyles.small.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECEIPT INFORMATION
  // ============================================================

  Widget _buildReceiptInformation(
    Responsive responsive,
    dynamic firstSale,
  ) {
    return _buildSection(
      child: Column(
        children: [
          if (_showCashierName)
            _infoRow(
              'Cashier',
              widget.cashier.name,
            ),
          if (_showReceiptDateTime)
            _infoRow(
              'Date',
              _formatDateTime(
                firstSale.createdAt,
              ),
              topSpacing: _showCashierName
                  ? AppSpacing.sm
                  : 0,
            ),
          if (_showReceiptNumber)
            _infoRow(
              'Receipt No.',
              '#${firstSale.id}',
              topSpacing:
                  (_showCashierName ||
                          _showReceiptDateTime)
                      ? AppSpacing.sm
                      : 0,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ITEMS
  // ============================================================

  Widget _buildItemsSection(
    Responsive responsive,
  ) {
    return _buildSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('ITEMS'),
          const SizedBox(height: AppSpacing.sm),
          ...widget.sales.map(
            (sale) {
              final product = _findProduct(
                sale.productId,
              );

              final productName =
                  product?.name ??
                  'Product #${sale.productId}';

              return _buildItemRow(
                responsive,
                productName,
                sale.quantity,
                sale.unitPrice,
                sale.totalPrice,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(
    Responsive responsive,
    String productName,
    dynamic quantity,
    dynamic unitPrice,
    dynamic totalPrice,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontSize:
                        responsive.isCompact
                            ? 13
                            : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Text(
                  '$quantity × ₦${_formatMoney(unitPrice)}',
                  style:
                      AppTextStyles.small.copyWith(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Text(
            '₦${_formatMoney(totalPrice)}',
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(
              fontSize:
                  responsive.isCompact
                      ? 13
                      : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOTALS
  // ============================================================

  Widget _buildTotalsSection(
    Responsive responsive,
  ) {
    return Column(
      children: [
        if (_showReceiptDiscount)
          _infoRow(
            'Discount',
            '₦0',
          ),

        if (_showReceiptTax)
          _infoRow(
            'Tax',
            '₦0',
            topSpacing:
                _showReceiptDiscount
                    ? AppSpacing.sm
                    : 0,
          ),

        SizedBox(
          height: responsive.value<double>(
            compact: AppSpacing.md,
            tablet: AppSpacing.md,
            desktop: AppSpacing.lg,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),

          decoration: const BoxDecoration(
            border: BorderDirectional(
              top: BorderSide(
                color: AppColors.border,
              ),
              bottom: BorderSide(
                color: AppColors.border,
              ),
            ),
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            crossAxisAlignment:
                CrossAxisAlignment.center,

            children: [
              Text(
                'TOTAL',
                style: AppTextStyles.title.copyWith(
                  fontSize:
                      responsive.isCompact
                          ? 16
                          : 17,
                ),
              ),

              Text(
                '₦${_formatMoney(total)}',
                style: AppTextStyles.price.copyWith(
                  fontSize:
                      responsive.isCompact
                          ? 20
                          : 22,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  Widget _buildPaymentSection(
    Responsive responsive,
  ) {
    final hasPayment = cashTotal > 0 ||
        posTotal > 0 ||
        transferTotal > 0;

    if (!hasPayment) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionLabel('PAYMENT'),
        const SizedBox(height: AppSpacing.sm),
        if (cashTotal > 0)
          _paymentRow(
            'Cash',
            cashTotal,
            Icons.payments_outlined,
            AppColors.cash,
          ),
        if (posTotal > 0)
          _paymentRow(
            'POS',
            posTotal,
            Icons.credit_card_outlined,
            AppColors.pos,
          ),
        if (transferTotal > 0)
          _paymentRow(
            'Transfer',
            transferTotal,
            Icons.account_balance_outlined,
            AppColors.transfer,
          ),
      ],
    );
  }

  Widget _paymentRow(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                AppRadius.md,
              ),
            ),
            child: Icon(
              icon,
              size: 17,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '₦${_formatMoney(amount)}',
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatus(dynamic firstSale) {
    final status = firstSale.status
        .toString()
        .toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        border: Border.all(
          color: AppColors.success.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            status,
            style: AppTextStyles.small.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    if (_footer.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Text(
        _footer,
        textAlign: TextAlign.center,
        style: AppTextStyles.small.copyWith(
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: child,
    );
  }

  // ============================================================
  // SECTION LABEL
  // ============================================================

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.small.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        fontSize: 10,
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    String label,
    String value, {
    double topSpacing = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: topSpacing,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.small,
            ),
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
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
          businessTagline: _businessTagline,
          address: _businessAddress,
          phone: _businessPhone,
          footer: _footer,
          receiptLogo: _businessLogo,
          showCashierName: _showCashierName,
          showReceiptDateTime:
              _showReceiptDateTime,
          showReceiptNumber:
              _showReceiptNumber,
          showReceiptTax: _showReceiptTax,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        backgroundColor:
            isError
                ? AppColors.danger
                : AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.md,
          ),
        ),
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


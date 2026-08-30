// lib/features/settings/receipt_settings_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/business/business_identity.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

class ReceiptSettingsScreen extends StatefulWidget {
  final SettingsDao settingsDao;

  const ReceiptSettingsScreen({super.key, required this.settingsDao});

  @override
  State<ReceiptSettingsScreen> createState() => _ReceiptSettingsScreenState();
}

class _ReceiptSettingsScreenState extends State<ReceiptSettingsScreen> {
  // ============================================================
  // RECEIPT SETTINGS CONTROLLER
  // ============================================================

  final TextEditingController _footerController = TextEditingController();

  // ============================================================
  // BUSINESS IDENTITY
  //
  // BusinessIdentity remains the single source of truth.
  // Receipt Settings does not save or duplicate identity data.
  // ============================================================

  String _businessName = '';

  String _businessTagline = '';

  String _businessPhone = '';

  String _businessEmail = '';

  String _businessAddress = '';

  String _businessType = '';

  String? _businessLogo;

  // ============================================================
  // RECEIPT SETTINGS
  // ============================================================

  bool _showCashierName = true;

  bool _showReceiptDateTime = true;

  bool _showReceiptNumber = true;

  bool _showReceiptTax = false;

  bool _showReceiptDiscount = true;

  String _paperSize = '80mm';

  bool _isLoading = true;

  bool _isSaving = false;

  // ============================================================
  // PAPER SIZES
  // ============================================================

  static const List<String> _paperSizes = ['58mm', '80mm', 'A4'];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadReceiptSettings();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> _loadReceiptSettings() async {
    try {
      // --------------------------------------------------------
      // BUSINESS IDENTITY
      // --------------------------------------------------------

      final businessName = await BusinessIdentity.getBusinessName(
        widget.settingsDao,
      );

      final businessTagline = await BusinessIdentity.getBusinessTagline(
        widget.settingsDao,
      );

      final businessPhone = await BusinessIdentity.getBusinessPhone(
        widget.settingsDao,
      );

      final businessEmail = await BusinessIdentity.getBusinessEmail(
        widget.settingsDao,
      );

      final businessAddress = await BusinessIdentity.getBusinessAddress(
        widget.settingsDao,
      );

      final businessType = await BusinessIdentity.getBusinessType(
        widget.settingsDao,
      );

      final businessLogo = await BusinessIdentity.getBusinessLogo(
        widget.settingsDao,
      );

      // --------------------------------------------------------
      // RECEIPT SETTINGS
      // --------------------------------------------------------

      final footer = await widget.settingsDao.getSetting(
        BusinessSettings.receiptFooter,
      );

      final showCashier = await widget.settingsDao.getSetting(
        BusinessSettings.showCashierName,
      );

      final showDateTime = await widget.settingsDao.getSetting(
        BusinessSettings.showReceiptDateTime,
      );

      final showNumber = await widget.settingsDao.getSetting(
        BusinessSettings.showReceiptNumber,
      );

      final showTax = await widget.settingsDao.getSetting(
        BusinessSettings.showReceiptTax,
      );

      final showDiscount = await widget.settingsDao.getSetting(
        BusinessSettings.showReceiptDiscount,
      );

      final paperSize = await widget.settingsDao.getSetting(
        BusinessSettings.receiptPaperSize,
      );

      if (!mounted) return;

      setState(() {
        // ------------------------------------------------------
        // BUSINESS IDENTITY
        // ------------------------------------------------------

        _businessName = businessName;

        _businessTagline = businessTagline;

        _businessPhone = businessPhone;

        _businessEmail = businessEmail;

        _businessAddress = businessAddress;

        _businessType = businessType;

        _businessLogo = businessLogo;

        // ------------------------------------------------------
        // RECEIPT SETTINGS
        // ------------------------------------------------------

        _footerController.text = footer ?? 'Thank you for your patronage.';

        _showCashierName = _parseBool(showCashier, defaultValue: true);

        _showReceiptDateTime = _parseBool(showDateTime, defaultValue: true);

        _showReceiptNumber = _parseBool(showNumber, defaultValue: true);

        _showReceiptTax = _parseBool(showTax, defaultValue: false);

        _showReceiptDiscount = _parseBool(showDiscount, defaultValue: true);

        if (paperSize != null && _paperSizes.contains(paperSize)) {
          _paperSize = paperSize;
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Failed to load receipt settings: $e', isError: true);
    }
  }

  // ============================================================
  // BOOLEAN PARSER
  // ============================================================

  bool _parseBool(String? value, {required bool defaultValue}) {
    if (value == null) {
      return defaultValue;
    }

    return value.trim().toLowerCase() == 'true';
  }

  // ============================================================
  // SAVE RECEIPT SETTINGS
  //
  // Business identity is intentionally NOT saved here.
  // Business Profile owns that data.
  // ============================================================

  Future<void> _saveReceiptSettings() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // --------------------------------------------------------
      // FOOTER
      // --------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.receiptFooter,
        _footerController.text.trim(),
      );

      // --------------------------------------------------------
      // DISPLAY OPTIONS
      // --------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.showCashierName,
        _showCashierName.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.showReceiptDateTime,
        _showReceiptDateTime.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.showReceiptNumber,
        _showReceiptNumber.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.showReceiptTax,
        _showReceiptTax.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.showReceiptDiscount,
        _showReceiptDiscount.toString(),
      );

      // --------------------------------------------------------
      // PAPER SIZE
      // --------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.receiptPaperSize,
        _paperSize,
      );

      if (!mounted) return;

      _showMessage('Receipt settings saved successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to save receipt settings: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : null,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final responsive = context.responsive;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Padding(
        padding: EdgeInsets.all(
          responsive.value(
            compact: AppSpacing.lg,
            tablet: AppSpacing.xl,
            desktop: AppSpacing.xxl,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSizes.iconButton,
                  height: AppSizes.iconButton,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle, style: AppTextStyles.bodySecondary),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: responsive.value(
                compact: AppSpacing.lg,
                tablet: AppSpacing.xl,
                desktop: AppSpacing.xl,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SWITCH TILE
  // ============================================================

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTextStyles.body),
      subtitle: Text(subtitle, style: AppTextStyles.bodySecondary),
      value: value,
      onChanged: onChanged,
    );
  }

  // ============================================================
  // BUSINESS IDENTITY CARD
  // ============================================================

  Widget _buildBusinessIdentityCard() {
    final responsive = context.responsive;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.value(
          compact: AppSpacing.md,
          tablet: AppSpacing.lg,
          desktop: AppSpacing.xl,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // ------------------------------------------------------
          // LOGO
          // ------------------------------------------------------
          _buildBusinessLogo(),

          const SizedBox(height: AppSpacing.md),

          // ------------------------------------------------------
          // BUSINESS NAME
          // ------------------------------------------------------
          Text(
            _businessName.isEmpty ? 'Business Name' : _businessName,
            textAlign: TextAlign.center,
            style: AppTextStyles.title,
          ),

          // ------------------------------------------------------
          // TAGLINE
          // ------------------------------------------------------
          if (_businessTagline.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                _businessTagline,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
            ),

          const SizedBox(height: AppSpacing.md),

          const Divider(),

          const SizedBox(height: AppSpacing.sm),

          // ------------------------------------------------------
          // ADDRESS
          // ------------------------------------------------------
          if (_businessAddress.isNotEmpty)
            _identityRow(Icons.location_on_outlined, _businessAddress),

          // ------------------------------------------------------
          // PHONE
          // ------------------------------------------------------
          if (_businessPhone.isNotEmpty)
            _identityRow(Icons.phone_outlined, _businessPhone),

          // ------------------------------------------------------
          // EMAIL
          // ------------------------------------------------------
          if (_businessEmail.isNotEmpty)
            _identityRow(Icons.email_outlined, _businessEmail),

          // ------------------------------------------------------
          // BUSINESS TYPE
          // ------------------------------------------------------
          if (_businessType.isNotEmpty)
            _identityRow(Icons.business_outlined, _businessType),

          const SizedBox(height: AppSpacing.md),

          // ------------------------------------------------------
          // SOURCE NOTICE
          // ------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
                 SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Business information is managed from Business Profile settings.',
                    style: AppTextStyles.small,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUSINESS LOGO
  // ============================================================

  Widget _buildBusinessLogo() {
    final responsive = context.responsive;

    final logoSize = responsive.value<double>(
      compact: AppSizes.iconButton,
      tablet: AppSizes.iconButton + AppSpacing.md,
      desktop: AppSizes.iconButton + AppSpacing.lg,
    );

    final iconSize = responsive.value<double>(
      compact: AppSpacing.xxxl,
      tablet: AppSpacing.xxxl,
      desktop: AppSpacing.xxxl + AppSpacing.xs,
    );

    if (_businessLogo == null || _businessLogo!.trim().isEmpty) {
      return Container(
        width: logoSize,
        height: logoSize,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.storefront_outlined,
          color: AppColors.primary,
          size: iconSize,
        ),
      );
    }

    final path = _businessLogo!.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.file(
        File(path),
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Container(
            width: logoSize,
            height: logoSize,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_outlined,
              color: AppColors.primary,
              size: iconSize,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // IDENTITY ROW
  // ============================================================

  Widget _identityRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppSpacing.lg, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: AppTextStyles.small,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECEIPT PREVIEW
  // ============================================================

  Widget _buildReceiptPreview() {
    final responsive = context.responsive;

    final footer = _footerController.text.trim();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: responsive.value<double>(
            compact: double.infinity,
            tablet: 520,
            desktop: 560,
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            responsive.value(
              compact: AppSpacing.lg,
              tablet: AppSpacing.xl,
              desktop: AppSpacing.xxl,
            ),
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // --------------------------------------------------
              // BUSINESS IDENTITY
              // --------------------------------------------------
              _buildBusinessLogo(),

              const SizedBox(height: AppSpacing.sm),

              Text(
                _businessName.isEmpty ? 'Business Name' : _businessName,
                textAlign: TextAlign.center,
                style: AppTextStyles.title,
              ),

              if (_businessTagline.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    _businessTagline,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.small,
                  ),
                ),

              if (_businessAddress.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    _businessAddress,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.small,
                  ),
                ),

              if (_businessPhone.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs / 2),
                  child: Text(
                    _businessPhone,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.small,
                  ),
                ),

              const Divider(height: AppSpacing.section / 2),

              // --------------------------------------------------
              // RECEIPT INFORMATION
              // --------------------------------------------------
              if (_showReceiptNumber) _previewRow('Receipt No.', '#000001'),

              if (_showReceiptDateTime) _previewRow('Date', '13/08/2026 13:30'),

              if (_showCashierName) _previewRow('Cashier', 'Staff'),

              const SizedBox(height: AppSpacing.sm),

              // --------------------------------------------------
              // ITEMS
              // --------------------------------------------------
              _previewItem('Coca Cola 50cl', '2 × ₦500', '₦1,000'),

              _previewItem('Water 75cl', '1 × ₦300', '₦300'),

              const Divider(height: AppSpacing.section / 2),

              // --------------------------------------------------
              // DISCOUNT
              // --------------------------------------------------
              if (_showReceiptDiscount) _previewRow('Discount', '₦0'),

              // --------------------------------------------------
              // TAX
              // --------------------------------------------------
              if (_showReceiptTax) _previewRow('Tax', '₦0'),

              // --------------------------------------------------
              // TOTAL
              // --------------------------------------------------
              _previewRow('TOTAL', '₦1,300', bold: true),

              const SizedBox(height: AppSpacing.xl),

              // --------------------------------------------------
              // FOOTER
              // --------------------------------------------------
              if (footer.isNotEmpty)
                Text(
                  footer,
                  style: AppTextStyles.small,
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: AppSpacing.sm),

              // --------------------------------------------------
              // PAPER SIZE
              // --------------------------------------------------
              Text('Paper Size: $_paperSize', style: AppTextStyles.small),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PREVIEW ROW
  // ============================================================

  Widget _previewRow(String label, String value, {bool bold = false}) {
    final style = bold ? AppTextStyles.title : AppTextStyles.bodySecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(value, textAlign: TextAlign.end, style: style),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW ITEM
  // ============================================================

  Widget _previewItem(String name, String quantity, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.xs / 2),
                Text(quantity, style: AppTextStyles.small),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(total, style: AppTextStyles.price),
        ],
      ),
    );
  }

  // ============================================================
  // TOP SAVE BUTTON
  // ============================================================

  Widget _buildTopSaveButton(Responsive responsive) {
    final showLabel = !responsive.isCompact;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveReceiptSettings,
        icon: _isSaving
            ? const SizedBox(
                width: AppSpacing.lg,
                height: AppSpacing.lg,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save),
        label: showLabel ? const Text('Save') : const SizedBox.shrink(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: const Text('Receipt Settings'),
        actions: [_buildTopSaveButton(responsive)],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: responsive.contentMaxWidth,
                ),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: responsive.verticalPadding,
                  ),
                  children: [
                    // ==========================================
                    // BUSINESS IDENTITY
                    // ==========================================
                    _section(
                      title: 'Business Identity',
                      subtitle:
                          'This information comes from your Business Profile and is used automatically on receipts.',
                      icon: Icons.business,
                      child: _buildBusinessIdentityCard(),
                    ),

                    // ==========================================
                    // RECEIPT DISPLAY
                    // ==========================================
                    _section(
                      title: 'Receipt Information',
                      subtitle: 'Choose what information appears on receipts.',
                      icon: Icons.visibility,
                      child: Column(
                        children: [
                          _switchTile(
                            title: 'Show Cashier Name',
                            subtitle:
                                'Display the staff member who processed the sale.',
                            value: _showCashierName,
                            onChanged: (value) {
                              setState(() {
                                _showCashierName = value;
                              });
                            },
                          ),

                          _switchTile(
                            title: 'Show Date & Time',
                            subtitle: 'Display the transaction date and time.',
                            value: _showReceiptDateTime,
                            onChanged: (value) {
                              setState(() {
                                _showReceiptDateTime = value;
                              });
                            },
                          ),

                          _switchTile(
                            title: 'Show Receipt Number',
                            subtitle: 'Display the unique receipt number.',
                            value: _showReceiptNumber,
                            onChanged: (value) {
                              setState(() {
                                _showReceiptNumber = value;
                              });
                            },
                          ),

                          _switchTile(
                            title: 'Show Tax',
                            subtitle: 'Display tax information on receipts.',
                            value: _showReceiptTax,
                            onChanged: (value) {
                              setState(() {
                                _showReceiptTax = value;
                              });
                            },
                          ),

                          _switchTile(
                            title: 'Show Discount',
                            subtitle:
                                'Display discount information on receipts.',
                            value: _showReceiptDiscount,
                            onChanged: (value) {
                              setState(() {
                                _showReceiptDiscount = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // ==========================================
                    // FOOTER
                    // ==========================================
                    _section(
                      title: 'Receipt Footer',
                      subtitle: 'Message displayed at the bottom of receipts.',
                      icon: Icons.notes,
                      child: _textField(
                        label: 'Footer Message',
                        controller: _footerController,
                        hint: 'Thank you for your patronage.',
                        maxLines: 3,
                      ),
                    ),

                    // ==========================================
                    // PAPER & PRINTING
                    // ==========================================
                    _section(
                      title: 'Paper & Printing',
                      subtitle: 'Configure the receipt paper format.',
                      icon: Icons.print,
                      child: DropdownButtonFormField<String>(
                        initialValue: _paperSize,
                        decoration: const InputDecoration(
                          labelText: 'Paper Size',
                        ),
                        items: _paperSizes
                            .map(
                              (size) => DropdownMenuItem<String>(
                                value: size,
                                child: Text(size),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _paperSize = value;
                          });
                        },
                      ),
                    ),

                    // ==========================================
                    // PREVIEW
                    // ==========================================
                    _section(
                      title: 'Receipt Preview',
                      subtitle:
                          'Preview how the receipt will look using your current business identity.',
                      icon: Icons.preview,
                      child: _buildReceiptPreview(),
                    ),

                    // ==========================================
                    // BOTTOM SAVE
                    // ==========================================
                    const SizedBox(height: AppSpacing.xs),

                    SizedBox(
                      height: responsive.buttonHeight,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveReceiptSettings,
                        icon: _isSaving
                            ? const SizedBox(
                                width: AppSpacing.lg,
                                height: AppSpacing.lg,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save Receipt Settings',
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.huge),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _footerController.dispose();

    super.dispose();
  }
}

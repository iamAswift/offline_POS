// lib/features/settings/receipt_settings_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../core/business/business_identity.dart';
import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

class ReceiptSettingsScreen extends StatefulWidget {
  final SettingsDao settingsDao;

  const ReceiptSettingsScreen({
    super.key,
    required this.settingsDao,
  });

  @override
  State<ReceiptSettingsScreen> createState() =>
      _ReceiptSettingsScreenState();
}

class _ReceiptSettingsScreenState
    extends State<ReceiptSettingsScreen> {
  // ============================================================
  // RECEIPT SETTINGS CONTROLLERS
  // ============================================================

  final _footerController = TextEditingController();

  // ============================================================
  // BUSINESS IDENTITY
  //
  // IMPORTANT:
  //
  // These values now come from BusinessIdentity.
  // Receipt Settings does NOT maintain another copy.
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

  final List<String> _paperSizes = const [
    '58mm',
    '80mm',
    'A4',
  ];

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
      //
      // Central source of truth.
      // --------------------------------------------------------

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

      // --------------------------------------------------------
      // RECEIPT-SPECIFIC SETTINGS
      // --------------------------------------------------------

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
        // ------------------------------------------------------
        // CENTRAL BUSINESS IDENTITY
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

        _footerController.text =
            footer ?? 'Thank you for your patronage.';

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

        if (paperSize != null &&
            _paperSizes.contains(paperSize)) {
          _paperSize = paperSize;
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load receipt settings: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // BOOLEAN PARSER
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
  // SAVE RECEIPT SETTINGS
  //
  // NOTE:
  //
  // Business identity is NOT saved here.
  //
  // It is saved from Business Profile.
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

      _showMessage(
        'Receipt settings saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save receipt settings: $e',
        isError: true,
      );
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

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.danger : null,
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
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
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
    return Card(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            AppTextStyles.title,
                      ),

                      const SizedBox(height: 3),

                      Text(
                        subtitle,
                        style:
                            AppTextStyles
                                .bodySecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

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

      title: Text(
        title,
        style: AppTextStyles.body,
      ),

      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySecondary,
      ),

      value: value,

      onChanged: onChanged,
    );
  }

  // ============================================================
  // BUSINESS IDENTITY PREVIEW
  // ============================================================

  Widget _buildBusinessIdentityCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: AppColors.border,
        ),
      ),

      child: Column(
        children: [
          // ------------------------------------------------------
          // LOGO
          // ------------------------------------------------------

          _buildBusinessLogo(),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // BUSINESS NAME
          // ------------------------------------------------------

          Text(
            _businessName.isEmpty
                ? 'Business Name'
                : _businessName,

            textAlign: TextAlign.center,

            style: AppTextStyles.title,
          ),

          // ------------------------------------------------------
          // TAGLINE
          // ------------------------------------------------------

          if (_businessTagline.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 4,
              ),

              child: Text(
                _businessTagline,

                textAlign:
                    TextAlign.center,

                style:
                    AppTextStyles
                        .bodySecondary,
              ),
            ),

          const SizedBox(height: 12),

          const Divider(),

          const SizedBox(height: 8),

          // ------------------------------------------------------
          // ADDRESS
          // ------------------------------------------------------

          if (_businessAddress.isNotEmpty)
            _identityRow(
              Icons.location_on_outlined,
              _businessAddress,
            ),

          // ------------------------------------------------------
          // PHONE
          // ------------------------------------------------------

          if (_businessPhone.isNotEmpty)
            _identityRow(
              Icons.phone_outlined,
              _businessPhone,
            ),

          // ------------------------------------------------------
          // EMAIL
          // ------------------------------------------------------

          if (_businessEmail.isNotEmpty)
            _identityRow(
              Icons.email_outlined,
              _businessEmail,
            ),

          // ------------------------------------------------------
          // BUSINESS TYPE
          // ------------------------------------------------------

          if (_businessType.isNotEmpty)
            _identityRow(
              Icons.business_outlined,
              _businessType,
            ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // SOURCE NOTICE
          // ------------------------------------------------------

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(alpha: 0.06),

              borderRadius:
                  BorderRadius.circular(8),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Business information is managed from Business Profile settings.',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey.shade700,
                    ),
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
    if (_businessLogo == null ||
        _businessLogo!.trim().isEmpty) {
      return Container(
        width: 64,
        height: 64,

        decoration: BoxDecoration(
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

    final path = _businessLogo!.trim();

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(10),

      child: Image.file(
        File(path),

        width: 70,
        height: 70,

        fit: BoxFit.contain,

        errorBuilder:
            (_, __, ___) {
          return Container(
            width: 64,
            height: 64,

            decoration: BoxDecoration(
              color:
                  AppColors.primaryLight,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.storefront_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // IDENTITY ROW
  // ============================================================

  Widget _identityRow(
    IconData icon,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),

          const SizedBox(width: 6),

          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.center,
              style:
                  AppTextStyles.small,
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
    final footer =
        _footerController.text.trim();

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,

        borderRadius:
            BorderRadius.circular(8),

        border: Border.all(
          color: AppColors.border,
        ),
      ),

      child: Column(
        children: [
          // ------------------------------------------------------
          // BUSINESS IDENTITY
          // ------------------------------------------------------

          _buildBusinessLogo(),

          const SizedBox(height: 10),

          Text(
            _businessName.isEmpty
                ? 'Business Name'
                : _businessName,

            textAlign: TextAlign.center,

            style: AppTextStyles.title,
          ),

          if (_businessTagline.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 3,
              ),

              child: Text(
                _businessTagline,

                textAlign:
                    TextAlign.center,

                style:
                    AppTextStyles.small,
              ),
            ),

          if (_businessAddress.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 4,
              ),

              child: Text(
                _businessAddress,

                textAlign:
                    TextAlign.center,

                style:
                    AppTextStyles.small,
              ),
            ),

          if (_businessPhone.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 2,
              ),

              child: Text(
                _businessPhone,

                textAlign:
                    TextAlign.center,

                style:
                    AppTextStyles.small,
              ),
            ),

          const Divider(
            height: 24,
          ),

          // ------------------------------------------------------
          // RECEIPT INFORMATION
          // ------------------------------------------------------

          if (_showReceiptNumber)
            _previewRow(
              'Receipt No.',
              '#000001',
            ),

          if (_showReceiptDateTime)
            _previewRow(
              'Date',
              '13/08/2026 13:30',
            ),

          if (_showCashierName)
            _previewRow(
              'Cashier',
              'Staff',
            ),

          const SizedBox(height: 10),

          // ------------------------------------------------------
          // ITEMS
          // ------------------------------------------------------

          _previewItem(
            'Coca Cola 50cl',
            '2 × ₦500',
            '₦1,000',
          ),

          _previewItem(
            'Water 75cl',
            '1 × ₦300',
            '₦300',
          ),

          const Divider(
            height: 24,
          ),

          // ------------------------------------------------------
          // DISCOUNT
          // ------------------------------------------------------

          if (_showReceiptDiscount)
            _previewRow(
              'Discount',
              '₦0',
            ),

          // ------------------------------------------------------
          // TAX
          // ------------------------------------------------------

          if (_showReceiptTax)
            _previewRow(
              'Tax',
              '₦0',
            ),

          // ------------------------------------------------------
          // TOTAL
          // ------------------------------------------------------

          _previewRow(
            'TOTAL',
            '₦1,300',
            bold: true,
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------
          // FOOTER
          // ------------------------------------------------------

          if (footer.isNotEmpty)
            Text(
              footer,

              style:
                  AppTextStyles.small,

              textAlign:
                  TextAlign.center,
            ),

          const SizedBox(height: 8),

          // ------------------------------------------------------
          // PAPER SIZE
          // ------------------------------------------------------

          Text(
            'Paper Size: $_paperSize',

            style:
                AppTextStyles.small,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW ROW
  // ============================================================

  Widget _previewRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    final style = bold
        ? AppTextStyles.title
        : AppTextStyles.bodySecondary;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 2,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [
          Text(
            label,
            style: style,
          ),

          Text(
            value,
            style: style,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW ITEM
  // ============================================================

  Widget _previewItem(
    String name,
    String quantity,
    String total,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  name,
                  style:
                      AppTextStyles.body,
                ),

                const SizedBox(height: 2),

                Text(
                  quantity,
                  style:
                      AppTextStyles.small,
                ),
              ],
            ),
          ),

          Text(
            total,
            style:
                AppTextStyles.price,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Receipt Settings'),

        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 12,
            ),

            child:
                ElevatedButton.icon(
              onPressed: _isSaving
                  ? null
                  : _saveReceiptSettings,

              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,

                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.save,
                    ),

              label:
                  const Text('Save'),
            ),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1000,
                ),

                child: ListView(
                  padding:
                      const EdgeInsets.all(
                    24,
                  ),

                  children: [
                    // ==================================================
                    // BUSINESS IDENTITY
                    // ==================================================

                    _section(
                      title:
                          'Business Identity',
                      subtitle:
                          'This information comes from your Business Profile and is used automatically on receipts.',
                      icon:
                          Icons.business,
                      child:
                          _buildBusinessIdentityCard(),
                    ),

                    // ==================================================
                    // RECEIPT DISPLAY
                    // ==================================================

                    _section(
                      title:
                          'Receipt Information',
                      subtitle:
                          'Choose what information appears on receipts.',
                      icon:
                          Icons.visibility,
                      child: Column(
                        children: [
                          _switchTile(
                            title:
                                'Show Cashier Name',
                            subtitle:
                                'Display the staff member who processed the sale.',
                            value:
                                _showCashierName,
                            onChanged:
                                (value) {
                              setState(() {
                                _showCashierName =
                                    value;
                              });
                            },
                          ),

                          _switchTile(
                            title:
                                'Show Date & Time',
                            subtitle:
                                'Display the transaction date and time.',
                            value:
                                _showReceiptDateTime,
                            onChanged:
                                (value) {
                              setState(() {
                                _showReceiptDateTime =
                                    value;
                              });
                            },
                          ),

                          _switchTile(
                            title:
                                'Show Receipt Number',
                            subtitle:
                                'Display the unique receipt number.',
                            value:
                                _showReceiptNumber,
                            onChanged:
                                (value) {
                              setState(() {
                                _showReceiptNumber =
                                    value;
                              });
                            },
                          ),

                          _switchTile(
                            title:
                                'Show Tax',
                            subtitle:
                                'Display tax information on receipts.',
                            value:
                                _showReceiptTax,
                            onChanged:
                                (value) {
                              setState(() {
                                _showReceiptTax =
                                    value;
                              });
                            },
                          ),

                          _switchTile(
                            title:
                                'Show Discount',
                            subtitle:
                                'Display discount information on receipts.',
                            value:
                                _showReceiptDiscount,
                            onChanged:
                                (value) {
                              setState(() {
                                _showReceiptDiscount =
                                    value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // FOOTER
                    // ==================================================

                    _section(
                      title:
                          'Receipt Footer',
                      subtitle:
                          'Message displayed at the bottom of receipts.',
                      icon:
                          Icons.notes,
                      child:
                          _textField(
                        label:
                            'Footer Message',
                        controller:
                            _footerController,
                        hint:
                            'Thank you for your patronage.',
                        maxLines: 3,
                      ),
                    ),

                    // ==================================================
                    // PAPER
                    // ==================================================

                    _section(
                      title:
                          'Paper & Printing',
                      subtitle:
                          'Configure the receipt paper format.',
                      icon:
                          Icons.print,
                      child:
                          DropdownButtonFormField<
                              String>(
                        initialValue:
                            _paperSize,

                        decoration:
                            const InputDecoration(
                          labelText:
                              'Paper Size',
                        ),

                        items:
                            _paperSizes
                                .map(
                                  (size) =>
                                      DropdownMenuItem<
                                          String>(
                                    value:
                                        size,
                                    child:
                                        Text(
                                      size,
                                    ),
                                  ),
                                )
                                .toList(),

                        onChanged:
                            (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          setState(() {
                            _paperSize =
                                value;
                          });
                        },
                      ),
                    ),

                    // ==================================================
                    // PREVIEW
                    // ==================================================

                    _section(
                      title:
                          'Receipt Preview',
                      subtitle:
                          'Preview how the receipt will look using your current business identity.',
                      icon:
                          Icons.preview,
                      child:
                          _buildReceiptPreview(),
                    ),

                    // ==================================================
                    // SAVE
                    // ==================================================

                    const SizedBox(
                      height: 5,
                    ),

                    SizedBox(
                      height: 52,

                      child:
                          ElevatedButton.icon(
                        onPressed:
                            _isSaving
                                ? null
                                : _saveReceiptSettings,

                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.save,
                              ),

                        label: Text(
                          _isSaving
                              ? 'Saving...'
                              : 'Save Receipt Settings',
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 40,
                    ),
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
// lib/features/settings/pos_settings_screen.dart

import 'package:flutter/material.dart';

import '../../core/pos/pos_settings_service.dart';
import '../../core/theme/styles.dart';
import '../../database/daos/settings_dao.dart';
import '../../models/pos_settings.dart';

class PosSettingsScreen extends StatefulWidget {
  final SettingsDao settingsDao;

  const PosSettingsScreen({
    super.key,
    required this.settingsDao,
  });

  @override
  State<PosSettingsScreen> createState() =>
      _PosSettingsScreenState();
}

class _PosSettingsScreenState extends State<PosSettingsScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _maximumDiscountController =
      TextEditingController();

  // ============================================================
  // SERVICE
  // ============================================================

  late final PosSettingsService _posSettingsService;

  // ============================================================
  // DEFAULT PAYMENT METHOD
  // ============================================================

  String _defaultPaymentMethod = 'cash';

  // ============================================================
  // PAYMENT METHODS
  //
  // Stage 1:
  // Only the three real payment methods are stored here.
  //
  // Split is handled by the POS checkout screen later.
  // ============================================================

  bool _paymentCash = true;
  bool _paymentPos = true;
  bool _paymentTransfer = true;

  // ============================================================
  // CUSTOMER
  // ============================================================

  bool _requireCustomerName = false;
  bool _requireCustomerPhone = false;

  // ============================================================
  // PRICING
  // ============================================================

  bool _allowDiscount = true;
  bool _allowPriceEditing = false;
  bool _requireDiscountApproval = true;

  // ============================================================
  // RECEIPT
  // ============================================================

  bool _automaticallyPrintReceipt = false;

  // ============================================================
  // CUSTOMER DISPLAY
  // ============================================================

  bool _showCustomerDisplay = false;

  String _customerDisplayDevice = 'iPad';

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = true;
  bool _isSaving = false;

  // ============================================================
  // OPTIONS
  // ============================================================

  static const List<String> _paymentMethodOptions = [
    'cash',
    'pos',
    'transfer',
  ];

  static const List<String> _displayDeviceOptions = [
    'iPad',
    'External Display',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _posSettingsService = PosSettingsService(
      settingsDao: widget.settingsDao,
    );

    _loadSettings();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> _loadSettings() async {
    try {
      final PosSettings settings =
          await _posSettingsService.load();

      if (!mounted) return;

      setState(() {
        // --------------------------------------------------------
        // PAYMENT
        // --------------------------------------------------------

        _paymentCash =
            settings.paymentCash;

        _paymentPos =
            settings.paymentPos;

        _paymentTransfer =
            settings.paymentTransfer;

        _defaultPaymentMethod =
            _paymentMethodOptions.contains(
          settings.defaultPaymentMethod,
        )
                ? settings.defaultPaymentMethod
                : _firstEnabledPaymentMethod();

        // --------------------------------------------------------
        // DISCOUNTS / PRICING
        // --------------------------------------------------------

        _allowDiscount =
            settings.allowDiscount;

        _maximumDiscountController.text =
            settings.maximumDiscount.toString();

        _allowPriceEditing =
            settings.allowPriceEditing;

        _requireDiscountApproval =
            settings.requireDiscountApproval;

        // --------------------------------------------------------
        // CUSTOMER
        // --------------------------------------------------------

        _requireCustomerName =
            settings.requireCustomerName;

        _requireCustomerPhone =
            settings.requireCustomerPhone;

        // --------------------------------------------------------
        // RECEIPT
        // --------------------------------------------------------

        _automaticallyPrintReceipt =
            settings.automaticallyPrintReceipt;

        // --------------------------------------------------------
        // CUSTOMER DISPLAY
        // --------------------------------------------------------

        _showCustomerDisplay =
            settings.showCustomerDisplay;

        _customerDisplayDevice =
            _displayDeviceOptions.contains(
          settings.customerDisplayDevice,
        )
                ? settings.customerDisplayDevice
                : 'iPad';

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load POS settings: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  Future<void> _saveSettings() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // --------------------------------------------------------
      // VALIDATE MAXIMUM DISCOUNT
      // --------------------------------------------------------

      final maximumDiscount =
          double.tryParse(
        _maximumDiscountController.text.trim(),
      );

      if (maximumDiscount == null ||
          maximumDiscount < 0 ||
          maximumDiscount > 100) {
        throw Exception(
          'Maximum discount must be between 0% and 100%.',
        );
      }

      // --------------------------------------------------------
      // VALIDATE PAYMENT METHODS
      // --------------------------------------------------------

      if (!_hasPaymentMethodEnabled()) {
        throw Exception(
          'At least one payment method must be enabled.',
        );
      }

      // --------------------------------------------------------
      // VALIDATE DEFAULT PAYMENT METHOD
      // --------------------------------------------------------

      if (!_isPaymentMethodEnabled(
        _defaultPaymentMethod,
      )) {
        throw Exception(
          'The default payment method must be enabled.',
        );
      }

      // --------------------------------------------------------
      // BUILD SETTINGS
      // --------------------------------------------------------

      final settings = PosSettings(
        defaultPaymentMethod:
            _defaultPaymentMethod,

        paymentCash:
            _paymentCash,

        paymentPos:
            _paymentPos,

        paymentTransfer:
            _paymentTransfer,

        allowDiscount:
            _allowDiscount,

        maximumDiscount:
            maximumDiscount,

        allowPriceEditing:
            _allowPriceEditing,

        requireDiscountApproval:
            _requireDiscountApproval,

        requireCustomerName:
            _requireCustomerName,

        requireCustomerPhone:
            _requireCustomerPhone,

        automaticallyPrintReceipt:
            _automaticallyPrintReceipt,

        showCustomerDisplay:
            _showCustomerDisplay,

        customerDisplayDevice:
            _customerDisplayDevice,
      );

      // --------------------------------------------------------
      // VALIDATE MODEL
      // --------------------------------------------------------

      if (!settings.isValid) {
        throw Exception(
          'Invalid POS settings.',
        );
      }

      // --------------------------------------------------------
      // SAVE
      // --------------------------------------------------------

      await _posSettingsService.save(
        settings,
      );

      if (!mounted) return;

      _showMessage(
        'POS settings saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
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
  // PAYMENT METHOD CHECK
  // ============================================================

  bool _isPaymentMethodEnabled(
    String method,
  ) {
    switch (method) {
      case 'cash':
        return _paymentCash;

      case 'pos':
        return _paymentPos;

      case 'transfer':
        return _paymentTransfer;

      default:
        return false;
    }
  }

  // ============================================================
  // PAYMENT METHOD COUNT
  // ============================================================

  bool _hasPaymentMethodEnabled() {
    return _paymentCash ||
        _paymentPos ||
        _paymentTransfer;
  }

  // ============================================================
  // FIRST ENABLED PAYMENT METHOD
  // ============================================================

  String _firstEnabledPaymentMethod() {
    if (_paymentCash) {
      return 'cash';
    }

    if (_paymentPos) {
      return 'pos';
    }

    if (_paymentTransfer) {
      return 'transfer';
    }

    return 'cash';
  }

  // ============================================================
  // HANDLE PAYMENT METHOD CHANGE
  // ============================================================

  void _setPaymentMethodEnabled(
    String method,
    bool enabled,
  ) {
    // ----------------------------------------------------------
    // Prevent disabling the final enabled method.
    // ----------------------------------------------------------

    if (!enabled &&
        _isPaymentMethodEnabled(method) &&
        _enabledPaymentMethodCount() == 1) {
      _showMessage(
        'At least one payment method must remain enabled.',
        isError: true,
      );

      return;
    }

    setState(() {
      switch (method) {
        case 'cash':
          _paymentCash = enabled;
          break;

        case 'pos':
          _paymentPos = enabled;
          break;

        case 'transfer':
          _paymentTransfer = enabled;
          break;
      }

      // --------------------------------------------------------
      // If the current default was disabled, automatically move
      // the default to another enabled payment method.
      // --------------------------------------------------------

      if (!_isPaymentMethodEnabled(
        _defaultPaymentMethod,
      )) {
        _defaultPaymentMethod =
            _firstEnabledPaymentMethod();
      }
    });
  }

  // ============================================================
  // ENABLED PAYMENT METHOD COUNT
  // ============================================================

  int _enabledPaymentMethodCount() {
    int count = 0;

    if (_paymentCash) {
      count++;
    }

    if (_paymentPos) {
      count++;
    }

    if (_paymentTransfer) {
      count++;
    }

    return count;
  }

  // ============================================================
  // DEFAULT PAYMENT CHANGE
  // ============================================================

  void _setDefaultPaymentMethod(
    String? value,
  ) {
    if (value == null) return;

    if (!_isPaymentMethodEnabled(value)) {
      _showMessage(
        'Enable this payment method before making it the default.',
        isError: true,
      );

      return;
    }

    setState(() {
      _defaultPaymentMethod = value;
    });
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
  // SWITCH TILE
  // ============================================================

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
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
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
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
                    color:
                        AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color:
                        AppColors.primary,
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
                      const SizedBox(
                        height: 3,
                      ),
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
  // PAYMENT METHOD TILE
  // ============================================================

  Widget _paymentMethodTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      elevation: 0,
      color: AppColors.surfaceSoft,
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        secondary: Icon(
          icon,
          color: AppColors.primary,
        ),
        title: Text(
          title,
          style: AppTextStyles.body,
        ),
        subtitle: Text(
          subtitle,
          style:
              AppTextStyles.bodySecondary,
        ),
        value: value,
        onChanged: onChanged,
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
        title: const Text(
          'POS / Sales Settings',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 12,
            ),
            child: ElevatedButton.icon(
              onPressed:
                  _isSaving
                      ? null
                      : _saveSettings,
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
              label: const Text(
                'Save',
              ),
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
                  maxWidth: 900,
                ),
                child: ListView(
                  padding:
                      AppTextStyles.screenPadding,
                  children: [
                    // ==================================================
                    // INTRO
                    // ==================================================

                    Card(
                      color:
                          AppColors.infoLight,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color:
                                  AppColors.info,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Text(
                                'Configure how the point-of-sale '
                                'screen handles payments, discounts, '
                                'customers, receipts and customer-facing displays.',
                                style:
                                    AppTextStyles
                                        .bodySecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // DEFAULT PAYMENT
                    // ==================================================

                    _sectionCard(
                      title:
                          'Default Payment',
                      subtitle:
                          'Choose the payment method selected by default at checkout.',
                      icon:
                          Icons.payments,
                      child:
                          DropdownButtonFormField<
                              String>(
                        initialValue:
                            _defaultPaymentMethod,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Default Payment Method',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'cash',
                            child:
                                Text('Cash'),
                          ),
                          DropdownMenuItem(
                            value: 'pos',
                            child:
                                Text('POS'),
                          ),
                          DropdownMenuItem(
                            value: 'transfer',
                            child: Text(
                              'Bank Transfer',
                            ),
                          ),
                        ],
                        onChanged:
                            _setDefaultPaymentMethod,
                      ),
                    ),

                    // ==================================================
                    // PAYMENT METHODS
                    // ==================================================

                    _sectionCard(
                      title:
                          'Payment Methods',
                      subtitle:
                          'Choose which payment methods are available at checkout.',
                      icon:
                          Icons.account_balance_wallet,
                      child: Column(
                        children: [
                          _paymentMethodTile(
                            title: 'Cash',
                            subtitle:
                                'Allow customers to pay with cash.',
                            icon:
                                Icons.money,
                            value:
                                _paymentCash,
                            onChanged:
                                (value) {
                              _setPaymentMethodEnabled(
                                'cash',
                                value,
                              );
                            },
                          ),

                          _paymentMethodTile(
                            title: 'POS',
                            subtitle:
                                'Allow card payments through a POS terminal.',
                            icon:
                                Icons.credit_card,
                            value:
                                _paymentPos,
                            onChanged:
                                (value) {
                              _setPaymentMethodEnabled(
                                'pos',
                                value,
                              );
                            },
                          ),

                          _paymentMethodTile(
                            title:
                                'Bank Transfer',
                            subtitle:
                                'Allow customers to pay by bank transfer.',
                            icon:
                                Icons.account_balance,
                            value:
                                _paymentTransfer,
                            onChanged:
                                (value) {
                              _setPaymentMethodEnabled(
                                'transfer',
                                value,
                              );
                            },
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Container(
                            padding:
                                const EdgeInsets.all(
                              12,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  AppColors.infoLight,
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Icon(
                                  Icons
                                      .call_split,
                                  size: 20,
                                  color:
                                      AppColors.info,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    'Split payments are handled directly on the sales screen using the enabled payment methods.',
                                    style:
                                        AppTextStyles
                                            .bodySecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // DISCOUNTS & PRICING
                    // ==================================================

                    _sectionCard(
                      title:
                          'Discounts & Pricing',
                      subtitle:
                          'Control discounts and manual price changes at checkout.',
                      icon:
                          Icons.discount,
                      child: Column(
                        children: [
                          _switchTile(
                            title:
                                'Allow Discounts',
                            subtitle:
                                'Allow staff to apply discounts during sales.',
                            value:
                                _allowDiscount,
                            onChanged:
                                (value) {
                              setState(() {
                                _allowDiscount =
                                    value;
                              });
                            },
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          TextField(
                            controller:
                                _maximumDiscountController,
                            enabled:
                                _allowDiscount,
                            keyboardType:
                                const TextInputType
                                    .numberWithOptions(
                              decimal: true,
                            ),
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Maximum Discount',
                              suffixText:
                                  '%',
                              hintText:
                                  '20',
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          _switchTile(
                            title:
                                'Require Discount Approval',
                            subtitle:
                                'Require approval before applying a discount.',
                            value:
                                _requireDiscountApproval,
                            onChanged:
                                _allowDiscount
                                    ? (value) {
                                        setState(
                                          () {
                                            _requireDiscountApproval =
                                                value;
                                          },
                                        );
                                      }
                                    : null,
                          ),

                          _switchTile(
                            title:
                                'Allow Price Editing',
                            subtitle:
                                'Allow the cashier to manually change a product price during checkout.',
                            value:
                                _allowPriceEditing,
                            onChanged:
                                (value) {
                              setState(() {
                                _allowPriceEditing =
                                    value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // CUSTOMER INFORMATION
                    // ==================================================

                    _sectionCard(
                      title:
                          'Customer Information',
                      subtitle:
                          'Control customer information collected during sales.',
                      icon:
                          Icons.person,
                      child: Column(
                        children: [
                          _switchTile(
                            title:
                                'Require Customer Name',
                            subtitle:
                                'Require a customer name before completing a sale.',
                            value:
                                _requireCustomerName,
                            onChanged:
                                (value) {
                              setState(() {
                                _requireCustomerName =
                                    value;
                              });
                            },
                          ),

                          _switchTile(
                            title:
                                'Require Customer Phone',
                            subtitle:
                                'Require a customer phone number before completing a sale.',
                            value:
                                _requireCustomerPhone,
                            onChanged:
                                (value) {
                              setState(() {
                                _requireCustomerPhone =
                                    value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // RECEIPTS
                    // ==================================================

                    _sectionCard(
                      title:
                          'Receipt Printing',
                      subtitle:
                          'Control how receipts are produced after sales.',
                      icon:
                          Icons.print,
                      child: _switchTile(
                        title:
                            'Automatically Print Receipt',
                        subtitle:
                            'Automatically send the receipt to the configured printer after a successful sale.',
                        value:
                            _automaticallyPrintReceipt,
                        onChanged:
                            (value) {
                          setState(() {
                            _automaticallyPrintReceipt =
                                value;
                          });
                        },
                      ),
                    ),

                    // ==================================================
                    // CUSTOMER DISPLAY
                    // ==================================================

                    _sectionCard(
                      title:
                          'Customer Display',
                      subtitle:
                          'Configure a screen that shows checkout information to the customer.',
                      icon:
                          Icons.desktop_mac,
                      child: Column(
                        children: [
                          _switchTile(
                            title:
                                'Show Customer Display',
                            subtitle:
                                'Enable a customer-facing display during checkout.',
                            value:
                                _showCustomerDisplay,
                            onChanged:
                                (value) {
                              setState(() {
                                _showCustomerDisplay =
                                    value;
                              });
                            },
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          DropdownButtonFormField<
                              String>(
                            initialValue:
                                _customerDisplayDevice,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Display Device',
                            ),
                            items:
                                _displayDeviceOptions
                                    .map(
                                      (
                                        device,
                                      ) =>
                                          DropdownMenuItem<
                                              String>(
                                        value:
                                            device,
                                        child:
                                            Text(
                                          device,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                _showCustomerDisplay
                                    ? (value) {
                                        if (value ==
                                            null) {
                                          return;
                                        }

                                        setState(
                                          () {
                                            _customerDisplayDevice =
                                                value;
                                          },
                                        );
                                      }
                                    : null,
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // SAVE
                    // ==================================================

                    const SizedBox(
                      height: 10,
                    ),

                    SizedBox(
                      height: 52,
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            _isSaving
                                ? null
                                : _saveSettings,
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
                              : 'Save POS Settings',
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
    _maximumDiscountController.dispose();

    super.dispose();
  }
}
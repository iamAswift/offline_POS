// lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:supermarket_inventory/features/reports/reports_dashboard.dart';

import '../../core/theme/styles.dart';
import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

import 'appearance_settings_screen.dart';
import 'business_profile_screen.dart';
import 'pos_settings_screen.dart';
import 'receipt_settings_screen.dart';
import 'security_settings_screen.dart';
import 'reports_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsDao settingsDao;

  const SettingsScreen({
    super.key,
    required this.settingsDao,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ============================================================
  // CURRENCY
  // ============================================================

  final _currencyController = TextEditingController();
  final _currencyCodeController = TextEditingController();
  final _decimalPlacesController = TextEditingController();

  // ============================================================
  // INVENTORY
  // ============================================================

  final _lowStockController = TextEditingController();

  // ============================================================
  // STAFF DEBT
  // ============================================================

  final _maxStaffDebtController = TextEditingController();

  // ============================================================
  // CURRENCY POSITION
  // ============================================================

  String _currencyPosition = 'before';

  // ============================================================
  // INVENTORY OPTIONS
  // ============================================================

  bool _allowNegativeStock = false;

  bool _requireBarcode = false;

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = true;

  bool _isSaving = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  // ============================================================
  // OPEN BUSINESS PROFILE
  // ============================================================

  void _openBusinessProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BusinessProfileScreen(
          settingsDao: widget.settingsDao,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN POS SETTINGS
  // ============================================================

  void _openPosSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PosSettingsScreen(
          settingsDao: widget.settingsDao,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN RECEIPT SETTINGS
  // ============================================================

  void _openReceiptSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReceiptSettingsScreen(
          settingsDao: widget.settingsDao,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN APPEARANCE SETTINGS
  // ============================================================

  void _openAppearanceSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppearanceSettingsScreen(
          settingsDao: widget.settingsDao,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN SECURITY SETTINGS
  // ============================================================

  void _openSecuritySettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SecuritySettingsScreen(
          settingsDao: widget.settingsDao,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN REPORTS SETTINGS
  // ============================================================

  void _openReportsSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportsSettingsScreen(
          settingsDao: widget.settingsDao,
        ),
      ),
    );
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> _loadSettings() async {
    try {
      // --------------------------------------------------------
      // CURRENCY
      // --------------------------------------------------------

      final currency =
          await widget.settingsDao.getSetting(
                BusinessSettings.currency,
              ) ??
              '₦';

      final currencyCode =
          await widget.settingsDao.getSetting(
                BusinessSettings.currencyCode,
              ) ??
              'NGN';

      final decimalPlaces =
          await widget.settingsDao.getIntSetting(
                BusinessSettings.decimalPlaces,
              ) ??
              0;

      final currencyPosition =
          await widget.settingsDao.getSetting(
                BusinessSettings.currencyPosition,
              ) ??
              'before';

      // --------------------------------------------------------
      // INVENTORY
      // --------------------------------------------------------

      final lowStock =
          await widget.settingsDao.getIntSetting(
                BusinessSettings.lowStockThreshold,
              ) ??
              10;

      final allowNegative =
          await widget.settingsDao.getSetting(
                BusinessSettings.allowNegativeStock,
              ) ??
              'false';

      final requireBarcode =
          await widget.settingsDao.getSetting(
                BusinessSettings.requireBarcode,
              ) ??
              'false';

      // --------------------------------------------------------
      // STAFF DEBT
      // --------------------------------------------------------

      final maxDebt =
          await widget.settingsDao.getDoubleSetting(
                BusinessSettings.maxStaffDebt,
              ) ??
              50000;

      if (!mounted) return;

      setState(() {
        // Currency
        _currencyController.text = currency;

        _currencyCodeController.text = currencyCode;

        _decimalPlacesController.text =
            decimalPlaces.toString();

        _currencyPosition = currencyPosition;

        // Inventory
        _lowStockController.text =
            lowStock.toString();

        _allowNegativeStock =
            allowNegative == 'true';

        _requireBarcode =
            requireBarcode == 'true';

        // Staff Debt
        _maxStaffDebtController.text =
            maxDebt.toStringAsFixed(0);

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load settings: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SAVE SETTINGS
  //
  // IMPORTANT:
  // Only settings that still belong on this main screen
  // are saved here.
  //
  // POS -> pos_settings_screen.dart
  // RECEIPTS -> receipt_settings_screen.dart
  // APPEARANCE -> appearance_settings_screen.dart
  // SECURITY -> security_settings_screen.dart
  // ============================================================

  Future<void> _saveSettings() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // ========================================================
      // VALIDATE CURRENCY
      // ========================================================

      final currency =
          _currencyController.text.trim();

      if (currency.isEmpty) {
        throw Exception(
          'Currency symbol cannot be empty.',
        );
      }

      final currencyCode =
          _currencyCodeController.text
              .trim()
              .toUpperCase();

      if (currencyCode.isEmpty) {
        throw Exception(
          'Currency code cannot be empty.',
        );
      }

      final decimalPlaces =
          int.tryParse(
        _decimalPlacesController.text.trim(),
      );

      if (decimalPlaces == null ||
          decimalPlaces < 0 ||
          decimalPlaces > 4) {
        throw Exception(
          'Decimal places must be between 0 and 4.',
        );
      }

      // ========================================================
      // VALIDATE LOW STOCK
      // ========================================================

      final lowStock =
          int.tryParse(
        _lowStockController.text.trim(),
      );

      if (lowStock == null || lowStock < 0) {
        throw Exception(
          'Low stock threshold must be a valid number.',
        );
      }

      // ========================================================
      // VALIDATE STAFF DEBT
      // ========================================================

      final maxStaffDebt =
          double.tryParse(
        _maxStaffDebtController.text.trim(),
      );

      if (maxStaffDebt == null ||
          maxStaffDebt < 0) {
        throw Exception(
          'Maximum staff debt must be a valid amount.',
        );
      }

      // ========================================================
      // CURRENCY & PRICING
      // ========================================================

      await widget.settingsDao.setSetting(
        BusinessSettings.currency,
        currency,
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.currencyCode,
        currencyCode,
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.decimalPlaces,
        decimalPlaces.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.currencyPosition,
        _currencyPosition,
      );

      // ========================================================
      // INVENTORY
      // ========================================================

      await widget.settingsDao.setSetting(
        BusinessSettings.lowStockThreshold,
        lowStock.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.allowNegativeStock,
        _allowNegativeStock.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.requireBarcode,
        _requireBarcode.toString(),
      );

      // ========================================================
      // STAFF DEBT
      // ========================================================

      await widget.settingsDao.setSetting(
        BusinessSettings.maxStaffDebt,
        maxStaffDebt.toString(),
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Settings saved successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
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
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? prefixText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefixText,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
                Icon(
                  icon,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.title,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SWITCH
  // ============================================================

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  // ============================================================
  // NAVIGATION CARD
  // ============================================================

  Widget _navigationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? iconBackground,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color:
                iconBackground ??
                AppColors.primaryLight,
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color:
                iconColor ??
                AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.title,
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySecondary,
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
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
        title: const Text('Settings'),
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
                      ),
                    )
                  : const Icon(
                      Icons.save,
                    ),
              label: const Text('Save'),
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
                      const EdgeInsets.all(24),
                  children: [

                    // ==================================================
                    // SETTINGS NAVIGATION
                    // ==================================================

                    _navigationCard(
                      icon: Icons.business,
                      title: 'Business Profile',
                      subtitle:
                          'Business name, contact information, '
                          'type and business details',
                      onTap:
                          _openBusinessProfile,
                    ),

                    // ==================================================
                    // POS / SALES
                    // ==================================================

                    _navigationCard(
                      icon: Icons.point_of_sale,
                      title: 'POS / Sales',
                      subtitle:
                          'Payments, discounts, customers, '
                          'price editing and customer display',
                      onTap:
                          _openPosSettings,
                    ),

                    // ==================================================
                    // RECEIPTS
                    // ==================================================

                    _navigationCard(
                      icon: Icons.receipt_long,
                      title: 'Receipt Settings',
                      subtitle:
                          'Receipt information, printing, '
                          'paper size and preview',
                      onTap:
                          _openReceiptSettings,
                    ),

                    // ============================================================
                    // REPORTS
                    // ============================================================

                    _navigationCard(
                      icon: Icons.analytics_outlined,
                      title: 'Reports',
                      subtitle:
                          'Default period, dashboard cards, charts '
                          'and PDF export preferences',
                      onTap:
                          _openReportsSettings,
                    ),

                    // ==================================================
                    // APPEARANCE
                    // ==================================================

                    _navigationCard(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      subtitle:
                          'Theme, colors, POS buttons, '
                          'images and layout',
                      onTap:
                          _openAppearanceSettings,
                    ),

                    // ==================================================
                    // SECURITY
                    // ==================================================

                    _navigationCard(
                      icon: Icons.security,
                      title: 'Security',
                      subtitle:
                          'Login, automatic logout '
                          'and protected actions',
                      onTap:
                          _openSecuritySettings,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================================================
                    // CURRENCY & PRICING
                    // ==================================================

                    _section(
                      title:
                          'Currency & Pricing',
                      icon:
                          Icons.payments,
                      children: [

                        _textField(
                          label:
                              'Currency Symbol',
                          controller:
                              _currencyController,
                          hint: '₦',
                        ),

                        _textField(
                          label:
                              'Currency Code',
                          controller:
                              _currencyCodeController,
                          hint: 'NGN',
                        ),

                        _textField(
                          label:
                              'Decimal Places',
                          controller:
                              _decimalPlacesController,
                          keyboardType:
                              TextInputType
                                  .number,
                          hint: '0',
                        ),

                        DropdownButtonFormField<
                            String>(
                          initialValue:
                              _currencyPosition,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Currency Position',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'before',
                              child: Text(
                                'Before amount — ₦1,000',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'after',
                              child: Text(
                                'After amount — 1,000 ₦',
                              ),
                            ),
                          ],
                          onChanged:
                              (value) {
                            if (value ==
                                null) {
                              return;
                            }

                            setState(() {
                              _currencyPosition =
                                  value;
                            });
                          },
                        ),
                      ],
                    ),

                    // ==================================================
                    // INVENTORY
                    // ==================================================

                    _section(
                      title: 'Inventory',
                      icon:
                          Icons.inventory_2,
                      children: [

                        _textField(
                          label:
                              'Low Stock Threshold',
                          controller:
                              _lowStockController,
                          keyboardType:
                              TextInputType
                                  .number,
                          hint: '10',
                        ),

                        _switchTile(
                          title:
                              'Allow Negative Stock',
                          subtitle:
                              'Allow sales even when available '
                              'stock reaches zero.',
                          value:
                              _allowNegativeStock,
                          onChanged:
                              (value) {
                            setState(() {
                              _allowNegativeStock =
                                  value;
                            });
                          },
                        ),

                        _switchTile(
                          title:
                              'Require Barcode',
                          subtitle:
                              'Require products to have a barcode.',
                          value:
                              _requireBarcode,
                          onChanged:
                              (value) {
                            setState(() {
                              _requireBarcode =
                                  value;
                            });
                          },
                        ),
                      ],
                    ),

                    // ==================================================
                    // STAFF & DEBT
                    // ==================================================

                    _section(
                      title:
                          'Staff & Debt',
                      icon:
                          Icons.people_alt,
                      children: [

                        _textField(
                          label:
                              'Maximum Staff Debt',
                          controller:
                              _maxStaffDebtController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          hint:
                              '50000',
                          prefixText:
                              '₦ ',
                        ),

                        const Text(
                          'This is the maximum outstanding '
                          'credit a staff member can have '
                          'at one time.',
                          style:
                              AppTextStyles.bodySecondary,
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          'Current default: ₦50,000',
                          style:
                              AppTextStyles.small
                                  .copyWith(
                            color:
                                Theme.of(
                              context,
                            )
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    // ==================================================
                    // FUTURE SETTINGS
                    // ==================================================

                    _navigationCard(
                      icon:
                          Icons.bar_chart,
                      title: 'Reports',
                      subtitle:
                          'Sales, inventory, profit and performance reports',
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(
                          MaterialPageRoute(
                            builder: (_) =>  ReportsSettingsScreen(
                              settingsDao: widget.settingsDao,
                            )
                          ),
                        );
                      },
                      iconColor:
                          AppColors.info,
                      iconBackground:
                          AppColors.infoLight,
                    ),

                    _navigationCard(
                      icon:
                          Icons.backup,
                      title: 'Backup & Data',
                      subtitle:
                          'Backup, restore and manage application data',
                      onTap: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Backup & Data will be available in a later phase.',
                            ),
                          ),
                        );
                      },
                    ),

                    _navigationCard(
                      icon:
                          Icons.info_outline,
                      title:
                          'About / System Information',
                      subtitle:
                          'Application version, database and system information',
                      onTap: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'About / System Information will be available in a later phase.',
                            ),
                          ),
                        );
                      },
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
                                ),
                              )
                            : const Icon(
                                Icons.save,
                              ),
                        label: Text(
                          _isSaving
                              ? 'Saving...'
                              : 'Save Settings',
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
    _currencyController.dispose();
    _currencyCodeController.dispose();
    _decimalPlacesController.dispose();
    _lowStockController.dispose();
    _maxStaffDebtController.dispose();

    super.dispose();
  }
}
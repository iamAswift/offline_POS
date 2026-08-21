// lib/features/settings/security_settings_screen.dart

import 'package:flutter/material.dart';

import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';
import '../../core/theme/styles.dart';

class SecuritySettingsScreen extends StatefulWidget {
  final SettingsDao settingsDao;

  const SecuritySettingsScreen({
    super.key,
    required this.settingsDao,
  });

  @override
  State<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends State<SecuritySettingsScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _logoutAfterController =
      TextEditingController();

  // ============================================================
  // SECURITY SETTINGS
  // ============================================================

  bool _requireLogin = true;

  bool _autoLogout = true;

  bool _requirePasswordStockAdjustment = true;

  bool _requirePasswordDeleteProduct = true;

  bool _requirePasswordCancelSale = true;

  bool _requirePasswordLargeDiscount = true;

  bool _requirePasswordChangeStaffDebtLimit = true;

  bool _requirePasswordViewProfit = true;

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
  // BOOLEAN HELPER
  // ============================================================

  bool _parseBool(
    String? value,
    bool defaultValue,
  ) {
    if (value == null) {
      return defaultValue;
    }

    return value.toLowerCase() == 'true';
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> _loadSettings() async {
    try {
      final requireLogin =
          await widget.settingsDao.getSetting(
                BusinessSettings.requireLogin,
              ) ??
              'true';

      final autoLogout =
          await widget.settingsDao.getSetting(
                BusinessSettings.autoLogout,
              ) ??
              'true';

      final logoutAfterMinutes =
          await widget.settingsDao.getSetting(
                BusinessSettings.logoutAfterMinutes,
              ) ??
              '15';

      final passwordStockAdjustment =
          await widget.settingsDao.getSetting(
                BusinessSettings
                    .requirePasswordStockAdjustment,
              ) ??
              'true';

      final passwordDeleteProduct =
          await widget.settingsDao.getSetting(
                BusinessSettings
                    .requirePasswordDeleteProduct,
              ) ??
              'true';

      final passwordCancelSale =
          await widget.settingsDao.getSetting(
                BusinessSettings
                    .requirePasswordCancelSale,
              ) ??
              'true';

      final passwordLargeDiscount =
          await widget.settingsDao.getSetting(
                BusinessSettings
                    .requirePasswordLargeDiscount,
              ) ??
              'true';

      final passwordStaffDebtLimit =
          await widget.settingsDao.getSetting(
                BusinessSettings
                    .requirePasswordChangeStaffDebtLimit,
              ) ??
              'true';

      final passwordViewProfit =
          await widget.settingsDao.getSetting(
                BusinessSettings
                    .requirePasswordViewProfit,
              ) ??
              'true';

      if (!mounted) {
        return;
      }

      setState(() {
        _requireLogin = _parseBool(
          requireLogin,
          true,
        );

        _autoLogout = _parseBool(
          autoLogout,
          true,
        );

        _logoutAfterController.text =
            logoutAfterMinutes;

        _requirePasswordStockAdjustment =
            _parseBool(
          passwordStockAdjustment,
          true,
        );

        _requirePasswordDeleteProduct =
            _parseBool(
          passwordDeleteProduct,
          true,
        );

        _requirePasswordCancelSale =
            _parseBool(
          passwordCancelSale,
          true,
        );

        _requirePasswordLargeDiscount =
            _parseBool(
          passwordLargeDiscount,
          true,
        );

        _requirePasswordChangeStaffDebtLimit =
            _parseBool(
          passwordStaffDebtLimit,
          true,
        );

        _requirePasswordViewProfit =
            _parseBool(
          passwordViewProfit,
          true,
        );

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load security settings: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  Future<void> _saveSettings() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final logoutMinutes = int.tryParse(
        _logoutAfterController.text.trim(),
      );

      if (logoutMinutes == null ||
          logoutMinutes < 1) {
        throw Exception(
          'Logout time must be at least 1 minute.',
        );
      }

      if (logoutMinutes > 1440) {
        throw Exception(
          'Logout time cannot exceed 1440 minutes.',
        );
      }

      // --------------------------------------------------------
      // LOGIN
      // --------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.requireLogin,
        _requireLogin.toString(),
      );

      // --------------------------------------------------------
      // AUTO LOGOUT
      // --------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.autoLogout,
        _autoLogout.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.logoutAfterMinutes,
        logoutMinutes.toString(),
      );

      // --------------------------------------------------------
      // PASSWORD PROTECTION
      // --------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings
            .requirePasswordStockAdjustment,
        _requirePasswordStockAdjustment.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings
            .requirePasswordDeleteProduct,
        _requirePasswordDeleteProduct.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings
            .requirePasswordCancelSale,
        _requirePasswordCancelSale.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings
            .requirePasswordLargeDiscount,
        _requirePasswordLargeDiscount.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings
            .requirePasswordChangeStaffDebtLimit,
        _requirePasswordChangeStaffDebtLimit
            .toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings
            .requirePasswordViewProfit,
        _requirePasswordViewProfit.toString(),
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Security settings saved successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

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
  // SECTION
  // ============================================================

  Widget _section({
    required String title,
    required String subtitle,
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
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:
                        AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.security,
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
            ...children,
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
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
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
          'Security Settings',
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
                    // LOGIN & SESSION
                    // ==================================================

                    _section(
                      title: 'Login & Session',
                      subtitle:
                          'Control how users access and remain logged into the system.',
                      icon: Icons.lock,
                      children: [
                        _switchTile(
                          title:
                              'Require Login',
                          subtitle:
                              'Require users to sign in before accessing the application.',
                          value:
                              _requireLogin,
                          onChanged: (value) {
                            setState(() {
                              _requireLogin =
                                  value;
                            });
                          },
                        ),

                        _switchTile(
                          title:
                              'Automatic Logout',
                          subtitle:
                              'Automatically log out inactive users.',
                          value:
                              _autoLogout,
                          onChanged:
                              _requireLogin
                                  ? (value) {
                                      setState(() {
                                        _autoLogout =
                                            value;
                                      });
                                    }
                                  : (_) {},
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        TextField(
                          controller:
                              _logoutAfterController,
                          enabled:
                              _requireLogin &&
                                  _autoLogout,
                          keyboardType:
                              TextInputType.number,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Logout After',
                            suffixText:
                                'minutes',
                            hintText:
                                '15',
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          'Recommended: 15 minutes for shared POS devices.',
                          style:
                              AppTextStyles
                                  .bodySecondary,
                        ),
                      ],
                    ),

                    // ==================================================
                    // PROTECTED ACTIONS
                    // ==================================================

                    _section(
                      title:
                          'Protected Actions',
                      subtitle:
                          'Require authentication before performing sensitive operations.',
                      icon:
                          Icons.admin_panel_settings,
                      children: [
                        _switchTile(
                          title:
                              'Stock Adjustment',
                          subtitle:
                              'Require a password before changing inventory quantities.',
                          value:
                              _requirePasswordStockAdjustment,
                          onChanged: (value) {
                            setState(() {
                              _requirePasswordStockAdjustment =
                                  value;
                            });
                          },
                        ),

                        const Divider(),

                        _switchTile(
                          title:
                              'Delete Product',
                          subtitle:
                              'Require a password before deleting a product.',
                          value:
                              _requirePasswordDeleteProduct,
                          onChanged: (value) {
                            setState(() {
                              _requirePasswordDeleteProduct =
                                  value;
                            });
                          },
                        ),

                        const Divider(),

                        _switchTile(
                          title:
                              'Cancel Sale',
                          subtitle:
                              'Require a password before cancelling or reversing a sale.',
                          value:
                              _requirePasswordCancelSale,
                          onChanged: (value) {
                            setState(() {
                              _requirePasswordCancelSale =
                                  value;
                            });
                          },
                        ),

                        const Divider(),

                        _switchTile(
                          title:
                              'Large Discount',
                          subtitle:
                              'Require a password before applying discounts that require approval.',
                          value:
                              _requirePasswordLargeDiscount,
                          onChanged: (value) {
                            setState(() {
                              _requirePasswordLargeDiscount =
                                  value;
                            });
                          },
                        ),

                        const Divider(),

                        _switchTile(
                          title:
                              'Change Staff Debt Limit',
                          subtitle:
                              'Require a password before changing the staff debt limit.',
                          value:
                              _requirePasswordChangeStaffDebtLimit,
                          onChanged: (value) {
                            setState(() {
                              _requirePasswordChangeStaffDebtLimit =
                                  value;
                            });
                          },
                        ),

                        const Divider(),

                        _switchTile(
                          title:
                              'View Profit',
                          subtitle:
                              'Require authentication before viewing sensitive profit information.',
                          value:
                              _requirePasswordViewProfit,
                          onChanged: (value) {
                            setState(() {
                              _requirePasswordViewProfit =
                                  value;
                            });
                          },
                        ),
                      ],
                    ),

                    // ==================================================
                    // SECURITY INFORMATION
                    // ==================================================

                    Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 20,
                      ),
                      color:
                          AppColors.infoLight,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          18,
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
                                'These settings control security preferences. '
                                'The protected-action settings will be enforced '
                                'by the corresponding application features.',
                                style:
                                    AppTextStyles
                                        .bodySecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ==================================================
                    // SAVE
                    // ==================================================

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
                                  strokeWidth: 2,
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
                              : 'Save Security Settings',
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
    _logoutAfterController.dispose();

    super.dispose();
  }
}
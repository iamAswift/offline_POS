// lib/features/settings/security_settings_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

class SecuritySettingsScreen extends StatefulWidget {
  final SettingsDao settingsDao;

  const SecuritySettingsScreen({super.key, required this.settingsDao});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _logoutAfterController = TextEditingController();

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

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = true;

  bool _isSaving = false;

  // ============================================================
  // RESPONSIVE HELPERS
  // ============================================================

  bool _isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 700;
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 560;
  }

  double _contentHorizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 560) {
      return 16;
    }

    if (width < 900) {
      return 24;
    }

    return 32;
  }

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

  bool _parseBool(String? value, bool defaultValue) {
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
          await widget.settingsDao.getSetting(BusinessSettings.requireLogin) ??
          'true';

      final autoLogout =
          await widget.settingsDao.getSetting(BusinessSettings.autoLogout) ??
          'true';

      final logoutAfterMinutes =
          await widget.settingsDao.getSetting(
            BusinessSettings.logoutAfterMinutes,
          ) ??
          '15';

      final passwordStockAdjustment =
          await widget.settingsDao.getSetting(
            BusinessSettings.requirePasswordStockAdjustment,
          ) ??
          'true';

      final passwordDeleteProduct =
          await widget.settingsDao.getSetting(
            BusinessSettings.requirePasswordDeleteProduct,
          ) ??
          'true';

      final passwordCancelSale =
          await widget.settingsDao.getSetting(
            BusinessSettings.requirePasswordCancelSale,
          ) ??
          'true';

      final passwordLargeDiscount =
          await widget.settingsDao.getSetting(
            BusinessSettings.requirePasswordLargeDiscount,
          ) ??
          'true';

      final passwordStaffDebtLimit =
          await widget.settingsDao.getSetting(
            BusinessSettings.requirePasswordChangeStaffDebtLimit,
          ) ??
          'true';

      final passwordViewProfit =
          await widget.settingsDao.getSetting(
            BusinessSettings.requirePasswordViewProfit,
          ) ??
          'true';

      if (!mounted) {
        return;
      }

      setState(() {
        _requireLogin = _parseBool(requireLogin, true);

        _autoLogout = _parseBool(autoLogout, true);

        _logoutAfterController.text = logoutAfterMinutes;

        _requirePasswordStockAdjustment = _parseBool(
          passwordStockAdjustment,
          true,
        );

        _requirePasswordDeleteProduct = _parseBool(passwordDeleteProduct, true);

        _requirePasswordCancelSale = _parseBool(passwordCancelSale, true);

        _requirePasswordLargeDiscount = _parseBool(passwordLargeDiscount, true);

        _requirePasswordChangeStaffDebtLimit = _parseBool(
          passwordStaffDebtLimit,
          true,
        );

        _requirePasswordViewProfit = _parseBool(passwordViewProfit, true);

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage('Failed to load security settings: $e', isError: true);
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
      final logoutMinutes = int.tryParse(_logoutAfterController.text.trim());

      if (logoutMinutes == null || logoutMinutes < 1) {
        throw Exception('Logout time must be at least 1 minute.');
      }

      if (logoutMinutes > 1440) {
        throw Exception('Logout time cannot exceed 1440 minutes.');
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
        BusinessSettings.requirePasswordStockAdjustment,
        _requirePasswordStockAdjustment.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.requirePasswordDeleteProduct,
        _requirePasswordDeleteProduct.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.requirePasswordCancelSale,
        _requirePasswordCancelSale.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.requirePasswordLargeDiscount,
        _requirePasswordLargeDiscount.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.requirePasswordChangeStaffDebtLimit,
        _requirePasswordChangeStaffDebtLimit.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.requirePasswordViewProfit,
        _requirePasswordViewProfit.toString(),
      );

      if (!mounted) {
        return;
      }

      _showMessage('Security settings saved successfully.');
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : null,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
          horizontal: _isMobile(context) ? 12 : 24,
          vertical: 16,
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
    required List<Widget> children,
  }) {
    final compact = _isCompact(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title: title, subtitle: subtitle, icon: icon),

            SizedBox(height: compact ? 16 : 20),

            ...children,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final compact = _isCompact(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: compact ? 40 : 44,
          height: compact ? 40 : 44,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
          ),
          child: Icon(icon, size: compact ? 21 : 23, color: AppColors.primary),
        ),

        SizedBox(width: compact ? 10 : 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.title),

              const SizedBox(height: 4),

              Text(subtitle, style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ],
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
    final compact = _isCompact(context);

    return SwitchListTile(
      contentPadding: EdgeInsets.symmetric(vertical: compact ? 2 : 4),
      title: Text(title, style: AppTextStyles.body),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(subtitle, style: AppTextStyles.bodySecondary),
      ),
      value: value,
      onChanged: onChanged,
      dense: compact,
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _sectionDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  // ============================================================
  // LOGOUT FIELD
  // ============================================================

  Widget _logoutField() {
    final enabled = _requireLogin && _autoLogout;

    return TextField(
      controller: _logoutAfterController,
      enabled: enabled,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Logout After',
        hintText: '15',
        suffixText: 'minutes',
        prefixIcon: const Icon(Icons.timer_outlined),
        helperText: 'Recommended: 15 minutes for shared POS devices.',
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _informationCard() {
    final compact = _isCompact(context);

    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: AppColors.infoLight,
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: compact ? 36 : 40,
              height: compact ? 36 : 40,
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline, color: AppColors.info),
            ),

            SizedBox(width: compact ? 10 : 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security preferences',
                    style: AppTextStyles.title.copyWith(color: AppColors.info),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'These settings control security preferences. '
                    'Protected-action settings are enforced by '
                    'the corresponding application features.',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _saveButton() {
    final compact = _isCompact(context);

    return SizedBox(
      width: double.infinity,
      height: compact ? 50 : 54,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveSettings,
        icon: _isSaving
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const Icon(Icons.save_outlined),
        label: Text(_isSaving ? 'Saving...' : 'Save Security Settings'),
      ),
    );
  }

  // ============================================================
  // APP BAR SAVE BUTTON
  // ============================================================

  Widget _appBarSaveButton() {
    final compact = _isCompact(context);

    return Padding(
      padding: EdgeInsets.only(right: compact ? 8 : 12),
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveSettings,
        icon: _isSaving
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const Icon(Icons.save_outlined, size: 18),
        label: Text(compact ? 'Save' : 'Save'),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);

    final horizontalPadding = _contentHorizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        actions: [_appBarSaveButton()],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      compact ? 16 : 24,
                      horizontalPadding,
                      40,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      // ==================================================
                      // PAGE INTRO
                      // ==================================================
                      Padding(
                        padding: EdgeInsets.only(bottom: compact ? 16 : 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: compact ? 42 : 48,
                              height: compact ? 42 : 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(
                                  compact ? 10 : 12,
                                ),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings_outlined,
                                color: AppColors.primary,
                                size: compact ? 22 : 26,
                              ),
                            ),

                            SizedBox(width: compact ? 10 : 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Security & Access',
                                    style: AppTextStyles.title,
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Manage login, session timeout and '
                                    'password protection for sensitive actions.',
                                    style: AppTextStyles.bodySecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // LOGIN & SESSION
                      // ==================================================
                      _section(
                        title: 'Login & Session',
                        subtitle:
                            'Control how users access and remain logged into the system.',
                        icon: Icons.lock_outline,
                        children: [
                          _switchTile(
                            title: 'Require Login',
                            subtitle:
                                'Require users to sign in before accessing the application.',
                            value: _requireLogin,
                            onChanged: (value) {
                              setState(() {
                                _requireLogin = value;

                                if (!value) {
                                  _autoLogout = false;
                                }
                              });
                            },
                          ),

                          _sectionDivider(),

                          _switchTile(
                            title: 'Automatic Logout',
                            subtitle: 'Automatically log out inactive users.',
                            value: _autoLogout,
                            onChanged: _requireLogin
                                ? (value) {
                                    setState(() {
                                      _autoLogout = value;
                                    });
                                  }
                                : (_) {},
                          ),

                          const SizedBox(height: 10),

                          _logoutField(),
                        ],
                      ),

                      // ==================================================
                      // PROTECTED ACTIONS
                      // ==================================================
                      _section(
                        title: 'Protected Actions',
                        subtitle:
                            'Require authentication before performing sensitive operations.',
                        icon: Icons.admin_panel_settings_outlined,
                        children: [
                          _switchTile(
                            title: 'Stock Adjustment',
                            subtitle:
                                'Require a password before changing inventory quantities.',
                            value: _requirePasswordStockAdjustment,
                            onChanged: (value) {
                              setState(() {
                                _requirePasswordStockAdjustment = value;
                              });
                            },
                          ),

                          _sectionDivider(),

                          _switchTile(
                            title: 'Delete Product',
                            subtitle:
                                'Require a password before deleting a product.',
                            value: _requirePasswordDeleteProduct,
                            onChanged: (value) {
                              setState(() {
                                _requirePasswordDeleteProduct = value;
                              });
                            },
                          ),

                          _sectionDivider(),

                          _switchTile(
                            title: 'Cancel Sale',
                            subtitle:
                                'Require a password before cancelling or reversing a sale.',
                            value: _requirePasswordCancelSale,
                            onChanged: (value) {
                              setState(() {
                                _requirePasswordCancelSale = value;
                              });
                            },
                          ),

                          _sectionDivider(),

                          _switchTile(
                            title: 'Large Discount',
                            subtitle:
                                'Require a password before applying discounts that require approval.',
                            value: _requirePasswordLargeDiscount,
                            onChanged: (value) {
                              setState(() {
                                _requirePasswordLargeDiscount = value;
                              });
                            },
                          ),

                          _sectionDivider(),

                          _switchTile(
                            title: 'Change Staff Debt Limit',
                            subtitle:
                                'Require a password before changing the staff debt limit.',
                            value: _requirePasswordChangeStaffDebtLimit,
                            onChanged: (value) {
                              setState(() {
                                _requirePasswordChangeStaffDebtLimit = value;
                              });
                            },
                          ),

                          _sectionDivider(),

                          _switchTile(
                            title: 'View Profit',
                            subtitle:
                                'Require authentication before viewing sensitive profit information.',
                            value: _requirePasswordViewProfit,
                            onChanged: (value) {
                              setState(() {
                                _requirePasswordViewProfit = value;
                              });
                            },
                          ),
                        ],
                      ),

                      // ==================================================
                      // SECURITY INFORMATION
                      // ==================================================
                      _informationCard(),

                      // ==================================================
                      // SAVE
                      // ==================================================
                      _saveButton(),

                      const SizedBox(height: 16),

                      Center(
                        child: Text(
                          'Security settings are stored locally with the application.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.small.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
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

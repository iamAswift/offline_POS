// lib/features/settings/reports_settings_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

class ReportsSettingsScreen extends StatefulWidget {
  final SettingsDao settingsDao;

  const ReportsSettingsScreen({super.key, required this.settingsDao});

  @override
  State<ReportsSettingsScreen> createState() => _ReportsSettingsScreenState();
}

class _ReportsSettingsScreenState extends State<ReportsSettingsScreen> {
  // ============================================================
  // DEFAULT PERIOD
  // ============================================================

  String _defaultPeriod = 'Day';

  static const List<String> _periodOptions = ['Day', 'Week', 'Month', 'Year'];

  // ============================================================
  // DASHBOARD VISIBILITY
  // ============================================================

  bool _showProfit = true;
  bool _showStockValue = true;

  // ============================================================
  // CHARTS
  // ============================================================

  bool _showCharts = true;
  bool _showSalesTrend = true;
  bool _showPaymentBreakdown = true;
  bool _showCategoryPerformance = true;

  // ============================================================
  // EXPORT
  // ============================================================

  bool _showExport = true;

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = true;
  bool _isSaving = false;

  // ============================================================
  // RESPONSIVE HELPERS
  // ============================================================

  bool _isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 560;
  }

  bool _isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 700;
  }

  double _horizontalPadding(BuildContext context) {
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
  // LOAD SETTINGS
  // ============================================================

  Future<void> _loadSettings() async {
    try {
      final defaultPeriod =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportDefaultPeriod,
          ) ??
          'Day';

      final showProfit =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowProfit,
          ) ??
          'true';

      final showStockValue =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowStockValue,
          ) ??
          'true';

      final showCharts =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowCharts,
          ) ??
          'true';

      final showSalesTrend =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowSalesTrend,
          ) ??
          'true';

      final showPaymentBreakdown =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowPaymentBreakdown,
          ) ??
          'true';

      final showCategoryPerformance =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowCategoryPerformance,
          ) ??
          'true';

      final showExport =
          await widget.settingsDao.getSetting(
            BusinessSettings.reportShowExport,
          ) ??
          'true';

      if (!mounted) return;

      setState(() {
        _defaultPeriod = _periodOptions.contains(defaultPeriod)
            ? defaultPeriod
            : 'Day';

        _showProfit = _parseBool(showProfit, true);

        _showStockValue = _parseBool(showStockValue, true);

        _showCharts = _parseBool(showCharts, true);

        _showSalesTrend = _parseBool(showSalesTrend, true);

        _showPaymentBreakdown = _parseBool(showPaymentBreakdown, true);

        _showCategoryPerformance = _parseBool(showCategoryPerformance, true);

        _showExport = _parseBool(showExport, true);

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Failed to load report settings: $e', isError: true);
    }
  }

  // ============================================================
  // BOOLEAN PARSER
  // ============================================================

  bool _parseBool(String? value, bool defaultValue) {
    if (value == null) {
      return defaultValue;
    }

    return value.trim().toLowerCase() == 'true';
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
      await widget.settingsDao.setSetting(
        BusinessSettings.reportDefaultPeriod,
        _defaultPeriod,
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.reportShowProfit,
        _showProfit.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.reportShowStockValue,
        _showStockValue.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.reportShowCharts,
        _showCharts.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.reportShowSalesTrend,
        _showSalesTrend.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.reportShowPaymentBreakdown,
        _showPaymentBreakdown.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.reportShowCategoryPerformance,
        _showCategoryPerformance.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.reportShowExport,
        _showExport.toString(),
      );

      if (!mounted) return;

      _showMessage('Report settings saved successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to save report settings: $e', isError: true);
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
            _sectionHeader(title: title, icon: icon),

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

  Widget _sectionHeader({required String title, required IconData icon}) {
    final compact = _isCompact(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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

        Expanded(child: Text(title, style: AppTextStyles.title)),
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
    required ValueChanged<bool>? onChanged,
  }) {
    final compact = _isCompact(context);

    return SwitchListTile(
      contentPadding: EdgeInsets.symmetric(vertical: compact ? 2 : 4),
      dense: compact,
      title: Text(title, style: AppTextStyles.body),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(subtitle, style: AppTextStyles.bodySecondary),
      ),
      value: value,
      onChanged: onChanged,
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
  // PERIOD SELECTOR
  // ============================================================

  Widget _periodSelector() {
    final compact = _isCompact(context);

    return DropdownButtonFormField<String>(
      initialValue: _defaultPeriod,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Default Period',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 12 : 16,
        ),
      ),
      items: _periodOptions.map((period) {
        return DropdownMenuItem<String>(value: period, child: Text(period));
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _defaultPeriod = value;
        });
      },
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _informationCard() {
    final compact = _isCompact(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: AppColors.primaryLight,
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: compact ? 36 : 40,
              height: compact ? 36 : 40,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline, color: AppColors.primary),
            ),

            SizedBox(width: compact ? 10 : 12),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reports configuration', style: AppTextStyles.title),

                  SizedBox(height: 4),

                  Text(
                    'These preferences control which information '
                    'is displayed on the reports dashboard and '
                    'which reporting tools are available.',
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
        label: Text(_isSaving ? 'Saving...' : 'Save Report Settings'),
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
        label: const Text('Save'),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);

    final horizontalPadding = _horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports Settings'),
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
                                Icons.analytics_outlined,
                                color: AppColors.primary,
                                size: compact ? 22 : 26,
                              ),
                            ),

                            SizedBox(width: compact ? 10 : 14),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reports & Analytics',
                                    style: AppTextStyles.title,
                                  ),

                                  SizedBox(height: 4),

                                  Text(
                                    'Configure the reports dashboard, '
                                    'analytics, default periods and export options.',
                                    style: AppTextStyles.bodySecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // DEFAULT PERIOD
                      // ==================================================
                      _section(
                        title: 'Default Report Period',
                        icon: Icons.calendar_today_outlined,
                        children: [_periodSelector()],
                      ),

                      // ==================================================
                      // DASHBOARD CARDS
                      // ==================================================
                      _section(
                        title: 'Dashboard Cards',
                        icon: Icons.dashboard_outlined,
                        children: [
                          _switchTile(
                            title: 'Show Profit',
                            subtitle:
                                'Display profit information on the reports dashboard.',
                            value: _showProfit,
                            onChanged: (value) {
                              setState(() {
                                _showProfit = value;
                              });
                            },
                          ),

                          _sectionDivider(),

                          _switchTile(
                            title: 'Show Stock Value',
                            subtitle:
                                'Display the current inventory value on the dashboard.',
                            value: _showStockValue,
                            onChanged: (value) {
                              setState(() {
                                _showStockValue = value;
                              });
                            },
                          ),
                        ],
                      ),

                      // ==================================================
                      // CHARTS
                      // ==================================================
                      _section(
                        title: 'Charts & Analytics',
                        icon: Icons.analytics_outlined,
                        children: [
                          _switchTile(
                            title: 'Show Charts',
                            subtitle:
                                'Show the analytics section on the reports dashboard.',
                            value: _showCharts,
                            onChanged: (value) {
                              setState(() {
                                _showCharts = value;
                              });
                            },
                          ),

                          _sectionDivider(),

                          _switchTile(
                            title: 'Sales Trend',
                            subtitle: 'Show sales performance over time.',
                            value: _showSalesTrend,
                            onChanged: _showCharts
                                ? (value) {
                                    setState(() {
                                      _showSalesTrend = value;
                                    });
                                  }
                                : null,
                          ),

                          _sectionDivider(),

                          _switchTile(
                            title: 'Payment Breakdown',
                            subtitle:
                                'Show how customers paid across the selected reporting period.',
                            value: _showPaymentBreakdown,
                            onChanged: _showCharts
                                ? (value) {
                                    setState(() {
                                      _showPaymentBreakdown = value;
                                    });
                                  }
                                : null,
                          ),

                          _sectionDivider(),

                          _switchTile(
                            title: 'Category Performance',
                            subtitle:
                                'Show sales performance grouped by product category.',
                            value: _showCategoryPerformance,
                            onChanged: _showCharts
                                ? (value) {
                                    setState(() {
                                      _showCategoryPerformance = value;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),

                      // ==================================================
                      // EXPORT
                      // ==================================================
                      _section(
                        title: 'PDF Export',
                        icon: Icons.picture_as_pdf_outlined,
                        children: [
                          _switchTile(
                            title: 'Show PDF Export',
                            subtitle:
                                'Display PDF export controls on the reports dashboard.',
                            value: _showExport,
                            onChanged: (value) {
                              setState(() {
                                _showExport = value;
                              });
                            },
                          ),
                        ],
                      ),

                      // ==================================================
                      // INFORMATION
                      // ==================================================
                      _informationCard(),

                      // ==================================================
                      // SAVE
                      // ==================================================
                      _saveButton(),

                      const SizedBox(height: 16),

                      Center(
                        child: Text(
                          'Report preferences are stored locally with the application.',
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
}

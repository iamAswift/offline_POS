// lib/features/settings/reports_settings_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

class ReportsSettingsScreen extends StatefulWidget {
  final SettingsDao settingsDao;

  const ReportsSettingsScreen({
    super.key,
    required this.settingsDao,
  });

  @override
  State<ReportsSettingsScreen> createState() =>
      _ReportsSettingsScreenState();
}

class _ReportsSettingsScreenState
    extends State<ReportsSettingsScreen> {
  // ============================================================
  // DEFAULT PERIOD
  // ============================================================

  String _defaultPeriod = 'Day';

  static const List<String> _periodOptions = [
    'Day',
    'Week',
    'Month',
    'Year',
  ];

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
        _defaultPeriod =
            _periodOptions.contains(defaultPeriod)
                ? defaultPeriod
                : 'Day';

        _showProfit = _parseBool(showProfit, true);

        _showStockValue =
            _parseBool(showStockValue, true);

        _showCharts =
            _parseBool(showCharts, true);

        _showSalesTrend =
            _parseBool(showSalesTrend, true);

        _showPaymentBreakdown =
            _parseBool(
          showPaymentBreakdown,
          true,
        );

        _showCategoryPerformance =
            _parseBool(
          showCategoryPerformance,
          true,
        );

        _showExport =
            _parseBool(showExport, true);

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load report settings: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // BOOLEAN PARSER
  // ============================================================

  bool _parseBool(
    String? value,
    bool defaultValue,
  ) {
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

      _showMessage(
        'Report settings saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save report settings: $e',
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Reports Settings',
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: AppTextStyles.screenPadding,
              children: [
                // ==================================================
                // DEFAULT PERIOD
                // ==================================================

                _section(
                  title: 'Default Report Period',
                  icon: Icons.calendar_today_outlined,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _defaultPeriod,
                      decoration: const InputDecoration(
                        labelText: 'Default Period',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _periodOptions.map((period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _defaultPeriod = value;
                        });
                      },
                    ),
                  ],
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

                    _switchTile(
                      title: 'Show Stock Value',
                      subtitle:
                          'Display current inventory value on the dashboard.',
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

                    const Divider(),

                    _switchTile(
                      title: 'Sales Trend',
                      subtitle:
                          'Show sales performance over time.',
                      value: _showSalesTrend,
                      onChanged: _showCharts
                          ? (value) {
                              setState(() {
                                _showSalesTrend = value;
                              });
                            }
                          : null,
                    ),

                    _switchTile(
                      title: 'Payment Breakdown',
                      subtitle:
                          'Show how customers paid.',
                      value: _showPaymentBreakdown,
                      onChanged: _showCharts
                          ? (value) {
                              setState(() {
                                _showPaymentBreakdown =
                                    value;
                              });
                            }
                          : null,
                    ),

                    _switchTile(
                      title: 'Category Performance',
                      subtitle:
                          'Show sales performance by category.',
                      value: _showCategoryPerformance,
                      onChanged: _showCharts
                          ? (value) {
                              setState(() {
                                _showCategoryPerformance =
                                    value;
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

                const SizedBox(height: 4),

                // ==================================================
                // SAVE
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    onPressed:
                        _isSaving ? null : _saveSettings,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Report Settings',
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
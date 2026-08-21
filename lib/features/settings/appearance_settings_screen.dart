// lib/features/settings/appearance_settings_screen.dart

import 'package:flutter/material.dart';

import '../../database/daos/settings_dao.dart';
import '../../database/business_settings.dart';
import '../../core/theme/styles.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  final SettingsDao settingsDao;

  const AppearanceSettingsScreen({
    super.key,
    required this.settingsDao,
  });

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState
    extends State<AppearanceSettingsScreen> {
  // ============================================================
  // STATE
  // ============================================================

  String _themeMode = 'system';

  String _accentColor = 'blue';

  bool _compactMode = false;

  bool _largePosButtons = true;

  bool _showProductImages = true;

  bool _isLoading = true;

  bool _isSaving = false;

  // ============================================================
  // ACCENT COLORS
  // ============================================================

  final List<Map<String, dynamic>> _accentColors = [
    {
      'name': 'blue',
      'label': 'Blue',
      'color': AppColors.primary,
    },
    {
      'name': 'orange',
      'label': 'Orange',
      'color': AppColors.accent,
    },
    {
      'name': 'green',
      'label': 'Green',
      'color': AppColors.success,
    },
    {
      'name': 'purple',
      'label': 'Purple',
      'color': Color(0xFF7F56D9),
    },
    {
      'name': 'red',
      'label': 'Red',
      'color': AppColors.danger,
    },
  ];

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
      final themeMode =
          await widget.settingsDao.getSetting(
                BusinessSettings.themeMode,
              ) ??
              'system';

      final accentColor =
          await widget.settingsDao.getSetting(
                BusinessSettings.accentColor,
              ) ??
              'blue';

      final compactMode =
          await widget.settingsDao.getSetting(
                BusinessSettings.compactMode,
              ) ??
              'false';

      final largePosButtons =
          await widget.settingsDao.getSetting(
                BusinessSettings.largePosButtons,
              ) ??
              'true';

      final showProductImages =
          await widget.settingsDao.getSetting(
                BusinessSettings.showProductImages,
              ) ??
              'true';

      if (!mounted) return;

      setState(() {
        _themeMode = _isValidTheme(themeMode)
            ? themeMode
            : 'system';

        _accentColor = _isValidAccentColor(
          accentColor,
        )
            ? accentColor
            : 'blue';

        _compactMode =
            compactMode == 'true';

        _largePosButtons =
            largePosButtons == 'true';

        _showProductImages =
            showProductImages == 'true';

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load appearance settings: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _isValidTheme(String value) {
    return [
      'system',
      'light',
      'dark',
    ].contains(value);
  }

  bool _isValidAccentColor(String value) {
    return _accentColors.any(
      (color) => color['name'] == value,
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveSettings() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.settingsDao.setSetting(
        BusinessSettings.themeMode,
        _themeMode,
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.accentColor,
        _accentColor,
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.compactMode,
        _compactMode.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.largePosButtons,
        _largePosButtons.toString(),
      );

      await widget.settingsDao.setSetting(
        BusinessSettings.showProductImages,
        _showProductImages.toString(),
      );

      if (!mounted) return;

      _showMessage(
        'Appearance settings saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save appearance settings: $e',
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
                        BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.palette_outlined,
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
                            AppTextStyles.bodySecondary,
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
  // THEME SELECTOR
  // ============================================================

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Theme',
          style: AppTextStyles.title,
        ),

        const SizedBox(height: 6),

        Text(
          'Choose how the application should appear.',
          style: AppTextStyles.bodySecondary,
        ),

        const SizedBox(height: 16),

        RadioGroup<String>(
          groupValue: _themeMode,
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _themeMode = value;
            });
          },
          child: Column(
            children: [
              _themeOption(
                value: 'system',
                title: 'System Default',
                subtitle:
                    'Follow your device appearance setting.',
                icon: Icons.settings_suggest_outlined,
              ),

              const Divider(),

              _themeOption(
                value: 'light',
                title: 'Light',
                subtitle:
                    'Use the light application theme.',
                icon: Icons.light_mode_outlined,
              ),

              const Divider(),

              _themeOption(
                value: 'dark',
                title: 'Dark',
                subtitle:
                    'Use the dark application theme.',
                icon: Icons.dark_mode_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // THEME OPTION
  // ============================================================

  Widget _themeOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(
        title,
        style: AppTextStyles.body,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySecondary,
      ),
      trailing: Radio<String>(
        value: value,
      ),
    );
  }

  // ============================================================
  // ACCENT COLOR
  // ============================================================

  Widget _buildAccentColorSelector() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Accent Color',
          style: AppTextStyles.title,
        ),

        const SizedBox(height: 6),

        Text(
          'Choose the primary accent used throughout the interface.',
          style: AppTextStyles.bodySecondary,
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _accentColors.map(
            (accent) {
              final name =
                  accent['name'] as String;

              final label =
                  accent['label'] as String;

              final color =
                  accent['color'] as Color;

              final selected =
                  _accentColor == name;

              return InkWell(
                borderRadius:
                    BorderRadius.circular(10),
                onTap: () {
                  setState(() {
                    _accentColor = name;
                  });
                },
                child: Container(
                  width: 130,
                  padding:
                      const EdgeInsets.all(12),
                  decoration:
                      BoxDecoration(
                    color: selected
                        ? color.withValues(
                            alpha: 0.08,
                          )
                        : null,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                    border: Border.all(
                      color: selected
                          ? color
                          : AppColors.border,
                      width:
                          selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration:
                            BoxDecoration(
                          color: color,
                          shape:
                              BoxShape.circle,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          label,
                          style:
                              AppTextStyles.body,
                        ),
                      ),
                      if (selected)
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: color,
                        ),
                    ],
                  ),
                ),
              );
            },
          ).toList(),
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
    IconData? icon,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary:
          icon != null ? Icon(icon) : null,
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appearance',
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 12,
            ),
            child: ElevatedButton.icon(
              onPressed: _isSaving
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
                      const EdgeInsets.all(24),
                  children: [
                    // ==================================================
                    // PAGE INTRO
                    // ==================================================

                    Text(
                      'Appearance Settings',
                      style:
                          AppTextStyles.heading,
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      'Customize how the inventory and POS application '
                      'looks and behaves on your device.',
                      style:
                          AppTextStyles.bodySecondary,
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==================================================
                    // THEME
                    // ==================================================

                    _sectionCard(
                      title: 'Theme',
                      subtitle:
                          'Choose your preferred application theme.',
                      icon:
                          Icons.brightness_6_outlined,
                      child:
                          _buildThemeSelector(),
                    ),

                    // ==================================================
                    // ACCENT COLOR
                    // ==================================================

                    _sectionCard(
                      title: 'Accent Color',
                      subtitle:
                          'Customize the primary interface color.',
                      icon:
                          Icons.color_lens_outlined,
                      child:
                          _buildAccentColorSelector(),
                    ),

                    // ==================================================
                    // POS DISPLAY
                    // ==================================================

                    _sectionCard(
                      title: 'POS Display',
                      subtitle:
                          'Adjust the interface for touchscreen sales.',
                      icon:
                          Icons.point_of_sale_outlined,
                      child: Column(
                        children: [
                          _switchTile(
                            title:
                                'Large POS Buttons',
                            subtitle:
                                'Use larger buttons for easier touchscreen '
                                'operation at the point of sale.',
                            value:
                                _largePosButtons,
                            onChanged: (value) {
                              setState(() {
                                _largePosButtons =
                                    value;
                              });
                            },
                            icon:
                                Icons.touch_app_outlined,
                          ),

                          const Divider(),

                          _switchTile(
                            title:
                                'Show Product Images',
                            subtitle:
                                'Display product images in the POS product '
                                'selection interface.',
                            value:
                                _showProductImages,
                            onChanged: (value) {
                              setState(() {
                                _showProductImages =
                                    value;
                              });
                            },
                            icon:
                                Icons.image_outlined,
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // LAYOUT
                    // ==================================================

                    _sectionCard(
                      title: 'Layout',
                      subtitle:
                          'Control the amount of information displayed '
                          'on screen.',
                      icon:
                          Icons.view_compact_outlined,
                      child: _switchTile(
                        title:
                            'Compact Mode',
                        subtitle:
                            'Reduce spacing and make lists display more '
                            'items on screen.',
                        value:
                            _compactMode,
                        onChanged: (value) {
                          setState(() {
                            _compactMode =
                                value;
                          });
                        },
                        icon:
                            Icons.density_small,
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
                        onPressed: _isSaving
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
                              : 'Save Appearance Settings',
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
}
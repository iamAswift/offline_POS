// lib/features/settings/appearance_settings_screen.dart

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

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

  static const List<Map<String, dynamic>> _accentColors = [
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
      'color': AppColors.pos,
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
        content: Text(
          message,
          style: AppTextStyles.body,
        ),
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
    final responsive = context.responsive;

    return Card(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.xl,
      ),
      child: Padding(
        padding: EdgeInsets.all(
          responsive.isCompact
              ? AppSpacing.lg
              : AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: responsive.isCompact
                      ? AppSizes.iconButton
                      : AppSizes.iconButton,
                  height: responsive.isCompact
                      ? AppSizes.iconButton
                      : AppSizes.iconButton,
                  decoration: BoxDecoration(
                    color:
                        AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.md,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(
                  width: AppSpacing.md,
                ),

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
                        height: AppSpacing.xs,
                      ),

                      Text(
                        subtitle,
                        style: AppTextStyles
                            .bodySecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

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
        const Text(
          'Theme',
          style: AppTextStyles.title,
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        const Text(
          'Choose how the application should appear.',
          style: AppTextStyles.bodySecondary,
        ),

        const SizedBox(
          height: AppSpacing.lg,
        ),

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
                icon:
                    Icons.settings_suggest_outlined,
              ),

              const Divider(
                color: AppColors.divider,
              ),

              _themeOption(
                value: 'light',
                title: 'Light',
                subtitle:
                    'Use the light application theme.',
                icon:
                    Icons.light_mode_outlined,
              ),

              const Divider(
                color: AppColors.divider,
              ),

              _themeOption(
                value: 'dark',
                title: 'Dark',
                subtitle:
                    'Use the dark application theme.',
                icon:
                    Icons.dark_mode_outlined,
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

      leading: Icon(
        icon,
        color: AppColors.textSecondary,
      ),

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
  // ACCENT COLOR SELECTOR
  // ============================================================

  Widget _buildAccentColorSelector() {
    final responsive = context.responsive;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Accent Color',
          style: AppTextStyles.title,
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        const Text(
          'Choose the primary accent used throughout the interface.',
          style: AppTextStyles.bodySecondary,
        ),

        const SizedBox(
          height: AppSpacing.lg,
        ),

        LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final columns = responsive.isCompact
                ? 1
                : responsive.isTablet
                    ? 2
                    : 3;

            final spacing = AppSpacing.md;

            final itemWidth =
                (constraints.maxWidth -
                        (spacing *
                            (columns - 1))) /
                    columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children:
                  _accentColors.map(
                (accent) {
                  final name =
                      accent['name'] as String;

                  final label =
                      accent['label'] as String;

                  final color =
                      accent['color'] as Color;

                  final selected =
                      _accentColor == name;

                  return SizedBox(
                    width: itemWidth,
                    child: _accentColorOption(
                      name: name,
                      label: label,
                      color: color,
                      selected: selected,
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // ACCENT COLOR OPTION
  // ============================================================

  Widget _accentColorOption({
    required String name,
    required String label,
    required Color color,
    required bool selected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
        onTap: () {
          setState(() {
            _accentColor = name;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(
                    alpha: 0.08,
                  )
                : AppColors.surfaceSoft,
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
            ),
            border: Border.all(
              color: selected
                  ? color
                  : AppColors.border,
              width: selected
                  ? AppSpacing.xs / 2
                  : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.xl,
                height: AppSpacing.xl,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body,
                ),
              ),

              if (selected)
                Icon(
                  Icons.check_circle,
                  size: AppSpacing.xl,
                  color: color,
                ),
            ],
          ),
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
    IconData? icon,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,

      secondary: icon != null
          ? Icon(
              icon,
              color: AppColors.textSecondary,
            )
          : null,

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
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    final responsive = context.responsive;

    return SizedBox(
      height: responsive.buttonHeight,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            _isSaving ? null : _saveSettings,

        icon: _isSaving
            ? const SizedBox(
                width: AppSpacing.lg,
                height: AppSpacing.lg,
                child:
                     CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
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
    );
  }

  // ============================================================
  // APP BAR SAVE ACTION
  // ============================================================

  Widget _buildAppBarSaveAction() {
    final responsive = context.responsive;

    if (responsive.isCompact) {
      return IconButton(
        tooltip: 'Save',
        onPressed:
            _isSaving ? null : _saveSettings,
        icon: _isSaving
            ? const SizedBox(
                width: AppSpacing.lg,
                height: AppSpacing.lg,
                child:
                     CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.save,
              ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        right: AppSpacing.md,
      ),
      child: ElevatedButton.icon(
        onPressed:
            _isSaving ? null : _saveSettings,

        icon: _isSaving
            ? const SizedBox(
                width: AppSpacing.lg,
                height: AppSpacing.lg,
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
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appearance',
        ),
        actions: [
          _buildAppBarSaveAction(),
        ],
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      responsive.contentMaxWidth,
                ),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        responsive.horizontalPadding,
                    vertical:
                        responsive.verticalPadding,
                  ),
                  children: [
                    // ==================================================
                    // PAGE INTRO
                    // ==================================================

                    const Text(
                      'Appearance Settings',
                      style:
                          AppTextStyles.heading,
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    const Text(
                      'Customize how the inventory and POS application '
                      'looks and behaves on your device.',
                      style:
                          AppTextStyles.bodySecondary,
                    ),

                    const SizedBox(
                      height: AppSpacing.xxl,
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

                          const Divider(
                            color:
                                AppColors.divider,
                          ),

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

                    _buildSaveButton(),

                    const SizedBox(
                      height: AppSpacing.huge,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// lib/features/settings/business_profile_screen.dart

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../core/widgets/business_logo_picker.dart';
import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

class BusinessProfileScreen extends StatefulWidget {
  final SettingsDao settingsDao;

  const BusinessProfileScreen({
    super.key,
    required this.settingsDao,
  });

  @override
  State<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState
    extends State<BusinessProfileScreen> {
  // ============================================================
  // FORM
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _businessNameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _receiptFooterController = TextEditingController();

  // ============================================================
  // BUSINESS
  // ============================================================

  String _businessType = 'General Retail';

  String? _businessLogoPath;

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = true;
  bool _isSaving = false;

  // ============================================================
  // BUSINESS TYPES
  // ============================================================

  static const List<String> _businessTypes = [
    'General Retail',
    'Supermarket',
    'Electronics',
    'Wine Shop',
    'Restaurant',
    'Pharmacy',
    'Fashion',
    'Hardware',
    'Beauty & Cosmetics',
    'Other',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadBusinessProfile();
  }

  // ============================================================
  // LOAD BUSINESS PROFILE
  // ============================================================

  Future<void> _loadBusinessProfile() async {
    try {
      final businessName =
          await widget.settingsDao.getSetting(
        BusinessSettings.businessName,
      );

      final tagline =
          await widget.settingsDao.getSetting(
        BusinessSettings.businessTagline,
      );

      final phone =
          await widget.settingsDao.getSetting(
        BusinessSettings.businessPhone,
      );

      final email =
          await widget.settingsDao.getSetting(
        BusinessSettings.businessEmail,
      );

      final address =
          await widget.settingsDao.getSetting(
        BusinessSettings.businessAddress,
      );

      final businessType =
          await widget.settingsDao.getSetting(
        BusinessSettings.businessType,
      );

      final receiptFooter =
          await widget.settingsDao.getSetting(
        BusinessSettings.receiptFooter,
      );

      // ----------------------------------------------------------
      // LOAD BUSINESS LOGO
      // ----------------------------------------------------------

      final businessLogo =
          await widget.settingsDao.getSetting(
        BusinessSettings.businessLogo,
      );

      if (!mounted) return;

      setState(() {
        _businessNameController.text =
            businessName ?? '';

        _taglineController.text =
            tagline ?? '';

        _phoneController.text =
            phone ?? '';

        _emailController.text =
            email ?? '';

        _addressController.text =
            address ?? '';

        _receiptFooterController.text =
            receiptFooter ??
                'Thank you for your patronage.';

        if (businessType != null &&
            _businessTypes.contains(
              businessType,
            )) {
          _businessType = businessType;
        }

        _businessLogoPath =
            businessLogo != null &&
                    businessLogo.trim().isNotEmpty
                ? businessLogo
                : null;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load business profile: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // SAVE BUSINESS PROFILE
  // ============================================================

  Future<void> _saveBusinessProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // ----------------------------------------------------------
      // BUSINESS NAME
      // ----------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.businessName,
        _businessNameController.text.trim(),
      );

      // ----------------------------------------------------------
      // TAGLINE
      // ----------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.businessTagline,
        _taglineController.text.trim(),
      );

      // ----------------------------------------------------------
      // BUSINESS TYPE
      // ----------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.businessType,
        _businessType,
      );

      // ----------------------------------------------------------
      // PHONE
      // ----------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.businessPhone,
        _phoneController.text.trim(),
      );

      // ----------------------------------------------------------
      // EMAIL
      // ----------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.businessEmail,
        _emailController.text.trim(),
      );

      // ----------------------------------------------------------
      // ADDRESS
      // ----------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.businessAddress,
        _addressController.text.trim(),
      );

      // ----------------------------------------------------------
      // RECEIPT FOOTER
      // ----------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.receiptFooter,
        _receiptFooterController.text.trim(),
      );

      // ----------------------------------------------------------
      // BUSINESS LOGO
      // ----------------------------------------------------------

      await widget.settingsDao.setSetting(
        BusinessSettings.businessLogo,
        _businessLogoPath ?? '',
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Business profile saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Failed to save business profile: $e',
        isError: true,
      );
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
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.lg,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon:
              icon != null ? Icon(icon) : null,
        ),
        validator: requiredField
            ? (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return '$label is required';
                }

                return null;
              }
            : null,
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _buildSectionCard({
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
          responsive.value(
            compact: AppSpacing.lg,
            tablet: AppSpacing.xl,
            desktop: AppSpacing.xxl,
          ),
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
                  width: responsive.value(
                    compact: AppSpacing.xxxl,
                    tablet: AppSpacing.huge,
                    desktop: AppSpacing.huge,
                  ),
                  height: responsive.value(
                    compact: AppSpacing.xxxl,
                    tablet: AppSpacing.huge,
                    desktop: AppSpacing.huge,
                  ),
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
                    size: responsive.value(
                      compact: AppSpacing.lg,
                      tablet: AppSpacing.xl,
                      desktop: AppSpacing.xl,
                    ),
                    color:
                        AppColors.primary,
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
                        style:
                            AppTextStyles
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
  // LOGO SECTION
  // ============================================================

  Widget _buildLogoSection() {
    return _buildSectionCard(
      title: 'Business Logo',
      subtitle:
          'Upload the logo that will be displayed throughout the system.',
      icon: Icons.image_outlined,
      child: Center(
        child: BusinessLogoPicker(
          initialPath: _businessLogoPath,
          onImageSelected: (path) {
            setState(() {
              _businessLogoPath = path;
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // BUSINESS IDENTITY SECTION
  // ============================================================

  Widget _buildBusinessIdentitySection() {
    return _buildSectionCard(
      title: 'Business Identity',
      subtitle:
          'Information displayed throughout the system.',
      icon: Icons.business,
      child: Column(
        children: [
          _buildTextField(
            controller:
                _businessNameController,
            label: 'Business Name',
            hint: 'e.g. DKing Wine Shop',
            icon: Icons.store,
            requiredField: true,
          ),

          _buildTextField(
            controller: _taglineController,
            label: 'Tagline',
            hint:
                'e.g. Quality drinks at great prices',
            icon: Icons.short_text,
          ),

          DropdownButtonFormField<String>(
            initialValue: _businessType,
            decoration:
                const InputDecoration(
              labelText: 'Business Type',
              prefixIcon:
                  Icon(Icons.category),
            ),
            items: _businessTypes
                .map(
                  (type) =>
                      DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style:
                          AppTextStyles.body,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _businessType = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTACT SECTION
  // ============================================================

  Widget _buildContactSection() {
    return _buildSectionCard(
      title: 'Contact Information',
      subtitle:
          'Contact details for your business.',
      icon: Icons.contact_phone,
      child: Column(
        children: [
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'e.g. 08132715857',
            icon: Icons.phone,
            keyboardType:
                TextInputType.phone,
          ),

          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint:
                'e.g. business@example.com',
            icon: Icons.email,
            keyboardType:
                TextInputType.emailAddress,
          ),

          _buildTextField(
            controller: _addressController,
            label: 'Business Address',
            hint:
                'e.g. Lugbe, Abuja, Nigeria',
            icon: Icons.location_on,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECEIPT SECTION
  // ============================================================

  Widget _buildReceiptSection() {
    return _buildSectionCard(
      title: 'Receipt Information',
      subtitle:
          'Text displayed at the bottom of receipts.',
      icon: Icons.receipt_long,
      child: _buildTextField(
        controller:
            _receiptFooterController,
        label: 'Receipt Footer',
        hint:
            'Thank you for your patronage.',
        icon: Icons.notes,
        maxLines: 3,
      ),
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
        onPressed: _isSaving
            ? null
            : _saveBusinessProfile,
        icon: _isSaving
            ? const SizedBox(
                width: AppSpacing.lg,
                height: AppSpacing.lg,
                child:
                     CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          _isSaving
              ? 'Saving...'
              : 'Save Business Profile',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE CONTENT
  // ============================================================

  Widget _buildContent() {
    final responsive = context.responsive;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: responsive.contentMaxWidth,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal:
                  responsive.horizontalPadding,
              vertical:
                  responsive.verticalPadding,
            ),
            children: [
              // --------------------------------------------------
              // LOGO
              // --------------------------------------------------

              _buildLogoSection(),

              // --------------------------------------------------
              // BUSINESS IDENTITY
              // --------------------------------------------------

              _buildBusinessIdentitySection(),

              // --------------------------------------------------
              // CONTACT
              // --------------------------------------------------

              _buildContactSection(),

              // --------------------------------------------------
              // RECEIPT
              // --------------------------------------------------

              _buildReceiptSection(),

              // --------------------------------------------------
              // SAVE
              // --------------------------------------------------

              const SizedBox(
                height: AppSpacing.sm,
              ),

              _buildSaveButton(),

              const SizedBox(
                height: AppSpacing.section,
              ),
            ],
          ),
        ),
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
          'Business Profile',
        ),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _buildContent(),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _businessNameController.dispose();
    _taglineController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _receiptFooterController.dispose();

    super.dispose();
  }
}
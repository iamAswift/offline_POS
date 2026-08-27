// lib/features/suppliers/supplier_form_screen.dart

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'package:supermarket_inventory/core/widgets/back_button.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/supplier_dao.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? existingSupplier;

  const SupplierFormScreen({
    super.key,
    this.existingSupplier,
  });

  @override
  State<SupplierFormScreen> createState() =>
      _SupplierFormScreenState();
}

class _SupplierFormScreenState
    extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final SupplierDao _supplierDao;

  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  bool _saving = false;

  bool get _isEditing =>
      widget.existingSupplier != null;

  @override
  void initState() {
    super.initState();

    _supplierDao = getSupplierDao();

    final supplier =
        widget.existingSupplier;

    _nameController =
        TextEditingController(
      text: supplier?.name ?? '',
    );

    _contactController =
        TextEditingController(
      text: supplier?.contact ?? '',
    );

    _addressController =
        TextEditingController(
      text: supplier?.address ?? '',
    );

    _notesController =
        TextEditingController(
      text: supplier?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE SUPPLIER
  // ============================================================

  Future<void> _saveSupplier() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final name =
        _nameController.text.trim();

    final contact =
        _contactController.text.trim();

    final address =
        _addressController.text.trim();

    final notes =
        _notesController.text.trim();

    setState(() {
      _saving = true;
    });

    try {
      final companion =
          SuppliersCompanion(
        name: Value(name),

        contact: contact.isEmpty
            ? const Value.absent()
            : Value(contact),

        address: address.isEmpty
            ? const Value.absent()
            : Value(address),

        notes: notes.isEmpty
            ? const Value.absent()
            : Value(notes),
      );

      if (_isEditing) {
        await _supplierDao.updateSupplier(
          widget.existingSupplier!
              .copyWithCompanion(companion),
        );
      } else {
        await _supplierDao.insertSupplier(
          companion,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showError(
        _isEditing
            ? 'Unable to update supplier.\n$e'
            : 'Unable to add supplier.\n$e',
      );
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              AppColors.danger,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // FIELD
  // ============================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_saving,
      keyboardType: keyboardType,
      maxLines: maxLines,

      textInputAction:
          maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.next,

      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),

      validator: required
          ? (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Enter supplier name';
              }

              return null;
            }
          : null,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        leading:
            const CentralBackButton(),

        title: Text(
          _isEditing
              ? 'Edit Supplier'
              : 'Add Supplier',
          style:
              AppTextStyles.heading,
        ),

        backgroundColor:
            AppColors.primary,

        foregroundColor:
            Colors.white,

        elevation: 0,
      ),

      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final width =
              constraints.maxWidth;

          final isTablet =
              width >= 600;

          final contentWidth =
              width > 850
                  ? 700.0
                  : width;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal:
                  isTablet ? 24 : 16,
              vertical:
                  isTablet ? 28 : 20,
            ),

            child: Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(
                  maxWidth:
                      contentWidth,
                ),

                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,

                    children: [
                      _buildHeader(
                        isTablet,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      _buildFormCard(
                        isTablet,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? 24 : 20,
      ),

      decoration: BoxDecoration(
        color:
            AppColors.surface,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color:
              AppColors.border,
        ),
      ),

      child: Row(
        children: [
          Container(
            width:
                isTablet ? 58 : 52,

            height:
                isTablet ? 58 : 52,

            decoration:
                BoxDecoration(
              color:
                  AppColors.primaryLight,

              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: Icon(
              _isEditing
                  ? Icons.edit_outlined
                  : Icons.business_outlined,

              color:
                  AppColors.primary,

              size:
                  isTablet ? 30 : 27,
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  _isEditing
                      ? 'Edit Supplier'
                      : 'Add Supplier',

                  style:
                      AppTextStyles.title,
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _isEditing
                      ? 'Update this supplier’s information.'
                      : 'Create a supplier record for your business.',

                  style:
                      AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORM CARD
  // ============================================================

  Widget _buildFormCard(
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? 24 : 20,
      ),

      decoration: BoxDecoration(
        color:
            AppColors.surface,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color:
              AppColors.border,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,

        children: [
          Text(
            'Supplier Information',
            style:
                AppTextStyles.title,
          ),

          const SizedBox(
            height: 18,
          ),

          _buildField(
            controller:
                _nameController,

            label:
                'Supplier Name',

            hintText:
                'Enter supplier name',

            icon:
                Icons.business_outlined,

            required:
                true,
          ),

          const SizedBox(
            height: 16,
          ),

          _buildField(
            controller:
                _contactController,

            label:
                'Contact',

            hintText:
                'Phone number or contact details',

            icon:
                Icons.phone_outlined,

            keyboardType:
                TextInputType.phone,
          ),

          const SizedBox(
            height: 16,
          ),

          _buildField(
            controller:
                _addressController,

            label:
                'Address',

            hintText:
                'Supplier address',

            icon:
                Icons.location_on_outlined,

            maxLines:
                2,
          ),

          const SizedBox(
            height: 16,
          ),

          _buildField(
            controller:
                _notesController,

            label:
                'Notes',

            hintText:
                'Optional notes about this supplier',

            icon:
                Icons.notes_outlined,

            maxLines:
                4,
          ),

          const SizedBox(
            height: 24,
          ),

          _buildSaveButton(),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,

      child: ElevatedButton.icon(
        onPressed:
            _saving
                ? null
                : _saveSupplier,

        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.accent,

          foregroundColor:
              Colors.white,

          disabledBackgroundColor:
              AppColors.textMuted,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),

        icon: _saving
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
            : Icon(
                _isEditing
                    ? Icons.save_outlined
                    : Icons.add_business_outlined,
              ),

        label: Text(
          _saving
              ? 'Saving...'
              : _isEditing
                  ? 'Save Changes'
                  : 'Save Supplier',

          style:
              AppTextStyles.body.copyWith(
            color:
                Colors.white,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
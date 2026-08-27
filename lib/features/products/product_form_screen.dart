// lib/features/products/product_form_screen.dart

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme/styles.dart';
import '../../core/widgets/back_button.dart';
import '../../core/widgets/inventory_widgets.dart';
import '../../database/app_database.dart';
import '../../database/daos/category_dao.dart';
import '../../database/daos/product_dao.dart';
import '../../core/responsive/responsive.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() =>
      _ProductFormScreenState();
}

class _ProductFormScreenState
    extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _expiryController = TextEditingController();

  int? _selectedCategoryId;
  String? _selectedUnit;
  String? _selectedImagePath;
  DateTime? _selectedExpiryDate;

  bool _isSaving = false;

  late final ProductDao _productDao;
  late final CategoryDao _categoryDao;

  final List<String> _units = [
    'pcs',
    'pack',
    'kg',
    'litre',
    'bag',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _productDao = getProductDao();
    _categoryDao = getCategoryDao();
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Future<void> _pickProductImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'png',
        'jpg',
        'jpeg',
        'svg',
      ],
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.first.path == null) {
      return;
    }

    final file = result.files.first;

    if (file.size > 2 * 1024 * 1024) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image is too large. Maximum size is 2MB.',
          ),
        ),
      );

      return;
    }

    final sourceFile = File(file.path!);

    final dir =
        await getApplicationDocumentsDirectory();

    final newPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

    await sourceFile.copy(newPath);

    if (!mounted) return;

    setState(() {
      _selectedImagePath = newPath;
    });
  }

  // ============================================================
  // EXPIRY DATE
  // ============================================================

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? now,
      firstDate: now,
      lastDate: DateTime(
        now.year + 5,
        now.month,
        now.day,
      ),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedExpiryDate = picked;

      _expiryController.text =
          '${picked.year}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    });
  }

  // ============================================================
  // SAVE PRODUCT
  // ============================================================

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _productDao.insertProduct(
        ProductsCompanion.insert(
          name: _nameController.text.trim(),
          brand: _brandController.text.trim().isEmpty
              ? const Value.absent()
              : Value(
                  _brandController.text.trim(),
                ),
          categoryId: _selectedCategoryId!,
          unit: _selectedUnit ?? 'pcs',
          costPrice: double.parse(
            _costPriceController.text.trim(),
          ),
          sellingPrice: double.parse(
            _sellingPriceController.text.trim(),
          ),
          stock: const Value(0),
          barcode: const Value.absent(),
          imagePath: _selectedImagePath == null
              ? const Value.absent()
              : Value(_selectedImagePath!),
          expiryDate: _selectedExpiryDate == null
              ? const Value.absent()
              : Value(_selectedExpiryDate!),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product created successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save product: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // SECTION SPACING
  // ============================================================

  double _sectionSpacing(BuildContext context) {
    final responsive = context.responsive;

    if (responsive.isCompact) {
      return AppSpacing.xxl;
    }

    if (responsive.isTablet) {
      return AppSpacing.xxxl;
    }

    return AppSpacing.section;
  }

  // ============================================================
  // CARD PADDING
  // ============================================================

  EdgeInsets _cardPadding(BuildContext context) {
    final responsive = context.responsive;

    if (responsive.isCompact) {
      return const EdgeInsets.all(14);
    }

    if (responsive.isTablet) {
      return const EdgeInsets.all(18);
    }

    return const EdgeInsets.all(20);
  }

  // ============================================================
  // FORM FIELD SPACING
  // ============================================================

  double _fieldSpacing(BuildContext context) {
    final responsive = context.responsive;

    if (responsive.isCompact) {
      return AppSpacing.sm + 2;
    }

    return AppSpacing.md;
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTextStyles.bodySecondary,
      hintStyle: AppTextStyles.small,
      prefixIcon: Icon(
        icon,
        size: 20,
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: const BorderSide(
          color: AppColors.danger,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: const BorderSide(
          color: AppColors.danger,
          width: 1.4,
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
      backgroundColor: AppColors.background,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        leading: const CentralBackButton(),
        title: Text(
          'Add Product',
          style: AppTextStyles.heading.copyWith(
            color: Colors.white,
            fontSize: responsive.isCompact ? 18 : 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: responsive.isCompact
                  ? double.infinity
                  : responsive.isTablet
                      ? 760
                      : 1000,
            ),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                responsive.isCompact
                    ? AppSpacing.lg
                    : AppSpacing.xl,
                responsive.horizontalPadding,
                responsive.isCompact
                    ? AppSpacing.xxxl
                    : AppSpacing.huge,
              ),
              children: [
                // ==================================================
                // PRODUCT INFORMATION
                // ==================================================

                const InventorySectionTitle(
                  title: 'Product Information',
                  subtitle:
                      'Add the basic details used to manage this product.',
                ),

                SizedBox(
                  height: responsive.isCompact
                      ? AppSpacing.md
                      : AppSpacing.lg,
                ),

                InventoryCard(
                  child: Padding(
                    padding: _cardPadding(context),
                    child: Column(
                      children: [
                        // PRODUCT NAME
                        TextFormField(
                          controller: _nameController,
                          textCapitalization:
                              TextCapitalization.words,
                          style: AppTextStyles.body,
                          decoration: _inputDecoration(
                            label: 'Product name',
                            hint: 'e.g. Coca-Cola 50cl',
                            icon:
                                Icons.inventory_2_outlined,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter product name';
                            }

                            return null;
                          },
                        ),

                        SizedBox(
                          height: _fieldSpacing(context),
                        ),

                        // BRAND
                        TextFormField(
                          controller: _brandController,
                          textCapitalization:
                              TextCapitalization.words,
                          style: AppTextStyles.body,
                          decoration: _inputDecoration(
                            label: 'Brand',
                            hint: 'Optional',
                            icon:
                                Icons.sell_outlined,
                          ),
                        ),

                        SizedBox(
                          height: _fieldSpacing(context),
                        ),

                        // CATEGORY
                        FutureBuilder<List<Category>>(
                          future:
                              _categoryDao.getAllCategories(),
                          builder:
                              (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                height: 52,
                                child: Center(
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }

                            final categories =
                                snapshot.data!;

                            return DropdownButtonFormField<int>(
                              initialValue:
                                  _selectedCategoryId,
                              style:
                                  AppTextStyles.body,
                              decoration:
                                  _inputDecoration(
                                label: 'Category',
                                icon: Icons
                                    .category_outlined,
                              ),
                              items:
                                  categories.map(
                                (category) {
                                  return DropdownMenuItem<
                                      int>(
                                    value:
                                        category.id,
                                    child: Text(
                                      category.name,
                                      style:
                                          AppTextStyles
                                              .body,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                    ),
                                  );
                                },
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryId =
                                      value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Select a category';
                                }

                                return null;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // PRODUCT IMAGE
                // ==================================================

                SizedBox(
                  height: _sectionSpacing(context),
                ),

                const InventorySectionTitle(
                  title: 'Product Image',
                  subtitle:
                      'Use a clear image so staff can identify the product quickly.',
                ),

                SizedBox(
                  height: responsive.isCompact
                      ? AppSpacing.md
                      : AppSpacing.lg,
                ),

                InventoryCard(
                  child: Padding(
                    padding: _cardPadding(context),
                    child: Column(
                      children: [
                        // IMAGE PREVIEW
                        Container(
                          height: responsive.isCompact
                              ? 130
                              : responsive.isTablet
                                  ? 155
                                  : 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                AppColors.surfaceSoft,
                            borderRadius:
                                BorderRadius.circular(
                              AppRadius.lg,
                            ),
                            border: Border.all(
                              color: AppColors.border,
                            ),
                          ),
                          child: _buildImagePreview(
                            responsive,
                          ),
                        ),

                        SizedBox(
                          height: responsive.isCompact
                              ? AppSpacing.md
                              : AppSpacing.lg,
                        ),

                        // UPLOAD BUTTON
                        SizedBox(
                          height:
                              responsive.controlHeight,
                          child: OutlinedButton.icon(
                            onPressed:
                                _pickProductImage,
                            icon: const Icon(
                              Icons
                                  .upload_file_outlined,
                              size: 19,
                            ),
                            label: Text(
                              _selectedImagePath ==
                                      null
                                  ? 'Upload Product Image'
                                  : 'Change Image',
                              style:
                                  AppTextStyles.body,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'PNG, JPG or SVG • Maximum 2MB',
                          style: AppTextStyles.small,
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // PRICING & UNIT
                // ==================================================

                SizedBox(
                  height: _sectionSpacing(context),
                ),

                const InventorySectionTitle(
                  title: 'Pricing & Unit',
                  subtitle:
                      'Set the purchasing and selling values for this product.',
                ),

                SizedBox(
                  height: responsive.isCompact
                      ? AppSpacing.md
                      : AppSpacing.lg,
                ),

                InventoryCard(
                  child: Padding(
                    padding: _cardPadding(context),
                    child: Column(
                      children: [
                        // =================================================
                        // PRICES
                        // =================================================

                        LayoutBuilder(
                          builder:
                              (context, constraints) {
                            final sideBySide =
                                constraints.maxWidth >=
                                    520;

                            if (!sideBySide) {
                              return Column(
                                children: [
                                  _buildCostPriceField(),

                                  SizedBox(
                                    height:
                                        _fieldSpacing(
                                      context,
                                    ),
                                  ),

                                  _buildSellingPriceField(),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child:
                                      _buildCostPriceField(),
                                ),

                                SizedBox(
                                  width:
                                      responsive.isCompact
                                          ? AppSpacing.sm
                                          : AppSpacing.md,
                                ),

                                Expanded(
                                  child:
                                      _buildSellingPriceField(),
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(
                          height: _fieldSpacing(context),
                        ),

                        // UNIT
                        DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          style: AppTextStyles.body,
                          decoration: _inputDecoration(
                            label: 'Unit',
                            icon:
                                Icons.straighten_outlined,
                          ),
                          items: _units.map(
                            (unit) {
                              return DropdownMenuItem<
                                  String>(
                                value: unit,
                                child: Text(
                                  unit,
                                  style:
                                      AppTextStyles.body,
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUnit = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Select a unit';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // EXPIRY
                // ==================================================

                SizedBox(
                  height: _sectionSpacing(context),
                ),

                const InventorySectionTitle(
                  title: 'Expiry',
                  subtitle:
                      'Add an expiry date for products that require tracking.',
                ),

                SizedBox(
                  height: responsive.isCompact
                      ? AppSpacing.md
                      : AppSpacing.lg,
                ),

                InventoryCard(
                  child: Padding(
                    padding: _cardPadding(context),
                    child: TextFormField(
                      controller: _expiryController,
                      readOnly: true,
                      style: AppTextStyles.body,
                      onTap: _pickExpiryDate,
                      decoration: _inputDecoration(
                        label: 'Expiry date',
                        hint: 'Select expiry date',
                        icon:
                            Icons.event_outlined,
                      ).copyWith(
                        suffixIcon: const Icon(
                          Icons
                              .calendar_month_outlined,
                          size: 20,
                          color:
                              AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Select expiry date';
                        }

                        return null;
                      },
                    ),
                  ),
                ),

                // ==================================================
                // SAVE BUTTON
                // ==================================================

                SizedBox(
                  height: responsive.isCompact
                      ? AppSpacing.xxl
                      : AppSpacing.xxxl,
                ),

                SizedBox(
                  height: responsive.buttonHeight,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSaving ? null : _saveProduct,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons
                                .check_circle_outline,
                            size: 19,
                          ),
                    label: Text(
                      _isSaving
                          ? 'Saving Product...'
                          : 'Save Product',
                      style:
                          AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w700,
                      ),
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
  // COST PRICE
  // ============================================================

  Widget _buildCostPriceField() {
    return TextFormField(
      controller: _costPriceController,
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
      style: AppTextStyles.body,
      decoration: _inputDecoration(
        label: 'Cost price',
        icon:
            Icons.shopping_cart_checkout_outlined,
      ).copyWith(
        prefixText: '₦ ',
        prefixStyle: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      validator: (value) {
        final price = double.tryParse(
          value?.trim() ?? '',
        );

        if (price == null || price < 0) {
          return 'Enter valid price';
        }

        return null;
      },
    );
  }

  // ============================================================
  // SELLING PRICE
  // ============================================================

  Widget _buildSellingPriceField() {
    return TextFormField(
      controller: _sellingPriceController,
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
      style: AppTextStyles.body,
      decoration: _inputDecoration(
        label: 'Selling price',
        icon: Icons.price_check_outlined,
      ).copyWith(
        prefixText: '₦ ',
        prefixStyle: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      validator: (value) {
        final price = double.tryParse(
          value?.trim() ?? '',
        );

        if (price == null || price < 0) {
          return 'Enter valid price';
        }

        return null;
      },
    );
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

  Widget _buildImagePreview(
    Responsive responsive,
  ) {
    if (_selectedImagePath == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: responsive.isCompact ? 34 : 42,
              color: AppColors.primary,
            ),

            const SizedBox(height: 6),

            const Text(
              'No product image selected',
              style: AppTextStyles.small,
            ),
          ],
        ),
      );
    }

    final file = File(_selectedImagePath!);

    if (!file.existsSync()) {
      return const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 42,
          color: AppColors.textMuted,
        ),
      );
    }

    if (_selectedImagePath!
        .toLowerCase()
        .endsWith('.svg')) {
      return Padding(
        padding: EdgeInsets.all(
          responsive.isCompact ? 16 : 22,
        ),
        child: SvgPicture.file(
          file,
          fit: BoxFit.contain,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppRadius.lg,
      ),
      child: Image.file(
        file,
        fit: BoxFit.contain,
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _expiryController.dispose();

    super.dispose();
  }
}
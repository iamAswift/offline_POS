//lib/features/products/product_form_screen.dart
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

  @override
  void initState() {
    super.initState();

    _productDao = getProductDao();
    _categoryDao = getCategoryDao();
  }

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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const CentralBackButton(),
        title: const Text(
          'Add Product',
          style: AppTextStyles.heading,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            40,
          ),
          children: [
            const InventorySectionTitle(
              title: 'Product Information',
              subtitle:
                  'Add the basic details used to manage this product.',
            ),
            const SizedBox(height: 14),
            InventoryCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Product name',
                      hintText: 'e.g. Coca-Cola 50cl',
                      prefixIcon: Icon(
                        Icons.inventory_2_outlined,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter product name';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _brandController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      hintText: 'Optional',
                      prefixIcon: Icon(
                        Icons.sell_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<List<Category>>(
                    future:
                        _categoryDao.getAllCategories(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          height: 56,
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
                        decoration:
                            const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                          ),
                        ),
                        items: categories.map(
                          (category) {
                            return DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(
                                category.name,
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

            const SizedBox(height: 24),

            const InventorySectionTitle(
              title: 'Product Image',
              subtitle:
                  'Use a clear image so staff can identify the product quickly.',
            ),

            const SizedBox(height: 14),

            InventoryCard(
              child: Column(
                children: [
                  Container(
                    height: 190,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: _buildImagePreview(),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _pickProductImage,
                    icon: const Icon(
                      Icons.upload_file_outlined,
                    ),
                    label: Text(
                      _selectedImagePath == null
                          ? 'Upload Product Image'
                          : 'Change Image',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PNG, JPG or SVG • Maximum 2MB',
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const InventorySectionTitle(
              title: 'Pricing & Unit',
              subtitle:
                  'Set the purchasing and selling values for this product.',
            ),

            const SizedBox(height: 14),

            InventoryCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller:
                              _costPriceController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(
                            labelText: 'Cost price',
                            prefixText: '₦ ',
                            prefixIcon: Icon(
                              Icons
                                  .shopping_cart_checkout_outlined,
                            ),
                          ),
                          validator: (value) {
                            final price =
                                double.tryParse(
                              value?.trim() ?? '',
                            );

                            if (price == null ||
                                price < 0) {
                              return 'Enter valid price';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller:
                              _sellingPriceController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(
                            labelText: 'Selling price',
                            prefixText: '₦ ',
                            prefixIcon: Icon(
                              Icons
                                  .price_check_outlined,
                            ),
                          ),
                          validator: (value) {
                            final price =
                                double.tryParse(
                              value?.trim() ?? '',
                            );

                            if (price == null ||
                                price < 0) {
                              return 'Enter valid price';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration:
                        const InputDecoration(
                      labelText: 'Unit',
                      prefixIcon: Icon(
                        Icons.straighten_outlined,
                      ),
                    ),
                    items: _units.map(
                      (unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
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

            const SizedBox(height: 24),

            const InventorySectionTitle(
              title: 'Expiry',
              subtitle:
                  'Add an expiry date for products that require tracking.',
            ),

            const SizedBox(height: 14),

            InventoryCard(
              child: TextFormField(
                controller: _expiryController,
                readOnly: true,
                onTap: _pickExpiryDate,
                decoration: const InputDecoration(
                  labelText: 'Expiry date',
                  hintText: 'Select expiry date',
                  prefixIcon: Icon(
                    Icons.event_outlined,
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_month_outlined,
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

            const SizedBox(height: 30),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed:
                    _isSaving ? null : _saveProduct,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.check_circle_outline,
                      ),
                label: Text(
                  _isSaving
                      ? 'Saving Product...'
                      : 'Save Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImagePath == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            SizedBox(height: 8),
            Text(
              'No product image selected',
              style: AppTextStyles.bodySecondary,
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
          size: 48,
          color: AppColors.textMuted,
        ),
      );
    }

    if (_selectedImagePath!
        .toLowerCase()
        .endsWith('.svg')) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: SvgPicture.file(
          file,
          fit: BoxFit.contain,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.file(
        file,
        fit: BoxFit.contain,
      ),
    );
  }

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
// lib/features/category/category_screen.dart

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../core/widgets/back_button.dart';
import '../../core/widgets/category_image_picker.dart';
import '../../core/widgets/inventory_widgets.dart';
import '../../database/app_database.dart';
import '../../database/daos/category_dao.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final CategoryDao _categoryDao;

  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    _categoryDao = getCategoryDao();
  }

  Future<void> _addCategoryDialog() async {
    final nameController = TextEditingController();
    String? selectedImage;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add Category',
            style: AppTextStyles.title,
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category name',
                        hintText: 'e.g. Beverages',
                        prefixIcon: Icon(
                          Icons.category_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    CategoryImagePicker(
                      onImageSelected: (path) {
                        setDialogState(() {
                          selectedImage = path;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final name = nameController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Category name cannot be empty.',
                      ),
                    ),
                  );
                  return;
                }

                await _categoryDao.insertCategory(
                  CategoriesCompanion(
                    name: Value(name),
                    imagePath: selectedImage == null
                        ? const Value.absent()
                        : Value(selectedImage!),
                  ),
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$name category created successfully.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Category'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
  }

  Future<void> _editCategoryDialog(Category category) async {
    final nameController = TextEditingController(
      text: category.name,
    );

    String? updatedImage = category.imagePath;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Edit Category',
            style: AppTextStyles.title,
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category name',
                        prefixIcon: Icon(
                          Icons.category_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    CategoryImagePicker(
                      onImageSelected: (path) {
                        setDialogState(() {
                          updatedImage = path;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final name = nameController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Category name cannot be empty.',
                      ),
                    ),
                  );
                  return;
                }

                await _categoryDao.updateCategory(
                  Category(
                    id: category.id,
                    name: name,
                    imagePath: updatedImage,
                  ),
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Category updated successfully.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Changes'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
  }

  Future<void> _deleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Category',
            style: AppTextStyles.title,
          ),
          content: Text(
            'Are you sure you want to delete "${category.name}"?',
            style: AppTextStyles.bodySecondary,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) {
      return;
    }

    await _categoryDao.deleteCategory(category.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${category.name}" deleted.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const CentralBackButton(),
        title: const Text(
          'Categories',
          style: AppTextStyles.heading,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Category>>(
        stream: _categoryDao.watchAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return InventoryEmptyState(
              icon: Icons.error_outline,
              title: 'Unable to load categories',
              message: 'Something went wrong while loading your categories.',
              action: ElevatedButton.icon(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            );
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return InventoryEmptyState(
              icon: Icons.category_outlined,
              title: 'No categories yet',
              message:
                  'Create categories to organize your products.',
              action: ElevatedButton.icon(
                onPressed: _addCategoryDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
              ),
            );
          }

          return Padding(
            padding: AppTextStyles.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InventorySectionTitle(
                  title: 'Product Categories',
                  subtitle:
                      'Organize your inventory into easy-to-manage groups.',
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(
                        categories[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: _addCategoryDialog,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Category',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return InventoryCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: category.imagePath != null &&
                      File(category.imagePath!).existsSync()
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.file(
                        File(category.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.category_outlined,
                        size: 52,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              14,
              12,
              8,
              12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Category options',
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editCategoryDialog(category);
                    } else if (value == 'delete') {
                      _deleteCategory(category);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// lib/features/category/category_screen.dart

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
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
  // ============================================================
  // DAO
  // ============================================================

  late final CategoryDao _categoryDao;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _categoryDao = getCategoryDao();
  }

  // ============================================================
  // ADD CATEGORY
  // ============================================================

  Future<void> _addCategoryDialog() async {
    final nameController = TextEditingController();

    String? selectedImage;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add Category',
            style: AppTextStyles.title,
          ),

          content: StatefulBuilder(
            builder: (
              dialogContentContext,
              setDialogState,
            ) {
              return ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxFormWidth,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Category name',
                          hintText: 'e.g. Beverages',
                          prefixIcon: const Icon(
                            Icons.category_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.md,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      CategoryImagePicker(
                        onImageSelected: (path) {
                          setDialogState(() {
                            selectedImage = path;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton.icon(
              onPressed: () async {
                final name = nameController.text.trim();

                if (name.isEmpty) {
                  if (!dialogContext.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
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

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.of(dialogContext).pop();

                if (!mounted) {
                  return;
                }

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

  // ============================================================
  // EDIT CATEGORY
  // ============================================================

  Future<void> _editCategoryDialog(Category category) async {
    final nameController = TextEditingController(
      text: category.name,
    );

    String? updatedImage = category.imagePath;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Edit Category',
            style: AppTextStyles.title,
          ),

          content: StatefulBuilder(
            builder: (
              dialogContentContext,
              setDialogState,
            ) {
              return ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxFormWidth,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Category name',
                          prefixIcon: const Icon(
                            Icons.category_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.md,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      CategoryImagePicker(
                        onImageSelected: (path) {
                          setDialogState(() {
                            updatedImage = path;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton.icon(
              onPressed: () async {
                final name = nameController.text.trim();

                if (name.isEmpty) {
                  if (!dialogContext.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
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

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.of(dialogContext).pop();

                if (!mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Category updated successfully.',
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.save_outlined,
              ),
              label: const Text(
                'Save Changes',
              ),
            ),
          ],
        );
      },
    );

    nameController.dispose();
  }

  // ============================================================
  // DELETE CATEGORY
  // ============================================================

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
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.surface,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
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

    await _categoryDao.deleteCategory(
      category.id,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${category.name}" deleted.',
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

      appBar: AppBar(
        leading: const CentralBackButton(),

        title: const Text(
          'Categories',
          style: AppTextStyles.heading,
        ),

        backgroundColor: AppColors.primary,

        foregroundColor: AppColors.surface,

        elevation: 0,

        centerTitle: false,
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
            return _buildErrorState();
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return _buildEmptyState();
          }

          return _buildCategoryContent(
            categories,
            responsive,
          );
        },
      ),

      floatingActionButton: _buildFloatingActionButton(
        responsive,
      ),
    );
  }

  // ============================================================
  // CATEGORY CONTENT
  // ============================================================

  Widget _buildCategoryContent(
    List<Category> categories,
    Responsive responsive,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppSizes.maxContentWidth,
        ),

        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.horizontalPadding,
            vertical: responsive.verticalPadding,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InventorySectionTitle(
                title: 'Product Categories',
                subtitle:
                    'Organize your inventory into easy-to-manage groups.',
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              Expanded(
                child: LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    return GridView.builder(
                      padding: EdgeInsets.only(
                        bottom: responsive.isCompact
                            ? 80
                            : AppSpacing.xl,
                      ),

                      gridDelegate:
                          SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent:
                            responsive.isCompact
                                ? 190
                                : responsive.isTablet
                                    ? 230
                                    : 260,

                        crossAxisSpacing:
                            AppSpacing.md,

                        mainAxisSpacing:
                            AppSpacing.md,

                        // Compact cards.
                        //
                        // The image is intentionally small so
                        // many categories can remain visible.
                        childAspectRatio:
                            responsive.isCompact
                                ? 1.45
                                : responsive.isTablet
                                    ? 1.55
                                    : 1.65,
                      ),

                      itemCount: categories.length,

                      itemBuilder: (
                        context,
                        index,
                      ) {
                        return _buildCategoryCard(
                          categories[index],
                          responsive,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _buildCategoryCard(
    Category category,
    Responsive responsive,
  ) {
    final imageFile = category.imagePath == null
        ? null
        : File(category.imagePath!);

    final hasImage =
        imageFile != null && imageFile.existsSync();

    return InventoryCard(
      padding: EdgeInsets.zero,

      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),

        child: InkWell(
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),

          onTap: () {
            _editCategoryDialog(category);
          },

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              // ==================================================
              // COMPACT IMAGE
              // ==================================================

              _buildCategoryImage(
                imageFile: imageFile,
                hasImage: hasImage,
                responsive: responsive,
              ),

              // ==================================================
              // CATEGORY DETAILS
              // ==================================================

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,

                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              AppTextStyles.small.copyWith(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: AppSpacing.xs,
                      ),

                      _buildCategoryMenu(
                        category,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY IMAGE
  // ============================================================

  Widget _buildCategoryImage({
    required File? imageFile,
    required bool hasImage,
    required Responsive responsive,
  }) {
    final imageHeight = responsive.isCompact
        ? 64.0
        : responsive.isTablet
            ? 72.0
            : 78.0;

    return SizedBox(
      height: imageHeight,
      width: double.infinity,

      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(
            AppRadius.lg,
          ),
        ),

        child: Container(
          color: AppColors.primaryLight,

          child: hasImage
              ? Image.file(
                  imageFile!,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Center(
                      child: Icon(
                        Icons.category_outlined,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    );
                  },
                )
              : const Center(
                  child: Icon(
                    Icons.category_outlined,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY MENU
  // ============================================================

  Widget _buildCategoryMenu(
    Category category,
  ) {
    return PopupMenuButton<String>(
      tooltip: 'Category options',

      padding: EdgeInsets.zero,

      iconSize: 20,

      icon: const Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
      ),

      onSelected: (value) {
        if (value == 'edit') {
          _editCategoryDialog(category);
        }

        if (value == 'delete') {
          _deleteCategory(category);
        }
      },

      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit'),
        ),

        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
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

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return InventoryEmptyState(
      icon: Icons.error_outline,
      title: 'Unable to load categories',
      message:
          'Something went wrong while loading your categories.',
      action: ElevatedButton.icon(
        onPressed: () {
          setState(() {});
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Try Again'),
      ),
    );
  }

  // ============================================================
  // FLOATING ACTION BUTTON
  // ============================================================

  Widget _buildFloatingActionButton(
    Responsive responsive,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive.isCompact
            ? AppSpacing.sm
            : 0,
      ),

      child: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.surface,

        onPressed: _addCategoryDialog,

        icon: const Icon(
          Icons.add,
        ),

        label: const Text(
          'Add Category',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
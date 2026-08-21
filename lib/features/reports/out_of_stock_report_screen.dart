// lib/features/reports/out_of_stock_report_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../database/tables/product_table.dart';
import '../../shared/pdf_report.dart';

class OutOfStockReportScreen extends StatelessWidget {
  const OutOfStockReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = getDatabase();
    final productDao = ProductDao(db);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: FutureBuilder<List<Product>>(
        future: productDao.getOutOfStockProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }

          if (snapshot.hasError) {
            return _ErrorState(
              error: snapshot.error.toString(),
            );
          }

          final products = snapshot.data ?? <Product>[];

          return _buildBody(
            context,
            products,
          );
        },
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.remove_shopping_cart_outlined,
              color: AppColors.danger,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Out of Stock",
            style: AppTextStyles.title,
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.divider,
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
    BuildContext context,
    List<Product> products,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth >= 700 ? 32 : 16,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(products.length),
                  const SizedBox(height: 24),

                  _buildSummaryCard(
                    products.length,
                  ),

                  const SizedBox(height: 28),

                  _buildSectionHeader(
                    products.length,
                  ),

                  const SizedBox(height: 14),

                  if (products.isEmpty)
                    const _EmptyState()
                  else
                    _buildProductsGrid(
                      products,
                      isWide,
                    ),

                  const SizedBox(height: 32),

                  if (products.isNotEmpty)
                    _buildExportSection(
                      context,
                      products,
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Inventory alert",
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: 6),
        const Text(
          "Products that currently have no available stock.",
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 15,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              count == 0
                  ? "Inventory is fully stocked"
                  : "$count ${count == 1 ? "product requires" : "products require"} restocking",
              style: AppTextStyles.small,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummaryCard(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.danger,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Out of stock products",
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  "$count",
                  style: AppTextStyles.price.copyWith(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: count > 0
                  ? AppColors.dangerLight
                  : AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count > 0 ? "Restock needed" : "All stocked",
              style: AppTextStyles.small.copyWith(
                color: count > 0
                    ? AppColors.danger
                    : AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Products",
          style: AppTextStyles.title,
        ),
        Text(
          "$count ${count == 1 ? "item" : "items"}",
          style: AppTextStyles.small,
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCTS GRID
  // ============================================================

  Widget _buildProductsGrid(
    List<Product> products,
    bool isWide,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;

        if (constraints.maxWidth >= 1000) {
          columns = 3;
        } else if (constraints.maxWidth >= 650) {
          columns = 2;
        } else {
          columns = 1;
        }

        if (columns == 1) {
          return Column(
            children: [
              for (int i = 0; i < products.length; i++) ...[
                _buildProductCard(products[i]),
                if (i != products.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.9,
          ),
          itemBuilder: (context, index) {
            return _buildProductCard(products[index]);
          },
        );
      },
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.remove_shopping_cart_outlined,
              color: AppColors.danger,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                const Text(
                  "Current stock",
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "0 units",
              style: AppTextStyles.small.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPORT
  // ============================================================

  Widget _buildExportSection(
    BuildContext context,
    List<Product> products,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;

          const content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.picture_as_pdf_outlined,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Export inventory report",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Generate a PDF containing all products currently out of stock.",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final button = ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(
              Icons.download_outlined,
              size: 19,
            ),
            label: const Text(
              "Export PDF",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => _exportPdf(
              context,
              products,
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 16),
                button,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: content,
              ),
              const SizedBox(width: 20),
              button,
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // PDF EXPORT
  // ============================================================

  Future<void> _exportPdf(
    BuildContext context,
    List<Product> products,
  ) async {
    try {
      final file = await PdfReport.generateReport(
        title: "Out of Stock Report",
        sections: [
          {
            "title": "Out of Stock Products",
            "headers": [
              "Product",
              "Stock",
            ],
            "rows": products
                .map(
                  (product) => [
                    product.name,
                    "0",
                  ],
                )
                .toList(),
          },
        ],
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          content: Text(
            "PDF saved at ${file.path}",
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text(
            "Unable to generate PDF: $e",
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No products out of stock",
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 7),
          const Text(
            "All products currently have available inventory.",
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOADING STATE
// ============================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              "Loading inventory report...",
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Unable to load report",
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: SelectableText(
                  error,
                  style: AppTextStyles.small,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
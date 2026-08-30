// lib/features/reports/out_of_stock_report_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../shared/pdf_report.dart';

class OutOfStockReportScreen extends StatefulWidget {
  const OutOfStockReportScreen({super.key});

  @override
  State<OutOfStockReportScreen> createState() => _OutOfStockReportScreenState();
}

class _OutOfStockReportScreenState extends State<OutOfStockReportScreen> {
  late final ProductDao productDao;

  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    final db = getDatabase();
    productDao = ProductDao(db);

    _loadReport();
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  Future<void> _loadReport() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final products = await productDao.getOutOfStockProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
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
          const Text('Out of Stock', style: AppTextStyles.title),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadReport,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const _OutOfStockLoadingState();
    }

    if (_error != null) {
      return _OutOfStockErrorState(error: _error!, onRetry: _loadReport);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadReport,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(),

                    const SizedBox(height: 24),

                    _buildSummaryCard(count: _products.length),

                    const SizedBox(height: 28),

                    _buildProductsSection(products: _products),

                    const SizedBox(height: 32),

                    if (_products.isNotEmpty)
                      _buildExportSection(
                        context: context,
                        products: _products,
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    final count = _products.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Inventory alert', style: AppTextStyles.heading),
        const SizedBox(height: 6),
        const Text(
          'Products that currently have no available stock.',
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
                  ? 'Inventory is fully stocked'
                  : '$count '
                        '${count == 1 ? 'product requires' : 'products require'} '
                        'restocking',
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

  Widget _buildSummaryCard({required int count}) {
    final hasOutOfStock = count > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildSummaryIcon(hasOutOfStock: hasOutOfStock),
                    const SizedBox(width: 14),
                    Expanded(child: _buildSummaryContent(count: count)),
                  ],
                ),
                const SizedBox(height: 14),
                _buildSummaryBadge(hasOutOfStock: hasOutOfStock),
              ],
            );
          }

          return Row(
            children: [
              _buildSummaryIcon(hasOutOfStock: hasOutOfStock),
              const SizedBox(width: 16),
              Expanded(child: _buildSummaryContent(count: count)),
              const SizedBox(width: 16),
              _buildSummaryBadge(hasOutOfStock: hasOutOfStock),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryIcon({required bool hasOutOfStock}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: hasOutOfStock ? AppColors.dangerLight : AppColors.successLight,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        hasOutOfStock
            ? Icons.remove_shopping_cart_outlined
            : Icons.check_circle_outline,
        color: hasOutOfStock ? AppColors.danger : AppColors.success,
        size: 26,
      ),
    );
  }

  Widget _buildSummaryContent({required int count}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Out of stock products', style: AppTextStyles.bodySecondary),
        const SizedBox(height: 4),
        Text('$count', style: AppTextStyles.price.copyWith(fontSize: 24)),
      ],
    );
  }

  Widget _buildSummaryBadge({required bool hasOutOfStock}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: hasOutOfStock ? AppColors.dangerLight : AppColors.successLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        hasOutOfStock ? 'Restock needed' : 'All stocked',
        style: AppTextStyles.small.copyWith(
          color: hasOutOfStock ? AppColors.danger : AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCTS SECTION
  // ============================================================

  Widget _buildProductsSection({required List<Product> products}) {
    final count = products.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Products', style: AppTextStyles.title),
            if (count > 0)
              Text(
                '$count ${count == 1 ? 'item' : 'items'}',
                style: AppTextStyles.small,
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (products.isEmpty)
          const _OutOfStockEmptyState()
        else
          _buildProductsGrid(products),
      ],
    );
  }

  // ============================================================
  // PRODUCTS GRID
  // ============================================================

  Widget _buildProductsGrid(List<Product> products) {
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
                if (i < products.length - 1) const SizedBox(height: 12),
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
            childAspectRatio: 3.0,
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
        border: Border.all(color: AppColors.border),
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
                  style: AppTextStyles.title.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                const Text('Current stock', style: AppTextStyles.small),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '0 units',
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

  Widget _buildExportSection({
    required BuildContext context,
    required List<Product> products,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
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
          final compact = constraints.maxWidth < 650;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExportContent(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _buildExportButton(
                    context: context,
                    products: products,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _buildExportContent()),
              const SizedBox(width: 20),
              _buildExportButton(context: context, products: products),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExportContent() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 30),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export out-of-stock report',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Generate a PDF containing all products '
                'currently out of stock.',
                style: TextStyle(
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
  }

  Widget _buildExportButton({
    required BuildContext context,
    required List<Product> products,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.download_outlined, size: 19),
      label: const Text(
        'Export PDF',
        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
      onPressed: () => _exportPdf(context: context, products: products),
    );
  }

  // ============================================================
  // PDF EXPORT
  // ============================================================

  Future<void> _exportPdf({
    required BuildContext context,
    required List<Product> products,
  }) async {
    try {
      final file = await PdfReport.generateReport(
        title: 'Out of Stock Report',
        sections: [
          {
            'title': 'Out of Stock Products',
            'headers': ['Product', 'Stock'],
            'rows': products.map((product) => [product.name, '0']).toList(),
          },
        ],
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          content: Text(
            'PDF saved at ${file.path}',
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
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
            'Unable to generate PDF: $e',
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
          ),
        ),
      );
    }
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _OutOfStockEmptyState extends StatelessWidget {
  const _OutOfStockEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
            'No products out of stock',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 7),
          const Text(
            'All products currently have available inventory.',
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

class _OutOfStockLoadingState extends StatelessWidget {
  const _OutOfStockLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading inventory report...',
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

class _OutOfStockErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _OutOfStockErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
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
                'Unable to load out-of-stock report',
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
                  border: Border.all(color: AppColors.border),
                ),
                child: SelectableText(
                  error,
                  style: AppTextStyles.small,
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

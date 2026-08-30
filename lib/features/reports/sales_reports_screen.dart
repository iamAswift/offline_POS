// lib/features/reports/sales_report_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/sales_dao.dart';
import '../../shared/pdf_report.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final db = getDatabase();

  late final SalesDao salesDao;
  late final ProductDao productDao;

  String _selectedFilter = 'Day';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();

    salesDao = SalesDao(db);
    productDao = ProductDao(db);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final range = _getRange();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          salesDao.getTotalSales(
            range.start,
            range.end,
          ),
          salesDao.getItemsSold(
            range.start,
            range.end,
          ),
          salesDao.getProfit(
            range.start,
            range.end,
          ),
          salesDao.getPaymentBreakdown(
            range.start,
            range.end,
          ),
          productDao.getLowStockProducts(),
          salesDao.getAllSales(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }

          if (snapshot.hasError) {
            return _ErrorState(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {});
              },
            );
          }

          if (!snapshot.hasData || snapshot.data!.length < 6) {
            return const _EmptyState();
          }

          final data = snapshot.data!;

          final totalSales = _toDouble(data[0]);
          final itemsSold = _toInt(data[1]);
          final profit = _toDouble(data[2]);

          final paymentBreakdown = _normalisePaymentBreakdown(
            data[3] as Map,
          );

          final lowStock = List<Product>.from(
            data[4] as List,
          );

          final allSales = List<Sale>.from(
            data[5] as List,
          );

          final filteredSales = allSales.where((sale) {
            return !sale.createdAt.isBefore(range.start) &&
                sale.createdAt.isBefore(range.end);
          }).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              setState(() {});
              await Future<void>.delayed(
                const Duration(milliseconds: 250),
              );
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: _horizontalPadding(width),
                    vertical: _verticalPadding(width),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1400,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(
                            range,
                            width,
                          ),

                          SizedBox(
                            height: _sectionSpacing(width),
                          ),

                          _buildOverviewSection(
                            totalSales: totalSales,
                            itemsSold: itemsSold,
                            profit: profit,
                            width: width,
                          ),

                          SizedBox(
                            height: _sectionSpacing(width),
                          ),

                          _buildPaymentSection(
                            paymentBreakdown,
                            width,
                          ),

                          SizedBox(
                            height: _sectionSpacing(width),
                          ),

                          _buildTransactionsSection(
                            filteredSales,
                            width,
                          ),

                          SizedBox(
                            height: _sectionSpacing(width),
                          ),

                          _buildLowStockSection(
                            lowStock,
                            width,
                          ),

                          SizedBox(
                            height: _sectionSpacing(width),
                          ),

                          _buildExportSection(
                            range: range,
                            totalSales: totalSales,
                            itemsSold: itemsSold,
                            profit: profit,
                            paymentBreakdown: paymentBreakdown,
                            lowStock: lowStock,
                            sales: filteredSales,
                            width: width,
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      titleSpacing: 20,
      toolbarHeight: 68,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text(
              'Sales Report',
              style: AppTextStyles.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildFilterDropdown(),
        ),
      ],
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
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(
    DateTimeRange range,
    double width,
  ) {
    final compact = width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales performance',
          style: compact
              ? AppTextStyles.title.copyWith(
                  fontSize: 20,
                )
              : AppTextStyles.heading,
        ),
        const SizedBox(height: 6),
        const Text(
          'Review sales, items sold, profit and payment activity.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 7),
              Text(
                _formatDateRange(range),
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverviewSection({
    required double totalSales,
    required int itemsSold,
    required double profit,
    required double width,
  }) {
    final cards = [
      _metricCard(
        title: 'Total Sales',
        value: _formatCurrency(totalSales),
        icon: Icons.payments_outlined,
        color: AppColors.primary,
        backgroundColor: AppColors.primaryLight,
      ),
      _metricCard(
        title: 'Items Sold',
        value: _formatNumber(itemsSold),
        icon: Icons.shopping_cart_outlined,
        color: AppColors.info,
        backgroundColor: AppColors.infoLight,
      ),
      _metricCard(
        title: 'Profit',
        value: _formatCurrency(profit),
        icon: Icons.trending_up,
        color: AppColors.success,
        backgroundColor: AppColors.successLight,
      ),
    ];

    final mobile = width < 600;
    final tablet = width >= 600 && width < 950;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: AppTextStyles.title,
        ),
        const SizedBox(height: 14),
        if (mobile)
          Column(
            children: [
              cards[0],
              const SizedBox(height: 12),
              cards[1],
              const SizedBox(height: 12),
              cards[2],
            ],
          )
        else if (tablet)
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const Expanded(
                    child: SizedBox(),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
              const SizedBox(width: 16),
              Expanded(child: cards[2]),
            ],
          ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 98,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT BREAKDOWN
  // ============================================================

  Widget _buildPaymentSection(
    Map<String, double> paymentBreakdown,
    double width,
  ) {
    final cash = paymentBreakdown['cash'] ?? 0;
    final pos = paymentBreakdown['pos'] ?? 0;
    final transfer = paymentBreakdown['transfer'] ?? 0;

    final total = cash + pos + transfer;

    final items = [
      _PaymentData(
        title: 'Cash',
        value: cash,
        icon: Icons.payments_outlined,
        color: AppColors.success,
      ),
      _PaymentData(
        title: 'POS',
        value: pos,
        icon: Icons.point_of_sale_outlined,
        color: AppColors.pos,
      ),
      _PaymentData(
        title: 'Transfer',
        value: transfer,
        icon: Icons.account_balance_outlined,
        color: AppColors.info,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Payment breakdown',
                style: AppTextStyles.title,
              ),
            ),
            _sectionBadge(
              icon: Icons.account_balance_wallet_outlined,
              text: 'Payments',
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: EdgeInsets.all(
            width < 600 ? 16 : 18,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  children: [
                    _paymentRow(
                      data: items[0],
                      total: total,
                    ),
                    const SizedBox(height: 18),
                    _paymentRow(
                      data: items[1],
                      total: total,
                    ),
                    const SizedBox(height: 18),
                    _paymentRow(
                      data: items[2],
                      total: total,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _paymentRow(
                      data: items[0],
                      total: total,
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: _paymentRow(
                      data: items[1],
                      total: total,
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: _paymentRow(
                      data: items[2],
                      total: total,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _paymentRow({
    required _PaymentData data,
    required double total,
  }) {
    final percentage = total > 0 ? data.value / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                data.icon,
                color: data.color,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                data.title,
                style: AppTextStyles.bodySecondary,
              ),
            ),
            Text(
              _formatCurrency(data.value),
              style: AppTextStyles.title.copyWith(
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 7,
            backgroundColor: AppColors.surfaceSoft,
            color: data.color,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}% of payments',
          style: AppTextStyles.small,
        ),
      ],
    );
  }

  Widget _sectionBadge({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Widget _buildTransactionsSection(
    List<Sale> sales,
    double width,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Sales transactions',
                style: AppTextStyles.title,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${sales.length} ${sales.length == 1 ? 'sale' : 'sales'}',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
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
          child: sales.isEmpty
              ? _buildNoSalesState()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final desktop = constraints.maxWidth >= 850;

                    return Column(
                      children: [
                        if (desktop)
                          _buildDesktopTransactionHeader(),
                        for (int i = 0; i < sales.length; i++)
                          _buildTransactionItem(
                            sales[i],
                            isLast: i == sales.length - 1,
                            desktop: desktop,
                          ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDesktopTransactionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              'Sale',
              style: AppTextStyles.small,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Date & time',
              style: AppTextStyles.small,
            ),
          ),
          Expanded(
            child: Text(
              'Payment',
              style: AppTextStyles.small,
            ),
          ),
          Expanded(
            child: Text(
              'Quantity',
              style: AppTextStyles.small,
            ),
          ),
          Expanded(
            child: Text(
              'Total',
              textAlign: TextAlign.right,
              style: AppTextStyles.small,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    Sale sale, {
    required bool isLast,
    required bool desktop,
  }) {
    final profit =
        (sale.unitPrice.toDouble() - sale.costPriceAtSale) *
        sale.quantity;

    final payment = _formatPaymentName(
      sale.paymentMethod,
    );

    final total = sale.totalPrice.toDouble();

    if (!desktop) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: isLast
            ? null
            : const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.divider,
                  ),
                ),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _saleIcon(
                  sale.paymentMethod,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sale #${sale.id}',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDateTime(sale.createdAt),
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatCurrency(total),
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(
                  icon: Icons.payments_outlined,
                  label: payment,
                ),
                _infoChip(
                  icon: Icons.shopping_cart_outlined,
                  label:
                      '${sale.quantity} ${sale.quantity == 1 ? 'item' : 'items'}',
                ),
                _infoChip(
                  icon: Icons.trending_up,
                  label: 'Profit ${_formatCurrency(profit)}',
                  color: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.divider,
                ),
              ),
            ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '#${sale.id}',
              style: AppTextStyles.title.copyWith(
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDateTime(sale.createdAt),
              style: AppTextStyles.small,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _saleIcon(
                  sale.paymentMethod,
                  size: 30,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    payment,
                    style: AppTextStyles.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${sale.quantity}',
              style: AppTextStyles.small,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(total),
                  style: AppTextStyles.title.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Profit ${_formatCurrency(profit)}',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _saleIcon(
    String paymentMethod, {
    double size = 38,
  }) {
    final method = paymentMethod.toLowerCase().trim();

    IconData icon;
    Color color;

    switch (method) {
      case 'cash':
        icon = Icons.payments_outlined;
        color = AppColors.success;
        break;

      case 'pos':
        icon = Icons.point_of_sale_outlined;
        color = AppColors.pos;
        break;

      case 'transfer':
        icon = Icons.account_balance_outlined;
        color = AppColors.info;
        break;

      case 'split':
        icon = Icons.call_split_outlined;
        color = AppColors.warning;
        break;

      case 'credit':
        icon = Icons.credit_score_outlined;
        color = AppColors.warning;
        break;

      default:
        icon = Icons.receipt_long_outlined;
        color = AppColors.primary;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.50,
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSalesState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textMuted,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No sales in this period',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 5),
          const Text(
            'There are no completed sales to display for the selected period.',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOW STOCK
  // ============================================================

  Widget _buildLowStockSection(
    List<Product> lowStock,
    double width,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Low stock',
                style: AppTextStyles.title,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: lowStock.isEmpty
                    ? AppColors.successLight
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lowStock.isEmpty
                    ? 'Stock healthy'
                    : '${lowStock.length} items',
                style: AppTextStyles.small.copyWith(
                  color: lowStock.isEmpty
                      ? AppColors.success
                      : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
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
          child: lowStock.isEmpty
              ? _buildHealthyStockState()
              : Column(
                  children: [
                    for (int i = 0; i < lowStock.length; i++)
                      _buildLowStockItem(
                        lowStock[i],
                        isLast: i == lowStock.length - 1,
                        compact: width < 600,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildHealthyStockState() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Inventory looks healthy',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 5),
          const Text(
            'All products are currently above their low-stock threshold.',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(
    Product product, {
    required bool isLast,
    required bool compact,
  }) {
    final stockLabel =
        '${product.stock} ${product.stock == 1 ? 'unit' : 'units'}';

    return Container(
      padding: EdgeInsets.all(
        compact ? 14 : 16,
      ),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.divider,
                ),
              ),
            ),
      child: Row(
        children: [
          Container(
            width: compact ? 40 : 42,
            height: compact ? 40 : 42,
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                const SizedBox(height: 3),
                const Text(
                  'Inventory level is low',
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
              stockLabel,
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
    required DateTimeRange range,
    required double totalSales,
    required int itemsSold,
    required double profit,
    required Map<String, double> paymentBreakdown,
    required List<Product> lowStock,
    required List<Sale> sales,
    required double width,
  }) {
    final compact = width < 650;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        compact ? 18 : 20,
      ),
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
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _exportContent(),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: _exportButton(
                    range: range,
                    totalSales: totalSales,
                    itemsSold: itemsSold,
                    profit: profit,
                    paymentBreakdown: paymentBreakdown,
                    lowStock: lowStock,
                    sales: sales,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _exportContent(),
                ),
                const SizedBox(width: 20),
                _exportButton(
                  range: range,
                  totalSales: totalSales,
                  itemsSold: itemsSold,
                  profit: profit,
                  paymentBreakdown: paymentBreakdown,
                  lowStock: lowStock,
                  sales: sales,
                ),
              ],
            ),
    );
  }

  Widget _exportContent() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.picture_as_pdf_outlined,
          color: Colors.white,
          size: 30,
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export sales report',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Generate a PDF containing sales, payment and inventory information for the selected period.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _exportButton({
    required DateTimeRange range,
    required double totalSales,
    required int itemsSold,
    required double profit,
    required Map<String, double> paymentBreakdown,
    required List<Product> lowStock,
    required List<Sale> sales,
  }) {
    return ElevatedButton.icon(
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
        'Export PDF',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () async {
        try {
          final file = await PdfReport.generateReport(
            title: 'Sales Report',
            sections: [
              {
                'title': _selectedFilter == 'Day'
                    ? 'Daily Overview'
                    : 'Sales Overview',
                'headers': [
                  'Metric',
                  'Value',
                ],
                'rows': [
                  [
                    'Period',
                    _formatDateRange(range),
                  ],
                  [
                    'Total Sales',
                    _formatCurrency(totalSales),
                  ],
                  [
                    'Items Sold',
                    _formatNumber(itemsSold),
                  ],
                  [
                    'Profit',
                    _formatCurrency(profit),
                  ],
                ],
              },
              {
                'title': 'Payment Breakdown',
                'headers': [
                  'Method',
                  'Amount',
                ],
                'rows': paymentBreakdown.entries
                    .map(
                      (e) => [
                        _formatPaymentName(e.key),
                        _formatCurrency(e.value),
                      ],
                    )
                    .toList(),
              },
              {
                'title': 'Sales Transactions',
                'headers': [
                  'Sale',
                  'Date',
                  'Payment',
                  'Quantity',
                  'Total',
                  'Profit',
                ],
                'rows': sales.map(
                  (sale) {
                    final saleProfit =
                        (sale.unitPrice.toDouble() -
                                sale.costPriceAtSale) *
                            sale.quantity;

                    return [
                      '#${sale.id}',
                      _formatDateTime(sale.createdAt),
                      _formatPaymentName(
                        sale.paymentMethod,
                      ),
                      '${sale.quantity}',
                      _formatCurrency(
                        sale.totalPrice.toDouble(),
                      ),
                      _formatCurrency(saleProfit),
                    ];
                  },
                ).toList(),
              },
              {
                'title': 'Low Stock',
                'headers': [
                  'Product',
                  'Stock',
                ],
                'rows': lowStock
                    .map(
                      (product) => [
                        product.name,
                        '${product.stock}',
                      ],
                    )
                    .toList(),
              },
            ],
          );

          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.success,
              content: Text(
                'PDF saved at ${file.path}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          );
        } catch (e) {
          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.danger,
              content: Text(
                'Unable to generate PDF: $e',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilterDropdown() {
    return SizedBox(
      width: 132,
      height: 42,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedFilter,
            isExpanded: true,
            borderRadius: BorderRadius.circular(10),
            dropdownColor: AppColors.surface,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            style: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            selectedItemBuilder: (context) {
              return const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Today'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('This Week'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('This Month'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('This Year'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Custom'),
                ),
              ];
            },
            items: const [
              DropdownMenuItem<String>(
                value: 'Day',
                child: Text('Today'),
              ),
              DropdownMenuItem<String>(
                value: 'Week',
                child: Text('This Week'),
              ),
              DropdownMenuItem<String>(
                value: 'Month',
                child: Text('This Month'),
              ),
              DropdownMenuItem<String>(
                value: 'Year',
                child: Text('This Year'),
              ),
              DropdownMenuItem<String>(
                value: 'Custom',
                child: Text('Custom'),
              ),
            ],
            onChanged: (String? value) async {
              if (value == null) {
                return;
              }

              if (value == 'Custom') {
                await _selectCustomDateRange();
                return;
              }

              setState(() {
                _selectedFilter = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final existingRange = _selectedDateRange;

    final initialRange = existingRange ??
        DateTimeRange(
          start: today.subtract(
            const Duration(days: 7),
          ),
          end: today,
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _selectedDateRange = picked;
      _selectedFilter = 'Custom';
    });
  }

  // ============================================================
  // DATE RANGE
  // ============================================================

  DateTimeRange _getRange() {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    switch (_selectedFilter) {
      case 'Day':
        return DateTimeRange(
          start: today,
          end: today.add(
            const Duration(days: 1),
          ),
        );

      case 'Week':
        final start = today.subtract(
          Duration(
            days: today.weekday - 1,
          ),
        );

        return DateTimeRange(
          start: start,
          end: start.add(
            const Duration(days: 7),
          ),
        );

      case 'Month':
        final start = DateTime(
          now.year,
          now.month,
          1,
        );

        final end = DateTime(
          now.year,
          now.month + 1,
          1,
        );

        return DateTimeRange(
          start: start,
          end: end,
        );

      case 'Year':
        final start = DateTime(
          now.year,
          1,
          1,
        );

        final end = DateTime(
          now.year + 1,
          1,
          1,
        );

        return DateTimeRange(
          start: start,
          end: end,
        );

      case 'Custom':
        final selected = _selectedDateRange;

        if (selected == null) {
          return DateTimeRange(
            start: today.subtract(
              const Duration(days: 7),
            ),
            end: today.add(
              const Duration(days: 1),
            ),
          );
        }

        final start = DateTime(
          selected.start.year,
          selected.start.month,
          selected.start.day,
        );

        final end = DateTime(
          selected.end.year,
          selected.end.month,
          selected.end.day,
        ).add(
          const Duration(days: 1),
        );

        return DateTimeRange(
          start: start,
          end: end,
        );

      default:
        return DateTimeRange(
          start: today,
          end: today.add(
            const Duration(days: 1),
          ),
        );
    }
  }

  // ============================================================
  // FORMATTING
  // ============================================================

  String _formatDateRange(DateTimeRange range) {
    final start = _formatDate(range.start);

    if (_selectedFilter == 'Day') {
      return start;
    }

    final end = _formatDate(
      range.end.subtract(
        const Duration(days: 1),
      ),
    );

    return '$start – $end';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${_formatDate(date)} • $hour:$minute $period';
  }

  String _formatCurrency(double value) {
    return '₦${_formatNumber(value.round())}';
  }

  String _formatNumber(num value) {
    final number = value.toInt();
    final string = number.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < string.length; i++) {
      if (i > 0 && (string.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(string[i]);
    }

    return buffer.toString();
  }

  String _formatPaymentName(String value) {
    switch (value.toLowerCase().trim()) {
      case 'cash':
        return 'Cash';

      case 'pos':
        return 'POS';

      case 'transfer':
        return 'Transfer';

      case 'split':
        return 'Split';

      case 'credit':
        return 'Credit';

      default:
        if (value.isEmpty) {
          return value;
        }

        return value[0].toUpperCase() +
            value.substring(1);
    }
  }

  Map<String, double> _normalisePaymentBreakdown(
    Map raw,
  ) {
    return {
      'cash': _toDouble(raw['cash']),
      'pos': _toDouble(raw['pos']),
      'transfer': _toDouble(raw['transfer']),
    };
  }

  // ============================================================
  // CONVERSIONS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // RESPONSIVE HELPERS
  // ============================================================

  double _horizontalPadding(double width) {
    if (width >= 1200) {
      return 32;
    }

    if (width >= 700) {
      return 24;
    }

    return 16;
  }

  double _verticalPadding(double width) {
    if (width >= 1200) {
      return 28;
    }

    if (width >= 700) {
      return 24;
    }

    return 20;
  }

  double _sectionSpacing(double width) {
    if (width >= 1000) {
      return 28;
    }

    if (width >= 600) {
      return 24;
    }

    return 20;
  }
}

// ============================================================
// PAYMENT MODEL
// ============================================================

class _PaymentData {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const _PaymentData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// ============================================================
// LOADING
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
              'Loading sales report...',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY
// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 16),
            Text(
              'No sales data available',
              style: AppTextStyles.title,
            ),
            SizedBox(height: 6),
            Text(
              'There is currently no sales data to display.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
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
                'Unable to load sales report',
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
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                ),
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
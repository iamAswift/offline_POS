// lib/features/suppliers/supplier_statement_screen.dart

import 'package:flutter/material.dart';

import 'package:supermarket_inventory/core/widgets/back_button.dart';

import '../../core/theme/styles.dart';
import '../../core/responsive/responsive.dart';
import '../../database/app_database.dart';
import '../../database/daos/supplier_payment_dao.dart';
import '../../database/daos/supplier_delivery_dao.dart';

class SupplierStatementScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierStatementScreen({super.key, required this.supplier});

  @override
  State<SupplierStatementScreen> createState() =>
      _SupplierStatementScreenState();
}

class _SupplierStatementScreenState extends State<SupplierStatementScreen> {
  late final SupplierPaymentDao _paymentDao;
  late final SupplierDeliveryDao _deliveryDao;

  bool _loading = true;

  double _totalPurchases = 0;
  double _totalPaid = 0;
  double _outstanding = 0;

  List<SupplierDelivery> _deliveries = [];
  List<SupplierPayment> _payments = [];

  @override
  void initState() {
    super.initState();

    _paymentDao = getSupplierPaymentDao();
    _deliveryDao = getSupplierDeliveryDao();

    _loadStatement();
  }

  // ============================================================
  // LOAD STATEMENT
  // ============================================================

  Future<void> _loadStatement() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final supplierId = widget.supplier.id;

      final results = await Future.wait([
        _deliveryDao.getSupplierPurchaseTotal(supplierId),
        _paymentDao.getSupplierPaymentTotal(supplierId),
        _deliveryDao.getDeliveriesForSupplier(supplierId),
        _paymentDao.getPaymentsForSupplier(supplierId),
      ]);

      final purchases = results[0] as double;
      final paid = results[1] as double;

      final deliveries = results[2] as List<SupplierDelivery>;
      final payments = results[3] as List<SupplierPayment>;

      if (!mounted) return;

      setState(() {
        _totalPurchases = purchases;
        _totalPaid = paid;
        _outstanding = purchases - paid;
        _deliveries = deliveries;
        _payments = payments;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Supplier statement error: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showError('Unable to load supplier statement.\n$e');
    }
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

        title: const Text('Supplier Statement', style: AppTextStyles.heading),

        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,

        actions: [
          SizedBox(
            width: AppSizes.iconButton,
            height: AppSizes.iconButton,
            child: IconButton(
              tooltip: 'Refresh',
              onPressed: _loadStatement,
              icon: const Icon(Icons.refresh, size: 21),
              padding: EdgeInsets.zero,
            ),
          ),

          SizedBox(width: responsive.isCompact ? 4 : 8),
        ],
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadStatement,

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                  vertical: responsive.verticalPadding,
                ),

                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: responsive.contentMaxWidth,
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          _buildSupplierHeader(responsive),

                          SizedBox(
                            height: responsive.isCompact
                                ? AppSpacing.lg
                                : AppSpacing.xl,
                          ),

                          _buildSummaryCards(responsive),

                          SizedBox(
                            height: responsive.isCompact
                                ? AppSpacing.xxl
                                : AppSpacing.xxxl,
                          ),

                          _buildStatementSection(responsive),

                          SizedBox(
                            height: responsive.isCompact
                                ? AppSpacing.xxxl
                                : AppSpacing.section,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // SUPPLIER HEADER
  // ============================================================

  Widget _buildSupplierHeader(Responsive responsive) {
    final compact = responsive.isCompact;

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(AppRadius.xl),

        border: Border.all(color: AppColors.border),
      ),

      child: Row(
        children: [
          Container(
            width: compact ? 58 : 68,
            height: compact ? 58 : 68,

            decoration: BoxDecoration(
              color: AppColors.primaryLight,

              borderRadius: BorderRadius.circular(
                compact ? AppRadius.lg : AppRadius.xl,
              ),
            ),

            child: Icon(
              Icons.business_outlined,
              size: compact ? 30 : 34,
              color: AppColors.primary,
            ),
          ),

          SizedBox(width: compact ? AppSpacing.md : AppSpacing.lg),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  widget.supplier.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: compact ? AppTextStyles.title : AppTextStyles.heading,
                ),

                if ((widget.supplier.contact ?? '').isNotEmpty) ...[
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          widget.supplier.contact!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                if ((widget.supplier.address ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          widget.supplier.address!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARDS
  // ============================================================

  Widget _buildSummaryCards(Responsive responsive) {
    final compact = responsive.isCompact;

    return GridView.count(
      crossAxisCount: 2,

      crossAxisSpacing: compact ? AppSpacing.md : AppSpacing.lg,

      mainAxisSpacing: compact ? AppSpacing.md : AppSpacing.lg,

      childAspectRatio: compact ? 1.55 : 2.5,

      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      children: [
        _summaryCard(
          title: 'Total Purchases',
          amount: _totalPurchases,
          icon: Icons.inventory_2_outlined,
          color: AppColors.primary,
          background: AppColors.primaryLight,
        ),

        _summaryCard(
          title: 'Total Paid',
          amount: _totalPaid,
          icon: Icons.payments_outlined,
          color: AppColors.success,
          background: AppColors.successLight,
        ),

        _summaryCard(
          title: 'Outstanding',
          amount: _outstanding > 0 ? _outstanding : 0,
          icon: Icons.account_balance_wallet_outlined,
          color: _outstanding > 0 ? AppColors.warning : AppColors.success,
          background: _outstanding > 0
              ? AppColors.warningLight
              : AppColors.successLight,
        ),

        _summaryCard(
          title: 'Transactions',
          amount: (_deliveries.length + _payments.length).toDouble(),
          icon: Icons.receipt_long_outlined,
          color: AppColors.info,
          background: AppColors.infoLight,
          isCount: true,
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required Color background,
    bool isCount = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(AppRadius.xl),

        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 1),

                decoration: BoxDecoration(
                  color: background,

                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),

                child: Icon(icon, size: 20, color: color),
              ),

              const Spacer(),

              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.small,
                ),
              ),
            ],
          ),

          const Spacer(),

          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,

            child: Text(
              isCount ? amount.toInt().toString() : _money(amount),

              style: AppTextStyles.price,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATEMENT SECTION
  // ============================================================

  Widget _buildStatementSection(Responsive responsive) {
    final transactions = _buildTransactions();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(AppRadius.xl),

        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg + 2),

            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),

                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,

                    borderRadius: BorderRadius.circular(AppRadius.md + 1),
                  ),

                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 19,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                const Expanded(
                  child: Text('Account Statement', style: AppTextStyles.title),
                ),

                Text(
                  '${transactions.length} entries',
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          if (transactions.isEmpty)
            _buildEmptyStatement()
          else
            _buildTransactionList(transactions, responsive),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD TRANSACTIONS
  // ============================================================

  List<_StatementTransaction> _buildTransactions() {
    final transactions = <_StatementTransaction>[];

    for (final delivery in _deliveries) {
      transactions.add(
        _StatementTransaction(
          date: delivery.deliveryDate,
          type: _StatementTransactionType.purchase,
          description: (delivery.invoiceNumber ?? '').isNotEmpty
              ? 'Invoice ${delivery.invoiceNumber}'
              : 'Delivery #${delivery.id}',
          amount: delivery.totalAmount,
          reference: delivery.invoiceNumber,
          id: delivery.id,
        ),
      );
    }

    for (final payment in _payments) {
      transactions.add(
        _StatementTransaction(
          date: payment.paymentDate,
          type: _StatementTransactionType.payment,
          description: '${_capitalize(payment.paymentMethod)} payment',
          amount: payment.amount,
          reference: payment.reference,
          id: payment.id,
        ),
      );
    }

    transactions.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);

      if (dateCompare != 0) {
        return dateCompare;
      }

      return a.id.compareTo(b.id);
    });

    double runningBalance = 0;

    for (final transaction in transactions) {
      if (transaction.type == _StatementTransactionType.purchase) {
        runningBalance += transaction.amount;
      } else {
        runningBalance -= transaction.amount;
      }

      transaction.runningBalance = runningBalance;
    }

    return transactions;
  }

  // ============================================================
  // TRANSACTION LIST
  // ============================================================

  Widget _buildTransactionList(
    List<_StatementTransaction> transactions,
    Responsive responsive,
  ) {
    final useTableLayout = responsive.isTablet || responsive.isDesktop;

    return Column(
      children: [
        if (useTableLayout) _buildDesktopHeader(),

        ...transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;

          return _buildTransactionTile(transaction, index, useTableLayout);
        }),
      ],
    );
  }

  // ============================================================
  // DESKTOP HEADER
  // ============================================================

  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg + 2,
        vertical: AppSpacing.md,
      ),

      color: AppColors.background,

      child: const Row(
        children: [
          SizedBox(width: 90, child: Text('Date', style: AppTextStyles.small)),

          Expanded(
            flex: 3,
            child: Text('Description', style: AppTextStyles.small),
          ),

          Expanded(
            child: Text(
              'Debit',
              textAlign: TextAlign.right,
              style: AppTextStyles.small,
            ),
          ),

          Expanded(
            child: Text(
              'Credit',
              textAlign: TextAlign.right,
              style: AppTextStyles.small,
            ),
          ),

          Expanded(
            child: Text(
              'Balance',
              textAlign: TextAlign.right,
              style: AppTextStyles.small,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION TILE
  // ============================================================

  Widget _buildTransactionTile(
    _StatementTransaction transaction,
    int index,
    bool useTableLayout,
  ) {
    final isPurchase = transaction.type == _StatementTransactionType.purchase;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg + 2,
        vertical: AppSpacing.md + 2,
      ),

      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),

      child: useTableLayout
          ? _buildDesktopTransaction(transaction, isPurchase)
          : _buildMobileTransaction(transaction, isPurchase),
    );
  }

  // ============================================================
  // DESKTOP TRANSACTION
  // ============================================================

  Widget _buildDesktopTransaction(
    _StatementTransaction transaction,
    bool isPurchase,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            _formatDate(transaction.date),
            style: AppTextStyles.small,
          ),
        ),

        Expanded(
          flex: 3,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm - 1),

                decoration: BoxDecoration(
                  color: isPurchase
                      ? AppColors.primaryLight
                      : AppColors.successLight,

                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),

                child: Icon(
                  isPurchase
                      ? Icons.local_shipping_outlined
                      : Icons.payments_outlined,
                  size: 17,
                  color: isPurchase ? AppColors.primary : AppColors.success,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      transaction.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body,
                    ),

                    if ((transaction.reference ?? '').isNotEmpty)
                      Text(
                        'Ref: ${transaction.reference}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Text(
            isPurchase ? _money(transaction.amount) : '—',
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(color: AppColors.warning),
          ),
        ),

        Expanded(
          child: Text(
            isPurchase ? '—' : _money(transaction.amount),
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(color: AppColors.success),
          ),
        ),

        Expanded(
          child: Text(
            _money(transaction.runningBalance),
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE TRANSACTION
  // ============================================================

  Widget _buildMobileTransaction(
    _StatementTransaction transaction,
    bool isPurchase,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),

              decoration: BoxDecoration(
                color: isPurchase
                    ? AppColors.primaryLight
                    : AppColors.successLight,

                borderRadius: BorderRadius.circular(AppRadius.lg - 1),
              ),

              child: Icon(
                isPurchase
                    ? Icons.local_shipping_outlined
                    : Icons.payments_outlined,
                size: 18,
                color: isPurchase ? AppColors.primary : AppColors.success,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    transaction.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    _formatDate(transaction.date),
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Flexible(
              child: Text(
                isPurchase
                    ? '+${_money(transaction.amount)}'
                    : '-${_money(transaction.amount)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: AppTextStyles.body.copyWith(
                  color: isPurchase ? AppColors.warning : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        if ((transaction.reference ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 45, top: AppSpacing.xs + 1),

            child: Text(
              'Ref: ${transaction.reference}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small,
            ),
          ),

        Padding(
          padding: const EdgeInsets.only(left: 45, top: AppSpacing.sm - 1),

          child: Row(
            children: [
              const Text('Balance: ', style: AppTextStyles.small),

              Flexible(
                child: Text(
                  _money(transaction.runningBalance),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATEMENT
  // ============================================================

  Widget _buildEmptyStatement() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.huge,
        horizontal: AppSpacing.xl,
      ),

      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: AppColors.textMuted,
            ),

            SizedBox(height: AppSpacing.md),

            Text('No transactions yet', style: AppTextStyles.title),

            SizedBox(height: AppSpacing.sm),

            Text(
              'Supplier deliveries and payments will appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _money(double amount) {
    return '₦${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ================================================================
// STATEMENT TRANSACTION MODEL
// ================================================================

enum _StatementTransactionType { purchase, payment }

class _StatementTransaction {
  final DateTime date;

  final _StatementTransactionType type;

  final String description;

  final double amount;

  final String? reference;

  final int id;

  double runningBalance = 0;

  _StatementTransaction({
    required this.date,
    required this.type,
    required this.description,
    required this.amount,
    required this.reference,
    required this.id,
  });
}

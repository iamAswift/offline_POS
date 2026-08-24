// lib/features/suppliers/supplier_statement_screen.dart

import 'package:flutter/material.dart';

import 'package:supermarket_inventory/core/widgets/back_button.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/supplier_payment_dao.dart';
import '../../database/daos/supplier_delivery_dao.dart';

class SupplierStatementScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierStatementScreen({
    super.key,
    required this.supplier,
  });

  @override
  State<SupplierStatementScreen> createState() =>
      _SupplierStatementScreenState();
}

class _SupplierStatementScreenState
    extends State<SupplierStatementScreen> {
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

      final deliveries =
          results[2] as List<SupplierDelivery>;

      final payments =
          results[3] as List<SupplierPayment>;

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
      debugPrint(
        'Supplier statement error: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showError(
        'Unable to load supplier statement.\n$e',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        leading: const CentralBackButton(),

        title: const Text(
          'Supplier Statement',
          style: AppTextStyles.heading,
        ),

        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        elevation: 0,

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadStatement,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadStatement,

              child: LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final width =
                      constraints.maxWidth;

                  final isTablet =
                      width >= 600;

                  final contentWidth =
                      width > 1200
                          ? 1150.0
                          : width;

                  return ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    padding: EdgeInsets.symmetric(
                      horizontal:
                          isTablet ? 24 : 16,
                      vertical: 20,
                    ),

                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(
                            maxWidth:
                                contentWidth,
                          ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,

                            children: [
                              _buildSupplierHeader(
                                isTablet,
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              _buildSummaryCards(
                                isTablet,
                              ),

                              const SizedBox(
                                height: 24,
                              ),

                              _buildStatementSection(
                                isTablet,
                              ),

                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  // ============================================================
  // SUPPLIER HEADER
  // ============================================================

  Widget _buildSupplierHeader(
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? 24 : 20,
      ),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: AppColors.border,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: isTablet ? 68 : 58,
            height: isTablet ? 68 : 58,

            decoration: BoxDecoration(
              color: AppColors.primaryLight,

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Icon(
              Icons.business_outlined,
              size: isTablet ? 34 : 30,
              color: AppColors.primary,
            ),
          ),

          SizedBox(
            width: isTablet ? 18 : 16,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  widget.supplier.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyles.heading,
                ),

                if ((widget.supplier.contact ?? '')
                    .isNotEmpty) ...[
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 15,
                        color:
                            AppColors.textSecondary,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          widget.supplier.contact!,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              AppTextStyles.bodySecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                if ((widget.supplier.address ?? '')
                    .isNotEmpty) ...[
                  const SizedBox(height: 4),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color:
                            AppColors.textSecondary,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          widget.supplier.address!,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              AppTextStyles.small,
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

  Widget _buildSummaryCards(
    bool isTablet,
  ) {
    return GridView.count(
      crossAxisCount: 2,

      crossAxisSpacing:
          isTablet ? 16 : 12,

      mainAxisSpacing:
          isTablet ? 16 : 12,

      childAspectRatio:
          isTablet ? 2.5 : 1.55,

      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      children: [
        _summaryCard(
          title: 'Total Purchases',
          amount: _totalPurchases,
          icon:
              Icons.inventory_2_outlined,
          color:
              AppColors.primary,
          background:
              AppColors.primaryLight,
        ),

        _summaryCard(
          title: 'Total Paid',
          amount: _totalPaid,
          icon:
              Icons.payments_outlined,
          color:
              AppColors.success,
          background:
              AppColors.successLight,
        ),

        _summaryCard(
          title: 'Outstanding',
          amount:
              _outstanding > 0
                  ? _outstanding
                  : 0,
          icon:
              Icons.account_balance_wallet_outlined,
          color:
              _outstanding > 0
                  ? AppColors.warning
                  : AppColors.success,
          background:
              _outstanding > 0
                  ? AppColors.warningLight
                  : AppColors.successLight,
        ),

        _summaryCard(
          title: 'Transactions',
          amount:
              (_deliveries.length +
                      _payments.length)
                  .toDouble(),
          icon:
              Icons.receipt_long_outlined,
          color:
              AppColors.info,
          background:
              AppColors.infoLight,
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
      padding:
          const EdgeInsets.all(16),

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
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(9),

                decoration:
                    BoxDecoration(
                  color:
                      background,

                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Icon(
                  icon,
                  size: 20,
                  color:
                      color,
                ),
              ),

              const Spacer(),

              Text(
                title,
                style:
                    AppTextStyles.small,
              ),
            ],
          ),

          const Spacer(),

          FittedBox(
            alignment:
                Alignment.centerLeft,

            fit:
                BoxFit.scaleDown,

            child: Text(
              isCount
                  ? amount
                      .toInt()
                      .toString()
                  : _money(amount),
              style:
                  AppTextStyles.price,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATEMENT SECTION
  // ============================================================

  Widget _buildStatementSection(
    bool isTablet,
  ) {
    final transactions =
        _buildTransactions();

    return Container(
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
            CrossAxisAlignment.start,

        children: [
          Padding(
            padding:
                const EdgeInsets.all(18),

            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(8),

                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.primaryLight,

                    borderRadius:
                        BorderRadius.circular(9),
                  ),

                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 19,
                    color:
                        AppColors.primary,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Account Statement',
                    style:
                        AppTextStyles.title,
                  ),
                ),

                Text(
                  '${transactions.length} entries',
                  style:
                      AppTextStyles.small,
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color: AppColors.divider,
          ),

          if (transactions.isEmpty)
            _buildEmptyStatement()
          else
            _buildTransactionList(
              transactions,
              isTablet,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD TRANSACTIONS
  // ============================================================

  List<_StatementTransaction>
      _buildTransactions() {
    final transactions =
        <_StatementTransaction>[];

    for (final delivery in _deliveries) {
      transactions.add(
        _StatementTransaction(
          date:
              delivery.deliveryDate,
          type:
              _StatementTransactionType.purchase,
          description:
              (delivery.invoiceNumber ?? '')
                      .isNotEmpty
                  ? 'Invoice ${delivery.invoiceNumber}'
                  : 'Delivery #${delivery.id}',
          amount:
              delivery.totalAmount,
          reference:
              delivery.invoiceNumber,
          id:
              delivery.id,
        ),
      );
    }

    for (final payment in _payments) {
      transactions.add(
        _StatementTransaction(
          date:
              payment.paymentDate,
          type:
              _StatementTransactionType.payment,
          description:
              '${_capitalize(payment.paymentMethod)} payment',
          amount:
              payment.amount,
          reference:
              payment.reference,
          id:
              payment.id,
        ),
      );
    }

    transactions.sort(
      (a, b) {
        final dateCompare =
            a.date.compareTo(b.date);

        if (dateCompare != 0) {
          return dateCompare;
        }

        return a.id.compareTo(b.id);
      },
    );

    double runningBalance = 0;

    for (final transaction
        in transactions) {
      if (transaction.type ==
          _StatementTransactionType.purchase) {
        runningBalance +=
            transaction.amount;
      } else {
        runningBalance -=
            transaction.amount;
      }

      transaction.runningBalance =
          runningBalance;
    }

    return transactions;
  }

  // ============================================================
  // TRANSACTION LIST
  // ============================================================

  Widget _buildTransactionList(
    List<_StatementTransaction>
        transactions,
    bool isTablet,
  ) {
    return Column(
      children: [
        if (isTablet)
          _buildDesktopHeader(),

        ...transactions
            .asMap()
            .entries
            .map(
              (entry) {
                final index =
                    entry.key;

                final transaction =
                    entry.value;

                return _buildTransactionTile(
                  transaction,
                  index,
                  isTablet,
                );
              },
            ),
      ],
    );
  }

  // ============================================================
  // DESKTOP HEADER
  // ============================================================

  Widget _buildDesktopHeader() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),

      color:
          AppColors.background,

      child: const Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              'Date',
              style:
                  AppTextStyles.small,
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              'Description',
              style:
                  AppTextStyles.small,
            ),
          ),

          Expanded(
            child: Text(
              'Debit',
              textAlign:
                  TextAlign.right,
              style:
                  AppTextStyles.small,
            ),
          ),

          Expanded(
            child: Text(
              'Credit',
              textAlign:
                  TextAlign.right,
              style:
                  AppTextStyles.small,
            ),
          ),

          Expanded(
            child: Text(
              'Balance',
              textAlign:
                  TextAlign.right,
              style:
                  AppTextStyles.small,
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
    bool isTablet,
  ) {
    final isPurchase =
        transaction.type ==
            _StatementTransactionType.purchase;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),

      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                AppColors.divider,
          ),
        ),
      ),

      child: isTablet
          ? _buildDesktopTransaction(
              transaction,
              isPurchase,
            )
          : _buildMobileTransaction(
              transaction,
              isPurchase,
            ),
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
            _formatDate(
              transaction.date,
            ),
            style:
                AppTextStyles.small,
          ),
        ),

        Expanded(
          flex: 3,
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(7),

                decoration:
                    BoxDecoration(
                  color: isPurchase
                      ? AppColors
                          .primaryLight
                      : AppColors
                          .successLight,

                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),

                child: Icon(
                  isPurchase
                      ? Icons
                          .local_shipping_outlined
                      : Icons
                          .payments_outlined,
                  size: 17,
                  color: isPurchase
                      ? AppColors.primary
                      : AppColors.success,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      transaction
                          .description,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          AppTextStyles.body,
                    ),

                    if ((transaction
                                .reference ??
                            '')
                        .isNotEmpty)
                      Text(
                        'Ref: ${transaction.reference}',
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            AppTextStyles
                                .small,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Text(
            isPurchase
                ? _money(
                    transaction.amount,
                  )
                : '—',
            textAlign:
                TextAlign.right,
            style:
                AppTextStyles.body.copyWith(
              color:
                  AppColors.warning,
            ),
          ),
        ),

        Expanded(
          child: Text(
            isPurchase
                ? '—'
                : _money(
                    transaction.amount,
                  ),
            textAlign:
                TextAlign.right,
            style:
                AppTextStyles.body.copyWith(
              color:
                  AppColors.success,
            ),
          ),
        ),

        Expanded(
          child: Text(
            _money(
              transaction.runningBalance,
            ),
            textAlign:
                TextAlign.right,
            style:
                AppTextStyles.body.copyWith(
              fontWeight:
                  FontWeight.w600,
            ),
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
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(8),

              decoration:
                  BoxDecoration(
                color: isPurchase
                    ? AppColors
                        .primaryLight
                    : AppColors
                        .successLight,

                borderRadius:
                    BorderRadius.circular(
                  9,
                ),
              ),

              child: Icon(
                isPurchase
                    ? Icons
                        .local_shipping_outlined
                    : Icons
                        .payments_outlined,
                size: 18,
                color: isPurchase
                    ? AppColors.primary
                    : AppColors.success,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    transaction
                        .description,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        AppTextStyles.body,
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    _formatDate(
                      transaction.date,
                    ),
                    style:
                        AppTextStyles.small,
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Text(
              isPurchase
                  ? '+${_money(transaction.amount)}'
                  : '-${_money(transaction.amount)}',
              style:
                  AppTextStyles.body.copyWith(
                color: isPurchase
                    ? AppColors.warning
                    : AppColors.success,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),

        if ((transaction.reference ??
                '')
            .isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.only(
              left: 45,
              top: 5,
            ),
            child: Text(
              'Ref: ${transaction.reference}',
              style:
                  AppTextStyles.small,
            ),
          ),

        Padding(
          padding:
              const EdgeInsets.only(
            left: 45,
            top: 6,
          ),

          child: Row(
            children: [
              const Text(
                'Balance: ',
                style:
                    AppTextStyles.small,
              ),

              Text(
                _money(
                  transaction
                      .runningBalance,
                ),
                style:
                    AppTextStyles.small.copyWith(
                  fontWeight:
                      FontWeight.w600,
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
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),

      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color:
                  AppColors.textMuted,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'No transactions yet',
              style:
                  AppTextStyles.title,
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'Supplier deliveries and payments will appear here.',
              textAlign:
                  TextAlign.center,
              style:
                  AppTextStyles.bodySecondary,
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

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day
            .toString()
            .padLeft(2, '0');

    final month =
        date.month
            .toString()
            .padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _capitalize(
    String value,
  ) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }

  void _showError(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        backgroundColor:
            AppColors.danger,
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}

// ================================================================
// STATEMENT TRANSACTION MODEL
// ================================================================

enum _StatementTransactionType {
  purchase,
  payment,
}

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
// lib/features/suppliers/supplier_payment_screen.dart

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;

import 'package:supermarket_inventory/core/widgets/back_button.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/supplier_payment_dao.dart';
import '../../database/daos/supplier_payment_allocation_dao.dart';
import '../../database/daos/supplier_delivery_dao.dart';

import 'supplier_delivery_screen.dart';

class SupplierPaymentScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierPaymentScreen({
    super.key,
    required this.supplier,
  });

  @override
  State<SupplierPaymentScreen> createState() =>
      _SupplierPaymentScreenState();
}

class _SupplierPaymentScreenState
    extends State<SupplierPaymentScreen> {
  late final SupplierPaymentDao _paymentDao;
  late final SupplierDeliveryDao _deliveryDao;
  late final SupplierPaymentAllocationDao _allocationDao;

  bool _loading = true;

  double _totalPurchases = 0;
  double _totalPaid = 0;
  double _outstanding = 0;
  double _unallocatedPayments = 0;

  List<SupplierDelivery> _deliveries = [];
  List<SupplierPayment> _payments = [];

  @override
  void initState() {
    super.initState();

    _paymentDao = getSupplierPaymentDao();
    _deliveryDao = getSupplierDeliveryDao();
    _allocationDao = getSupplierPaymentAllocationDao();

    _loadDashboard();
  }

  // ============================================================
  // LOAD DASHBOARD
  // ============================================================

  Future<void> _loadDashboard() async {
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

      double unallocated = 0;

      for (final payment in payments) {
        final allocated =
            await _allocationDao
                .getAllocatedAmountForPayment(
          payment.id,
        );

        final remaining =
            payment.amount - allocated;

        if (remaining > 0) {
          unallocated += remaining;
        }
      }

      if (!mounted) return;

      setState(() {
        _totalPurchases = purchases;
        _totalPaid = paid;

        _outstanding =
            purchases - paid > 0
                ? purchases - paid
                : 0;

        _unallocatedPayments = unallocated;

        _deliveries = deliveries;
        _payments = payments;

        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'Supplier dashboard error: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showError(
        'Unable to load supplier information.\n$e',
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

        title: Text(
          widget.supplier.name,
          style: AppTextStyles.heading,
        ),

        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        elevation: 0,

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadDashboard,
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
              onRefresh: _loadDashboard,

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
                                CrossAxisAlignment
                                    .stretch,

                            children: [
                              _buildSupplierHeader(
                                isTablet,
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              _buildDashboardOverview(
                                isTablet,
                              ),

                              const SizedBox(
                                height: 24,
                              ),

                              _buildQuickActions(
                                isTablet,
                              ),

                              const SizedBox(
                                height: 24,
                              ),

                              _buildPaymentsSection(
                                isTablet,
                              ),

                              const SizedBox(
                                height: 24,
                              ),

                              _buildDeliveriesSection(
                                isTablet,
                              ),

                              const SizedBox(
                                height: 24,
                              ),

                              _buildStatementButton(
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

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,

        onPressed:
            _showAddPaymentDialog,

        icon: const Icon(
          Icons.payment,
        ),

        label: const Text(
          'Record Payment',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
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
        crossAxisAlignment:
            CrossAxisAlignment.center,

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
                          style: AppTextStyles
                              .bodySecondary,
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
  // DASHBOARD OVERVIEW
  // ============================================================

  Widget _buildDashboardOverview(
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Account Overview',
                style: AppTextStyles.title,
              ),
            ),

            Text(
              '${_deliveries.length} deliveries',
              style: AppTextStyles.small,
            ),
          ],
        ),

        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,

          crossAxisSpacing:
              isTablet ? 16 : 12,

          mainAxisSpacing:
              isTablet ? 16 : 12,

          childAspectRatio:
              isTablet ? 2.25 : 1.45,

          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          children: [
            _summaryCard(
              title: 'Purchases',
              amount: _totalPurchases,
              icon:
                  Icons.inventory_2_outlined,
              color: AppColors.primary,
              background:
                  AppColors.primaryLight,
            ),

            _summaryCard(
              title: 'Paid',
              amount: _totalPaid,
              icon:
                  Icons.payments_outlined,
              color: AppColors.success,
              background:
                  AppColors.successLight,
            ),

            _summaryCard(
              title: 'Outstanding',
              amount: _outstanding,
              icon:
                  Icons.account_balance_wallet_outlined,
              color: _outstanding > 0
                  ? AppColors.warning
                  : AppColors.success,
              background: _outstanding > 0
                  ? AppColors.warningLight
                  : AppColors.successLight,
            ),

            _summaryCard(
              title: 'Unallocated',
              amount:
                  _unallocatedPayments,
              icon:
                  Icons.link_off_outlined,
              color:
                  _unallocatedPayments > 0
                      ? AppColors.info
                      : AppColors.success,
              background:
                  AppColors.infoLight,
            ),
          ],
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: AppColors.border,
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

                decoration: BoxDecoration(
                  color: background,

                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Icon(
                  icon,
                  size: 20,
                  color: color,
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

            fit: BoxFit.scaleDown,

            child: Text(
              _money(amount),
              style:
                  AppTextStyles.price,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions(
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Supplier Management',
          style: AppTextStyles.title,
        ),

        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,

          crossAxisSpacing:
              isTablet ? 16 : 12,

          mainAxisSpacing:
              isTablet ? 16 : 12,

          childAspectRatio:
              isTablet ? 3.2 : 2.2,

          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          children: [
            _actionCard(
              icon:
                  Icons.local_shipping_outlined,
              title: 'Deliveries',
              subtitle:
                  '${_deliveries.length} records',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SupplierDeliveriesScreen(
                      supplier: widget.supplier,
                    ),
                  ),
                );

                if (!mounted) return;

                await _loadDashboard();
              },
            ),

            _actionCard(
              icon:
                  Icons.account_balance_outlined,
              title: 'Allocations',
              subtitle:
                  'Match payments',
              onTap: () {
                _showComingSoon(
                  'Payment allocations',
                );
              },
            ),

            _actionCard(
              icon:
                  Icons.payments_outlined,
              title: 'Payments',
              subtitle:
                  '${_payments.length} records',
              onTap: () {
                _showComingSoon(
                  'Supplier payments',
                );
              },
            ),

            _actionCard(
              icon:
                  Icons.receipt_long_outlined,
              title: 'Statement',
              subtitle:
                  'View account history',
              onTap: () {
                _showComingSoon(
                  'Supplier statement',
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,

      borderRadius:
          BorderRadius.circular(14),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(14),

        onTap: onTap,

        child: Container(
          padding:
              const EdgeInsets.all(14),

          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(14),

            border: Border.all(
              color: AppColors.border,
            ),
          ),

          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color:
                      AppColors.primaryLight,

                  borderRadius:
                      BorderRadius.circular(11),
                ),

                child: Icon(
                  icon,
                  color:
                      AppColors.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTextStyles.body,
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTextStyles.small,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                size: 20,
                color:
                    AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENTS
  // ============================================================

  Widget _buildPaymentsSection(
    bool isTablet,
  ) {
    return _sectionContainer(
      title: 'Recent Payments',
      icon:
          Icons.payments_outlined,

      child: _payments.isEmpty
          ? _emptySection(
              icon:
                  Icons.payments_outlined,
              message:
                  'No payments recorded for this supplier.',
            )
          : Column(
              children: _payments
                  .take(5)
                  .map(
                    (payment) =>
                        _paymentTile(
                      payment,
                      isTablet,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _paymentTile(
    SupplierPayment payment,
    bool isTablet,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 13,
      ),

      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.all(9),

            decoration: BoxDecoration(
              color:
                  AppColors.successLight,

              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.arrow_upward,
              size: 18,
              color:
                  AppColors.success,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  _capitalize(
                    payment.paymentMethod,
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyles.body,
                ),

                const SizedBox(height: 3),

                Text(
                  _formatDate(
                    payment.paymentDate,
                  ),
                  style:
                      AppTextStyles.small,
                ),

                if ((payment.reference ?? '')
                    .isNotEmpty)
                  Text(
                    'Ref: ${payment.reference}',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        AppTextStyles.small,
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            _money(payment.amount),
            style:
                AppTextStyles.price.copyWith(
              color:
                  AppColors.success,
              fontSize:
                  isTablet ? 17 : 16,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELIVERIES
  // ============================================================

  Widget _buildDeliveriesSection(
    bool isTablet,
  ) {
    return _sectionContainer(
      title: 'Recent Deliveries',
      icon:
          Icons.local_shipping_outlined,

      child: _deliveries.isEmpty
          ? _emptySection(
              icon:
                  Icons.local_shipping_outlined,
              message:
                  'No deliveries recorded for this supplier.',
            )
          : Column(
              children: _deliveries
                  .take(5)
                  .map(
                    (delivery) =>
                        _deliveryTile(
                      delivery,
                      isTablet,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _deliveryTile(
    SupplierDelivery delivery,
    bool isTablet,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 13,
      ),

      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.all(9),

            decoration: BoxDecoration(
              color:
                  AppColors.primaryLight,

              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  (delivery.invoiceNumber ?? '')
                          .isNotEmpty
                      ? 'Invoice ${delivery.invoiceNumber}'
                      : 'Delivery #${delivery.id}',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyles.body,
                ),

                const SizedBox(height: 3),

                Text(
                  _formatDate(
                    delivery.deliveryDate,
                  ),
                  style:
                      AppTextStyles.small,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            _money(
              delivery.totalAmount,
            ),
            style:
                AppTextStyles.price.copyWith(
              fontSize:
                  isTablet ? 17 : 16,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATEMENT BUTTON
  // ============================================================

  Widget _buildStatementButton(
    bool isTablet,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        _showComingSoon(
          'Supplier statement',
        );
      },

      icon: const Icon(
        Icons.receipt_long_outlined,
      ),

      label: Padding(
        padding:
            EdgeInsets.symmetric(
          vertical:
              isTablet ? 16 : 14,
        ),

        child: const Text(
          'View Supplier Statement',
          style:
              AppTextStyles.body,
        ),
      ),

      style:
          OutlinedButton.styleFrom(
        foregroundColor:
            AppColors.primary,

        side: const BorderSide(
          color:
              AppColors.primary,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION CONTAINER
  // ============================================================

  Widget _sectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
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
                    const EdgeInsets.all(7),

                decoration: BoxDecoration(
                  color:
                      AppColors.primaryLight,

                  borderRadius:
                      BorderRadius.circular(8),
                ),

                child: Icon(
                  icon,
                  size: 18,
                  color:
                      AppColors.primary,
                ),
              ),

              const SizedBox(width: 9),

              Text(
                title,
                style:
                    AppTextStyles.title,
              ),
            ],
          ),

          const SizedBox(height: 8),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY SECTION
  // ============================================================

  Widget _emptySection({
    required IconData icon,
    required String message,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 24,
      ),

      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color:
                  AppColors.textMuted,
            ),

            const SizedBox(height: 8),

            Text(
              message,
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
  // ADD PAYMENT
  // ============================================================

  Future<void> _showAddPaymentDialog() async {
    final amountController =
        TextEditingController();

    final referenceController =
        TextEditingController();

    final notesController =
        TextEditingController();

    String paymentMethod = 'cash';

    final formKey =
        GlobalKey<FormState>();

    final result =
        await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Record Supplier Payment',
                style:
                    AppTextStyles.title,
              ),

              content: SizedBox(
                width: 450,

                child: Form(
                  key: formKey,

                  child:
                      SingleChildScrollView(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        _dialogTextField(
                          controller:
                              amountController,
                          label:
                              'Amount',
                          hint:
                              '0.00',
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          validator:
                              (value) {
                            final amount =
                                double.tryParse(
                              value ?? '',
                            );

                            if (amount ==
                                    null ||
                                amount <= 0) {
                              return 'Enter a valid amount';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        DropdownButtonFormField<
                            String>(
                          value:
                              paymentMethod,

                          decoration:
                              const InputDecoration(
                            labelText:
                                'Payment Method',
                            border:
                                OutlineInputBorder(),
                          ),

                          items:
                              const [
                            DropdownMenuItem(
                              value:
                                  'cash',
                              child:
                                  Text(
                                'Cash',
                              ),
                            ),
                            DropdownMenuItem(
                              value:
                                  'transfer',
                              child:
                                  Text(
                                'Bank Transfer',
                              ),
                            ),
                            DropdownMenuItem(
                              value:
                                  'pos',
                              child:
                                  Text(
                                'POS',
                              ),
                            ),
                            DropdownMenuItem(
                              value:
                                  'other',
                              child:
                                  Text(
                                'Other',
                              ),
                            ),
                          ],

                          onChanged:
                              (value) {
                            if (value ==
                                null) {
                              return;
                            }

                            setDialogState(
                              () {
                                paymentMethod =
                                    value;
                              },
                            );
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        _dialogTextField(
                          controller:
                              referenceController,
                          label:
                              'Reference',
                          hint:
                              'Optional',
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        _dialogTextField(
                          controller:
                              notesController,
                          label:
                              'Notes',
                          hint:
                              'Optional',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton.icon(
                  onPressed:
                      () async {
                    if (!formKey
                        .currentState!
                        .validate()) {
                      return;
                    }

                    final amount =
                        double.parse(
                      amountController
                          .text
                          .trim(),
                    );

                    try {
                      await _paymentDao
                          .insertPayment(
                        SupplierPaymentsCompanion(
                          supplierId:
                              Value(
                            widget
                                .supplier
                                .id,
                          ),

                          amount:
                              Value(
                            amount,
                          ),

                          paymentMethod:
                              Value(
                            paymentMethod,
                          ),

                          reference:
                              referenceController
                                      .text
                                      .trim()
                                      .isEmpty
                                  ? const Value
                                      .absent()
                                  : Value(
                                      referenceController
                                          .text
                                          .trim(),
                                    ),

                          notes:
                              notesController
                                      .text
                                      .trim()
                                      .isEmpty
                                  ? const Value
                                      .absent()
                                  : Value(
                                      notesController
                                          .text
                                          .trim(),
                                    ),
                        ),
                      );

                      if (!dialogContext
                          .mounted) {
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                        true,
                      );
                    } catch (e) {
                      _showError(
                        'Unable to record payment.\n$e',
                      );
                    }
                  },

                  icon:
                      const Icon(
                    Icons.check,
                  ),

                  label:
                      const Text(
                    'Record Payment',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    referenceController.dispose();
    notesController.dispose();

    if (result == true) {
      await _loadDashboard();
    }
  }

  // ============================================================
  // FORM FIELD
  // ============================================================

  Widget _dialogTextField({
    required TextEditingController
        controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)?
        validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,

      decoration:
          InputDecoration(
        labelText: label,
        hintText: hint,
        border:
            const OutlineInputBorder(),
      ),
    );
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(
    String feature,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '$feature screen will be connected next.',
        ),
        behavior:
            SnackBarBehavior.floating,
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
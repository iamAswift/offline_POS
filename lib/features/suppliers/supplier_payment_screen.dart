// lib/features/suppliers/supplier_payment_screen.dart

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'package:supermarket_inventory/core/widgets/back_button.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/supplier_delivery_dao.dart';
import '../../database/daos/supplier_payment_allocation_dao.dart';
import '../../database/daos/supplier_payment_dao.dart';
import '../../features/suppliers/supplier_payment_allocation_screen.dart';
import 'supplier_delivery_screen.dart';
import 'supplier_statement_screen.dart';
import 'stock_adjustment_screen.dart';

class SupplierPaymentScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierPaymentScreen({super.key, required this.supplier});

  @override
  State<SupplierPaymentScreen> createState() => _SupplierPaymentScreenState();
}

class _SupplierPaymentScreenState extends State<SupplierPaymentScreen> {
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
      final deliveries = results[2] as List<SupplierDelivery>;
      final payments = results[3] as List<SupplierPayment>;

      double unallocated = 0;

      for (final payment in payments) {
        final allocated = await _allocationDao.getAllocatedAmountForPayment(
          payment.id,
        );

        final remaining = payment.amount - allocated;

        if (remaining > 0) {
          unallocated += remaining;
        }
      }

      if (!mounted) return;

      setState(() {
        _totalPurchases = purchases;
        _totalPaid = paid;
        _outstanding = purchases - paid > 0 ? purchases - paid : 0;
        _unallocatedPayments = unallocated;
        _deliveries = deliveries;
        _payments = payments;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Supplier dashboard error: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showError('Unable to load supplier information.\n$e');
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
        title: Text(widget.supplier.name, style: AppTextStyles.heading),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final isTablet = width >= 600;

                  final contentWidth = width > 1200 ? 1150.0 : width;

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? AppSpacing.xl : AppSpacing.md,
                      vertical: AppSpacing.lg,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSupplierHeader(isTablet),

                              const SizedBox(height: AppSpacing.lg),

                              _buildDashboardOverview(isTablet),

                              const SizedBox(height: AppSpacing.xl),

                              _buildQuickActions(isTablet),

                              const SizedBox(height: AppSpacing.xl),

                              _buildPaymentsSection(isTablet),

                              const SizedBox(height: AppSpacing.xl),

                              _buildDeliveriesSection(isTablet),

                              const SizedBox(height: AppSpacing.xl),

                              _buildStatementButton(isTablet),

                              const SizedBox(height: AppSpacing.xxl),


                              const SizedBox(height: AppSpacing.xxl),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: _showAddPaymentDialog,
        icon: const Icon(Icons.payment),
        label: const Text(
          'Record Payment',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ============================================================
  // SUPPLIER HEADER
  // ============================================================

  Widget _buildSupplierHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppSpacing.xl : AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 68 : 58,
            height: isTablet ? 68 : 58,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.business_outlined,
              size: isTablet ? 34 : 30,
              color: AppColors.primary,
            ),
          ),

          SizedBox(width: isTablet ? AppSpacing.lg : AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.supplier.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading,
                ),

                if ((widget.supplier.contact ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
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
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
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
  // DASHBOARD OVERVIEW
  // ============================================================

  Widget _buildDashboardOverview(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Account Overview', style: AppTextStyles.title),
            ),
            Text(
              '${_deliveries.length} deliveries',
              style: AppTextStyles.small,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: isTablet ? AppSpacing.md : AppSpacing.sm,
          mainAxisSpacing: isTablet ? AppSpacing.md : AppSpacing.sm,
          childAspectRatio: isTablet ? 2.25 : 1.45,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _summaryCard(
              title: 'Purchases',
              amount: _totalPurchases,
              icon: Icons.inventory_2_outlined,
              color: AppColors.primary,
              background: AppColors.primaryLight,
            ),
            _summaryCard(
              title: 'Paid',
              amount: _totalPaid,
              icon: Icons.payments_outlined,
              color: AppColors.success,
              background: AppColors.successLight,
            ),
            _summaryCard(
              title: 'Outstanding',
              amount: _outstanding,
              icon: Icons.account_balance_wallet_outlined,
              color: _outstanding > 0 ? AppColors.warning : AppColors.success,
              background: _outstanding > 0
                  ? AppColors.warningLight
                  : AppColors.successLight,
            ),
            _summaryCard(
              title: 'Unallocated',
              amount: _unallocatedPayments,
              icon: Icons.link_off_outlined,
              color: _unallocatedPayments > 0
                  ? AppColors.info
                  : AppColors.success,
              background: AppColors.infoLight,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Text(title, style: AppTextStyles.small),
            ],
          ),

          const Spacer(),

          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(_money(amount), style: AppTextStyles.price),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Supplier Management', style: AppTextStyles.title),

        const SizedBox(height: AppSpacing.md),

        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: isTablet ? AppSpacing.md : AppSpacing.sm,
          mainAxisSpacing: isTablet ? AppSpacing.md : AppSpacing.sm,
          childAspectRatio: isTablet ? 3.2 : 2.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _actionCard(
              icon: Icons.local_shipping_outlined,
              title: 'Deliveries',
              subtitle: '${_deliveries.length} records',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SupplierDeliveriesScreen(supplier: widget.supplier),
                  ),
                );

                if (!mounted) return;

                await _loadDashboard();
              },
            ),

            _actionCard(
              icon: Icons.account_balance_outlined,
              title: 'Allocations',
              subtitle: 'Match payments',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SupplierPaymentAllocationScreen(
                      supplier: widget.supplier,
                    ),
                  ),
                );

                if (!mounted) return;

                await _loadDashboard();
              },
            ),

            _actionCard(
              icon: Icons.tune_rounded,
              title: 'Stock Adjustments',
              subtitle: 'Correct inventory',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StockAdjustmentScreen(
                      supplierId: widget.supplier.id,
                    ),
                  ),
                );

                if (!mounted) return;

                await _loadDashboard();
              },
            ),

            _actionCard(
              icon: Icons.receipt_long_outlined,
              title: 'Statement',
              subtitle: 'View account history',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SupplierStatementScreen(supplier: widget.supplier),
                  ),
                );

                if (!mounted) return;

                await _loadDashboard();
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textMuted,
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

  Widget _buildPaymentsSection(bool isTablet) {
    return _sectionContainer(
      title: 'Recent Payments',
      icon: Icons.payments_outlined,
      child: _payments.isEmpty
          ? _emptySection(
              icon: Icons.payments_outlined,
              message: 'No payments recorded for this supplier.',
            )
          : Column(
              children: _payments
                  .take(5)
                  .map((payment) => _paymentTile(payment, isTablet))
                  .toList(),
            ),
    );
  }

  Widget _paymentTile(SupplierPayment payment, bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 1),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_upward,
              size: 18,
              color: AppColors.success,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(payment.paymentMethod),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body,
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  _formatDate(payment.paymentDate),
                  style: AppTextStyles.small,
                ),

                if ((payment.reference ?? '').isNotEmpty)
                  Text(
                    'Ref: ${payment.reference}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small,
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Text(
            _money(payment.amount),
            style: AppTextStyles.price.copyWith(
              color: AppColors.success,
              fontSize: isTablet ? 17 : 16,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELIVERIES
  // ============================================================

  Widget _buildDeliveriesSection(bool isTablet) {
    return _sectionContainer(
      title: 'Recent Deliveries',
      icon: Icons.local_shipping_outlined,
      child: _deliveries.isEmpty
          ? _emptySection(
              icon: Icons.local_shipping_outlined,
              message: 'No deliveries recorded for this supplier.',
            )
          : Column(
              children: _deliveries
                  .take(5)
                  .map((delivery) => _deliveryTile(delivery, isTablet))
                  .toList(),
            ),
    );
  }

  Widget _deliveryTile(SupplierDelivery delivery, bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 1),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (delivery.invoiceNumber ?? '').isNotEmpty
                      ? 'Invoice ${delivery.invoiceNumber}'
                      : 'Delivery #${delivery.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body,
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  _formatDate(delivery.deliveryDate),
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Text(
            _money(delivery.totalAmount),
            style: AppTextStyles.price.copyWith(fontSize: isTablet ? 17 : 16),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATEMENT BUTTON
  // ============================================================

  Widget _buildStatementButton(bool isTablet) {
    return OutlinedButton.icon(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SupplierStatementScreen(supplier: widget.supplier),
          ),
        );

        if (!mounted) return;

        await _loadDashboard();
      },
      icon: const Icon(Icons.receipt_long_outlined),
      label: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? AppSpacing.md : AppSpacing.sm + 2,
        ),
        child: const Text('View Supplier Statement', style: AppTextStyles.body),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs + 1),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),

              const SizedBox(width: AppSpacing.sm),

              Text(title, style: AppTextStyles.title),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY SECTION
  // ============================================================

  Widget _emptySection({required IconData icon, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColors.textMuted),

            const SizedBox(height: AppSpacing.sm),

            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
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
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _SupplierPaymentDialog(
        supplierId: widget.supplier.id,
        paymentDao: _paymentDao,
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadDashboard();
    }
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature screen will be connected next.'),
        behavior: SnackBarBehavior.floating,
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
// SUPPLIER PAYMENT DIALOG
// ================================================================

class _SupplierPaymentDialog extends StatefulWidget {
  final int supplierId;
  final SupplierPaymentDao paymentDao;

  const _SupplierPaymentDialog({
    required this.supplierId,
    required this.paymentDao,
  });

  @override
  State<_SupplierPaymentDialog> createState() => _SupplierPaymentDialogState();
}

class _SupplierPaymentDialogState extends State<_SupplierPaymentDialog> {
  late final TextEditingController _amountController;

  late final TextEditingController _referenceController;

  late final TextEditingController _notesController;

  final _formKey = GlobalKey<FormState>();

  String _paymentMethod = 'cash';
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();

    _referenceController = TextEditingController();

    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD DIALOG
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Supplier Payment', style: AppTextStyles.title),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _amountController,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(
                      value: 'transfer',
                      child: Text('Bank Transfer'),
                    ),
                    DropdownMenuItem(value: 'pos', child: Text('POS')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _paymentMethod = value;
                          });
                        },
                ),

                const SizedBox(height: AppSpacing.md),

                TextFormField(
                  controller: _referenceController,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Reference',
                    hintText: 'Optional',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                TextFormField(
                  controller: _notesController,
                  enabled: !_saving,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancel'),
        ),

        ElevatedButton.icon(
          onPressed: _saving ? null : _savePayment,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check),
          label: Text(_saving ? 'Saving...' : 'Record Payment'),
        ),
      ],
    );
  }

  // ============================================================
  // SAVE PAYMENT
  // ============================================================

  Future<void> _savePayment() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await widget.paymentDao.insertPayment(
        SupplierPaymentsCompanion(
          supplierId: Value(widget.supplierId),
          amount: Value(amount),
          paymentMethod: Value(_paymentMethod),
          reference: _referenceController.text.trim().isEmpty
              ? const Value.absent()
              : Value(_referenceController.text.trim()),
          notes: _notesController.text.trim().isEmpty
              ? const Value.absent()
              : Value(_notesController.text.trim()),
        ),
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to record payment.\n$e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

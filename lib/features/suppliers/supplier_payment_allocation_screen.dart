// lib/features/suppliers/supplier_payment_allocation_screen.dart

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../core/widgets/back_button.dart';
import '../../database/app_database.dart';
import '../../database/daos/supplier_delivery_dao.dart';
import '../../database/daos/supplier_payment_allocation_dao.dart';
import '../../database/daos/supplier_payment_dao.dart';

class SupplierPaymentAllocationScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierPaymentAllocationScreen({super.key, required this.supplier});

  @override
  State<SupplierPaymentAllocationScreen> createState() =>
      _SupplierPaymentAllocationScreenState();
}

class _SupplierPaymentAllocationScreenState
    extends State<SupplierPaymentAllocationScreen> {
  late final SupplierPaymentAllocationDao _allocationDao;
  late final SupplierPaymentDao _paymentDao;
  late final SupplierDeliveryDao _deliveryDao;

  bool _loading = true;
  String? _error;

  List<SupplierPayment> _payments = [];
  List<SupplierDelivery> _deliveries = [];
  List<SupplierPaymentAllocation> _allocations = [];

  final Map<int, double> _paymentAllocated = {};
  final Map<int, double> _deliveryAllocated = {};

  @override
  void initState() {
    super.initState();

    _allocationDao = getSupplierPaymentAllocationDao();
    _paymentDao = getSupplierPaymentDao();
    _deliveryDao = getSupplierDeliveryDao();

    _loadData();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final supplierId = widget.supplier.id;

      final results = await Future.wait([
        _paymentDao.getPaymentsForSupplier(supplierId),
        _deliveryDao.getDeliveriesForSupplier(supplierId),
        _allocationDao.getAllocationsForSupplier(supplierId),
      ]);

      final payments = results[0] as List<SupplierPayment>;
      final deliveries = results[1] as List<SupplierDelivery>;
      final allocations = results[2] as List<SupplierPaymentAllocation>;

      final paymentAllocated = <int, double>{};
      final deliveryAllocated = <int, double>{};

      for (final allocation in allocations) {
        final amount = allocation.amount.toDouble();

        paymentAllocated[allocation.paymentId] =
            (paymentAllocated[allocation.paymentId] ?? 0.0) + amount;

        deliveryAllocated[allocation.deliveryId] =
            (deliveryAllocated[allocation.deliveryId] ?? 0.0) + amount;
      }

      if (!mounted) return;

      setState(() {
        _payments = payments;
        _deliveries = deliveries;
        _allocations = allocations;

        _paymentAllocated
          ..clear()
          ..addAll(paymentAllocated);

        _deliveryAllocated
          ..clear()
          ..addAll(deliveryAllocated);

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // BALANCES
  // ============================================================

  double _paymentRemaining(SupplierPayment payment) {
    final allocated = _paymentAllocated[payment.id] ?? 0.0;

    final remaining = payment.amount.toDouble() - allocated;

    return remaining > 0.0 ? remaining : 0.0;
  }

  double _deliveryOutstanding(SupplierDelivery delivery) {
    final allocated = _deliveryAllocated[delivery.id] ?? 0.0;

    final remaining = delivery.totalAmount.toDouble() - allocated;

    return remaining > 0.0 ? remaining : 0.0;
  }

  double _paymentAvailableForEdit(
    SupplierPayment payment,
    SupplierPaymentAllocation? existingAllocation,
  ) {
    var available = _paymentRemaining(payment);

    if (existingAllocation != null &&
        existingAllocation.paymentId == payment.id) {
      available += existingAllocation.amount.toDouble();
    }

    return available > 0.0 ? available : 0.0;
  }

  double _deliveryAvailableForEdit(
    SupplierDelivery delivery,
    SupplierPaymentAllocation? existingAllocation,
  ) {
    var available = _deliveryOutstanding(delivery);

    if (existingAllocation != null &&
        existingAllocation.deliveryId == delivery.id) {
      available += existingAllocation.amount.toDouble();
    }

    return available > 0.0 ? available : 0.0;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _money(double value) {
    return '₦${value.toStringAsFixed(2)}';
  }

  String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _deliveryReference(SupplierDelivery delivery) {
    final invoice = delivery.invoiceNumber?.trim();

    if (invoice != null && invoice.isNotEmpty) {
      return invoice;
    }

    return 'Delivery #${delivery.id}';
  }

  SupplierPayment? _paymentById(int id) {
    for (final payment in _payments) {
      if (payment.id == id) {
        return payment;
      }
    }

    return null;
  }

  SupplierDelivery? _deliveryById(int id) {
    for (final delivery in _deliveries) {
      if (delivery.id == id) {
        return delivery;
      }
    }

    return null;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // ALLOCATION DIALOG
  // ============================================================

  Future<void> _openAllocationDialog({
    SupplierPayment? selectedPayment,
    SupplierDelivery? selectedDelivery,
    SupplierPaymentAllocation? existingAllocation,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _SupplierPaymentAllocationDialog(
          payments: _payments,
          deliveries: _deliveries,
          selectedPayment: selectedPayment,
          selectedDelivery: selectedDelivery,
          existingAllocation: existingAllocation,
          paymentAvailableForEdit: _paymentAvailableForEdit,
          deliveryAvailableForEdit: _deliveryAvailableForEdit,
          money: _money,
          date: _date,
          deliveryReference: _deliveryReference,
          findPayment: _paymentById,
          findDelivery: _deliveryById,
          allocatePayment:
              ({
                required int paymentId,
                required int deliveryId,
                required double amount,
              }) {
                return _allocationDao.allocatePayment(
                  paymentId: paymentId,
                  deliveryId: deliveryId,
                  amount: amount,
                );
              },
          updateAllocation:
              ({required int allocationId, required double amount}) {
                return _allocationDao.updateAllocation(
                  allocationId: allocationId,
                  amount: amount,
                );
              },
        );
      },
    );

    if (result == true) {
      await _loadData();

      if (!mounted) return;

      _showMessage(
        existingAllocation == null
            ? 'Payment allocated successfully.'
            : 'Allocation updated successfully.',
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteAllocation(SupplierPaymentAllocation allocation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final responsive = context.responsive;

        return AlertDialog(
          title: const Text('Delete Allocation', style: AppTextStyles.title),
          content: Text(
            'Delete the allocation of '
            '${_money(allocation.amount.toDouble())}?',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: Size(
                  responsive.buttonHeight * 2.0,
                  responsive.buttonHeight,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _allocationDao.deleteAllocation(allocation.id);

      await _loadData();

      if (!mounted) return;

      _showMessage('Allocation deleted.');
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSizes.cardMinHeight),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
            ),
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
                  style: AppTextStyles.small,
                ),
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: AppTextStyles.title),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(Responsive responsive) {
    double totalPayments = 0.0;
    double totalPaymentRemaining = 0.0;

    for (final payment in _payments) {
      totalPayments += payment.amount.toDouble();
      totalPaymentRemaining += _paymentRemaining(payment);
    }

    double totalDeliveries = 0.0;
    double totalDeliveryOutstanding = 0.0;

    for (final delivery in _deliveries) {
      totalDeliveries += delivery.totalAmount.toDouble();
      totalDeliveryOutstanding += _deliveryOutstanding(delivery);
    }

    final cards = [
      _summaryCard(
        title: 'Payments',
        value: _money(totalPayments),
        icon: Icons.payments_outlined,
      ),
      _summaryCard(
        title: 'Unallocated',
        value: _money(totalPaymentRemaining),
        icon: Icons.account_balance_wallet_outlined,
      ),
      _summaryCard(
        title: 'Deliveries',
        value: _money(totalDeliveries),
        icon: Icons.local_shipping_outlined,
      ),
      _summaryCard(
        title: 'Outstanding',
        value: _money(totalDeliveryOutstanding),
        icon: Icons.pending_actions_outlined,
      ),
    ];

    if (responsive.isCompact) {
      return GridView.builder(
        itemCount: cards.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.55,
        ),
        itemBuilder: (context, index) {
          return cards[index];
        },
      );
    }

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.isTablet ? 4 : 4,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: responsive.isTablet ? 1.35 : 1.55,
      ),
      itemBuilder: (context, index) {
        return cards[index];
      },
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY CARD
  // ============================================================

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(title, textAlign: TextAlign.center, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENTS
  // ============================================================

  Widget _buildPayments(Responsive responsive) {
    if (_payments.isEmpty) {
      return _emptyCard(
        icon: Icons.payments_outlined,
        title: 'No supplier payments',
        subtitle: 'Create a supplier payment before allocating it.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _sectionHeader(
            icon: Icons.payments_outlined,
            title: 'Supplier Payments',
            subtitle: 'Payments available for allocation',
          ),
          const Divider(height: 1),
          ..._payments.map((payment) {
            final allocated = _paymentAllocated[payment.id] ?? 0.0;

            final remaining = _paymentRemaining(payment);

            final fullyAllocated = remaining <= 0.000001;

            return _buildPaymentItem(
              payment: payment,
              allocated: allocated,
              remaining: remaining,
              fullyAllocated: fullyAllocated,
              responsive: responsive,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentItem({
    required SupplierPayment payment,
    required double allocated,
    required double remaining,
    required bool fullyAllocated,
    required Responsive responsive,
  }) {
    final action = fullyAllocated
        ? const Chip(label: Text('Fully allocated', style: AppTextStyles.small))
        : FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: Size(
                responsive.buttonHeight * 2.1,
                responsive.buttonHeight,
              ),
            ),
            onPressed: () {
              _openAllocationDialog(selectedPayment: payment);
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Allocate'),
          );

    if (responsive.isCompact) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _money(payment.amount.toDouble()),
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _date(payment.paymentDate),
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Allocated ${_money(allocated)} • '
              'Remaining ${_money(remaining)}',
              style: AppTextStyles.small,
            ),
            const SizedBox(height: AppSpacing.md),
            Align(alignment: Alignment.centerRight, child: action),
          ],
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.10),
        child: const Icon(Icons.payments_outlined, color: AppColors.primary),
      ),
      title: Text(_money(payment.amount.toDouble()), style: AppTextStyles.body),
      subtitle: Text(
        '${_date(payment.paymentDate)}'
        ' • Allocated ${_money(allocated)}'
        ' • Remaining ${_money(remaining)}',
      ),
      trailing: action,
    );
  }

  // ============================================================
  // DELIVERIES
  // ============================================================

  Widget _buildDeliveries(Responsive responsive) {
    if (_deliveries.isEmpty) {
      return _emptyCard(
        icon: Icons.local_shipping_outlined,
        title: 'No supplier deliveries',
        subtitle: 'There are no deliveries available for this supplier.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _sectionHeader(
            icon: Icons.local_shipping_outlined,
            title: 'Supplier Deliveries',
            subtitle: 'Invoices / deliveries that can receive payment',
          ),
          const Divider(height: 1),
          ..._deliveries.map((delivery) {
            final allocated = _deliveryAllocated[delivery.id] ?? 0.0;

            final outstanding = _deliveryOutstanding(delivery);

            final fullyPaid = outstanding <= 0.000001;

            return _buildDeliveryItem(
              delivery: delivery,
              allocated: allocated,
              outstanding: outstanding,
              fullyPaid: fullyPaid,
              responsive: responsive,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryItem({
    required SupplierDelivery delivery,
    required double allocated,
    required double outstanding,
    required bool fullyPaid,
    required Responsive responsive,
  }) {
    final action = fullyPaid
        ? const Chip(label: Text('Fully paid', style: AppTextStyles.small))
        : OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: Size(
                responsive.buttonHeight * 2.5,
                responsive.buttonHeight,
              ),
            ),
            onPressed: () {
              _openAllocationDialog(selectedDelivery: delivery);
            },
            icon: const Icon(Icons.link, size: 18),
            label: const Text('Apply payment'),
          );

    if (responsive.isCompact) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _deliveryReference(delivery),
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _date(delivery.deliveryDate),
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Total ${_money(delivery.totalAmount.toDouble())}',
              style: AppTextStyles.small,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Paid ${_money(allocated)} • '
              'Outstanding ${_money(outstanding)}',
              style: AppTextStyles.small,
            ),
            const SizedBox(height: AppSpacing.md),
            Align(alignment: Alignment.centerRight, child: action),
          ],
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.10),
        child: const Icon(
          Icons.receipt_long_outlined,
          color: AppColors.primary,
        ),
      ),
      title: Text(_deliveryReference(delivery), style: AppTextStyles.body),
      subtitle: Text(
        '${_date(delivery.deliveryDate)}'
        ' • Total ${_money(delivery.totalAmount.toDouble())}'
        ' • Paid ${_money(allocated)}'
        ' • Outstanding ${_money(outstanding)}',
      ),
      trailing: action,
    );
  }

  // ============================================================
  // ALLOCATION HISTORY
  // ============================================================

  Widget _buildAllocationHistory(Responsive responsive) {
    if (_allocations.isEmpty) {
      return _emptyCard(
        icon: Icons.account_balance_outlined,
        title: 'No allocations',
        subtitle: 'Payments allocated to deliveries will appear here.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _sectionHeader(
            icon: Icons.account_balance_outlined,
            title: 'Allocation History',
            subtitle: 'Payments matched against supplier deliveries',
          ),
          const Divider(height: 1),
          ..._allocations.map((allocation) {
            final payment = _paymentById(allocation.paymentId);

            final delivery = _deliveryById(allocation.deliveryId);

            return _buildAllocationItem(
              allocation: allocation,
              payment: payment,
              delivery: delivery,
              responsive: responsive,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAllocationItem({
    required SupplierPaymentAllocation allocation,
    required SupplierPayment? payment,
    required SupplierDelivery? delivery,
    required Responsive responsive,
  }) {
    final menu = PopupMenuButton<String>(
      tooltip: 'Allocation actions',
      onSelected: (value) {
        if (value == 'edit') {
          _openAllocationDialog(existingAllocation: allocation);
        }

        if (value == 'delete') {
          _deleteAllocation(allocation);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );

    if (responsive.isCompact) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.success.withValues(alpha: 0.10),
              child: const Icon(Icons.link, color: AppColors.success),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _money(allocation.amount.toDouble()),
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Payment: '
                    '${payment == null ? '#${allocation.paymentId}' : _money(payment.amount.toDouble())}',
                    style: AppTextStyles.small,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Delivery: '
                    '${delivery == null ? '#${allocation.deliveryId}' : _deliveryReference(delivery)}',
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),
            menu,
          ],
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.success.withValues(alpha: 0.10),
        child: const Icon(Icons.link, color: AppColors.success),
      ),
      title: Text(
        _money(allocation.amount.toDouble()),
        style: AppTextStyles.body,
      ),
      subtitle: Text(
        'Payment: '
        '${payment == null ? '#${allocation.paymentId}' : _money(payment.amount.toDouble())}'
        ' → Delivery: '
        '${delivery == null ? '#${allocation.deliveryId}' : _deliveryReference(delivery)}',
      ),
      trailing: menu,
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
        title: Text(
          'Payment Allocations',
          style: responsive.isCompact
              ? AppTextStyles.title.copyWith(color: Colors.white)
              : AppTextStyles.heading.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final responsive = context.responsive;

                  final horizontalPadding = responsive.horizontalPadding;

                  final verticalPadding = responsive.verticalPadding;

                  final maxWidth = responsive.contentMaxWidth;

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildPageHeader(responsive),
                              SizedBox(
                                height: responsive.isCompact
                                    ? AppSpacing.lg
                                    : AppSpacing.xxl,
                              ),
                              _buildSummary(responsive),
                              SizedBox(
                                height: responsive.isCompact
                                    ? AppSpacing.lg
                                    : AppSpacing.xxl,
                              ),
                              _buildPaymentDeliveryLayout(responsive),
                              SizedBox(
                                height: responsive.isCompact
                                    ? AppSpacing.lg
                                    : AppSpacing.xxl,
                              ),
                              _buildAllocationHistory(responsive),
                              const SizedBox(height: AppSpacing.xxxl),
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
  // PAYMENT + DELIVERY RESPONSIVE LAYOUT
  // ============================================================

  Widget _buildPaymentDeliveryLayout(Responsive responsive) {
    if (responsive.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPayments(responsive),
          const SizedBox(height: AppSpacing.lg),
          _buildDeliveries(responsive),
        ],
      );
    }

    if (responsive.isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPayments(responsive),
          const SizedBox(height: AppSpacing.xxl),
          _buildDeliveries(responsive),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildPayments(responsive)),
        const SizedBox(width: AppSpacing.xxl),
        Expanded(child: _buildDeliveries(responsive)),
      ],
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(Responsive responsive) {
    final isCompact = responsive.isCompact;

    return Container(
      padding: EdgeInsets.all(isCompact ? AppSpacing.lg : AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isCompact ? 52 : 64,
            height: isCompact ? 52 : 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              Icons.account_balance_outlined,
              size: isCompact ? 26 : 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Allocations',
                  style: isCompact
                      ? AppTextStyles.title
                      : AppTextStyles.heading,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.supplier.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Match supplier payments against deliveries and invoices.',
                  maxLines: isCompact ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    final responsive = context.responsive;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.horizontalPadding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 36,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _error ?? 'Unable to load data.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: Size(0, responsive.buttonHeight),
                ),
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ALLOCATION DIALOG
// ============================================================================
//
// IMPORTANT:
// The TextEditingController belongs to this State object.
// It is created in initState() and disposed in dispose().
// The parent screen never disposes it.
// ============================================================================

class _SupplierPaymentAllocationDialog extends StatefulWidget {
  final List<SupplierPayment> payments;
  final List<SupplierDelivery> deliveries;

  final SupplierPayment? selectedPayment;
  final SupplierDelivery? selectedDelivery;
  final SupplierPaymentAllocation? existingAllocation;

  final double Function(
    SupplierPayment payment,
    SupplierPaymentAllocation? existingAllocation,
  )
  paymentAvailableForEdit;

  final double Function(
    SupplierDelivery delivery,
    SupplierPaymentAllocation? existingAllocation,
  )
  deliveryAvailableForEdit;

  final String Function(double value) money;
  final String Function(DateTime date) date;

  final String Function(SupplierDelivery delivery) deliveryReference;

  final SupplierPayment? Function(int id) findPayment;

  final SupplierDelivery? Function(int id) findDelivery;

  final Future<void> Function({
    required int paymentId,
    required int deliveryId,
    required double amount,
  })
  allocatePayment;

  final Future<void> Function({
    required int allocationId,
    required double amount,
  })
  updateAllocation;

  const _SupplierPaymentAllocationDialog({
    required this.payments,
    required this.deliveries,
    required this.selectedPayment,
    required this.selectedDelivery,
    required this.existingAllocation,
    required this.paymentAvailableForEdit,
    required this.deliveryAvailableForEdit,
    required this.money,
    required this.date,
    required this.deliveryReference,
    required this.findPayment,
    required this.findDelivery,
    required this.allocatePayment,
    required this.updateAllocation,
  });

  @override
  State<_SupplierPaymentAllocationDialog> createState() =>
      _SupplierPaymentAllocationDialogState();
}

class _SupplierPaymentAllocationDialogState
    extends State<_SupplierPaymentAllocationDialog> {
  int? _paymentId;
  int? _deliveryId;

  late final TextEditingController _controller;

  String? _validationError;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _paymentId =
        widget.selectedPayment?.id ?? widget.existingAllocation?.paymentId;

    _deliveryId =
        widget.selectedDelivery?.id ?? widget.existingAllocation?.deliveryId;

    _controller = TextEditingController(
      text: widget.existingAllocation == null
          ? ''
          : widget.existingAllocation!.amount.toDouble().toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  InputDecoration _inputDecoration(String label, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      filled: true,
      fillColor: AppColors.surface,
    );
  }

  Widget _dialogLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: AppTextStyles.body),
    );
  }

  void _setValidationError(String message) {
    if (!mounted) return;

    setState(() {
      _validationError = message;
    });
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (_saving) return;

    final paymentId = _paymentId;
    final deliveryId = _deliveryId;

    final amount = double.tryParse(_controller.text.trim());

    if (paymentId == null) {
      _setValidationError('Please select a payment.');
      return;
    }

    if (deliveryId == null) {
      _setValidationError('Please select a delivery.');
      return;
    }

    if (amount == null || amount <= 0.0) {
      _setValidationError('Enter a valid allocation amount.');
      return;
    }

    final payment = widget.findPayment(paymentId);

    final delivery = widget.findDelivery(deliveryId);

    if (payment == null) {
      _setValidationError('The selected payment could not be found.');
      return;
    }

    if (delivery == null) {
      _setValidationError('The selected delivery could not be found.');
      return;
    }

    final paymentAvailable = widget.paymentAvailableForEdit(
      payment,
      widget.existingAllocation,
    );

    final deliveryAvailable = widget.deliveryAvailableForEdit(
      delivery,
      widget.existingAllocation,
    );

    final maxAmount = paymentAvailable < deliveryAvailable
        ? paymentAvailable
        : deliveryAvailable;

    if (amount > maxAmount + 0.000001) {
      _setValidationError(
        'Allocation cannot exceed '
        '${widget.money(maxAmount)}.',
      );
      return;
    }

    setState(() {
      _saving = true;
      _validationError = null;
    });

    try {
      if (widget.existingAllocation == null) {
        await widget.allocatePayment(
          paymentId: paymentId,
          deliveryId: deliveryId,
          amount: amount,
        );
      } else {
        await widget.updateAllocation(
          allocationId: widget.existingAllocation!.id,
          amount: amount,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _validationError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    final currentPayment = _paymentId == null
        ? null
        : widget.findPayment(_paymentId!);

    final currentDelivery = _deliveryId == null
        ? null
        : widget.findDelivery(_deliveryId!);

    final paymentAvailable = currentPayment == null
        ? 0.0
        : widget.paymentAvailableForEdit(
            currentPayment,
            widget.existingAllocation,
          );

    final deliveryAvailable = currentDelivery == null
        ? 0.0
        : widget.deliveryAvailableForEdit(
            currentDelivery,
            widget.existingAllocation,
          );

    final maxAmount = paymentAvailable < deliveryAvailable
        ? paymentAvailable
        : deliveryAvailable;

    final dialogWidth = responsive.isCompact
        ? double.infinity
        : responsive.isTablet
        ? 600.0
        : 680.0;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: responsive.isCompact ? AppSpacing.sm : AppSpacing.xxl,
        vertical: responsive.isCompact ? AppSpacing.lg : AppSpacing.xxxl,
      ),
      titlePadding: EdgeInsets.fromLTRB(
        responsive.isCompact ? AppSpacing.lg : AppSpacing.xxl,
        responsive.isCompact ? AppSpacing.lg : AppSpacing.xxl,
        responsive.isCompact ? AppSpacing.lg : AppSpacing.xxl,
        AppSpacing.md,
      ),
      contentPadding: EdgeInsets.fromLTRB(
        responsive.isCompact ? AppSpacing.lg : AppSpacing.xxl,
        AppSpacing.md,
        responsive.isCompact ? AppSpacing.lg : AppSpacing.xxl,
        AppSpacing.sm,
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        responsive.isCompact ? AppSpacing.lg : AppSpacing.xxl,
        AppSpacing.sm,
        responsive.isCompact ? AppSpacing.lg : AppSpacing.xxl,
        responsive.isCompact ? AppSpacing.lg : AppSpacing.xxl,
      ),
      title: Text(
        widget.existingAllocation == null
            ? 'Allocate Payment'
            : 'Edit Allocation',
        style: responsive.isCompact
            ? AppTextStyles.title
            : AppTextStyles.heading,
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogLabel('Payment'),

              DropdownButtonFormField<int>(
                initialValue: _paymentId,
                isExpanded: true,
                decoration: _inputDecoration('Select payment'),
                items: widget.payments.map((payment) {
                  final available = widget.paymentAvailableForEdit(
                    payment,
                    widget.existingAllocation,
                  );

                  return DropdownMenuItem<int>(
                    value: payment.id,
                    child: Text(
                      '${widget.money(payment.amount.toDouble())} • '
                      '${widget.date(payment.paymentDate)} • '
                      'Available ${widget.money(available)}',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySecondary,
                    ),
                  );
                }).toList(),
                onChanged: widget.existingAllocation != null || _saving
                    ? null
                    : (value) {
                        setState(() {
                          _paymentId = value;
                          _validationError = null;
                        });
                      },
              ),

              const SizedBox(height: AppSpacing.lg),

              _dialogLabel('Delivery / Invoice'),

              DropdownButtonFormField<int>(
                initialValue: _deliveryId,
                isExpanded: true,
                decoration: _inputDecoration('Select delivery'),
                items: widget.deliveries.map((delivery) {
                  final outstanding = widget.deliveryAvailableForEdit(
                    delivery,
                    widget.existingAllocation,
                  );

                  return DropdownMenuItem<int>(
                    value: delivery.id,
                    child: Text(
                      '${widget.deliveryReference(delivery)} • '
                      '${widget.money(delivery.totalAmount.toDouble())} • '
                      'Outstanding ${widget.money(outstanding)}',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySecondary,
                    ),
                  );
                }).toList(),
                onChanged: widget.existingAllocation != null || _saving
                    ? null
                    : (value) {
                        setState(() {
                          _deliveryId = value;
                          _validationError = null;
                        });
                      },
              ),

              const SizedBox(height: AppSpacing.lg),

              _dialogLabel('Amount'),

              TextField(
                controller: _controller,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: _inputDecoration(
                  'Allocation amount',
                  prefixText: '₦ ',
                ),
                onChanged: (_) {
                  if (_validationError != null) {
                    setState(() {
                      _validationError = null;
                    });
                  }
                },
              ),

              const SizedBox(height: AppSpacing.md),

              if (currentPayment != null && currentDelivery != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Allocation limits',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Maximum: '
                        '${widget.money(maxAmount)}',
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Payment available: '
                        '${widget.money(paymentAvailable)}\n'
                        'Delivery outstanding: '
                        '${widget.money(deliveryAvailable)}',
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),

              if (_validationError != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Text(
                    _validationError!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ],
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
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: Size(0, responsive.buttonHeight),
          ),
          onPressed: _saving ? null : _save,
          child: _saving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Text(widget.existingAllocation == null ? 'Allocate' : 'Save'),
        ),
      ],
    );
  }
}

// lib/features/suppliers/supplier_payment_allocation_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
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
      final payments = await _paymentDao.getPaymentsForSupplier(
        widget.supplier.id,
      );

      final deliveries = await _deliveryDao.getDeliveriesForSupplier(
        widget.supplier.id,
      );

      final allocations = await _allocationDao.getAllocationsForSupplier(
        widget.supplier.id,
      );

      final paymentAllocated = <int, double>{};
      final deliveryAllocated = <int, double>{};

      for (final allocation in allocations) {
        paymentAllocated[allocation.paymentId] =
            (paymentAllocated[allocation.paymentId] ?? 0.0) +
            allocation.amount.toDouble();

        deliveryAllocated[allocation.deliveryId] =
            (deliveryAllocated[allocation.deliveryId] ?? 0.0) +
            allocation.amount.toDouble();
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
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // ALLOCATION DIALOG
  // ============================================================

  Future<void> _openAllocationDialog({
    SupplierPayment? selectedPayment,
    SupplierDelivery? selectedDelivery,
    SupplierPaymentAllocation? existingAllocation,
  }) async {
    int? paymentId = selectedPayment?.id ?? existingAllocation?.paymentId;

    int? deliveryId = selectedDelivery?.id ?? existingAllocation?.deliveryId;

    final controller = TextEditingController(
      text: existingAllocation?.amount.toDouble().toStringAsFixed(2) ?? '',
    );

    String? validationError;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentPayment = paymentId == null
                ? null
                : _paymentById(paymentId!);

            final currentDelivery = deliveryId == null
                ? null
                : _deliveryById(deliveryId!);

            final paymentAvailable = currentPayment == null
                ? 0.0
                : _paymentAvailableForEdit(currentPayment, existingAllocation);

            final deliveryAvailable = currentDelivery == null
                ? 0.0
                : _deliveryAvailableForEdit(
                    currentDelivery,
                    existingAllocation,
                  );

            final maxAmount = paymentAvailable < deliveryAvailable
                ? paymentAvailable
                : deliveryAvailable;

            return AlertDialog(
              title: Text(
                existingAllocation == null
                    ? 'Allocate Payment'
                    : 'Edit Allocation',
                style: AppTextStyles.title,
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dialogLabel('Payment'),

                      DropdownButtonFormField<int>(
                        initialValue: paymentId,
                        isExpanded: true,
                        decoration: _inputDecoration('Select payment'),
                        items: _payments.map((payment) {
                          final available = _paymentAvailableForEdit(
                            payment,
                            existingAllocation,
                          );

                          return DropdownMenuItem<int>(
                            value: payment.id,
                            child: Text(
                              '${_money(payment.amount.toDouble())} • '
                              '${_date(payment.paymentDate)} • '
                              'Available ${_money(available)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: existingAllocation != null
                            ? null
                            : (value) {
                                setDialogState(() {
                                  paymentId = value;
                                  validationError = null;
                                });
                              },
                      ),

                      const SizedBox(height: 18),

                      _dialogLabel('Delivery / Invoice'),

                      DropdownButtonFormField<int>(
                        initialValue: deliveryId,
                        isExpanded: true,
                        decoration: _inputDecoration('Select delivery'),
                        items: _deliveries.map((delivery) {
                          final outstanding = _deliveryAvailableForEdit(
                            delivery,
                            existingAllocation,
                          );

                          return DropdownMenuItem<int>(
                            value: delivery.id,
                            child: Text(
                              '${_deliveryReference(delivery)} • '
                              '${_money(delivery.totalAmount.toDouble())} • '
                              'Outstanding ${_money(outstanding)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: existingAllocation != null
                            ? null
                            : (value) {
                                setDialogState(() {
                                  deliveryId = value;
                                  validationError = null;
                                });
                              },
                      ),

                      const SizedBox(height: 18),

                      _dialogLabel('Amount'),

                      TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration(
                          'Allocation amount',
                          prefixText: '₦ ',
                        ),
                        onChanged: (_) {
                          setDialogState(() {
                            validationError = null;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      if (currentPayment != null && currentDelivery != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Allocation limits',
                                style: AppTextStyles.body,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Maximum: ${_money(maxAmount)}',
                                style: AppTextStyles.title,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Payment available: '
                                '${_money(paymentAvailable)}\n'
                                'Delivery outstanding: '
                                '${_money(deliveryAvailable)}',
                                style: AppTextStyles.small,
                              ),
                            ],
                          ),
                        ),

                      if (validationError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          validationError!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final amount = double.tryParse(controller.text.trim());

                    if (paymentId == null) {
                      setDialogState(() {
                        validationError = 'Please select a payment.';
                      });
                      return;
                    }

                    if (deliveryId == null) {
                      setDialogState(() {
                        validationError = 'Please select a delivery.';
                      });
                      return;
                    }

                    if (amount == null || amount <= 0.0) {
                      setDialogState(() {
                        validationError = 'Enter a valid allocation amount.';
                      });
                      return;
                    }

                    final payment = _paymentById(paymentId!);

                    final delivery = _deliveryById(deliveryId!);

                    if (payment == null) {
                      setDialogState(() {
                        validationError =
                            'The selected payment could not be found.';
                      });
                      return;
                    }

                    if (delivery == null) {
                      setDialogState(() {
                        validationError =
                            'The selected delivery could not be found.';
                      });
                      return;
                    }

                    final paymentAvailable = _paymentAvailableForEdit(
                      payment,
                      existingAllocation,
                    );

                    final deliveryAvailable = _deliveryAvailableForEdit(
                      delivery,
                      existingAllocation,
                    );

                    final maxAmount = paymentAvailable < deliveryAvailable
                        ? paymentAvailable
                        : deliveryAvailable;

                    if (amount > maxAmount + 0.000001) {
                      setDialogState(() {
                        validationError =
                            'Allocation cannot exceed '
                            '${_money(maxAmount)}.';
                      });
                      return;
                    }

                    try {
                      if (existingAllocation == null) {
                        await _allocationDao.allocatePayment(
                          paymentId: paymentId!,
                          deliveryId: deliveryId!,
                          amount: amount,
                        );
                      } else {
                        await _allocationDao.updateAllocation(
                          allocationId: existingAllocation.id,
                          amount: amount,
                        );
                      }

                      if (!dialogContext.mounted) return;

                      Navigator.of(dialogContext).pop(true);
                    } catch (e) {
                      if (!dialogContext.mounted) return;

                      setDialogState(() {
                        validationError = e.toString().replaceFirst(
                          'Exception: ',
                          '',
                        );
                      });
                    }
                  },
                  child: Text(existingAllocation == null ? 'Allocate' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

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
        return AlertDialog(
          title: const Text('Delete Allocation'),
          content: Text(
            'Delete the allocation of '
            '${_money(allocation.amount.toDouble())}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
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

  InputDecoration _inputDecoration(String label, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _dialogLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(text, style: AppTextStyles.body),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.small),
                  const SizedBox(height: 4),
                  Text(value, style: AppTextStyles.title),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyles.small),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: 5),
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
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
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

    return Row(
      children: [
        _summaryCard(
          title: 'Payments',
          value: _money(totalPayments),
          icon: Icons.payments_outlined,
        ),
        const SizedBox(width: 12),
        _summaryCard(
          title: 'Unallocated',
          value: _money(totalPaymentRemaining),
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(width: 12),
        _summaryCard(
          title: 'Deliveries',
          value: _money(totalDeliveries),
          icon: Icons.local_shipping_outlined,
        ),
        const SizedBox(width: 12),
        _summaryCard(
          title: 'Outstanding',
          value: _money(totalDeliveryOutstanding),
          icon: Icons.pending_actions_outlined,
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENTS
  // ============================================================

  Widget _buildPayments() {
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
        borderRadius: BorderRadius.circular(14),
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

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                child: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                _money(payment.amount.toDouble()),
                style: AppTextStyles.body,
              ),
              subtitle: Text(
                '${_date(payment.paymentDate)}'
                ' • Allocated ${_money(allocated)}'
                ' • Remaining ${_money(remaining)}',
              ),
              trailing: fullyAllocated
                  ? const Chip(label: Text('Fully allocated'))
                  : FilledButton.icon(
                      onPressed: () {
                        _openAllocationDialog(selectedPayment: payment);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Allocate'),
                    ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // DELIVERIES
  // ============================================================

  Widget _buildDeliveries() {
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
        borderRadius: BorderRadius.circular(14),
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

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                _deliveryReference(delivery),
                style: AppTextStyles.body,
              ),
              subtitle: Text(
                '${_date(delivery.deliveryDate)}'
                ' • Total '
                '${_money(delivery.totalAmount.toDouble())}'
                ' • Paid ${_money(allocated)}'
                ' • Outstanding '
                '${_money(outstanding)}',
              ),
              trailing: fullyPaid
                  ? const Chip(label: Text('Fully paid'))
                  : OutlinedButton.icon(
                      onPressed: () {
                        _openAllocationDialog(selectedDelivery: delivery);
                      },
                      icon: const Icon(Icons.link, size: 18),
                      label: const Text('Apply payment'),
                    ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // ALLOCATION HISTORY
  // ============================================================

  Widget _buildAllocationHistory() {
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
        borderRadius: BorderRadius.circular(14),
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

            return ListTile(
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
              trailing: PopupMenuButton<String>(
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
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Allocations'),
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
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Allocations',
                          style: AppTextStyles.heading,
                        ),
                        const SizedBox(height: 5),
                        Text(widget.supplier.name, style: AppTextStyles.body),
                        const SizedBox(height: 24),

                        _buildSummary(),

                        const SizedBox(height: 24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildPayments()),
                            const SizedBox(width: 18),
                            Expanded(child: _buildDeliveries()),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _buildAllocationHistory(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

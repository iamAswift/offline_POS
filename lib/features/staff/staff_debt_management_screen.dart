// lib/features/staff/staff_debt_management_screen.dart

import 'package:flutter/material.dart';

import '../../database/daos/staff_debt_payment_dao.dart';
import '../../database/daos/staff_purchase_dao.dart';

class StaffDebtManagementScreen extends StatefulWidget {
  final StaffDebtPaymentDao debtPaymentDao;
  final StaffPurchaseDao staffPurchaseDao;
  final int recordedBy;

  const StaffDebtManagementScreen({
    super.key,
    required this.debtPaymentDao,
    required this.staffPurchaseDao,
    required this.recordedBy,
  });

  @override
  State<StaffDebtManagementScreen> createState() =>
      _StaffDebtManagementScreenState();
}

class _StaffDebtManagementScreenState
    extends State<StaffDebtManagementScreen> {
  bool _isLoading = true;

  List<Map<String, dynamic>> _staffDebt = [];

  double _maxDebt = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDebtData();
  }

  // ============================================================
  // LOAD DEBT DATA
  // ============================================================

  Future<void> _loadDebtData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // --------------------------------------------------------
      // GET STAFF WITH CREDIT PURCHASES
      // --------------------------------------------------------

      final debtSummary =
          await widget.staffPurchaseDao.getStaffDebtSummary();

      // --------------------------------------------------------
      // GET MAXIMUM ALLOWED STAFF DEBT
      // --------------------------------------------------------

      final maxDebt =
          await widget.staffPurchaseDao.getMaxStaffDebt();

      final List<Map<String, dynamic>> updated = [];

      // --------------------------------------------------------
      // CALCULATE EACH STAFF MEMBER'S CURRENT BALANCE
      // --------------------------------------------------------

      for (final staff in debtSummary) {
        final dynamic rawStaffId = staff['staffId'];

        final int? staffId = rawStaffId is int
            ? rawStaffId
            : int.tryParse(
                rawStaffId?.toString() ?? '',
              );

        if (staffId == null) {
          continue;
        }

        final String staffName =
            staff['staffName']?.toString() ?? 'Unknown Staff';

        final dynamic rawTotalDebt =
            staff['totalDebt'];

        final double totalDebt =
            rawTotalDebt is num
                ? rawTotalDebt.toDouble()
                : double.tryParse(
                      rawTotalDebt?.toString() ?? '',
                    ) ??
                    0.0;

        // ------------------------------------------------------
        // GET ALL PAYMENTS MADE BY THIS STAFF MEMBER
        // ------------------------------------------------------

        final double totalPaid =
            await widget.debtPaymentDao
                .getTotalDebtPayments(staffId);

        // ------------------------------------------------------
        // CURRENT OUTSTANDING BALANCE
        // ------------------------------------------------------

        final double rawBalance =
            totalDebt - totalPaid;

        final double balance =
            rawBalance > 0 ? rawBalance : 0.0;

        // ------------------------------------------------------
        // REMAINING CREDIT LIMIT
        // ------------------------------------------------------

        final double rawRemaining =
            maxDebt - balance;

        final double remainingCredit =
            rawRemaining > 0 ? rawRemaining : 0.0;

        updated.add({
          'staffId': staffId,
          'staffName': staffName,
          'totalDebt': totalDebt,
          'totalPaid': totalPaid,
          'balance': balance,
          'remainingCredit': remainingCredit,
        });
      }

      // --------------------------------------------------------
      // SORT BY STAFF NAME
      // --------------------------------------------------------

      updated.sort(
        (a, b) => a['staffName']
            .toString()
            .toLowerCase()
            .compareTo(
              b['staffName']
                  .toString()
                  .toLowerCase(),
            ),
      );

      if (!mounted) return;

      setState(() {
        _staffDebt = updated;
        _maxDebt = maxDebt;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Failed to load staff debt: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // RECORD REPAYMENT
  // ============================================================

  Future<void> _showRepaymentDialog(
    Map<String, dynamic> staff,
  ) async {
    final int staffId =
        staff['staffId'] as int;

    final String staffName =
        staff['staffName'].toString();

    final double balance =
        (staff['balance'] as num).toDouble();

    if (balance <= 0) {
      _showMessage(
        '$staffName has no outstanding debt.',
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _RepaymentDialog(
          staffId: staffId,
          staffName: staffName,
          balance: balance,
          debtPaymentDao: widget.debtPaymentDao,
          recordedBy: widget.recordedBy,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _loadDebtData();

      if (!mounted) return;

      _showMessage(
        'Repayment recorded successfully for $staffName.',
      );
    }
  }

  // ============================================================
  // PAYMENT HISTORY
  // ============================================================

  Future<void> _showPaymentHistory(
    Map<String, dynamic> staff,
  ) async {
    final int staffId =
        staff['staffId'] as int;

    final String staffName =
        staff['staffName'].toString();

    try {
      final payments =
          await widget.debtPaymentDao
              .getStaffDebtPaymentHistory(
        staffId,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              '$staffName - Repayment History',
            ),
            content: SizedBox(
              width: 600,
              height: 450,
              child: payments.isEmpty
                  ? const Center(
                      child: Text(
                        'No repayments recorded.',
                      ),
                    )
                  : ListView.separated(
                      itemCount:
                          payments.length,
                      separatorBuilder:
                          (_, __) =>
                              const Divider(),
                      itemBuilder:
                          (context, index) {
                        final payment =
                            payments[index];

                        final String note =
                            payment.note
                                    ?.trim() ??
                                '';

                        return ListTile(
                          leading:
                              const CircleAvatar(
                            child: Icon(
                              Icons.payments,
                            ),
                          ),
                          title: Text(
                            _money(
                              payment.amount
                                  .toDouble(),
                            ),
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${payment.paymentMethod.toUpperCase()}'
                            '${note.isEmpty ? '' : '\n$note'}'
                            '\n${payment.createdAt}',
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child:
                    const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to load repayment history: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : null,
      ),
    );
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String _money(double value) {
    return '₦${value.toStringAsFixed(2)}';
  }

  // ============================================================
  // STAFF CARD
  // ============================================================

  Widget _buildStaffCard(
    Map<String, dynamic> staff,
  ) {
    final String staffName =
        staff['staffName'].toString();

    final int staffId =
        staff['staffId'] as int;

    final double balance =
        (staff['balance'] as num)
            .toDouble();

    final double totalDebt =
        (staff['totalDebt'] as num)
            .toDouble();

    final double totalPaid =
        (staff['totalPaid'] as num)
            .toDouble();

    final double remainingCredit =
        (staff['remainingCredit'] as num)
            .toDouble();

    final double progress =
        _maxDebt <= 0
            ? 0.0
            : (balance / _maxDebt)
                .clamp(0.0, 1.0);

    final bool hasDebt =
        balance > 0;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Text(
                    staffName.trim().isEmpty
                        ? '?'
                        : staffName
                            .trim()
                            .substring(
                              0,
                              1,
                            )
                            .toUpperCase(),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        staffName,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Staff ID: $staffId',
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // CURRENT BALANCE
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Outstanding',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      _money(balance),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                        color: hasDebt
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // DEBT PROGRESS
            // ==================================================

            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  'Debt usage: '
                  '${_money(balance)} / '
                  '${_money(_maxDebt)}',
                ),
                Text(
                  'Available: '
                  '${_money(remainingCredit)}',
                  style: TextStyle(
                    color:
                        remainingCredit > 0
                            ? Colors.green
                            : Colors.red,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SUMMARY
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.grey
                    .withValues(alpha: 0.08),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Credit Purchases',
                      _money(totalDebt),
                      Icons.shopping_cart,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Repaid',
                      _money(totalPaid),
                      Icons.check_circle,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Balance',
                      _money(balance),
                      Icons
                          .account_balance_wallet,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // ACTIONS
            // ==================================================

            Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _showPaymentHistory(
                        staff,
                      );
                    },
                    icon: const Icon(
                      Icons.history,
                    ),
                    label: const Text(
                      'History',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed: hasDebt
                        ? () {
                            _showRepaymentDialog(
                              staff,
                            );
                          }
                        : null,
                    icon: const Icon(
                      Icons.payments,
                    ),
                    label: const Text(
                      'Record Repayment',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 22,
        ),

        const SizedBox(height: 6),

        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Staff Debt Management',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading
                ? null
                : _loadDebtData,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadDebtData,
              child: _staffDebt.isEmpty
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: 250,
                        ),
                        Center(
                          child: Text(
                            'No outstanding staff debt records found.',
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),
                      children: [
                        Text(
                          'Staff Debt Overview',
                          style:
                              Theme.of(
                                context,
                              )
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          'Monitor staff credit purchases, repayments and outstanding balances.',
                          style:
                              Theme.of(
                                context,
                              )
                                  .textTheme
                                  .bodyMedium,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        ..._staffDebt.map(
                          _buildStaffCard,
                        ),

                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
            ),
    );
  }
}

// ================================================================
// REPAYMENT DIALOG
// ================================================================

class _RepaymentDialog
    extends StatefulWidget {
  final int staffId;
  final String staffName;
  final double balance;
  final StaffDebtPaymentDao debtPaymentDao;
  final int recordedBy;

  const _RepaymentDialog({
    required this.staffId,
    required this.staffName,
    required this.balance,
    required this.debtPaymentDao,
    required this.recordedBy,
  });

  @override
  State<_RepaymentDialog> createState() =>
      _RepaymentDialogState();
}

class _RepaymentDialogState
    extends State<_RepaymentDialog> {
  late final TextEditingController
      _amountController;

  late final TextEditingController
      _noteController;

  String _paymentMethod = 'cash';

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _amountController =
        TextEditingController();

    _noteController =
        TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE PAYMENT
  // ============================================================

  Future<void> _savePayment() async {
    if (_isSaving) return;

    final double? amount =
        double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      _showError(
        'Enter a valid payment amount.',
      );
      return;
    }

    if (amount > widget.balance) {
      _showError(
        'Payment cannot exceed the outstanding debt of '
        '₦${widget.balance.toStringAsFixed(2)}.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.debtPaymentDao
          .recordDebtPayment(
        staffId: widget.staffId,
        amount: amount,
        paymentMethod:
            _paymentMethod,
        recordedBy:
            widget.recordedBy,
        note:
            _noteController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showError(
        'Failed to record repayment: $e',
      );
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Record Debt Repayment',
      ),

      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                widget.staffName,
                style:
                    const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Outstanding debt: '
                '₦${widget.balance.toStringAsFixed(2)}',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller:
                    _amountController,
                enabled: !_isSaving,
                autofocus: true,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText:
                      'Payment Amount',
                  prefixText: '₦ ',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<
                  String>(
                initialValue:
                    _paymentMethod,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Payment Method',
                  border:
                      OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'cash',
                    child:
                        Text('Cash'),
                  ),
                  DropdownMenuItem(
                    value: 'pos',
                    child:
                        Text('POS'),
                  ),
                  DropdownMenuItem(
                    value: 'transfer',
                    child:
                        Text('Transfer'),
                  ),
                  DropdownMenuItem(
                    value: 'payroll',
                    child: Text(
                      'Payroll Deduction',
                    ),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value ==
                            null) {
                          return;
                        }

                        setState(() {
                          _paymentMethod =
                              value;
                        });
                      },
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    _noteController,
                enabled: !_isSaving,
                maxLines: 3,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Note (Optional)',
                  hintText:
                      'e.g. January salary deduction',
                  border:
                      OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(
                    context,
                  ).pop(false);
                },
          child:
              const Text('Cancel'),
        ),

        ElevatedButton.icon(
          onPressed: _isSaving
              ? null
              : _savePayment,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.payments,
                ),
          label: Text(
            _isSaving
                ? 'Saving...'
                : 'Record Payment',
          ),
        ),
      ],
    );
  }
}
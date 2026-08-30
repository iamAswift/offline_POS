// lib/features/staff/staff_debt_management_screen.dart

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../core/widgets/back_button.dart';
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
      final debtSummary =
          await widget.staffPurchaseDao.getStaffDebtSummary();

      final maxDebt =
          await widget.staffPurchaseDao.getMaxStaffDebt();

      final List<Map<String, dynamic>> updated = [];

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

        final double totalPaid =
            await widget.debtPaymentDao
                .getTotalDebtPayments(staffId);

        final double rawBalance =
            totalDebt - totalPaid;

        final double balance =
            rawBalance > 0 ? rawBalance : 0.0;

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
          final responsive =
              Responsive(dialogContext);

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppRadius.lg,
              ),
            ),
            title: Text(
              '$staffName - Repayment History',
              style: AppTextStyles.title,
            ),
            content: SizedBox(
              width: responsive.isCompact
                  ? double.infinity
                  : 600,
              height: responsive.isCompact
                  ? 380
                  : 450,
              child: payments.isEmpty
                  ? Center(
                      child: Text(
                        'No repayments recorded.',
                        style:
                            AppTextStyles.bodySecondary,
                      ),
                    )
                  : ListView.separated(
                      itemCount: payments.length,
                      separatorBuilder: (_, __) =>
                          const Divider(
                        color: AppColors.divider,
                      ),
                      itemBuilder:
                          (context, index) {
                        final payment =
                            payments[index];

                        final String note =
                            payment.note
                                    ?.trim() ??
                                '';

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.successLight,
                            foregroundColor:
                                AppColors.success,
                            child: const Icon(
                              Icons.payments_outlined,
                            ),
                          ),
                          title: Text(
                            _money(
                              payment.amount
                                  .toDouble(),
                            ),
                            style:
                                AppTextStyles.price,
                          ),
                          subtitle: Text(
                            '${payment.paymentMethod.toUpperCase()}'
                            '${note.isEmpty ? '' : '\n$note'}'
                            '\n${payment.createdAt}',
                            style:
                                AppTextStyles.small,
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
                child: const Text('Close'),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor:
            isError
                ? AppColors.danger
                : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.md,
          ),
        ),
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
    final responsive = Responsive(context);

    final String staffName =
        staff['staffName'].toString();

    final int staffId =
        staff['staffId'] as int;

    final double balance =
        (staff['balance'] as num).toDouble();

    final double totalDebt =
        (staff['totalDebt'] as num).toDouble();

    final double totalPaid =
        (staff['totalPaid'] as num).toDouble();

    final double remainingCredit =
        (staff['remainingCredit'] as num).toDouble();

    final double progress =
        _maxDebt <= 0
            ? 0.0
            : (balance / _maxDebt)
                .clamp(0.0, 1.0);

    final bool hasDebt =
        balance > 0;

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(
          responsive.isCompact
              ? AppSpacing.lg
              : AppSpacing.xl,
        ),
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: responsive.isCompact
                      ? 22
                      : 25,
                  backgroundColor:
                      AppColors.primaryLight,
                  foregroundColor:
                      AppColors.primary,
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
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(
                  width: AppSpacing.md,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        staffName,
                        style:
                            AppTextStyles.title,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: AppSpacing.xs,
                      ),
                      Text(
                        'Staff ID: $staffId',
                        style:
                            AppTextStyles.small,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: AppSpacing.md,
                ),

                // CURRENT BALANCE
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Outstanding',
                      style:
                          AppTextStyles.small,
                    ),
                    const SizedBox(
                      height: AppSpacing.xs,
                    ),
                    Text(
                      _money(balance),
                      style: AppTextStyles.price
                          .copyWith(
                        color: hasDebt
                            ? AppColors.danger
                            : AppColors.success,
                        fontSize:
                            responsive.isCompact
                                ? 16
                                : 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            // ==================================================
            // DEBT PROGRESS
            // ==================================================

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.round,
              ),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    AppColors.divider,
                color: hasDebt
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Debt usage: '
                    '${_money(balance)} / '
                    '${_money(_maxDebt)}',
                    style:
                        AppTextStyles.small,
                  ),
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Text(
                  'Available: '
                  '${_money(remainingCredit)}',
                  style:
                      AppTextStyles.small.copyWith(
                    color: remainingCredit > 0
                        ? AppColors.success
                        : AppColors.danger,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            // ==================================================
            // SUMMARY
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
                horizontal: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.md,
                ),
                border: Border.all(
                  color: AppColors.divider,
                ),
              ),
              child: responsive.isCompact
                  ? Column(
                      children: [
                        _buildSummaryItem(
                          'Credit Purchases',
                          _money(totalDebt),
                          Icons.shopping_cart_outlined,
                        ),
                        const Divider(
                          height: AppSpacing.xl,
                        ),
                        _buildSummaryItem(
                          'Repaid',
                          _money(totalPaid),
                          Icons.check_circle_outline,
                        ),
                        const Divider(
                          height: AppSpacing.xl,
                        ),
                        _buildSummaryItem(
                          'Balance',
                          _money(balance),
                          Icons.account_balance_wallet_outlined,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child:
                              _buildSummaryItem(
                            'Credit Purchases',
                            _money(totalDebt),
                            Icons.shopping_cart_outlined,
                          ),
                        ),
                        Expanded(
                          child:
                              _buildSummaryItem(
                            'Repaid',
                            _money(totalPaid),
                            Icons.check_circle_outline,
                          ),
                        ),
                        Expanded(
                          child:
                              _buildSummaryItem(
                            'Balance',
                            _money(balance),
                            Icons.account_balance_wallet_outlined,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            // ==================================================
            // ACTIONS
            // ==================================================

            responsive.isCompact
                ? Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
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
                        style:
                            _outlinedButtonStyle(),
                      ),
                      const SizedBox(
                        height: AppSpacing.sm,
                      ),
                      ElevatedButton.icon(
                        onPressed: hasDebt
                            ? () {
                                _showRepaymentDialog(
                                  staff,
                                );
                              }
                            : null,
                        icon: const Icon(
                          Icons.payments_outlined,
                        ),
                        label: const Text(
                          'Record Repayment',
                        ),
                        style:
                            _primaryButtonStyle(),
                      ),
                    ],
                  )
                : Row(
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
                          style:
                              _outlinedButtonStyle(),
                        ),
                      ),
                      const SizedBox(
                        width: AppSpacing.md,
                      ),
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
                            Icons.payments_outlined,
                          ),
                          label: const Text(
                            'Record Repayment',
                          ),
                          style:
                              _primaryButtonStyle(),
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
          color: AppColors.primary,
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        Text(
          label,
          style: AppTextStyles.small,
          textAlign: TextAlign.center,
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================
  // BUTTON STYLES
  // ============================================================

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(
        0,
        AppSizes.buttonHeight,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
      ),
      textStyle: AppTextStyles.body.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size(
        0,
        AppSizes.buttonHeight,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      side: const BorderSide(
        color: AppColors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
      ),
      textStyle: AppTextStyles.body.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        leading: const CentralBackButton(),
        title: const Text(
          'Staff Debt Management',
          style: AppTextStyles.heading,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadDebtData,
              child: _staffDebt.isEmpty
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            responsive.horizontalPadding,
                      ),
                      children: [
                        const SizedBox(
                          height: 180,
                        ),
                        _buildEmptyState(),
                      ],
                    )
                  : ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            responsive.horizontalPadding,
                        vertical:
                            responsive.verticalPadding,
                      ),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(
                              maxWidth:
                                  responsive.contentMaxWidth,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                // ==================================
                                // PAGE HEADER
                                // ==================================

                                Text(
                                  'Staff Debt Overview',
                                  style:
                                      AppTextStyles
                                          .dashboardTitle,
                                ),

                                const SizedBox(
                                  height:
                                      AppSpacing.xs,
                                ),

                                Text(
                                  'Monitor staff credit purchases, repayments and outstanding balances.',
                                  style:
                                      AppTextStyles
                                          .dashboardSubtitle,
                                ),

                                const SizedBox(
                                  height:
                                      AppSpacing.xxl,
                                ),

                                // ==================================
                                // STAFF CARDS
                                // ==================================

                                ..._staffDebt.map(
                                  _buildStaffCard,
                                ),

                                const SizedBox(
                                  height:
                                      AppSpacing.lg,
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
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        padding: const EdgeInsets.all(
          AppSpacing.xxxl,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.round,
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 32,
                color: AppColors.success,
              ),
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              'No Outstanding Debt',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              'No outstanding staff debt records were found.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
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
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.md,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
      ),

      title: Text(
        'Record Debt Repayment',
        style: AppTextStyles.title,
      ),

      content: SizedBox(
        width: responsive.isCompact
            ? double.infinity
            : 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ================================================
              // STAFF
              // ================================================

              Container(
                padding: const EdgeInsets.all(
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.md,
                  ),
                  border: Border.all(
                    color:
                        AppColors.primary.withValues(
                      alpha: 0.15,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor:
                          Colors.white,
                      child: Text(
                        widget.staffName
                                .trim()
                                .isEmpty
                            ? '?'
                            : widget.staffName
                                .trim()
                                .substring(
                                  0,
                                  1,
                                )
                                .toUpperCase(),
                        style:
                            const TextStyle(
                          fontFamily:
                              'Poppins',
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.md,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            widget.staffName,
                            style:
                                AppTextStyles.title,
                          ),
                          const SizedBox(
                            height:
                                AppSpacing.xs,
                          ),
                          Text(
                            'Outstanding debt',
                            style:
                                AppTextStyles.small,
                          ),
                          const SizedBox(
                            height:
                                AppSpacing.xs,
                          ),
                          Text(
                            '₦${widget.balance.toStringAsFixed(2)}',
                            style: AppTextStyles
                                .price
                                .copyWith(
                              color:
                                  AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              // ================================================
              // AMOUNT
              // ================================================

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

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // ================================================
              // PAYMENT METHOD
              // ================================================

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

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // ================================================
              // NOTE
              // ================================================

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

      actionsPadding:
          const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
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
          style: ElevatedButton.styleFrom(
            backgroundColor:
                AppColors.primary,
            foregroundColor:
                Colors.white,
            minimumSize: const Size(
              0,
              AppSizes.buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.md,
              ),
            ),
          ),
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.payments_outlined,
                ),
          label: Text(
            _isSaving
                ? 'Saving...'
                : 'Record Payment',
            style:
                AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
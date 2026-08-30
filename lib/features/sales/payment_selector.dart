// lib/features/sales/payment_selector.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../models/pos_settings.dart';

class PaymentSelector extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;
  final PosSettings posSettings;

  final Function(
    double cash,
    double pos,
    double transfer,
  ) onPaymentConfirmed;

  final Function(
    double cashReceived,
    double cashApplied,
    double change,
  )? onCashPaymentDetails;

  final int total;

  const PaymentSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
    required this.onPaymentConfirmed,
    required this.total,
    required this.posSettings,
    this.onCashPaymentDetails,
  });

  // ============================================================
  // PAYMENT SETTINGS
  // ============================================================

  bool _isPaymentMethodEnabled(String method) {
    return posSettings.isPaymentMethodEnabled(method);
  }

  bool get _splitEnabled {
    return posSettings.enabledPaymentMethodCount >= 2;
  }

  // ============================================================
  // PAYMENT POPUP
  // ============================================================

  void _showPaymentPopup(
    BuildContext context,
    String method,
  ) {
    if (!_isPaymentMethodEnabled(method) && method != 'split') {
      _showError(
        context,
        '${PosSettings.paymentMethodLabel(method)} '
        'is disabled in POS settings.',
      );
      return;
    }

    if (method == 'split' && !_splitEnabled) {
      _showError(
        context,
        'Split payment requires at least two enabled '
        'payment methods.',
      );
      return;
    }

    final cashController = TextEditingController();
    final posController = TextEditingController();
    final transferController = TextEditingController();

    // ============================================================
    // IMPORTANT:
    // This notifier belongs to the bottom sheet.
    // It is disposed only after the sheet has completely closed.
    // ============================================================

    final cashEntered = ValueNotifier<double>(0);

    if (method == 'cash') {
      cashController.text = total.toString();
      cashEntered.value = total.toDouble();
    }

    if (method == 'pos') {
      posController.text = total.toString();
    }

    if (method == 'transfer') {
      transferController.text = total.toString();
    }

    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (sheetContext) {
        final screenWidth = MediaQuery.of(sheetContext).size.width;
        final isTablet = screenWidth >= 600;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                sheetContext,
              ).viewInsets.bottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 500 : 410,
                ),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    isTablet ? AppRadius.lg : AppRadius.md,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? AppSpacing.md : AppSpacing.sm,
                      AppSpacing.xs,
                      isTablet ? AppSpacing.md : AppSpacing.sm,
                      AppSpacing.sm,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // HANDLE
                        // ==================================================

                        Center(
                          child: Container(
                            width: 30,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(
                                AppRadius.round,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ==================================================
                        // HEADER
                        // ==================================================

                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: _paymentColor(method).withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Icon(
                                _paymentIcon(method),
                                color: _paymentColor(method),
                                size: 18,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Complete Payment',
                                    style: AppTextStyles.title.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    _paymentLabel(method),
                                    style: AppTextStyles.small.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 30,
                                minHeight: 30,
                              ),
                              onPressed: () {
                                Navigator.pop(sheetContext);
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 9),

                        // ==================================================
                        // TOTAL
                        // ==================================================

                        _buildTotalCard(method),

                        const SizedBox(height: 9),

                        // ==================================================
                        // CASH
                        // ==================================================

                        if (method == 'cash')
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _buildAmountField(
                                label: 'Cash Received',
                                hint: 'Enter amount received',
                                controller: cashController,
                                icon: Icons.payments_outlined,
                                color: AppColors.success,
                                onChanged: (value) {
                                  cashEntered.value =
                                      double.tryParse(
                                        value.trim(),
                                      ) ??
                                      0;
                                },
                              ),

                              const SizedBox(height: 6),

                              ValueListenableBuilder<double>(
                                valueListenable: cashEntered,
                                builder: (
                                  context,
                                  amount,
                                  _,
                                ) {
                                  final due = total.toDouble();
                                  final difference = amount - due;

                                  if (amount > 0 && amount < due) {
                                    return _buildPaymentStatus(
                                      label: 'AMOUNT REMAINING',
                                      amount: due - amount,
                                      color: AppColors.danger,
                                      icon: Icons.warning_amber_outlined,
                                    );
                                  }

                                  if ((amount - due).abs() <= 0.01) {
                                    return _buildPaymentStatus(
                                      label: 'EXACT PAYMENT',
                                      amount: due,
                                      color: AppColors.success,
                                      icon: Icons.check_circle_outline,
                                    );
                                  }

                                  if (difference > 0) {
                                    return _buildPaymentStatus(
                                      label: 'CHANGE',
                                      amount: difference,
                                      color: AppColors.success,
                                      icon: Icons.payments_outlined,
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),

                        // ==================================================
                        // POS
                        // ==================================================

                        if (method == 'pos')
                          _buildAmountField(
                            label: 'POS Amount',
                            hint: 'Enter POS amount',
                            controller: posController,
                            icon: Icons.credit_card_outlined,
                            color: AppColors.primary,
                          ),

                        // ==================================================
                        // TRANSFER
                        // ==================================================

                        if (method == 'transfer')
                          _buildAmountField(
                            label: 'Transfer Amount',
                            hint: 'Enter transfer amount',
                            controller: transferController,
                            icon: Icons.account_balance_outlined,
                            color: AppColors.inventory,
                          ),

                        // ==================================================
                        // SPLIT
                        // ==================================================

                        if (method == 'split')
                          _buildSplitPayment(
                            cashController,
                            posController,
                            transferController,
                          ),

                        const SizedBox(height: 9),

                        // ==================================================
                        // ACTIONS
                        // ==================================================

                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(sheetContext);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        AppColors.textPrimary,
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 7),

                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    size: 17,
                                  ),
                                  label: const Text(
                                    'Complete Sale',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    _confirmPayment(
                                      context,
                                      sheetContext,
                                      method,
                                      cashController,
                                      posController,
                                      transferController,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).then(
      (result) {
        // ============================================================
        // IMPORTANT:
        // The bottom sheet is now fully closed.
        //
        // Only NOW do we:
        //   1. Dispose controllers/notifier
        //   2. Update parent payment method
        //   3. Send payment to SalesScreen
        //
        // This prevents the "dirty widget in wrong build scope"
        // and "_dependents.isEmpty" assertions.
        // ============================================================

        cashController.dispose();
        posController.dispose();
        transferController.dispose();
        cashEntered.dispose();

        if (result == null) {
          return;
        }

        final resultMethod = result['method'] as String?;

        if (resultMethod == null) {
          return;
        }

        onMethodSelected(resultMethod);

        if (resultMethod == 'cash') {
          final cashReceived =
              (result['cashReceived'] as num?)?.toDouble() ?? 0;

          final cashApplied =
              (result['cashApplied'] as num?)?.toDouble() ?? 0;

          final change =
              (result['change'] as num?)?.toDouble() ?? 0;

          onCashPaymentDetails?.call(
            cashReceived,
            cashApplied,
            change,
          );

          onPaymentConfirmed(
            cashApplied,
            0,
            0,
          );

          return;
        }

        if (resultMethod == 'pos') {
          final pos =
              (result['pos'] as num?)?.toDouble() ?? 0;

          onPaymentConfirmed(
            0,
            pos,
            0,
          );

          return;
        }

        if (resultMethod == 'transfer') {
          final transfer =
              (result['transfer'] as num?)?.toDouble() ?? 0;

          onPaymentConfirmed(
            0,
            0,
            transfer,
          );

          return;
        }

        if (resultMethod == 'split') {
          final cash =
              (result['cash'] as num?)?.toDouble() ?? 0;

          final pos =
              (result['pos'] as num?)?.toDouble() ?? 0;

          final transfer =
              (result['transfer'] as num?)?.toDouble() ?? 0;

          onPaymentConfirmed(
            cash,
            pos,
            transfer,
          );
        }
      },
    );
  }

  // ============================================================
  // TOTAL CARD
  // ============================================================

  Widget _buildTotalCard(String method) {
    final color = _paymentColor(method);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: color,
              size: 15,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL DUE',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    fontSize: 8,
                  ),
                ),
                Text(
                  '₦${_formatMoney(total)}',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 20,
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT STATUS
  // ============================================================

  Widget _buildPaymentStatus({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 15,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                fontSize: 9,
              ),
            ),
          ),

          Text(
            '₦${_formatMoney(amount)}',
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SPLIT PAYMENT
  // ============================================================

  Widget _buildSplitPayment(
    TextEditingController cashController,
    TextEditingController posController,
    TextEditingController transferController,
  ) {
    final enabled = <Widget>[];

    if (_isPaymentMethodEnabled('cash')) {
      enabled.add(
        _buildSplitField(
          'Cash',
          cashController,
          AppColors.success,
          Icons.payments_outlined,
        ),
      );
    }

    if (_isPaymentMethodEnabled('pos')) {
      enabled.add(
        _buildSplitField(
          'POS',
          posController,
          AppColors.primary,
          Icons.credit_card_outlined,
        ),
      );
    }

    if (_isPaymentMethodEnabled('transfer')) {
      enabled.add(
        _buildSplitField(
          'Transfer',
          transferController,
          AppColors.inventory,
          Icons.account_balance_outlined,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Split Payment',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          'Enter the amount for each method.',
          style: AppTextStyles.small.copyWith(
            color: AppColors.textSecondary,
            fontSize: 9,
          ),
        ),

        const SizedBox(height: 7),

        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: enabled.map((field) {
            return SizedBox(
              width: enabled.length == 1
                  ? double.infinity
                  : enabled.length == 2
                  ? 205
                  : 165,
              child: field,
            );
          }).toList(),
        ),

        const SizedBox(height: 7),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.warning,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  'Combined amounts must equal the total due.',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
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
  // SPLIT FIELD
  // ============================================================

  Widget _buildSplitField(
    String label,
    TextEditingController controller,
    Color color,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      style: AppTextStyles.body.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: color,
          size: 17,
        ),
        filled: true,
        fillColor: color.withValues(alpha: 0.045),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 9,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(
            color: color,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONFIRM PAYMENT
  // ============================================================

  void _confirmPayment(
    BuildContext context,
    BuildContext sheetContext,
    String method,
    TextEditingController cashController,
    TextEditingController posController,
    TextEditingController transferController,
  ) {
    if (method != 'split' && !_isPaymentMethodEnabled(method)) {
      _showError(
        context,
        '${PosSettings.paymentMethodLabel(method)} '
        'is disabled in POS settings.',
      );
      return;
    }

    if (method == 'split' && !_splitEnabled) {
      _showError(
        context,
        'Split payment is unavailable because fewer than two '
        'payment methods are enabled.',
      );
      return;
    }

    final cashEntered =
        double.tryParse(
          cashController.text.trim(),
        ) ??
        0;

    final pos =
        double.tryParse(
          posController.text.trim(),
        ) ??
        0;

    final transfer =
        double.tryParse(
          transferController.text.trim(),
        ) ??
        0;

    final due = total.toDouble();

    // ==========================================================
    // CASH
    // ==========================================================

    if (method == 'cash') {
      if (cashEntered <= 0) {
        _showError(
          context,
          'Please enter the cash received.',
        );
        return;
      }

      if (cashEntered < due) {
        _showError(
          context,
          'Cash received is not enough. '
          'Required: ₦${_formatMoney(total)}',
        );
        return;
      }

      final cashApplied = due;
      final change = cashEntered - cashApplied;

      // ========================================================
      // IMPORTANT:
      // Do NOT call the parent immediately.
      //
      // Return the result to the bottom-sheet Future instead.
      // The parent will be updated only after the sheet closes.
      // ========================================================

      Navigator.pop(
        sheetContext,
        <String, dynamic>{
          'method': method,
          'cashReceived': cashEntered,
          'cashApplied': cashApplied,
          'change': change,
        },
      );

      return;
    }

    // ==========================================================
    // POS
    // ==========================================================

    if (method == 'pos') {
      if (pos <= 0) {
        _showError(
          context,
          'Please enter the POS amount.',
        );
        return;
      }

      if ((pos - due).abs() > 0.01) {
        _showError(
          context,
          'POS payment must equal '
          '₦${_formatMoney(total)}. '
          'Entered: ₦${_formatMoney(pos)}',
        );
        return;
      }

      Navigator.pop(
        sheetContext,
        <String, dynamic>{
          'method': method,
          'pos': pos,
        },
      );

      return;
    }

    // ==========================================================
    // TRANSFER
    // ==========================================================

    if (method == 'transfer') {
      if (transfer <= 0) {
        _showError(
          context,
          'Please enter the transfer amount.',
        );
        return;
      }

      if ((transfer - due).abs() > 0.01) {
        _showError(
          context,
          'Transfer payment must equal '
          '₦${_formatMoney(total)}. '
          'Entered: ₦${_formatMoney(transfer)}',
        );
        return;
      }

      Navigator.pop(
        sheetContext,
        <String, dynamic>{
          'method': method,
          'transfer': transfer,
        },
      );

      return;
    }

    // ==========================================================
    // SPLIT
    // ==========================================================

    if (method == 'split') {
      final paymentTotal =
          cashEntered +
          pos +
          transfer;

      if (paymentTotal <= 0) {
        _showError(
          context,
          'Please enter at least one payment amount.',
        );
        return;
      }

      if ((paymentTotal - due).abs() > 0.01) {
        final difference = due - paymentTotal;

        if (difference > 0) {
          _showError(
            context,
            'Payment is short by '
            '₦${_formatMoney(difference)}.',
          );
        } else {
          _showError(
            context,
            'Payment exceeds the total by '
            '₦${_formatMoney(difference.abs())}.',
          );
        }

        return;
      }

      // ========================================================
      // CRITICAL FIX:
      //
      // Previously:
      //
      // Navigator.pop(sheetContext);
      // onPaymentConfirmed(...);
      //
      // This caused the bottom sheet and SalesScreen to rebuild
      // during the same widget lifecycle.
      //
      // Now we simply return the payment result.
      // The .then() in _showPaymentPopup() handles it after
      // the bottom sheet has completely closed.
      // ========================================================

      Navigator.pop(
        sheetContext,
        <String, dynamic>{
          'method': method,
          'cash': cashEntered,
          'pos': pos,
          'transfer': transfer,
        },
      );

      return;
    }

    _showError(
      context,
      'Invalid payment method.',
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AMOUNT FIELD
  // ============================================================

  Widget _buildAmountField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      style: AppTextStyles.body.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: color,
          size: 19,
        ),
        filled: true,
        fillColor: color.withValues(alpha: 0.045),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(
            color: color,
            width: 1.3,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.035),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final width = constraints.maxWidth;
          final isTablet = width >= 600;

          final paymentButtons = <Widget>[];

          if (_isPaymentMethodEnabled('cash')) {
            paymentButtons.add(
              _paymentButton(
                context,
                label: 'Cash',
                subtitle: 'Cash',
                icon: Icons.payments_outlined,
                color: AppColors.success,
                method: 'cash',
              ),
            );
          }

          if (_isPaymentMethodEnabled('pos')) {
            paymentButtons.add(
              _paymentButton(
                context,
                label: 'POS',
                subtitle: 'Card',
                icon: Icons.credit_card_outlined,
                color: AppColors.primary,
                method: 'pos',
              ),
            );
          }

          if (_isPaymentMethodEnabled('transfer')) {
            paymentButtons.add(
              _paymentButton(
                context,
                label: 'Transfer',
                subtitle: 'Bank',
                icon: Icons.account_balance_outlined,
                color: AppColors.inventory,
                method: 'transfer',
              ),
            );
          }

          if (_splitEnabled) {
            paymentButtons.add(
              _paymentButton(
                context,
                label: 'Split',
                subtitle: 'Multiple',
                icon: Icons.call_split,
                color: AppColors.warning,
                method: 'split',
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==================================================
              // COMPACT HEADER
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(
                        AppRadius.sm,
                      ),
                    ),
                    child: const Icon(
                      Icons.payments_outlined,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      'Payment',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  if (total > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppRadius.round,
                        ),
                      ),
                      child: Text(
                        '₦${_formatMoney(total)}',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 5),

              // ==================================================
              // PAYMENT BUTTONS
              // ==================================================

              if (paymentButtons.isEmpty)
                _buildNoPaymentMethods()
              else if (isTablet)
                _buildTabletPaymentGrid(
                  paymentButtons,
                  width,
                )
              else
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: paymentButtons.map(
                    (button) {
                      return SizedBox(
                        width: (width - 5) / 2,
                        child: button,
                      );
                    },
                  ).toList(),
                ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // TABLET GRID
  // ============================================================

  Widget _buildTabletPaymentGrid(
    List<Widget> buttons,
    double width,
  ) {
    final itemWidth = (width - 6) / 2;

    return Wrap(
      spacing: 6,
      runSpacing: 5,
      children: buttons.map(
        (button) {
          return SizedBox(
            width: itemWidth,
            child: button,
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // NO PAYMENT METHODS
  // ============================================================

  Widget _buildNoPaymentMethods() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Text(
        'No payment methods are enabled.',
        style: TextStyle(
          color: AppColors.danger,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT BUTTON
  // ============================================================

  Widget _paymentButton(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String method,
  }) {
    final isSelected = selectedMethod == method;

    return SizedBox(
      height: 39,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: () {
            _showPaymentPopup(
              context,
              method,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color
                  : color.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: isSelected
                    ? color
                    : color.withValues(alpha: 0.16),
                width: isSelected ? 1.1 : 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.18)
                        : color.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(
                      AppRadius.sm,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 15,
                    color: isSelected ? Colors.white : color,
                  ),
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),

                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small.copyWith(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.80)
                              : AppColors.textSecondary,
                          fontSize: 7,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 15,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ICON
  // ============================================================

  IconData _paymentIcon(String method) {
    switch (method) {
      case 'pos':
        return Icons.credit_card_outlined;

      case 'transfer':
        return Icons.account_balance_outlined;

      case 'split':
        return Icons.call_split;

      case 'cash':
      default:
        return Icons.payments_outlined;
    }
  }

  // ============================================================
  // COLOR
  // ============================================================

  Color _paymentColor(String method) {
    switch (method) {
      case 'pos':
        return AppColors.primary;

      case 'transfer':
        return AppColors.inventory;

      case 'split':
        return AppColors.warning;

      case 'cash':
      default:
        return AppColors.success;
    }
  }

  // ============================================================
  // LABEL
  // ============================================================

  String _paymentLabel(String method) {
    switch (method) {
      case 'pos':
        return 'POS / Card payment';

      case 'transfer':
        return 'Bank transfer';

      case 'split':
        return 'Multiple payment methods';

      case 'cash':
      default:
        return 'Cash payment';
    }
  }

  // ============================================================
  // MONEY
  // ============================================================

  String _formatMoney(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }
}

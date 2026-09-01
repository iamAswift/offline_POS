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

    // ==========================================================
    // IMPORTANT
    //
    // Payment controllers are now owned by the StatefulWidget
    // displayed inside the bottom sheet.
    //
    // PaymentSelector itself does NOT create or dispose:
    //
    //   TextEditingController
    //   FocusNode
    //   ValueNotifier
    //
    // This prevents the controller lifecycle from being tied
    // manually to the bottom-sheet Future.
    // ==========================================================

    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (sheetContext) {
        return _PaymentBottomSheet(
          method: method,
          total: total,
          posSettings: posSettings,
        );
      },
    ).then(
      (result) {
        // ========================================================
        // The bottom sheet has returned its final result.
        //
        // The controllers are NOT disposed here.
        //
        // _PaymentBottomSheetState.dispose() owns that lifecycle.
        // ========================================================

        if (result == null) {
          return;
        }

        final resultMethod = result['method'] as String?;

        if (resultMethod == null || resultMethod.trim().isEmpty) {
          return;
        }

        // ========================================================
        // Update selected payment method only after the sheet
        // has returned its result.
        // ========================================================

        onMethodSelected(resultMethod);

        // ========================================================
        // CASH
        // ========================================================

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

          // IMPORTANT:
          //
          // Only the amount applied to the sale is passed to
          // SalesScreen.
          //
          // Example:
          //
          // Sale = ₦7,500
          // Cash received = ₦10,000
          // Change = ₦2,500
          //
          // SalesScreen receives:
          //
          // cash = ₦7,500
          // pos = ₦0
          // transfer = ₦0
          //

          onPaymentConfirmed(
            cashApplied,
            0,
            0,
          );

          return;
        }

        // ========================================================
        // POS
        // ========================================================

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

        // ========================================================
        // TRANSFER
        // ========================================================

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

        // ========================================================
        // SPLIT
        // ========================================================

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

          return;
        }
      },
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
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
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
        borderRadius: BorderRadius.circular(
          AppRadius.sm,
        ),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
        borderRadius: BorderRadius.circular(
          AppRadius.sm,
        ),
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
  // PAYMENT FIELD
  // ============================================================

  Widget _buildAmountField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    ValueChanged<String>? onChanged,
    bool autofocus = true,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
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
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SPLIT FIELD
  // ============================================================

  Widget _buildSplitField({
    required String label,
    required TextEditingController controller,
    required Color color,
    required IconData icon,
  }) {
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
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT BUTTON
  // ============================================================

  Widget _buildPaymentButton(
    BuildContext context, {
    required String label,
    required String method,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedMethod == method;

    return SizedBox(
      height: 39,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          onTap: () {
            _showPaymentPopup(
              context,
              method,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 140,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.10)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppRadius.sm,
              ),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.35)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected
                      ? color
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small.copyWith(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? color
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: color,
                  ),
              ],
            ),
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
    final enabledMethods = <Widget>[];

    if (_isPaymentMethodEnabled('cash')) {
      enabledMethods.add(
        _buildPaymentButton(
          context,
          label: 'Cash',
          method: 'cash',
          icon: Icons.payments_outlined,
          color: AppColors.success,
        ),
      );
    }

    if (_isPaymentMethodEnabled('pos')) {
      enabledMethods.add(
        _buildPaymentButton(
          context,
          label: 'POS',
          method: 'pos',
          icon: Icons.credit_card_outlined,
          color: AppColors.primary,
        ),
      );
    }

    if (_isPaymentMethodEnabled('transfer')) {
      enabledMethods.add(
        _buildPaymentButton(
          context,
          label: 'Transfer',
          method: 'transfer',
          icon: Icons.account_balance_outlined,
          color: AppColors.inventory,
        ),
      );
    }

    if (_splitEnabled) {
      enabledMethods.add(
        _buildPaymentButton(
          context,
          label: 'Split',
          method: 'split',
          icon: Icons.call_split_outlined,
          color: AppColors.warning,
        ),
      );
    }

    if (enabledMethods.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(
            alpha: 0.06,
          ),
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          border: Border.all(
            color: AppColors.danger.withValues(
              alpha: 0.15,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_outlined,
              color: AppColors.danger,
              size: 17,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'No payment methods are enabled in POS settings.',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: enabledMethods.map(
        (widget) {
          return SizedBox(
            width: enabledMethods.length == 1
                ? double.infinity
                : enabledMethods.length == 2
                ? 170
                : 125,
            child: widget,
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // PAYMENT LABEL
  // ============================================================

  String _paymentLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Cash payment';

      case 'pos':
        return 'POS / card payment';

      case 'transfer':
        return 'Bank transfer';

      case 'split':
        return 'Multiple payment methods';

      default:
        return PosSettings.paymentMethodLabel(method);
    }
  }

  // ============================================================
  // PAYMENT ICON
  // ============================================================

  IconData _paymentIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.payments_outlined;

      case 'pos':
        return Icons.credit_card_outlined;

      case 'transfer':
        return Icons.account_balance_outlined;

      case 'split':
        return Icons.call_split_outlined;

      default:
        return Icons.payment_outlined;
    }
  }

  // ============================================================
  // PAYMENT COLOR
  // ============================================================

  Color _paymentColor(String method) {
    switch (method) {
      case 'cash':
        return AppColors.success;

      case 'pos':
        return AppColors.primary;

      case 'transfer':
        return AppColors.inventory;

      case 'split':
        return AppColors.warning;

      default:
        return AppColors.primary;
    }
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String _formatMoney(num value) {
    final rounded = value.round();

    final text = rounded.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final position = text.length - i;

      buffer.write(text[i]);

      if (position > 1 && position % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}

// ==================================================================
// PAYMENT BOTTOM SHEET
// ==================================================================
//
// This widget owns ALL payment input state.
//
// This is the important lifecycle change.
//
// Controllers are created in State.initState() and disposed in
// State.dispose(). PaymentSelector never manually disposes them.
// ==================================================================

class _PaymentBottomSheet extends StatefulWidget {
  final String method;
  final int total;
  final PosSettings posSettings;

  const _PaymentBottomSheet({
    required this.method,
    required this.total,
    required this.posSettings,
  });

  @override
  State<_PaymentBottomSheet> createState() =>
      _PaymentBottomSheetState();
}

class _PaymentBottomSheetState
    extends State<_PaymentBottomSheet> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  late final TextEditingController cashController;
  late final TextEditingController posController;
  late final TextEditingController transferController;

  // ============================================================
  // CASH STATE
  // ============================================================

  late final ValueNotifier<double> cashEntered;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    cashController = TextEditingController();
    posController = TextEditingController();
    transferController = TextEditingController();

    cashEntered = ValueNotifier<double>(0);

    // ==========================================================
    // DEFAULT AMOUNTS
    // ==========================================================

    if (widget.method == 'cash') {
      cashController.text = widget.total.toString();

      cashEntered.value =
          widget.total.toDouble();
    }

    if (widget.method == 'pos') {
      posController.text = widget.total.toString();
    }

    if (widget.method == 'transfer') {
      transferController.text =
          widget.total.toString();
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================
  //
  // This is now the ONLY place where these controllers/notifier
  // are disposed.
  //
  // Flutter calls this when the bottom-sheet State is removed.
  // ============================================================

  @override
  void dispose() {
    cashController.dispose();
    posController.dispose();
    transferController.dispose();
    cashEntered.dispose();

    super.dispose();
  }

  // ============================================================
  // PAYMENT SETTINGS
  // ============================================================

  bool _isPaymentMethodEnabled(String method) {
    return widget.posSettings.isPaymentMethodEnabled(
      method,
    );
  }

  bool get _splitEnabled {
    return widget
            .posSettings
            .enabledPaymentMethodCount >=
        2;
  }

  // ============================================================
  // CONFIRM PAYMENT
  // ============================================================

  void _confirmPayment(
    BuildContext context,
    BuildContext sheetContext,
  ) {
    final method = widget.method;

    if (method != 'split' &&
        !_isPaymentMethodEnabled(method)) {
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

    final cashEnteredAmount =
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

    final due = widget.total.toDouble();

    // ==========================================================
    // CASH
    // ==========================================================

    if (method == 'cash') {
      if (cashEnteredAmount <= 0) {
        _showError(
          context,
          'Please enter the cash received.',
        );
        return;
      }

      if (cashEnteredAmount < due) {
        _showError(
          context,
          'Cash received is not enough. '
          'Required: ₦${_formatMoney(widget.total)}',
        );
        return;
      }

      final cashApplied = due;

      final change =
          cashEnteredAmount - cashApplied;

      // ========================================================
      // Return result.
      //
      // DO NOT call parent callbacks directly from this widget.
      // ========================================================

      Navigator.pop(
        sheetContext,
        <String, dynamic>{
          'method': method,
          'cashReceived': cashEnteredAmount,
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
          '₦${_formatMoney(widget.total)}. '
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
          '₦${_formatMoney(widget.total)}. '
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
          cashEnteredAmount +
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
        final difference =
            due - paymentTotal;

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
      // Validate enabled methods.
      // ========================================================

      if (cashEnteredAmount > 0 &&
          !_isPaymentMethodEnabled('cash')) {
        _showError(
          context,
          'Cash is disabled in POS settings.',
        );
        return;
      }

      if (pos > 0 &&
          !_isPaymentMethodEnabled('pos')) {
        _showError(
          context,
          'POS is disabled in POS settings.',
        );
        return;
      }

      if (transfer > 0 &&
          !_isPaymentMethodEnabled('transfer')) {
        _showError(
          context,
          'Transfer is disabled in POS settings.',
        );
        return;
      }

      // ========================================================
      // Return split payment result.
      // ========================================================

      Navigator.pop(
        sheetContext,
        <String, dynamic>{
          'method': method,
          'cash': cashEnteredAmount,
          'pos': pos,
          'transfer': transfer,
        },
      );

      return;
    }

    // ==========================================================
    // INVALID METHOD
    // ==========================================================

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
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
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
    bool autofocus = true,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
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
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SPLIT PAYMENT
  // ============================================================

  Widget _buildSplitPayment() {
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
          children: enabled.map(
            (field) {
              return SizedBox(
                width: enabled.length == 1
                    ? double.infinity
                    : enabled.length == 2
                    ? 205
                    : 165,
                child: field,
              );
            },
          ).toList(),
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
            borderRadius: BorderRadius.circular(
              AppRadius.sm,
            ),
            border: Border.all(
              color: AppColors.warning.withValues(
                alpha: 0.15,
              ),
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
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
          borderSide: BorderSide(
            color: color,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOTAL CARD
  // ============================================================

  Widget _buildTotalCard() {
    final color = _paymentColor(widget.method);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(
          AppRadius.sm,
        ),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                  '₦${_formatMoney(widget.total)}',
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
        borderRadius: BorderRadius.circular(
          AppRadius.sm,
        ),
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
  // PAYMENT ICON
  // ============================================================

  IconData _paymentIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.payments_outlined;

      case 'pos':
        return Icons.credit_card_outlined;

      case 'transfer':
        return Icons.account_balance_outlined;

      case 'split':
        return Icons.call_split_outlined;

      default:
        return Icons.payment_outlined;
    }
  }

  // ============================================================
  // PAYMENT COLOR
  // ============================================================

  Color _paymentColor(String method) {
    switch (method) {
      case 'cash':
        return AppColors.success;

      case 'pos':
        return AppColors.primary;

      case 'transfer':
        return AppColors.inventory;

      case 'split':
        return AppColors.warning;

      default:
        return AppColors.primary;
    }
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String _formatMoney(num value) {
    final rounded = value.round();

    final text = rounded.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final position = text.length - i;

      buffer.write(text[i]);

      if (position > 1 && position % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    final isTablet = screenWidth >= 600;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(
            context,
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
                isTablet
                    ? AppRadius.lg
                    : AppRadius.md,
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isTablet
                      ? AppSpacing.md
                      : AppSpacing.sm,
                  AppSpacing.xs,
                  isTablet
                      ? AppSpacing.md
                      : AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                          borderRadius:
                              BorderRadius.circular(
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
                            color: _paymentColor(
                              widget.method,
                            ).withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              AppRadius.sm,
                            ),
                          ),
                          child: Icon(
                            _paymentIcon(
                              widget.method,
                            ),
                            color: _paymentColor(
                              widget.method,
                            ),
                            size: 18,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'Complete Payment',
                                style:
                                    AppTextStyles.title
                                        .copyWith(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                              Text(
                                PosSettings
                                    .paymentMethodLabel(
                                  widget.method,
                                ),
                                style:
                                    AppTextStyles.small
                                        .copyWith(
                                  color: AppColors
                                      .textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          visualDensity:
                              VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
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

                    _buildTotalCard(),

                    const SizedBox(height: 9),

                    // ==================================================
                    // CASH
                    // ==================================================

                    if (widget.method == 'cash')
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildAmountField(
                            label: 'Cash Received',
                            hint:
                                'Enter amount received',
                            controller:
                                cashController,
                            icon:
                                Icons.payments_outlined,
                            color:
                                AppColors.success,
                            onChanged: (value) {
                              cashEntered.value =
                                  double.tryParse(
                                        value.trim(),
                                      ) ??
                                      0;
                            },
                          ),

                          const SizedBox(height: 6),

                          ValueListenableBuilder<
                              double>(
                            valueListenable:
                                cashEntered,
                            builder: (
                              context,
                              amount,
                              _,
                            ) {
                              final due =
                                  widget.total
                                      .toDouble();

                              final difference =
                                  amount - due;

                              if (amount > 0 &&
                                  amount < due) {
                                return _buildPaymentStatus(
                                  label:
                                      'AMOUNT REMAINING',
                                  amount:
                                      due - amount,
                                  color:
                                      AppColors.danger,
                                  icon: Icons
                                      .warning_amber_outlined,
                                );
                              }

                              if ((amount - due)
                                      .abs() <=
                                  0.01) {
                                return _buildPaymentStatus(
                                  label:
                                      'EXACT PAYMENT',
                                  amount: due,
                                  color:
                                      AppColors.success,
                                  icon: Icons
                                      .check_circle_outline,
                                );
                              }

                              if (difference > 0) {
                                return _buildPaymentStatus(
                                  label: 'CHANGE',
                                  amount:
                                      difference,
                                  color:
                                      AppColors.success,
                                  icon: Icons
                                      .payments_outlined,
                                );
                              }

                              return const SizedBox
                                  .shrink();
                            },
                          ),
                        ],
                      ),

                    // ==================================================
                    // POS
                    // ==================================================

                    if (widget.method == 'pos')
                      _buildAmountField(
                        label: 'POS Amount',
                        hint: 'Enter POS amount',
                        controller: posController,
                        icon:
                            Icons.credit_card_outlined,
                        color: AppColors.primary,
                      ),

                    // ==================================================
                    // TRANSFER
                    // ==================================================

                    if (widget.method == 'transfer')
                      _buildAmountField(
                        label: 'Transfer Amount',
                        hint:
                            'Enter transfer amount',
                        controller:
                            transferController,
                        icon: Icons
                            .account_balance_outlined,
                        color:
                            AppColors.inventory,
                      ),

                    // ==================================================
                    // SPLIT
                    // ==================================================

                    if (widget.method == 'split')
                      _buildSplitPayment(),

                    const SizedBox(height: 9),

                    // ==================================================
                    // ACTIONS
                    // ==================================================

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child:
                                OutlinedButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                              },
                              style:
                                  OutlinedButton
                                      .styleFrom(
                                foregroundColor:
                                    AppColors
                                        .textPrimary,
                                side:
                                    const BorderSide(
                                  color:
                                      AppColors
                                          .border,
                                ),
                                padding:
                                    EdgeInsets.zero,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    AppRadius.sm,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w700,
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
                            child:
                                ElevatedButton.icon(
                              icon: const Icon(
                                Icons
                                    .check_circle_outline,
                                size: 17,
                              ),
                              label: const Text(
                                'Complete Sale',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    AppColors
                                        .success,
                                foregroundColor:
                                    Colors.white,
                                elevation: 0,
                                padding:
                                    EdgeInsets.zero,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    AppRadius.sm,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                _confirmPayment(
                                  context,
                                  context,
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
  }
}
// lib/features/sales/payment_selector.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../models/pos_settings.dart';

class PaymentSelector extends StatelessWidget {
  final String selectedMethod;

  final Function(String) onMethodSelected;

  /// POS settings control which payment methods are available.
  final PosSettings posSettings;

  /// Amounts applied to the sale.
  ///
  /// For cash:
  /// cash = amount applied to the sale, NOT physical cash received.
  ///
  /// Example:
  /// Sale = ₦500
  /// Cash received = ₦1,000
  /// Change = ₦500
  ///
  /// onPaymentConfirmed receives:
  /// cash = ₦500
  /// pos = ₦0
  /// transfer = ₦0
  final Function(
    double cash,
    double pos,
    double transfer,
  ) onPaymentConfirmed;

  /// Optional callback for cash transactions.
  ///
  /// cashReceived = physical cash received
  /// cashApplied = amount applied to sale
  /// change = cashReceived - cashApplied
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

  bool _isPaymentMethodEnabled(
    String method,
  ) {
    return posSettings.isPaymentMethodEnabled(
      method,
    );
  }

  /// Split is available when at least two payment methods
  /// are enabled.
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
    // ----------------------------------------------------------
    // SAFETY CHECK
    // ----------------------------------------------------------

    if (!_isPaymentMethodEnabled(method) &&
        method != 'split') {
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

    final cashController =
        TextEditingController();

    final posController =
        TextEditingController();

    final transferController =
        TextEditingController();

    final cashEntered =
        ValueNotifier<double>(0);

    // ==========================================================
    // DEFAULT VALUES
    // ==========================================================

    if (method == "cash") {
      cashController.text =
          total.toString();

      cashEntered.value =
          total.toDouble();
    }

    if (method == "pos") {
      posController.text =
          total.toString();
    }

    if (method == "transfer") {
      transferController.text =
          total.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      barrierColor:
          Colors.black.withValues(
        alpha: 0.35,
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(
                    sheetContext,
                  ).viewInsets.bottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 560,
                ),
                child: Material(
                  color:
                      AppColors.surface,
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(
                      24,
                    ),
                    bottom: Radius.circular(
                      24,
                    ),
                  ),
                  clipBehavior:
                      Clip.antiAlias,
                  child:
                      SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      14,
                      20,
                      20,
                    ),
                    child:
                        Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // DRAG HANDLE
                        // ==================================================

                        Center(
                          child:
                              Container(
                            width: 38,
                            height: 4,
                            decoration:
                                BoxDecoration(
                              color:
                                  AppColors
                                      .border,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================================
                        // HEADER
                        // ==================================================

                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration:
                                  BoxDecoration(
                                color:
                                    _paymentColor(
                                  method,
                                ).withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  13,
                                ),
                              ),
                              child:
                                  Icon(
                                _paymentIcon(
                                  method,
                                ),
                                color:
                                    _paymentColor(
                                  method,
                                ),
                                size: 23,
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    "Complete Payment",
                                    style:
                                        AppTextStyles
                                            .title
                                            .copyWith(
                                      fontSize:
                                          19,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 2,
                                  ),

                                  Text(
                                    _paymentLabel(
                                      method,
                                    ),
                                    style:
                                        AppTextStyles
                                            .small
                                            .copyWith(
                                      color:
                                          AppColors
                                              .textSecondary,
                                      fontSize:
                                          12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              tooltip:
                                  "Close",
                              visualDensity:
                                  VisualDensity
                                      .compact,
                              onPressed:
                                  () {
                                Navigator.pop(
                                  sheetContext,
                                );
                              },
                              icon:
                                  const Icon(
                                Icons.close,
                                size: 22,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================================
                        // TOTAL DUE
                        // ==================================================

                        _buildTotalCard(
                          method,
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================================
                        // CASH
                        // ==================================================

                        if (method ==
                            "cash")
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              _buildAmountField(
                                label:
                                    "Cash Received",
                                hint:
                                    "Enter amount received",
                                controller:
                                    cashController,
                                icon:
                                    Icons
                                        .payments_outlined,
                                color:
                                    AppColors
                                        .success,
                                onChanged:
                                    (value) {
                                  cashEntered
                                      .value =
                                      double.tryParse(
                                            value
                                                .trim(),
                                          ) ??
                                          0;
                                },
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              ValueListenableBuilder<
                                  double>(
                                valueListenable:
                                    cashEntered,
                                builder: (
                                  context,
                                  amount,
                                  _,
                                ) {
                                  final change =
                                      amount -
                                          total
                                              .toDouble();

                                  // ------------------------------------------------
                                  // NOT ENOUGH
                                  // ------------------------------------------------

                                  if (amount >
                                          0 &&
                                      amount <
                                          total) {
                                    final remaining =
                                        total
                                                .toDouble() -
                                            amount;

                                    return _buildPaymentStatus(
                                      label:
                                          "AMOUNT REMAINING",
                                      amount:
                                          remaining,
                                      color:
                                          AppColors
                                              .danger,
                                      icon:
                                          Icons
                                              .warning_amber_outlined,
                                    );
                                  }

                                  // ------------------------------------------------
                                  // EXACT
                                  // ------------------------------------------------

                                  if (amount ==
                                      total
                                          .toDouble()) {
                                    return _buildPaymentStatus(
                                      label:
                                          "EXACT PAYMENT",
                                      amount:
                                          total
                                              .toDouble(),
                                      color:
                                          AppColors
                                              .success,
                                      icon:
                                          Icons
                                              .check_circle_outline,
                                    );
                                  }

                                  // ------------------------------------------------
                                  // CHANGE
                                  // ------------------------------------------------

                                  if (change >
                                      0) {
                                    return _buildPaymentStatus(
                                      label:
                                          "CHANGE",
                                      amount:
                                          change,
                                      color:
                                          AppColors
                                              .success,
                                      icon:
                                          Icons
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

                        if (method ==
                            "pos")
                          _buildAmountField(
                            label:
                                "POS Amount",
                            hint:
                                "Enter POS amount",
                            controller:
                                posController,
                            icon:
                                Icons
                                    .credit_card_outlined,
                            color:
                                AppColors
                                    .primary,
                          ),

                        // ==================================================
                        // TRANSFER
                        // ==================================================

                        if (method ==
                            "transfer")
                          _buildAmountField(
                            label:
                                "Transfer Amount",
                            hint:
                                "Enter transfer amount",
                            controller:
                                transferController,
                            icon:
                                Icons
                                    .account_balance_outlined,
                            color:
                                AppColors
                                    .inventory,
                          ),

                        // ==================================================
                        // SPLIT
                        // ==================================================

                        if (method ==
                            "split")
                          _buildSplitPayment(
                            cashController,
                            posController,
                            transferController,
                          ),

                        const SizedBox(
                          height: 18,
                        ),

                        // ==================================================
                        // ACTIONS
                        // ==================================================

                        Row(
                          children: [
                            Expanded(
                              child:
                                  SizedBox(
                                height: 50,
                                child:
                                    OutlinedButton(
                                  onPressed:
                                      () {
                                    Navigator.pop(
                                      sheetContext,
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
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        12,
                                      ),
                                    ),
                                  ),
                                  child:
                                      const Text(
                                    "Cancel",
                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                      fontSize:
                                          14,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              flex: 2,
                              child:
                                  SizedBox(
                                height: 50,
                                child:
                                    ElevatedButton.icon(
                                  icon:
                                      const Icon(
                                    Icons
                                        .check_circle_outline,
                                    size: 20,
                                  ),
                                  label:
                                      const Text(
                                    "Complete Sale",
                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                      fontSize:
                                          14,
                                    ),
                                  ),
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        AppColors
                                            .success,
                                    foregroundColor:
                                        Colors
                                            .white,
                                    elevation:
                                        0,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        12,
                                      ),
                                    ),
                                  ),
                                  onPressed:
                                      () {
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
    ).whenComplete(
      () {
        cashController.dispose();
        posController.dispose();
        transferController.dispose();
        cashEntered.dispose();
      },
    );
  }

  // ============================================================
  // TOTAL CARD
  // ============================================================

  Widget _buildTotalCard(
    String method,
  ) {
    final color =
        _paymentColor(method);

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.055,
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border:
            Border.all(
          color:
              color.withValues(
            alpha: 0.14,
          ),
        ),
      ),
      child:
          Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(
              color:
                  color.withValues(
                alpha: 0.10,
              ),
              shape:
                  BoxShape.circle,
            ),
            child:
                Icon(
              Icons.receipt_long_outlined,
              color: color,
              size: 19,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  "TOTAL DUE",
                  style:
                      AppTextStyles
                          .small
                          .copyWith(
                    color:
                        AppColors
                            .textSecondary,
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing:
                        0.8,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  "₦${_formatMoney(total)}",
                  style:
                      AppTextStyles
                          .heading
                          .copyWith(
                    fontSize: 25,
                    color: color,
                    fontWeight:
                        FontWeight.w800,
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
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.07,
        ),
        borderRadius:
            BorderRadius.circular(
          11,
        ),
        border:
            Border.all(
          color:
              color.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child:
          Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 19,
          ),

          const SizedBox(
            width: 9,
          ),

          Expanded(
            child:
                Text(
              label,
              style:
                  AppTextStyles
                      .small
                      .copyWith(
                color: color,
                fontWeight:
                    FontWeight.w700,
                letterSpacing:
                    0.6,
              ),
            ),
          ),

          Text(
            "₦${_formatMoney(amount)}",
            style:
                AppTextStyles
                    .body
                    .copyWith(
              color: color,
              fontWeight:
                  FontWeight.w800,
              fontSize: 16,
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
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          "Split Payment",
          style:
              AppTextStyles
                  .body
                  .copyWith(
            fontWeight:
                FontWeight.w800,
            fontSize: 15,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          "Enter the amount applied through each method.",
          style:
              AppTextStyles
                  .small
                  .copyWith(
            color:
                AppColors
                    .textSecondary,
            fontSize: 11,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        if (_isPaymentMethodEnabled(
          'cash',
        ))
          _buildSplitRow(
            "Cash",
            cashController,
            AppColors.success,
            Icons.payments_outlined,
          ),

        if (_isPaymentMethodEnabled(
          'cash',
        ) &&
            (_isPaymentMethodEnabled(
                  'pos',
                ) ||
                _isPaymentMethodEnabled(
                  'transfer',
                )))
          const SizedBox(
            height: 9,
          ),

        if (_isPaymentMethodEnabled(
          'pos',
        ))
          _buildSplitRow(
            "POS",
            posController,
            AppColors.primary,
            Icons.credit_card_outlined,
          ),

        if (_isPaymentMethodEnabled(
              'pos',
            ) &&
            _isPaymentMethodEnabled(
              'transfer',
            ))
          const SizedBox(
            height: 9,
          ),

        if (_isPaymentMethodEnabled(
          'transfer',
        ))
          _buildSplitRow(
            "Transfer",
            transferController,
            AppColors.inventory,
            Icons.account_balance_outlined,
          ),

        const SizedBox(
          height: 10,
        ),

        Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.all(
            11,
          ),
          decoration:
              BoxDecoration(
            color:
                AppColors
                    .warningLight,
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            border:
                Border.all(
              color:
                  AppColors.warning
                      .withValues(
                alpha: 0.15,
              ),
            ),
          ),
          child:
              Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color:
                    AppColors.warning,
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child:
                    Text(
                  "Combined amounts must equal the total due.",
                  style:
                      AppTextStyles
                          .small
                          .copyWith(
                    color:
                        AppColors
                            .warning,
                    fontWeight:
                        FontWeight.w600,
                    fontSize: 11,
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
  // PAYMENT CONFIRMATION
  // ============================================================

  void _confirmPayment(
    BuildContext context,
    BuildContext sheetContext,
    String method,
    TextEditingController cashController,
    TextEditingController posController,
    TextEditingController transferController,
  ) {
    // ----------------------------------------------------------
    // FINAL SETTINGS CHECK
    // ----------------------------------------------------------

    if (method != 'split' &&
        !_isPaymentMethodEnabled(
          method,
        )) {
      _showError(
        context,
        '${PosSettings.paymentMethodLabel(method)} '
        'is disabled in POS settings.',
      );
      return;
    }

    if (method == 'split' &&
        !_splitEnabled) {
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

    // ==========================================================
    // CASH
    // ==========================================================

    if (method == "cash") {
      if (cashEntered <= 0) {
        _showError(
          context,
          "Please enter the cash received.",
        );
        return;
      }

      if (cashEntered < total) {
        _showError(
          context,
          "Cash received is not enough. "
          "Required: ₦${_formatMoney(total)}",
        );
        return;
      }

      final cashApplied =
          total.toDouble();

      final change =
          cashEntered - cashApplied;

      onMethodSelected(
        method,
      );

      onCashPaymentDetails?.call(
        cashEntered,
        cashApplied,
        change,
      );

      Navigator.pop(
        sheetContext,
      );

      onPaymentConfirmed(
        cashApplied,
        0,
        0,
      );

      return;
    }

    // ==========================================================
    // POS
    // ==========================================================

    if (method == "pos") {
      if (pos <= 0) {
        _showError(
          context,
          "Please enter the POS amount.",
        );
        return;
      }

      if ((pos - total).abs() >
          0.01) {
        _showError(
          context,
          "POS payment must equal "
          "₦${_formatMoney(total)}. "
          "Entered: ₦${_formatMoney(pos)}",
        );
        return;
      }

      onMethodSelected(
        method,
      );

      Navigator.pop(
        sheetContext,
      );

      onPaymentConfirmed(
        0,
        pos,
        0,
      );

      return;
    }

    // ==========================================================
    // TRANSFER
    // ==========================================================

    if (method == "transfer") {
      if (transfer <= 0) {
        _showError(
          context,
          "Please enter the transfer amount.",
        );
        return;
      }

      if ((transfer - total).abs() >
          0.01) {
        _showError(
          context,
          "Transfer payment must equal "
          "₦${_formatMoney(total)}. "
          "Entered: ₦${_formatMoney(transfer)}",
        );
        return;
      }

      onMethodSelected(
        method,
      );

      Navigator.pop(
        sheetContext,
      );

      onPaymentConfirmed(
        0,
        0,
        transfer,
      );

      return;
    }

    // ==========================================================
    // SPLIT PAYMENT
    // ==========================================================

    if (method == "split") {
      final paymentTotal =
          cashEntered +
              pos +
              transfer;

      if (paymentTotal <= 0) {
        _showError(
          context,
          "Please enter at least one payment amount.",
        );
        return;
      }

      if ((paymentTotal - total)
              .abs() >
          0.01) {
        _showError(
          context,
          "Payment must equal "
          "₦${_formatMoney(total)}. "
          "Entered: ₦${_formatMoney(paymentTotal)}",
        );
        return;
      }

      onMethodSelected(
        method,
      );

      Navigator.pop(
        sheetContext,
      );

      onPaymentConfirmed(
        cashEntered,
        pos,
        transfer,
      );

      return;
    }

    // ==========================================================
    // UNKNOWN PAYMENT METHOD
    // ==========================================================

    _showError(
      context,
      "Invalid payment method.",
    );
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            AppColors.danger,
        margin:
            const EdgeInsets.all(
          16,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        content:
            Text(message),
      ),
    );
  }

  // ============================================================
  // NORMAL PAYMENT FIELD
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
      controller:
          controller,
      autofocus:
          true,
      onChanged:
          onChanged,
      keyboardType:
          const TextInputType
              .numberWithOptions(
        decimal: true,
      ),
      style:
          AppTextStyles
              .body
              .copyWith(
        fontSize: 17,
        fontWeight:
            FontWeight.w700,
      ),
      decoration:
          InputDecoration(
        labelText:
            label,
        hintText:
            hint,
        prefixIcon:
            Icon(
          icon,
          color: color,
          size: 21,
        ),
        filled:
            true,
        fillColor:
            color.withValues(
          alpha: 0.045,
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color:
                color.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color:
                color.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color: color,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SPLIT PAYMENT FIELD
  // ============================================================

  Widget _buildSplitRow(
    String label,
    TextEditingController controller,
    Color color,
    IconData icon,
  ) {
    return TextField(
      controller:
          controller,
      keyboardType:
          const TextInputType
              .numberWithOptions(
        decimal: true,
      ),
      style:
          AppTextStyles
              .body
              .copyWith(
        fontSize: 16,
        fontWeight:
            FontWeight.w700,
      ),
      decoration:
          InputDecoration(
        labelText:
            "$label Amount",
        prefixIcon:
            Icon(
          icon,
          color: color,
          size: 20,
        ),
        filled:
            true,
        fillColor:
            color.withValues(
          alpha: 0.045,
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color:
                color.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color:
                color.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color: color,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        14,
        11,
        14,
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        border:
            const Border(
          top: BorderSide(
            color:
                AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color:
                Colors.black.withValues(
              alpha: 0.05,
            ),
            offset:
                const Offset(
              0,
              -3,
            ),
          ),
        ],
      ),
      child:
          LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          // ========================================================
          // BUILD ONLY ENABLED PAYMENT BUTTONS
          // ========================================================

          final paymentButtons =
              <Widget>[];

          if (_isPaymentMethodEnabled(
            'cash',
          )) {
            paymentButtons.add(
              _paymentButton(
                context,
                label: "Cash",
                subtitle: "Cash",
                icon:
                    Icons
                        .payments_outlined,
                color:
                    AppColors.success,
                method: "cash",
              ),
            );
          }

          if (_isPaymentMethodEnabled(
            'pos',
          )) {
            paymentButtons.add(
              _paymentButton(
                context,
                label: "POS",
                subtitle: "Card",
                icon:
                    Icons
                        .credit_card_outlined,
                color:
                    AppColors.primary,
                method: "pos",
              ),
            );
          }

          if (_isPaymentMethodEnabled(
            'transfer',
          )) {
            paymentButtons.add(
              _paymentButton(
                context,
                label: "Transfer",
                subtitle: "Bank",
                icon:
                    Icons
                        .account_balance_outlined,
                color:
                    AppColors.inventory,
                method: "transfer",
              ),
            );
          }

          if (_splitEnabled) {
            paymentButtons.add(
              _paymentButton(
                context,
                label: "Split",
                subtitle: "Multiple",
                icon:
                    Icons.call_split,
                color:
                    AppColors.warning,
                method: "split",
              ),
            );
          }

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .primaryLight,
                      borderRadius:
                          BorderRadius
                              .circular(
                        8,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .payments_outlined,
                      color:
                          AppColors
                              .primary,
                      size: 17,
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          "Payment",
                          style:
                              AppTextStyles
                                  .body
                                  .copyWith(
                            fontWeight:
                                FontWeight
                                    .w800,
                            fontSize:
                                14,
                          ),
                        ),

                        Text(
                          "Select payment method",
                          style:
                              AppTextStyles
                                  .small
                                  .copyWith(
                            color:
                                AppColors
                                    .textSecondary,
                            fontSize:
                                10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (total > 0)
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            AppColors
                                .primaryLight,
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                      ),
                      child:
                          Text(
                        "₦${_formatMoney(total)}",
                        style:
                            AppTextStyles
                                .body
                                .copyWith(
                          color:
                              AppColors
                                  .primary,
                          fontWeight:
                              FontWeight
                                  .w800,
                          fontSize:
                              13,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(
                height: 9,
              ),

              // ==================================================
              // PAYMENT METHODS
              // ==================================================

              if (paymentButtons.isEmpty)
                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors
                            .danger
                            .withValues(
                      alpha: 0.06,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),
                    border:
                        Border.all(
                      color:
                          AppColors
                              .danger
                              .withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ),
                  child:
                      const Text(
                    "No payment methods are enabled. "
                    "Please enable at least one method in POS Settings.",
                    style:
                        TextStyle(
                      color:
                          AppColors
                              .danger,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                )
              else if (constraints.maxWidth >=
                  600)
                Row(
                  children: [
                    for (
                      int i = 0;
                      i <
                          paymentButtons
                              .length;
                      i++
                    ) ...[
                      if (i > 0)
                        const SizedBox(
                          width: 7,
                        ),

                      Expanded(
                        child:
                            paymentButtons[
                                i],
                      ),
                    ],
                  ],
                )
              else
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children:
                      paymentButtons,
                ),
            ],
          );
        },
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
    final isSelected =
        selectedMethod == method;

    return SizedBox(
      height: 50,
      child:
          Material(
        color:
            Colors.transparent,
        child:
            InkWell(
          borderRadius:
              BorderRadius.circular(
            11,
          ),
          onTap: () {
            _showPaymentPopup(
              context,
              method,
            );
          },
          child:
              AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 160,
            ),
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration:
                BoxDecoration(
              color: isSelected
                  ? color
                  : color.withValues(
                      alpha: 0.055,
                    ),
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
              border:
                  Border.all(
                color: isSelected
                    ? color
                    : color.withValues(
                        alpha: 0.16,
                      ),
                width:
                    isSelected
                        ? 1.3
                        : 1,
              ),
            ),
            child:
                Row(
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration:
                      BoxDecoration(
                    color: isSelected
                        ? Colors.white
                            .withValues(
                            alpha: 0.18,
                          )
                        : color.withValues(
                            alpha: 0.09,
                          ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      8,
                    ),
                  ),
                  child:
                      Icon(
                    icon,
                    size: 17,
                    color: isSelected
                        ? Colors.white
                        : color,
                  ),
                ),

                const SizedBox(
                  width: 7,
                ),

                Expanded(
                  child:
                      Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            AppTextStyles
                                .body
                                .copyWith(
                          color:
                              isSelected
                                  ? Colors.white
                                  : AppColors
                                      .textPrimary,
                          fontWeight:
                              FontWeight
                                  .w800,
                          fontSize:
                              12,
                        ),
                      ),

                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            AppTextStyles
                                .small
                                .copyWith(
                          color:
                              isSelected
                                  ? Colors.white
                                      .withValues(
                                      alpha:
                                          0.80,
                                    )
                                  : AppColors
                                      .textSecondary,
                          fontSize:
                              9,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isSelected)
                  const Icon(
                    Icons
                        .check_circle,
                    color:
                        Colors.white,
                    size: 17,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT ICON
  // ============================================================

  IconData _paymentIcon(
    String method,
  ) {
    switch (method) {
      case "pos":
        return Icons
            .credit_card_outlined;

      case "transfer":
        return Icons
            .account_balance_outlined;

      case "split":
        return Icons.call_split;

      case "cash":
      default:
        return Icons
            .payments_outlined;
    }
  }

  // ============================================================
  // PAYMENT COLOR
  // ============================================================

  Color _paymentColor(
    String method,
  ) {
    switch (method) {
      case "pos":
        return AppColors.primary;

      case "transfer":
        return AppColors.inventory;

      case "split":
        return AppColors.warning;

      case "cash":
      default:
        return AppColors.success;
    }
  }

  // ============================================================
  // PAYMENT LABEL
  // ============================================================

  String _paymentLabel(
    String method,
  ) {
    switch (method) {
      case "pos":
        return "POS / Card payment";

      case "transfer":
        return "Bank transfer";

      case "split":
        return "Multiple payment methods";

      case "cash":
      default:
        return "Cash payment";
    }
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String _formatMoney(
    num value,
  ) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(
            r'\B(?=(\d{3})+(?!\d))',
          ),
          (match) => ',',
        );
  }
}
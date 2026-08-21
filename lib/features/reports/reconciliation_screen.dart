// lib/features/reports/reconciliation_screen.dart

import 'package:flutter/material.dart';

import '../../database/daos/product_dao.dart';
import '../../shared/pdf_report.dart';
import '../../models/reconciliation_row.dart';

class ReconciliationScreen extends StatefulWidget {
  final ProductDao productDao;
  final DateTime date;

  const ReconciliationScreen({
    super.key,
    required this.productDao,
    required this.date,
  });

  @override
  State<ReconciliationScreen> createState() =>
      _ReconciliationScreenState();
}

class _ReconciliationScreenState
    extends State<ReconciliationScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(
        selected.year,
        selected.month,
        selected.day,
      );
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Reconciliation',
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Select date',
            onPressed: _selectDate,
            icon: const Icon(
              Icons.calendar_today_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: widget.productDao.getDailyReconciliation(
          _selectedDate,
        ),
        builder: (context, snapshot) {
          // --------------------------------------------------------
          // LOADING
          // --------------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading reconciliation...',
                  ),
                ],
              ),
            );
          }

          // --------------------------------------------------------
          // ERROR
          // --------------------------------------------------------

          if (snapshot.hasError) {
            return _ErrorState(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {});
              },
            );
          }

          // --------------------------------------------------------
          // NO DATA
          // --------------------------------------------------------

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No reconciliation data available.',
              ),
            );
          }

          final rows = snapshot.data!;

          // --------------------------------------------------------
          // EMPTY
          // --------------------------------------------------------

          if (rows.isEmpty) {
            return _EmptyState(
              date: _formatDate(_selectedDate),
            );
          }

          // --------------------------------------------------------
          // SUMMARY
          // --------------------------------------------------------

          final totalProducts = rows.length;

          final totalReceived = rows.fold<num>(
            0,
            (sum, row) => sum + row.received,
          );

          final totalSold = rows.fold<num>(
            0,
            (sum, row) => sum + row.sold,
          );

          final discrepancyCount = rows.where(
            (row) => row.difference != 0,
          ).length;

          final totalDifference = rows.fold<num>(
            0,
            (sum, row) => sum + row.difference,
          );

          final totalShortage = rows
              .where(
                (row) => row.difference < 0,
              )
              .fold<num>(
                0,
                (sum, row) =>
                    sum + row.difference.abs(),
              );

          final totalExcess = rows
              .where(
                (row) => row.difference > 0,
              )
              .fold<num>(
                0,
                (sum, row) =>
                    sum + row.difference,
              );

          // --------------------------------------------------------
          // PAGE
          // --------------------------------------------------------

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                final isWide =
                    constraints.maxWidth >= 1000;

                return SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        isWide ? 32 : 16,
                    vertical: 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 1500,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // HEADER
                          // ==================================================

                          _PageHeader(
                            date:
                                _formatDate(
                              _selectedDate,
                            ),
                            onSelectDate:
                                _selectDate,
                            colorScheme:
                                colorScheme,
                            theme: theme,
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // SUMMARY
                          // ==================================================

                          _SummaryGrid(
                            totalProducts:
                                totalProducts,
                            totalReceived:
                                totalReceived,
                            totalSold:
                                totalSold,
                            discrepancyCount:
                                discrepancyCount,
                            totalDifference:
                                totalDifference,
                            totalShortage:
                                totalShortage,
                            totalExcess:
                                totalExcess,
                            isWide:
                                isWide,
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // REPORT CARD
                          // ==================================================

                          Card(
                            clipBehavior:
                                Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets
                                          .fromLTRB(
                                    20,
                                    20,
                                    20,
                                    16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child:
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              'Stock Reconciliation',
                                              style: theme
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              'Opening stock, receipts, sales and closing variance',
                                              style: theme
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      _StatusBadge(
                                        hasDiscrepancy:
                                            discrepancyCount >
                                                0,
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(
                                  height: 1,
                                ),

                                // ==================================================
                                // TABLE
                                // ==================================================

                                SingleChildScrollView(
                                  scrollDirection:
                                      Axis.horizontal,
                                  child:
                                      ConstrainedBox(
                                    constraints:
                                        BoxConstraints(
                                      minWidth:
                                          isWide
                                              ? constraints
                                                      .maxWidth -
                                                  64
                                              : 1150,
                                    ),
                                    child:
                                        DataTable(
                                      headingRowHeight:
                                          54,
                                      dataRowMinHeight:
                                          62,
                                      dataRowMaxHeight:
                                          76,
                                      horizontalMargin:
                                          20,
                                      columnSpacing:
                                          30,
                                      headingTextStyle:
                                          theme
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            color:
                                                colorScheme
                                                    .onSurface,
                                          ),
                                      columns:
                                          const [
                                        DataColumn(
                                          label:
                                              Text(
                                            'Product',
                                          ),
                                        ),
                                        DataColumn(
                                          label:
                                              Text(
                                            'Opening',
                                          ),
                                          numeric:
                                              true,
                                        ),
                                        DataColumn(
                                          label:
                                              Text(
                                            'Received',
                                          ),
                                          numeric:
                                              true,
                                        ),
                                        DataColumn(
                                          label:
                                              Text(
                                            'Sold',
                                          ),
                                          numeric:
                                              true,
                                        ),
                                        DataColumn(
                                          label:
                                              Text(
                                            'Expected',
                                          ),
                                          numeric:
                                              true,
                                        ),
                                        DataColumn(
                                          label:
                                              Text(
                                            'Physical',
                                          ),
                                          numeric:
                                              true,
                                        ),
                                        DataColumn(
                                          label:
                                              Text(
                                            'Variance',
                                          ),
                                          numeric:
                                              true,
                                        ),
                                      ],
                                      rows: rows
                                          .map(
                                        (row) {
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                SizedBox(
                                                  width:
                                                      240,
                                                  child:
                                                      Text(
                                                    row.productName,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              DataCell(
                                                _NumberCell(
                                                  row.openingStock,
                                                ),
                                              ),

                                              DataCell(
                                                _MovementCell(
                                                  value:
                                                      row.received,
                                                  color:
                                                      Colors.blue,
                                                ),
                                              ),

                                              DataCell(
                                                _MovementCell(
                                                  value:
                                                      row.sold,
                                                  color:
                                                      Colors.orange,
                                                ),
                                              ),

                                              DataCell(
                                                _NumberCell(
                                                  row.expectedClosing,
                                                ),
                                              ),

                                              DataCell(
                                                _NumberCell(
                                                  row.physicalCount,
                                                ),
                                              ),

                                              DataCell(
                                                _VarianceBadge(
                                                  difference:
                                                      row.difference,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ),

                                const Divider(
                                  height: 1,
                                ),

                                // ==================================================
                                // EXPORT
                                // ==================================================

                                Padding(
                                  padding:
                                      const EdgeInsets
                                          .all(20),
                                  child: LayoutBuilder(
                                    builder: (
                                      context,
                                      footerConstraints,
                                    ) {
                                      final compact =
                                          footerConstraints
                                                  .maxWidth <
                                              650;

                                      final button =
                                          FilledButton.icon(
                                        onPressed:
                                            () async {
                                          try {
                                            final file =
                                                await PdfReport
                                                    .generateReconciliationReport(
                                              rows,
                                              _selectedDate,
                                            );

                                            if (!context
                                                .mounted) {
                                              return;
                                            }

                                            ScaffoldMessenger
                                                .of(
                                                    context)
                                                .showSnackBar(
                                              SnackBar(
                                                behavior:
                                                    SnackBarBehavior
                                                        .floating,
                                                content:
                                                    Text(
                                                  'Report saved to ${file.path}',
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            if (!context
                                                .mounted) {
                                              return;
                                            }

                                            ScaffoldMessenger
                                                .of(
                                                    context)
                                                .showSnackBar(
                                              SnackBar(
                                                behavior:
                                                    SnackBarBehavior
                                                        .floating,
                                                backgroundColor:
                                                    colorScheme
                                                        .error,
                                                content:
                                                    Text(
                                                  'Failed to export report: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon:
                                            const Icon(
                                          Icons
                                              .picture_as_pdf_outlined,
                                        ),
                                        label:
                                            const Text(
                                          'Export PDF',
                                        ),
                                      );

                                      if (compact) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              'Report date: ${_formatDate(_selectedDate)}',
                                              style: theme
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            const SizedBox(
                                              height: 12,
                                            ),
                                            button,
                                          ],
                                        );
                                      }

                                      return Row(
                                        children: [
                                          Expanded(
                                            child:
                                                Text(
                                              'Report date: ${_formatDate(_selectedDate)}',
                                              style: theme
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ),
                                          button,
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// PAGE HEADER
// ============================================================================

class _PageHeader extends StatelessWidget {
  final String date;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onSelectDate;

  const _PageHeader({
    required this.date,
    required this.colorScheme,
    required this.theme,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.fact_check_outlined,
            color:
                colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Reconciliation',
                style: theme
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onSelectDate,
          icon: const Icon(
            Icons.calendar_today_outlined,
            size: 18,
          ),
          label: const Text(
            'Change date',
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SUMMARY GRID
// ============================================================================

class _SummaryGrid extends StatelessWidget {
  final int totalProducts;
  final num totalReceived;
  final num totalSold;
  final int discrepancyCount;
  final num totalDifference;
  final num totalShortage;
  final num totalExcess;
  final bool isWide;

  const _SummaryGrid({
    required this.totalProducts,
    required this.totalReceived,
    required this.totalSold,
    required this.discrepancyCount,
    required this.totalDifference,
    required this.totalShortage,
    required this.totalExcess,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        icon: Icons.inventory_2_outlined,
        title: 'Products',
        value: '$totalProducts',
        subtitle: 'Tracked',
      ),
      _SummaryCard(
        icon: Icons.move_to_inbox_outlined,
        title: 'Received',
        value: '$totalReceived',
        subtitle: 'Units received',
        color: Colors.blue,
      ),
      _SummaryCard(
        icon: Icons.shopping_cart_outlined,
        title: 'Sold',
        value: '$totalSold',
        subtitle: 'Units sold',
        color: Colors.orange,
      ),
      _SummaryCard(
        icon: Icons.warning_amber_rounded,
        title: 'Discrepancies',
        value: '$discrepancyCount',
        subtitle: discrepancyCount == 0
            ? 'No variance'
            : 'Requires attention',
        warning: discrepancyCount > 0,
      ),
    ];

    final varianceCard = _SummaryCard(
      icon: totalDifference < 0
          ? Icons.trending_down
          : totalDifference > 0
              ? Icons.trending_up
              : Icons.check_circle_outline,
      title: 'Net Variance',
      value: '$totalDifference',
      subtitle: totalDifference == 0
          ? 'Balanced'
          : 'Shortage $totalShortage / Excess $totalExcess',
      warning: totalDifference < 0,
    );

    if (isWide) {
      return Row(
        children: [
          ...cards.map(
            (card) => Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(
                  right: 12,
                ),
                child: card,
              ),
            ),
          ),
          Expanded(
            child: varianceCard,
          ),
        ],
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        ...cards,
        varianceCard,
      ],
    );
  }
}

// ============================================================================
// SUMMARY CARD
// ============================================================================

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color? color;
  final bool warning;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.color,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme =
        theme.colorScheme;

    final effectiveColor = warning
        ? colorScheme.error
        : color ?? colorScheme.primary;

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(
                color: effectiveColor
                    .withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: Icon(
                icon,
                color: effectiveColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: theme
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: theme
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// NUMBER CELL
// ============================================================================

class _NumberCell extends StatelessWidget {
  final num value;

  const _NumberCell(this.value);

  @override
  Widget build(BuildContext context) {
    return Text(
      '$value',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ============================================================================
// MOVEMENT CELL
// ============================================================================

class _MovementCell extends StatelessWidget {
  final num value;
  final Color color;

  const _MovementCell({
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        '$value',
        style: TextStyle(
          color: color,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  final bool hasDiscrepancy;

  const _StatusBadge({
    required this.hasDiscrepancy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final backgroundColor =
        hasDiscrepancy
            ? colorScheme.errorContainer
            : colorScheme.primaryContainer;

    final foregroundColor =
        hasDiscrepancy
            ? colorScheme.onErrorContainer
            : colorScheme.onPrimaryContainer;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration:
          BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            hasDiscrepancy
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            size: 16,
            color: foregroundColor,
          ),
          const SizedBox(width: 6),
          Text(
            hasDiscrepancy
                ? 'Review required'
                : 'Reconciled',
            style: TextStyle(
              color: foregroundColor,
              fontWeight:
                  FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VARIANCE BADGE
// ============================================================================

class _VarianceBadge extends StatelessWidget {
  final num difference;

  const _VarianceBadge({
    required this.difference,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    if (difference == 0) {
      return Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration:
            BoxDecoration(
          color:
              colorScheme.primaryContainer,
          borderRadius:
              BorderRadius.circular(8),
        ),
        child: Text(
          '0',
          style: TextStyle(
            color: colorScheme
                .onPrimaryContainer,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      );
    }

    final isShortage =
        difference < 0;

    final backgroundColor =
        isShortage
            ? colorScheme.errorContainer
            : colorScheme.tertiaryContainer;

    final foregroundColor =
        isShortage
            ? colorScheme.onErrorContainer
            : colorScheme.onTertiaryContainer;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        difference > 0
            ? '+$difference'
            : '$difference',
        style: TextStyle(
          color: foregroundColor,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyState extends StatelessWidget {
  final String date;

  const _EmptyState({
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);
    final colorScheme =
        theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 450,
        ),
        child: Card(
          child: Padding(
            padding:
                const EdgeInsets.all(40),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration:
                      BoxDecoration(
                    color: colorScheme
                        .surfaceContainerHighest,
                    shape:
                        BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fact_check_outlined,
                    size: 36,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'No reconciliation data',
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'There is no reconciliation data available for $date.',
                  textAlign:
                      TextAlign.center,
                  style: theme
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR STATE
// ============================================================================

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 600,
          ),
          child: Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(28),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 52,
                    color:
                        colorScheme.error,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Text(
                    'Unable to load reconciliation',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  SelectableText(
                    error,
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label:
                        const Text(
                      'Retry',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
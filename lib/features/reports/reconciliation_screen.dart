// lib/features/reports/reconciliation_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/daos/product_dao.dart';
import '../../models/reconciliation_row.dart';
import '../../shared/pdf_report.dart';

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

    if (selected == null || !mounted) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: FutureBuilder<List<ReconciliationRow>>(
        future: widget.productDao.getDailyReconciliation(
          _selectedDate,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const _LoadingState();
          }

          if (snapshot.hasError) {
            return _ErrorState(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {});
              },
            );
          }

          if (!snapshot.hasData) {
            return const _EmptyDataState();
          }

          final rows = snapshot.data!;

          if (rows.isEmpty) {
            return _EmptyState(
              date: _formatDate(_selectedDate),
            );
          }

          return _buildReport(
            context,
            rows,
          );
        },
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Daily Reconciliation',
            style: AppTextStyles.title,
          ),
        ],
      ),
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
            Icons.refresh_outlined,
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.divider,
        ),
      ),
    );
  }

  // ============================================================
  // REPORT
  // ============================================================

  Widget _buildReport(
    BuildContext context,
    List<ReconciliationRow> rows,
  ) {
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
          (sum, row) => sum + row.difference.abs(),
        );

    final totalExcess = rows
        .where(
          (row) => row.difference > 0,
        )
        .fold<num>(
          0,
          (sum, row) => sum + row.difference,
        );

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        setState(() {});
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 &&
              constraints.maxWidth < 1000;

          final horizontalPadding = isMobile
              ? 16.0
              : isTablet
                  ? 24.0
                  : 32.0;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1500,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _PageHeader(
                      date: _formatDate(_selectedDate),
                      onSelectDate: _selectDate,
                      isMobile: isMobile,
                    ),

                    const SizedBox(height: 24),

                    _SummaryGrid(
                      totalProducts: totalProducts,
                      totalReceived: totalReceived,
                      totalSold: totalSold,
                      discrepancyCount: discrepancyCount,
                      totalDifference: totalDifference,
                      totalShortage: totalShortage,
                      totalExcess: totalExcess,
                    ),

                    const SizedBox(height: 28),

                    _ReportCard(
                      rows: rows,
                      selectedDate: _selectedDate,
                      discrepancyCount: discrepancyCount,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
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
  final VoidCallback onSelectDate;
  final bool isMobile;

  const _PageHeader({
    required this.date,
    required this.onSelectDate,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.fact_check_outlined,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Reconciliation',
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 5),
              Text(
                date,
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 16),
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

    return Row(
      children: [
        Expanded(
          child: header,
        ),
        const SizedBox(width: 16),
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

  const _SummaryGrid({
    required this.totalProducts,
    required this.totalReceived,
    required this.totalSold,
    required this.discrepancyCount,
    required this.totalDifference,
    required this.totalShortage,
    required this.totalExcess,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 1200
            ? 5
            : width >= 850
                ? 3
                : width >= 550
                    ? 2
                    : 1;

        final cards = [
          _SummaryCard(
            icon: Icons.inventory_2_outlined,
            title: 'Products',
            value: '$totalProducts',
            subtitle: 'Products tracked',
          ),
          _SummaryCard(
            icon: Icons.move_to_inbox_outlined,
            title: 'Received',
            value: '$totalReceived',
            subtitle: 'Units received',
            color: AppColors.primary,
          ),
          _SummaryCard(
            icon: Icons.shopping_cart_outlined,
            title: 'Sold',
            value: '$totalSold',
            subtitle: 'Units sold',
            color: AppColors.accent,
          ),
          _SummaryCard(
            icon: Icons.warning_amber_rounded,
            title: 'Discrepancies',
            value: '$discrepancyCount',
            subtitle: discrepancyCount == 0
                ? 'No variance found'
                : 'Requires attention',
            warning: discrepancyCount > 0,
          ),
          _SummaryCard(
            icon: totalDifference < 0
                ? Icons.trending_down_outlined
                : totalDifference > 0
                    ? Icons.trending_up_outlined
                    : Icons.check_circle_outline,
            title: 'Net Variance',
            value: '$totalDifference',
            subtitle: totalDifference == 0
                ? 'Balanced'
                : 'Shortage $totalShortage / Excess $totalExcess',
            warning: totalDifference < 0,
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: width < 550
                ? 3.2
                : width < 850
                    ? 2.1
                    : 1.8,
          ),
          itemBuilder: (context, index) {
            return cards[index];
          },
        );
      },
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
    final effectiveColor = warning
        ? AppColors.danger
        : color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: effectiveColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.small,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.price.copyWith(
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
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
}

// ============================================================================
// REPORT CARD
// ============================================================================

class _ReportCard extends StatelessWidget {
  final List<ReconciliationRow> rows;
  final DateTime selectedDate;
  final int discrepancyCount;

  const _ReportCard({
    required this.rows,
    required this.selectedDate,
    required this.discrepancyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildHeader(context),

          const Divider(
            height: 1,
          ),

          _buildTable(context),

          const Divider(
            height: 1,
          ),

          _buildExportFooter(context),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 600;

          final title = const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Stock Reconciliation',
                style: AppTextStyles.title,
              ),
              SizedBox(height: 5),
              Text(
                'Opening stock, receipts, sales and closing variance.',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          );

          final badge = _StatusBadge(
            hasDiscrepancy:
                discrepancyCount > 0,
          );

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 12),
                badge,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: title,
              ),
              const SizedBox(width: 16),
              badge,
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth =
            constraints.maxWidth < 900
                ? 900.0
                : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: DataTable(
              headingRowHeight: 52,
              dataRowMinHeight: 58,
              dataRowMaxHeight: 72,
              horizontalMargin: 20,
              columnSpacing: 28,
              dividerThickness: 0.5,
              headingTextStyle:
                  AppTextStyles.small.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              dataTextStyle:
                  AppTextStyles.small.copyWith(
                color: AppColors.textPrimary,
              ),
              columns: const [
                DataColumn(
                  label: Text('Product'),
                ),
                DataColumn(
                  label: Text('Opening'),
                  numeric: true,
                ),
                DataColumn(
                  label: Text('Received'),
                  numeric: true,
                ),
                DataColumn(
                  label: Text('Sold'),
                  numeric: true,
                ),
                DataColumn(
                  label: Text('Expected'),
                  numeric: true,
                ),
                DataColumn(
                  label: Text('Physical'),
                  numeric: true,
                ),
                DataColumn(
                  label: Text('Variance'),
                  numeric: true,
                ),
              ],
              rows: rows.map((row) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        row.productName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: AppTextStyles.small
                            .copyWith(
                          fontWeight:
                              FontWeight.w600,
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
                        value: row.received,
                        color: AppColors.primary,
                      ),
                    ),
                    DataCell(
                      _MovementCell(
                        value: row.sold,
                        color: AppColors.accent,
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
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // EXPORT FOOTER
  // ============================================================

  Widget _buildExportFooter(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 600;

          final dateText = Text(
            'Report date: ${_formatDate(selectedDate)}',
            style: AppTextStyles.small,
          );

          final button = ElevatedButton.icon(
            onPressed: () => _exportPdf(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              size: 19,
            ),
            label: const Text(
              'Export PDF',
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                dateText,
                const SizedBox(height: 12),
                button,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: dateText,
              ),
              button,
            ],
          );
        },
      ),
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
  // PDF EXPORT
  // ============================================================

  Future<void> _exportPdf(
    BuildContext context,
  ) async {
    try {
      final file =
          await PdfReport.generateReconciliationReport(
        rows,
        selectedDate,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          content: Text(
            'Report saved to ${file.path}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text(
            'Failed to export report: $e',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
      );
    }
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
      style: AppTextStyles.small.copyWith(
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
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$value',
        style: AppTextStyles.small.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
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
    final backgroundColor = hasDiscrepancy
        ? AppColors.dangerLight
        : AppColors.successLight;

    final foregroundColor = hasDiscrepancy
        ? AppColors.danger
        : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
            style: AppTextStyles.small.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
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
    if (difference == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '0',
          style: AppTextStyles.small.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final isShortage = difference < 0;

    final backgroundColor = isShortage
        ? AppColors.dangerLight
        : AppColors.successLight;

    final foregroundColor = isShortage
        ? AppColors.danger
        : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difference > 0
            ? '+$difference'
            : '$difference',
        style: AppTextStyles.small.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY DATA STATE
// ============================================================================

class _EmptyDataState extends StatelessWidget {
  const _EmptyDataState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No reconciliation data available.',
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  size: 32,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No reconciliation data',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'There is no reconciliation data available for $date.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOADING STATE
// ============================================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Loading reconciliation...',
              style: AppTextStyles.bodySecondary,
            ),
          ],
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 30,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load reconciliation',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius:
                      BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: SelectableText(
                  error,
                  style: AppTextStyles.small,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_outlined,
                ),
                label: const Text(
                  'Retry',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

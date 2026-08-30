// lib/features/reports/expiry_report_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';

class ExpiryReportScreen extends StatelessWidget {
  const ExpiryReportScreen({super.key});

  // ============================================================
  // FETCH EXPIRY DATA
  // ============================================================

  Future<Map<String, List<Product>>> _fetchExpiryData() async {
    final dao = getProductDao();

    final expiring = await dao.getExpiringProducts();
    final expired = await dao.getExpiredProducts();

    return {
      'expiring': expiring,
      'expired': expired,
    };
  }

  // ============================================================
  // DATE FORMATTER
  // ============================================================

  static String _formatDate(DateTime? date) {
    if (date == null) {
      return 'No expiry date';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expiry Report',
              style: AppTextStyles.title,
            ),
            SizedBox(height: 2),
            Text(
              'Monitor products approaching or past expiry',
              style: AppTextStyles.small,
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, List<Product>>>(
        future: _fetchExpiryData(),
        builder: (context, snapshot) {
          // ======================================================
          // LOADING
          // ======================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          // ======================================================
          // ERROR
          // ======================================================

          if (snapshot.hasError) {
            return _errorState(snapshot.error);
          }

          // ======================================================
          // DATA
          // ======================================================

          final data = snapshot.data ?? <String, List<Product>>{};

          final expiring = data['expiring'] ?? <Product>[];
          final expired = data['expired'] ?? <Product>[];

          final totalAtRisk = expiring.length + expired.length;

          // ======================================================
          // RESPONSIVE CONTENT
          // ======================================================

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final isCompact = width < 650;
              final isMedium = width >= 650 && width < 1000;

              final horizontalPadding = isCompact
                  ? 16.0
                  : isMedium
                      ? 20.0
                      : 28.0;

              final verticalPadding = isCompact ? 16.0 : 24.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // PAGE HEADER
                    // ==================================================

                    _pageHeader(
                      isCompact: isCompact,
                    ),

                    SizedBox(
                      height: isCompact ? 20 : 24,
                    ),

                    // ==================================================
                    // SUMMARY
                    // ==================================================

                    _summarySection(
                      expiringCount: expiring.length,
                      expiredCount: expired.length,
                      totalAtRisk: totalAtRisk,
                      isCompact: isCompact,
                    ),

                    SizedBox(
                      height: isCompact ? 24 : 30,
                    ),

                    // ==================================================
                    // EXPIRING SOON
                    // ==================================================

                    _sectionHeader(
                      title: 'Expiring Soon',
                      subtitle:
                          'Products expiring within the next 3 months',
                      count: expiring.length,
                      color: AppColors.warning,
                      icon: Icons.warning_amber_rounded,
                      isCompact: isCompact,
                    ),

                    const SizedBox(height: 12),

                    if (expiring.isEmpty)
                      _emptySection(
                        icon: Icons.check_circle_outline,
                        title: 'No products expiring soon',
                        subtitle:
                            'Your current stock has no products approaching expiry.',
                        color: AppColors.success,
                      )
                    else
                      _productList(
                        products: expiring,
                        status: 'Expiring Soon',
                        color: AppColors.warning,
                        icon: Icons.warning_amber_rounded,
                        isCompact: isCompact,
                      ),

                    SizedBox(
                      height: isCompact ? 24 : 30,
                    ),

                    // ==================================================
                    // EXPIRED
                    // ==================================================

                    _sectionHeader(
                      title: 'Expired Products',
                      subtitle:
                          'Products that have already passed their expiry date',
                      count: expired.length,
                      color: AppColors.danger,
                      icon: Icons.cancel_outlined,
                      isCompact: isCompact,
                    ),

                    const SizedBox(height: 12),

                    if (expired.isEmpty)
                      _emptySection(
                        icon: Icons.check_circle_outline,
                        title: 'No expired products',
                        subtitle:
                            'There are currently no expired products in your inventory.',
                        color: AppColors.success,
                      )
                    else
                      _productList(
                        products: expired,
                        status: 'Expired',
                        color: AppColors.danger,
                        icon: Icons.cancel_outlined,
                        isCompact: isCompact,
                      ),

                    SizedBox(
                      height: isCompact ? 12 : 20,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // SUMMARY SECTION
  // ============================================================

  Widget _summarySection({
    required int expiringCount,
    required int expiredCount,
    required int totalAtRisk,
    required bool isCompact,
  }) {
    final cards = [
      _SummaryData(
        title: 'Expiring Soon',
        value: '$expiringCount',
        subtitle: 'Within 3 months',
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning,
      ),
      _SummaryData(
        title: 'Expired',
        value: '$expiredCount',
        subtitle: 'Require immediate action',
        icon: Icons.cancel_outlined,
        color: AppColors.danger,
      ),
      _SummaryData(
        title: 'Total At Risk',
        value: '$totalAtRisk',
        subtitle: 'Products requiring attention',
        icon: Icons.inventory_2_outlined,
        color: AppColors.info,
      ),
    ];

    // ==========================================================
    // COMPACT / MOBILE
    // ==========================================================

    if (isCompact) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            _summaryCard(
              data: cards[i],
              isCompact: true,
            ),
            if (i < cards.length - 1)
              const SizedBox(height: 12),
          ],
        ],
      );
    }

    // ==========================================================
    // TABLET / DESKTOP
    // ==========================================================
    //
    // IMPORTANT:
    // Do NOT use CrossAxisAlignment.stretch here.
    //
    // This Row is inside a vertically scrolling
    // SingleChildScrollView, which gives it an unbounded height.
    // CrossAxisAlignment.stretch would therefore try to give the
    // children an infinite height and cause:
    //
    // BoxConstraints forces an infinite height.
    //
    // ==========================================================

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(
            child: _summaryCard(
              data: cards[i],
              isCompact: false,
            ),
          ),
          if (i < cards.length - 1)
            const SizedBox(width: 16),
        ],
      ],
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _pageHeader({
    required bool isCompact,
  }) {
    final icon = Container(
      padding: EdgeInsets.all(
        isCompact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.event_busy_outlined,
        color: AppColors.warning,
        size: isCompact ? 22 : 25,
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Overview',
          style: isCompact
              ? AppTextStyles.title
              : AppTextStyles.heading,
        ),
        const SizedBox(height: 4),
        Text(
          'Monitor stock that requires attention before it becomes a loss.',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 14),
        Expanded(
          child: content,
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required _SummaryData data,
    required bool isCompact,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(
          isCompact ? 14 : 18,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                isCompact ? 9 : 10,
              ),
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                data.icon,
                color: data.color,
                size: isCompact ? 21 : 23,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.price,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required int count,
    required Color color,
    required IconData icon,
    required bool isCompact,
  }) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.small.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final titleContent = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: isCompact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.small,
          ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        titleContent,
        const SizedBox(width: 12),
        badge,
      ],
    );
  }

  // ============================================================
  // PRODUCT LIST
  // ============================================================

  Widget _productList({
    required List<Product> products,
    required String status,
    required Color color,
    required IconData icon,
    required bool isCompact,
  }) {
    return Column(
      children: [
        for (var i = 0; i < products.length; i++) ...[
          _productCard(
            name: products[i].name,
            expiryDate: products[i].expiryDate,
            status: status,
            color: color,
            icon: icon,
            isCompact: isCompact,
          ),
          if (i < products.length - 1)
            const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _productCard({
    required String name,
    required DateTime? expiryDate,
    required String status,
    required Color color,
    required IconData icon,
    required bool isCompact,
  }) {
    final statusBadge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTextStyles.small.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final iconContainer = Container(
      padding: EdgeInsets.all(
        isCompact ? 10 : 11,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: isCompact ? 21 : 23,
      ),
    );

    final details = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  status == 'Expired'
                      ? 'Expired: ${_formatDate(expiryDate)}'
                      : 'Expires: ${_formatDate(expiryDate)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // ==========================================================
    // COMPACT / MOBILE
    // ==========================================================

    if (isCompact) {
      return Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconContainer,
                  const SizedBox(width: 12),
                  details,
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: statusBadge,
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================================
    // TABLET / DESKTOP
    // ==========================================================

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconContainer,
            const SizedBox(width: 14),
            details,
            const SizedBox(width: 12),
            statusBadge,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY SECTION
  // ============================================================

  Widget _emptySection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 28,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 25,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(Object? error) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 32,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load expiry report',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
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
// SUMMARY DATA
// ============================================================================

class _SummaryData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

// lib/features/reports/expiry_report_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';

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

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,

        titleSpacing: 20,

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

      // ========================================================
      // BODY
      // ========================================================

      body: FutureBuilder<Map<String, List<Product>>>(
        future: _fetchExpiryData(),

        builder: (context, snapshot) {
          // ======================================================
          // LOADING
          // ======================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
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

          final data = snapshot.data ??
              <String, List<Product>>{};

          final expiring =
              data['expiring'] ?? <Product>[];

          final expired =
              data['expired'] ?? <Product>[];

          final totalAtRisk =
              expiring.length + expired.length;

          // ======================================================
          // RESPONSIVE LAYOUT
          // ======================================================

          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact =
                  constraints.maxWidth < 700;

              return SingleChildScrollView(
                padding: EdgeInsets.all(
                  isCompact
                      ? 16
                      : 24,
                ),

                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 1100,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        // ==========================================
                        // PAGE HEADER
                        // ==========================================

                        _pageHeader(),

                        const SizedBox(height: 24),

                        // ==========================================
                        // SUMMARY
                        // ==========================================

                        if (isCompact)
                          Column(
                            children: [
                              _summaryCard(
                                title:
                                    'Expiring Soon',
                                value:
                                    '${expiring.length}',
                                subtitle:
                                    'Within 3 months',
                                icon: Icons
                                    .warning_amber_rounded,
                                color:
                                    AppColors.warning,
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              _summaryCard(
                                title:
                                    'Expired',
                                value:
                                    '${expired.length}',
                                subtitle:
                                    'Require immediate action',
                                icon: Icons
                                    .cancel_outlined,
                                color:
                                    AppColors.danger,
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              _summaryCard(
                                title:
                                    'Total At Risk',
                                value:
                                    '$totalAtRisk',
                                subtitle:
                                    'Products requiring attention',
                                icon: Icons
                                    .inventory_2_outlined,
                                color:
                                    AppColors.info,
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child:
                                    _summaryCard(
                                  title:
                                      'Expiring Soon',
                                  value:
                                      '${expiring.length}',
                                  subtitle:
                                      'Within 3 months',
                                  icon: Icons
                                      .warning_amber_rounded,
                                  color:
                                      AppColors.warning,
                                ),
                              ),

                              const SizedBox(
                                width: 16,
                              ),

                              Expanded(
                                child:
                                    _summaryCard(
                                  title:
                                      'Expired',
                                  value:
                                      '${expired.length}',
                                  subtitle:
                                      'Require immediate action',
                                  icon: Icons
                                      .cancel_outlined,
                                  color:
                                      AppColors.danger,
                                ),
                              ),

                              const SizedBox(
                                width: 16,
                              ),

                              Expanded(
                                child:
                                    _summaryCard(
                                  title:
                                      'Total At Risk',
                                  value:
                                      '$totalAtRisk',
                                  subtitle:
                                      'Products requiring attention',
                                  icon: Icons
                                      .inventory_2_outlined,
                                  color:
                                      AppColors.info,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(
                          height: 30,
                        ),

                        // ==========================================
                        // EXPIRING SOON
                        // ==========================================

                        _sectionHeader(
                          title:
                              'Expiring Soon',
                          subtitle:
                              'Products expiring within the next 3 months',
                          count:
                              expiring.length,
                          color:
                              AppColors.warning,
                          icon: Icons
                              .warning_amber_rounded,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        if (expiring.isEmpty)
                          _emptySection(
                            icon: Icons
                                .check_circle_outline,
                            title:
                                'No products expiring soon',
                            subtitle:
                                'Your current stock has no products approaching expiry.',
                            color:
                                AppColors.success,
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),

                            itemCount:
                                expiring.length,

                            separatorBuilder:
                                (_, __) =>
                                    const SizedBox(
                              height: 10,
                            ),

                            itemBuilder:
                                (context, index) {
                              final product =
                                  expiring[index];

                              return _productCard(
                                name:
                                    product.name,
                                expiryDate:
                                    product.expiryDate,
                                status:
                                    'Expiring Soon',
                                color:
                                    AppColors.warning,
                                icon: Icons
                                    .warning_amber_rounded,
                              );
                            },
                          ),

                        const SizedBox(
                          height: 30,
                        ),

                        // ==========================================
                        // EXPIRED
                        // ==========================================

                        _sectionHeader(
                          title:
                              'Expired Products',
                          subtitle:
                              'Products that have already passed their expiry date',
                          count:
                              expired.length,
                          color:
                              AppColors.danger,
                          icon: Icons
                              .cancel_outlined,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        if (expired.isEmpty)
                          _emptySection(
                            icon: Icons
                                .check_circle_outline,
                            title:
                                'No expired products',
                            subtitle:
                                'There are currently no expired products in your inventory.',
                            color:
                                AppColors.success,
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),

                            itemCount:
                                expired.length,

                            separatorBuilder:
                                (_, __) =>
                                    const SizedBox(
                              height: 10,
                            ),

                            itemBuilder:
                                (context, index) {
                              final product =
                                  expired[index];

                              return _productCard(
                                name:
                                    product.name,
                                expiryDate:
                                    product.expiryDate,
                                status:
                                    'Expired',
                                color:
                                    AppColors.danger,
                                icon: Icons
                                    .cancel_outlined,
                              );
                            },
                          ),

                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _pageHeader() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Container(
          width: 48,
          height: 48,

          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius:
                BorderRadius.circular(12),
          ),

          child: const Icon(
            Icons.event_busy_outlined,
            color: AppColors.warning,
            size: 25,
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'Expiry Overview',
                style: AppTextStyles.heading,
              ),

              SizedBox(height: 4),

              Text(
                'Monitor stock that requires attention before it becomes a loss.',
                style:
                    AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: AppColors.border,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),

              borderRadius:
                  BorderRadius.circular(11),
            ),

            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style:
                      AppTextStyles.small,
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyles.price,
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyles.small,
                ),
              ],
            ),
          ),
        ],
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
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.10,
            ),

            borderRadius:
                BorderRadius.circular(10),
          ),

          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style:
                    AppTextStyles.title,
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style:
                    AppTextStyles.small,
              ),
            ],
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.10,
            ),

            borderRadius:
                BorderRadius.circular(20),
          ),

          child: Text(
            '$count',

            style: TextStyle(
              fontFamily: 'Poppins',
              color: color,
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
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
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: color.withValues(
            alpha: 0.18,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 8,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      AppTextStyles.body.copyWith(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .calendar_today_outlined,
                      size: 13,
                      color:
                          AppColors.textMuted,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        status == 'Expired'
                            ? 'Expired: ${_formatDate(expiryDate)}'
                            : 'Expires: ${_formatDate(expiryDate)}',

                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            AppTextStyles.small,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),

            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Text(
              status,

              style: TextStyle(
                fontFamily: 'Poppins',
                color: color,
                fontSize: 10,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(Object? error) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width: 64,
              height: 64,

              decoration: BoxDecoration(
                color:
                    AppColors.dangerLight,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.error_outline,
                size: 32,
                color:
                    AppColors.danger,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load expiry report',
              textAlign:
                  TextAlign.center,
              style:
                  AppTextStyles.title,
            ),

            const SizedBox(height: 8),

            Text(
              '$error',
              textAlign:
                  TextAlign.center,

              style:
                  AppTextStyles.bodySecondary,
            ),
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
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 28,
      ),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: AppColors.border,
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
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
            textAlign:
                TextAlign.center,

            style:
                AppTextStyles.body.copyWith(
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            textAlign:
                TextAlign.center,

            style:
                AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }
}
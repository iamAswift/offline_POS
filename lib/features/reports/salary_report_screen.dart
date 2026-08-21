
// lib/features/reports/salary_report_screen.dart

import 'package:drift/drift.dart' as d;
import 'package:flutter/material.dart';

import '../../database/app_database.dart';
import '../../database/tables/user_profiles_table.dart';
import '../../database/tables/user_table.dart';
import '../../shared/pdf_report.dart';

class SalaryReportScreen extends StatelessWidget {
  const SalaryReportScreen({super.key});

  // ============================================================
  // APP COLORS
  // ============================================================

  static const Color _pageBackground = Color(0xFFF7F8FA);
  static const Color _primary = Color(0xFF4F46E5);
  static const Color _success = Color(0xFF16A34A);
  static const Color _danger = Color(0xFFDC2626);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

  // ============================================================
  // FETCH SALARY REPORT
  // ============================================================

  Future<List<Map<String, dynamic>>> _fetchSalaryReport() async {
    final db = getDatabase();

    final query = db.select(db.userProfiles).join([
      d.innerJoin(
        db.users,
        db.users.id.equalsExp(db.userProfiles.userId),
      ),
    ]);

    final rows = await query.get();

    final report = rows
        .map((row) {
          final user = row.readTable(db.users);
          final profile = row.readTable(db.userProfiles);

          final role = user.role.trim().toLowerCase();

          // --------------------------------------------------------
          // STAFF PAYROLL REPORT
          //
          // Only staff/cashier users belong in this report.
          // Managers/owners/admins are excluded.
          // --------------------------------------------------------

          if (role != 'staff' && role != 'cashier') {
            return null;
          }

          return <String, dynamic>{
            'name': user.name.trim(),
            'email': user.email.trim(),
            'role': user.role.trim(),
            'salary': _toDouble(profile.salary),
            'amountOwed': _toDouble(profile.amountOwed),
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    // ------------------------------------------------------------
    // SORT BY STAFF NAME
    // ------------------------------------------------------------

    report.sort(
      (a, b) => (a['name'] as String).toLowerCase().compareTo(
            (b['name'] as String).toLowerCase(),
          ),
    );

    return report;
  }

  // ============================================================
  // VALUE CONVERSION
  // ============================================================

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString().replaceAll(',', '').trim(),
        ) ??
        0.0;
  }

  // ============================================================
  // CURRENCY FORMATTER
  // ============================================================

  static String _formatCurrency(double value) {
    final absoluteValue = value.abs();

    final formatted = absoluteValue
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)},',
        );

    return value < 0
        ? '-₦$formatted'
        : '₦$formatted';
  }

  // ============================================================
  // ROLE COLOR
  // ============================================================

  static Color _roleColor(String role) {
    switch (role.trim().toLowerCase()) {
      case 'cashier':
        return Colors.teal;

      case 'staff':
        return _primary;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // INITIALS
  // ============================================================

  static String _initials(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    final parts = trimmed.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _textPrimary,
        titleSpacing: 20,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salary & Debt Report',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Staff payroll overview',
              style: TextStyle(
                fontSize: 12,
                color: _textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // DATA
      // ==========================================================

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSalaryReport(),

        builder: (context, snapshot) {
          // ========================================================
          // LOADING
          // ========================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _primary,
              ),
            );
          }

          // ========================================================
          // ERROR
          // ========================================================

          if (snapshot.hasError) {
            return _errorState(
              context,
              snapshot.error,
            );
          }

          final report = snapshot.data ?? <Map<String, dynamic>>[];

          // ========================================================
          // EMPTY
          // ========================================================

          if (report.isEmpty) {
            return _emptyState();
          }

          // ========================================================
          // TOTALS
          // ========================================================

          final totalSalary = report.fold<double>(
            0.0,
            (sum, staff) {
              return sum + _toDouble(staff['salary']);
            },
          );

          final totalDebt = report.fold<double>(
            0.0,
            (sum, staff) {
              final debt = _toDouble(staff['amountOwed']);

              // Debt should not be displayed as a negative amount.
              return sum + (debt > 0 ? debt : 0);
            },
          );

          final totalStaff = report.length;

          final staffWithDebt = report.where(
            (staff) {
              return _toDouble(staff['amountOwed']) > 0;
            },
          ).length;

          // ========================================================
          // RESPONSIVE LAYOUT
          // ========================================================

          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 760;

              return SingleChildScrollView(
                padding: EdgeInsets.all(
                  isCompact ? 16 : 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1150,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ============================================
                        // PAGE HEADER
                        // ============================================

                        _pageHeader(),

                        const SizedBox(height: 24),

                        // ============================================
                        // SUMMARY CARDS
                        // ============================================

                        if (isCompact)
                          Column(
                            children: [
                              _summaryCard(
                                title: 'Total Salary',
                                value: _formatCurrency(
                                  totalSalary,
                                ),
                                subtitle: 'Monthly payroll',
                                icon: Icons.payments_outlined,
                                color: _success,
                              ),
                              const SizedBox(height: 12),
                              _summaryCard(
                                title: 'Outstanding Debt',
                                value: _formatCurrency(
                                  totalDebt,
                                ),
                                subtitle: staffWithDebt == 0
                                    ? 'No staff debt'
                                    : '$staffWithDebt staff with outstanding debt',
                                icon: Icons.warning_amber_rounded,
                                color: staffWithDebt > 0
                                    ? _danger
                                    : _success,
                              ),
                              const SizedBox(height: 12),
                              _summaryCard(
                                title: 'Staff',
                                value: '$totalStaff',
                                subtitle: 'Active staff profiles',
                                icon: Icons.people_outline,
                                color: _primary,
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: _summaryCard(
                                  title: 'Total Salary',
                                  value: _formatCurrency(
                                    totalSalary,
                                  ),
                                  subtitle: 'Monthly payroll',
                                  icon: Icons.payments_outlined,
                                  color: _success,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _summaryCard(
                                  title: 'Outstanding Debt',
                                  value: _formatCurrency(
                                    totalDebt,
                                  ),
                                  subtitle: staffWithDebt == 0
                                      ? 'No staff debt'
                                      : '$staffWithDebt staff with outstanding debt',
                                  icon: Icons.warning_amber_rounded,
                                  color: staffWithDebt > 0
                                      ? _danger
                                      : _success,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _summaryCard(
                                  title: 'Staff',
                                  value: '$totalStaff',
                                  subtitle: 'Active staff profiles',
                                  icon: Icons.people_outline,
                                  color: _primary,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 30),

                        // ============================================
                        // STAFF SECTION HEADER
                        // ============================================

                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Staff Payroll',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$totalStaff ${totalStaff == 1 ? 'staff' : 'staff'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ============================================
                        // STAFF LIST
                        // ============================================

                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: report.length,
                          separatorBuilder: (_, __) {
                            return const SizedBox(height: 10);
                          },
                          itemBuilder: (context, index) {
                            final staff = report[index];

                            final name =
                                staff['name']?.toString().trim() ??
                                    'Unknown Staff';

                            final email =
                                staff['email']?.toString().trim() ?? '';

                            final role =
                                staff['role']?.toString().trim() ?? 'Staff';

                            final salary = _toDouble(
                              staff['salary'],
                            );

                            final amountOwed = _toDouble(
                              staff['amountOwed'],
                            );

                            return _staffCard(
                              name: name,
                              email: email,
                              role: role,
                              salary: salary,
                              amountOwed: amountOwed,
                              isCompact: isCompact,
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // ============================================
                        // EXPORT
                        // ============================================

                        _exportCard(
                          context: context,
                          report: report,
                          totalSalary: totalSalary,
                          totalDebt: totalDebt,
                        ),

                        const SizedBox(height: 24),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: _primary,
            size: 25,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payroll Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Review staff salaries and outstanding amounts.',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textSecondary,
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
  // STAFF CARD
  // ============================================================

  Widget _staffCard({
    required String name,
    required String email,
    required String role,
    required double salary,
    required double amountOwed,
    required bool isCompact,
  }) {
    final roleColor = _roleColor(role);
    final hasDebt = amountOwed > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasDebt ? Colors.red.shade100 : _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isCompact
          ? _compactStaffLayout(
              name: name,
              email: email,
              role: role,
              salary: salary,
              amountOwed: amountOwed,
              roleColor: roleColor,
              hasDebt: hasDebt,
            )
          : _desktopStaffLayout(
              name: name,
              email: email,
              role: role,
              salary: salary,
              amountOwed: amountOwed,
              roleColor: roleColor,
              hasDebt: hasDebt,
            ),
    );
  }

  // ============================================================
  // DESKTOP STAFF ROW
  // ============================================================

  Widget _desktopStaffLayout({
    required String name,
    required String email,
    required String role,
    required double salary,
    required double amountOwed,
    required Color roleColor,
    required bool hasDebt,
  }) {
    return Row(
      children: [
        _avatar(
          name,
          roleColor,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _staffIdentity(
            name: name,
            email: email,
            role: role,
            roleColor: roleColor,
          ),
        ),
        const SizedBox(width: 20),
        _amountColumn(
          label: 'Salary',
          value: _formatCurrency(salary),
          color: _textPrimary,
        ),
        const SizedBox(width: 28),
        _amountColumn(
          label: 'Outstanding',
          value: hasDebt
              ? _formatCurrency(amountOwed)
              : 'No debt',
          color: hasDebt ? _danger : _success,
        ),
        const SizedBox(width: 16),
        Icon(
          hasDebt
              ? Icons.warning_amber_rounded
              : Icons.check_circle_outline,
          size: 20,
          color: hasDebt ? _danger : _success,
        ),
      ],
    );
  }

  // ============================================================
  // COMPACT STAFF CARD
  // ============================================================

  Widget _compactStaffLayout({
    required String name,
    required String email,
    required String role,
    required double salary,
    required double amountOwed,
    required Color roleColor,
    required bool hasDebt,
  }) {
    return Column(
      children: [
        Row(
          children: [
            _avatar(
              name,
              roleColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _staffIdentity(
                name: name,
                email: email,
                role: role,
                roleColor: roleColor,
              ),
            ),
            Icon(
              hasDebt
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              size: 20,
              color: hasDebt ? _danger : _success,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _pageBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: _amountColumn(
                  label: 'Salary',
                  value: _formatCurrency(salary),
                  color: _textPrimary,
                  alignStart: true,
                ),
              ),
              Expanded(
                child: _amountColumn(
                  label: 'Outstanding',
                  value: hasDebt
                      ? _formatCurrency(amountOwed)
                      : 'No debt',
                  color: hasDebt ? _danger : _success,
                  alignStart: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STAFF AVATAR
  // ============================================================

  Widget _avatar(
    String name,
    Color roleColor,
  ) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: roleColor.withValues(alpha: 0.10),
      child: Text(
        _initials(name),
        style: TextStyle(
          color: roleColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // STAFF IDENTITY
  // ============================================================

  Widget _staffIdentity({
    required String name,
    required String email,
    required String role,
    required Color roleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role,
                style: TextStyle(
                  color: roleColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AMOUNT COLUMN
  // ============================================================

  Widget _amountColumn({
    required String label,
    required String value,
    required Color color,
    bool alignStart = false,
  }) {
    return Column(
      crossAxisAlignment: alignStart
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EXPORT CARD
  // ============================================================

  Widget _exportCard({
    required BuildContext context,
    required List<Map<String, dynamic>> report,
    required double totalSalary,
    required double totalDebt,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _primary,
            Color(0xFF3730A3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;

          final description = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Export payroll report',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Generate a PDF containing salary, outstanding debt and staff totals.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12,
                ),
              ),
            ],
          );

          final button = ElevatedButton.icon(
            onPressed: () {
              _exportReport(
                context,
                report,
                totalSalary,
                totalDebt,
              );
            },
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              size: 19,
            ),
            label: const Text(
              'Export PDF',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: description),
                  ],
                ),
                const SizedBox(height: 16),
                button,
              ],
            );
          }

          return Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(child: description),
              const SizedBox(width: 20),
              button,
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // EXPORT PDF
  // ============================================================

  Future<void> _exportReport(
    BuildContext context,
    List<Map<String, dynamic>> report,
    double totalSalary,
    double totalDebt,
  ) async {
    try {
      final file = await PdfReport.generateReport(
        title: 'Salary & Debt Report',
        sections: [
          {
            'title': 'Payroll Summary',
            'headers': [
              'Metric',
              'Value',
            ],
            'rows': [
              [
                'Total Staff',
                '${report.length}',
              ],
              [
                'Total Monthly Salary',
                _formatCurrency(totalSalary),
              ],
              [
                'Total Outstanding Debt',
                _formatCurrency(totalDebt),
              ],
            ],
          },
          {
            'title': 'Staff Payroll',
            'headers': [
              'Staff',
              'Role',
              'Salary',
              'Outstanding',
            ],
            'rows': report.map((staff) {
              final name =
                  staff['name']?.toString() ?? 'Unknown Staff';

              final role =
                  staff['role']?.toString() ?? 'Staff';

              final salary =
                  _toDouble(staff['salary']);

              final debt =
                  _toDouble(staff['amountOwed']);

              return [
                name,
                role,
                _formatCurrency(salary),
                debt > 0
                    ? _formatCurrency(debt)
                    : 'No debt',
              ];
            }).toList(),
          },
        ],
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _success,
          content: const Text(
            'Salary & debt report saved successfully.',
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      debugPrint(
        'Salary PDF saved at: ${file.path}',
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _danger,
          content: Text(
            'Failed to export salary report: $error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(
    BuildContext context,
    Object? error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.shade100,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _danger.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 32,
                  color: _danger,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load salary report',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 36,
                color: _primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No staff profiles found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create staff profiles to see salary information here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

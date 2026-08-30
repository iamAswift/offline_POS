// lib/features/reports/salary_report_screen.dart

import 'package:drift/drift.dart' as d;
import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../database/app_database.dart';

import '../../shared/pdf_report.dart';

class SalaryReportScreen extends StatelessWidget {
  const SalaryReportScreen({super.key});

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

          // Only staff and cashier users belong in payroll.
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

    return value < 0 ? '-₦$formatted' : '₦$formatted';
  }

  // ============================================================
  // ROLE COLOR
  // ============================================================

  static Color _roleColor(
    BuildContext context,
    String role,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (role.trim().toLowerCase()) {
      case 'cashier':
        return colorScheme.tertiary;

      case 'staff':
        return AppColors.primary;

      default:
        return colorScheme.onSurfaceVariant;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salary & Debt Report',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Staff payroll overview',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSalaryReport(),
        builder: (context, snapshot) {
          // ========================================================
          // LOADING
          // ========================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ========================================================
          // ERROR
          // ========================================================

          if (snapshot.hasError) {
            return _ErrorState(
              error: snapshot.error,
            );
          }

          final report =
              snapshot.data ?? <Map<String, dynamic>>[];

          // ========================================================
          // EMPTY
          // ========================================================

          if (report.isEmpty) {
            return const _EmptyState();
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
          // RESPONSIVE PAGE
          // ========================================================

          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 760;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 16 : 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // PAGE HEADER
                    // ==================================================

                    _PageHeader(
                      isCompact: isCompact,
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // SUMMARY
                    // ==================================================

                    _SummarySection(
                      totalSalary: totalSalary,
                      totalDebt: totalDebt,
                      totalStaff: totalStaff,
                      staffWithDebt: staffWithDebt,
                      isCompact: isCompact,
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // STAFF SECTION
                    // ==================================================

                    _SectionHeader(
                      totalStaff: totalStaff,
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // STAFF LIST
                    // ==================================================

                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
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
                            staff['email']?.toString().trim() ??
                                '';

                        final role =
                            staff['role']?.toString().trim() ??
                                'Staff';

                        final salary = _toDouble(
                          staff['salary'],
                        );

                        final amountOwed = _toDouble(
                          staff['amountOwed'],
                        );

                        return _StaffCard(
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

                    // ==================================================
                    // EXPORT
                    // ==================================================

                    _ExportCard(
                      report: report,
                      totalSalary: totalSalary,
                      totalDebt: totalDebt,
                    ),

                    const SizedBox(height: 24),
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
  // EXPORT PDF
  // ============================================================

  Future<void> _exportReport(
    BuildContext context,
    List<Map<String, dynamic>> report,
    double totalSalary,
    double totalDebt,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;

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
                  staff['name']?.toString() ??
                      'Unknown Staff';

              final role =
                  staff['role']?.toString() ??
                      'Staff';

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

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.primary,
          content: const Text(
            'Salary & debt report saved successfully.',
          ),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );

      debugPrint(
        'Salary PDF saved at: ${file.path}',
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.error,
          content: Text(
            'Failed to export salary report: $error',
          ),
        ),
      );
    }
  }
}

// ============================================================================
// PAGE HEADER
// ============================================================================

class _PageHeader extends StatelessWidget {
  final bool isCompact;

  const _PageHeader({
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.primary,
            size: isCompact ? 22 : 25,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payroll Overview',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Review staff salaries and outstanding amounts.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SUMMARY SECTION
// ============================================================================

class _SummarySection extends StatelessWidget {
  final double totalSalary;
  final double totalDebt;
  final int totalStaff;
  final int staffWithDebt;
  final bool isCompact;

  const _SummarySection({
    required this.totalSalary,
    required this.totalDebt,
    required this.totalStaff,
    required this.staffWithDebt,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        title: 'Total Salary',
        value: SalaryReportScreen._formatCurrency(
          totalSalary,
        ),
        subtitle: 'Monthly payroll',
        icon: Icons.payments_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      _SummaryCard(
        title: 'Outstanding Debt',
        value: SalaryReportScreen._formatCurrency(
          totalDebt,
        ),
        subtitle: staffWithDebt == 0
            ? 'No staff debt'
            : '$staffWithDebt staff with outstanding debt',
        icon: Icons.warning_amber_rounded,
        color: staffWithDebt > 0
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      _SummaryCard(
        title: 'Staff',
        value: '$totalStaff',
        subtitle: 'Active staff profiles',
        icon: Icons.people_outline,
        color: AppColors.primary,
      ),
    ];

    if (isCompact) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1)
              const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(
            child: cards[i],
          ),
          if (i < cards.length - 1)
            const SizedBox(width: 16),
        ],
      ],
    );
  }
}

// ============================================================================
// SUMMARY CARD
// ============================================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final int totalStaff;

  const _SectionHeader({
    required this.totalStaff,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Staff Payroll',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$totalStaff ${totalStaff == 1 ? 'staff' : 'staff'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// STAFF CARD
// ============================================================================

class _StaffCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final double salary;
  final double amountOwed;
  final bool isCompact;

  const _StaffCard({
    required this.name,
    required this.email,
    required this.role,
    required this.salary,
    required this.amountOwed,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final roleColor = SalaryReportScreen._roleColor(
      context,
      role,
    );

    final hasDebt = amountOwed > 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isCompact
            ? _CompactLayout(
                name: name,
                email: email,
                role: role,
                salary: salary,
                amountOwed: amountOwed,
                roleColor: roleColor,
                hasDebt: hasDebt,
              )
            : _DesktopLayout(
                name: name,
                email: email,
                role: role,
                salary: salary,
                amountOwed: amountOwed,
                roleColor: roleColor,
                hasDebt: hasDebt,
              ),
      ),
    );
  }
}

// ============================================================================
// DESKTOP STAFF LAYOUT
// ============================================================================

class _DesktopLayout extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final double salary;
  final double amountOwed;
  final Color roleColor;
  final bool hasDebt;

  const _DesktopLayout({
    required this.name,
    required this.email,
    required this.role,
    required this.salary,
    required this.amountOwed,
    required this.roleColor,
    required this.hasDebt,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        _Avatar(
          name: name,
          color: roleColor,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StaffIdentity(
            name: name,
            email: email,
            role: role,
            roleColor: roleColor,
          ),
        ),
        const SizedBox(width: 20),
        _AmountColumn(
          label: 'Salary',
          value: SalaryReportScreen._formatCurrency(
            salary,
          ),
        ),
        const SizedBox(width: 28),
        _AmountColumn(
          label: 'Outstanding',
          value: hasDebt
              ? SalaryReportScreen._formatCurrency(
                  amountOwed,
                )
              : 'No debt',
          valueColor: hasDebt
              ? colorScheme.error
              : colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Icon(
          hasDebt
              ? Icons.warning_amber_rounded
              : Icons.check_circle_outline,
          size: 20,
          color: hasDebt
              ? colorScheme.error
              : colorScheme.primary,
        ),
      ],
    );
  }
}

// ============================================================================
// COMPACT STAFF LAYOUT
// ============================================================================

class _CompactLayout extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final double salary;
  final double amountOwed;
  final Color roleColor;
  final bool hasDebt;

  const _CompactLayout({
    required this.name,
    required this.email,
    required this.role,
    required this.salary,
    required this.amountOwed,
    required this.roleColor,
    required this.hasDebt,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            _Avatar(
              name: name,
              color: roleColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StaffIdentity(
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
              color: hasDebt
                  ? colorScheme.error
                  : colorScheme.primary,
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
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: _AmountColumn(
                  label: 'Salary',
                  value: SalaryReportScreen._formatCurrency(
                    salary,
                  ),
                  alignStart: true,
                ),
              ),
              Expanded(
                child: _AmountColumn(
                  label: 'Outstanding',
                  value: hasDebt
                      ? SalaryReportScreen._formatCurrency(
                          amountOwed,
                        )
                      : 'No debt',
                  valueColor: hasDebt
                      ? colorScheme.error
                      : colorScheme.primary,
                  alignStart: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// AVATAR
// ============================================================================

class _Avatar extends StatelessWidget {
  final String name;
  final Color color;

  const _Avatar({
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: color.withValues(alpha: 0.10),
      child: Text(
        SalaryReportScreen._initials(name),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================================
// STAFF IDENTITY
// ============================================================================

class _StaffIdentity extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final Color roleColor;

  const _StaffIdentity({
    required this.name,
    required this.email,
    required this.role,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
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
                style: theme.textTheme.labelSmall?.copyWith(
                  color: roleColor,
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
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// AMOUNT COLUMN
// ============================================================================

class _AmountColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool alignStart;

  const _AmountColumn({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignStart = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: alignStart
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EXPORT CARD
// ============================================================================

class _ExportCard extends StatelessWidget {
  final List<Map<String, dynamic>> report;
  final double totalSalary;
  final double totalDebt;

  const _ExportCard({
    required this.report,
    required this.totalSalary,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: AppColors.primary,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 650;

            final content = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: colorScheme.onPrimary,
                  size: 30,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export payroll report',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Generate a PDF containing salary, outstanding debt and staff totals.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          color: colorScheme.onPrimary
                              .withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final button = FilledButton.icon(
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
              ),
              label: const Text(
                'Export PDF',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.onPrimary,
                foregroundColor: AppColors.primary,
              ),
            );

            if (compact) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  content,
                  const SizedBox(height: 16),
                  button,
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: content,
                ),
                const SizedBox(width: 20),
                button,
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // EXPORT
  // ============================================================

  Future<void> _exportReport(
    BuildContext context,
    List<Map<String, dynamic>> report,
    double totalSalary,
    double totalDebt,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;

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
                SalaryReportScreen._formatCurrency(
                  totalSalary,
                ),
              ],
              [
                'Total Outstanding Debt',
                SalaryReportScreen._formatCurrency(
                  totalDebt,
                ),
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
                  staff['name']?.toString() ??
                      'Unknown Staff';

              final role =
                  staff['role']?.toString() ??
                      'Staff';

              final salary =
                  SalaryReportScreen._toDouble(
                staff['salary'],
              );

              final debt =
                  SalaryReportScreen._toDouble(
                staff['amountOwed'],
              );

              return [
                name,
                role,
                SalaryReportScreen._formatCurrency(
                  salary,
                ),
                debt > 0
                    ? SalaryReportScreen._formatCurrency(
                        debt,
                      )
                    : 'No debt',
              ];
            }).toList(),
          },
        ],
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.primary,
          content: const Text(
            'Salary & debt report saved successfully.',
          ),
        ),
      );

      debugPrint(
        'Salary PDF saved at: ${file.path}',
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.error,
          content: Text(
            'Failed to export salary report: $error',
          ),
        ),
      );
    }
  }
}

// ============================================================================
// ERROR STATE
// ============================================================================

class _ErrorState extends StatelessWidget {
  final Object? error;

  const _ErrorState({
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 32,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load salary report',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
// EMPTY STATE
// ============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No staff profiles found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create staff profiles to see salary information here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
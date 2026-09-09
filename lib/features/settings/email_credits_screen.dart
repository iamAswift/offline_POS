// lib/features/settings/email_credits_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/email/email_credits_service.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../database/business_settings.dart';
import '../../database/daos/settings_dao.dart';

class EmailCreditsScreen extends StatefulWidget {
  final SettingsDao settingsDao;

  const EmailCreditsScreen({super.key, required this.settingsDao});

  @override
  State<EmailCreditsScreen> createState() => _EmailCreditsScreenState();
}

class _EmailCreditsScreenState extends State<EmailCreditsScreen>
    with WidgetsBindingObserver {
  late final EmailCreditsService _creditsService;

  EmailCreditBalance? _balance;
  List<EmailCreditLedgerEntry> _entries = [];
  List<EmailCreditPackage> _packages = [];

  // Email is enabled by default so existing installations
  // continue working exactly as they did before this setting existed.
  bool _emailEnabled = true;

  bool _isSavingEmailEnabled = false;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingPackages = false;
  bool _isOpeningCheckout = false;
  bool _checkoutWasOpened = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _creditsService = EmailCreditsService(settingsDao: widget.settingsDao);

    _loadCredits();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _checkoutWasOpened) {
      _checkoutWasOpened = false;
      _loadCredits(refresh: true);
    }
  }

  Future<void> _loadCredits({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isRefreshing = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        _creditsService.getBalance(),
        _creditsService.getLedger(limit: 50),
        _getEmailEnabled(),
      ]);

      final balance = results[0] as EmailCreditBalance;

      final ledger = results[1] as EmailCreditLedger;

      final emailEnabled = results[2] as bool;

      if (!mounted) {
        return;
      }

      setState(() {
        _balance = balance;
        _entries = ledger.entries;
        _emailEnabled = emailEnabled;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _cleanError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<bool> _getEmailEnabled() async {
    final value = await widget.settingsDao.getSetting(
      BusinessSettings.emailEnabled,
    );

    if (value == null) {
      return true;
    }

    return value.toLowerCase() == 'true';
  }

  Future<void> _setEmailEnabled(bool enabled) async {
    if (_isSavingEmailEnabled) {
      return;
    }

    final previousValue = _emailEnabled;

    setState(() {
      _emailEnabled = enabled;
      _isSavingEmailEnabled = true;
    });

    try {
      await widget.settingsDao.setSetting(
        BusinessSettings.emailEnabled,
        enabled.toString(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Transactional email enabled.'
                : 'Transactional email disabled.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _emailEnabled = previousValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update email setting: '
            '${_cleanError(e)}',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingEmailEnabled = false;
        });
      }
    }
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Bad state: ', '')
        .replaceFirst('Exception: ', '');
  }

  String _formatAmount(int amount) {
    return NumberFormat.decimalPattern().format(amount.abs());
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  }

  String _formatLedgerType(String type) {
    switch (type.toLowerCase()) {
      case 'purchase':
        return 'Credit Purchase';

      case 'usage':
        return 'Email Usage';

      case 'refund':
        return 'Credit Refund';

      case 'adjustment':
        return 'Account Adjustment';

      default:
        if (type.isEmpty) {
          return 'Credit Activity';
        }

        return type[0].toUpperCase() + type.substring(1);
    }
  }

  IconData _ledgerIcon(String type) {
    switch (type.toLowerCase()) {
      case 'purchase':
        return Icons.add_card_outlined;

      case 'usage':
        return Icons.email_outlined;

      case 'refund':
        return Icons.undo_outlined;

      case 'adjustment':
        return Icons.tune_outlined;

      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _amountColor(String type) {
    switch (type.toLowerCase()) {
      case 'purchase':
      case 'refund':
        return AppColors.success;

      case 'usage':
        return AppColors.textSecondary;

      default:
        return AppColors.textPrimary;
    }
  }

  Widget _buildEmailSettingsCard(Responsive responsive) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(
          responsive.isCompact ? AppSpacing.xl : AppSpacing.xxl,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _emailEnabled
                    ? AppColors.successLight
                    : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.email_outlined,
                color: _emailEnabled ? AppColors.success : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transactional Email', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _emailEnabled
                        ? 'Automatic sale receipt emails are enabled.'
                        : 'Automatic sale receipt emails are disabled.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _emailEnabled
                        ? 'Completed sales can send receipts using '
                              'your Creator Yard Email Credits.'
                        : 'Sales will continue normally, but no new '
                              'email receipt jobs will be created.',
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Switch(
                value: _emailEnabled,
                onChanged: _isSavingEmailEnabled ? null : _setEmailEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(Responsive responsive) {
    final balance = _balance?.balance ?? 0;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(
          responsive.isCompact ? AppSpacing.xl : AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email Credits', style: AppTextStyles.title),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Transactional email balance',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: _isRefreshing
                      ? null
                      : () => _loadCredits(refresh: true),
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_outlined),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Text('Available credits', style: AppTextStyles.bodySecondary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              NumberFormat.decimalPattern().format(balance),
              style: AppTextStyles.price.copyWith(
                fontSize: responsive.isCompact ? 34 : 42,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '1 credit is currently used for 1 '
              'transactional email.',
              style: AppTextStyles.small,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseCard(Responsive responsive) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(
          responsive.isCompact ? AppSpacing.xl : AppSpacing.xxl,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.accentDark,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Buy Email Credits', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Purchase Creator Yard Email Credits '
                    'when your balance is low.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: responsive.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingPackages || _isOpeningCheckout
                          ? null
                          : _showPurchaseDialog,
                      icon: _isOpeningCheckout
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: Text(
                        _isOpeningCheckout
                            ? 'Opening Checkout...'
                            : 'Buy Credits',
                      ),
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

  Future<void> _showPurchaseDialog() async {
    if (_isLoadingPackages) {
      return;
    }

    setState(() {
      _isLoadingPackages = true;
    });

    try {
      final packages = await _creditsService.getPackages();

      if (!mounted) {
        return;
      }

      setState(() {
        _packages = packages;
        _isLoadingPackages = false;
      });

      if (_packages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email credit packages are currently available.'),
          ),
        );
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (_) => _PurchasePackageDialog(
          packages: _packages,
          onPurchase: _startPurchase,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingPackages = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load credit packages: '
            '${_cleanError(e)}',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _startPurchase({
    required EmailCreditPackage package,
    required String customerEmail,
    String? customerName,
  }) async {
    if (_isOpeningCheckout) {
      return;
    }

    final normalizedEmail = customerEmail.trim().toLowerCase();

    final normalizedName = customerName?.trim();

    if (normalizedEmail.isEmpty) {
      throw StateError('Customer email is required.');
    }

    setState(() {
      _isOpeningCheckout = true;
    });

    try {
      final purchase = await _creditsService.purchaseCredits(
        packageId: package.id,
        customerEmail: normalizedEmail,
        customerName: normalizedName?.isEmpty ?? true ? null : normalizedName,
      );

      final checkoutUrl = purchase.checkoutUrl.trim();

      if (checkoutUrl.isEmpty) {
        throw StateError('Flutterwave checkout URL was not returned.');
      }

      final uri = Uri.tryParse(checkoutUrl);

      if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) {
        throw StateError('Flutterwave returned an invalid checkout URL.');
      }

      _checkoutWasOpened = true;

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _checkoutWasOpened = false;

        throw StateError('Could not open Flutterwave checkout.');
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${package.credits} email credits checkout opened.'),
        ),
      );
    } catch (e) {
      _checkoutWasOpened = false;

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not start credit purchase: '
            '${_cleanError(e)}',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningCheckout = false;
        });
      }
    }
  }

  Widget _buildLedgerSection(Responsive responsive) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(
          responsive.isCompact ? AppSpacing.xl : AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Credit History', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Recent purchases and email usage from '
              'the Creator Yard credit account.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 40,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'No credit activity yet.',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _entries.length,
                separatorBuilder: (_, __) => const Divider(
                  height: AppSpacing.xl,
                  color: AppColors.divider,
                ),
                itemBuilder: (context, index) {
                  final entry = _entries[index];

                  final isPositive = entry.amount > 0;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          _ledgerIcon(entry.type),
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatLedgerType(entry.type),
                              style: AppTextStyles.body,
                            ),
                            if (entry.description?.trim().isNotEmpty ??
                                false) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                entry.description!.trim(),
                                style: AppTextStyles.bodySecondary,
                              ),
                            ],
                            if (entry.reference?.trim().isNotEmpty ??
                                false) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                entry.reference!.trim(),
                                style: AppTextStyles.small,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _formatDate(entry.createdAt),
                              style: AppTextStyles.small,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        '${isPositive ? '+' : '-'}'
                        '${_formatAmount(entry.amount)}',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _amountColor(entry.type),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Unable to load Email Credits',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage ??
                  'The Email Credits service could '
                      'not be reached.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => _loadCredits(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(title: const Text('Email Credits')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _balance == null
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: () => _loadCredits(refresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                  vertical: responsive.verticalPadding,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: responsive.contentMaxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildEmailSettingsCard(responsive),
                          const SizedBox(height: AppSpacing.lg),
                          _buildBalanceCard(responsive),
                          const SizedBox(height: AppSpacing.lg),
                          _buildPurchaseCard(responsive),
                          const SizedBox(height: AppSpacing.lg),
                          _buildLedgerSection(responsive),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PurchasePackageDialog extends StatefulWidget {
  final List<EmailCreditPackage> packages;

  final Future<void> Function({
    required EmailCreditPackage package,
    required String customerEmail,
    String? customerName,
  })
  onPurchase;

  const _PurchasePackageDialog({
    required this.packages,
    required this.onPurchase,
  });

  @override
  State<_PurchasePackageDialog> createState() => _PurchasePackageDialogState();
}

class _PurchasePackageDialogState extends State<_PurchasePackageDialog> {
  EmailCreditPackage? _selectedPackage;

  final _emailController = TextEditingController();

  final _nameController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    if (widget.packages.isNotEmpty) {
      _selectedPackage = widget.packages.first;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatNgn(int amount) {
    return NumberFormat.decimalPattern().format(amount);
  }

  Future<void> _submit() async {
    final package = _selectedPackage;

    if (package == null) {
      return;
    }

    final email = _emailController.text.trim();

    final name = _nameController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onPurchase(
        package: package,
        customerEmail: email,
        customerName: name.isEmpty ? null : name,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buy Email Credits'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a credit package.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...widget.packages.map((package) {
                final selected = _selectedPackage?.id == package.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: _isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _selectedPackage = package;
                            });
                          },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryLight
                            : AppColors.surface,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_formatNgn(package.credits)} credits',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '₦${_formatNgn(package.priceNgn)}',
                                  style: AppTextStyles.bodySecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _emailController,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Customer email',
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _nameController,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Customer name (optional)',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'You will be redirected to Flutterwave to complete the payment.',
                style: AppTextStyles.small,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Continue to Payment'),
        ),
      ],
    );
  }
}

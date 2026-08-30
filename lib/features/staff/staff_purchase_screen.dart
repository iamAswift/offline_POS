// lib/features/staff/staff_purchase_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../core/widgets/back_button.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/staff_purchase_dao.dart';
import '../../database/daos/user_dao.dart';

class StaffPurchaseScreen extends StatefulWidget {
  const StaffPurchaseScreen({super.key});

  @override
  State<StaffPurchaseScreen> createState() =>
      _StaffPurchaseScreenState();
}

class _StaffPurchaseScreenState extends State<StaffPurchaseScreen> {
  late final ProductDao _productDao;
  late final UserDao _userDao;
  late final StaffPurchaseDao _staffPurchaseDao;

  final _formKey = GlobalKey<FormState>();

  int? _selectedStaffId;
  int? _selectedProductId;

  String _paymentType = 'cash';

  final _quantityController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _noteController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  List<User> _staff = [];
  List<Product> _products = [];

  Product? _selectedProduct;

  double _currentDebt = 0.0;
  double _maxDebt = 50000.0;

  @override
  void initState() {
    super.initState();

    _productDao = getProductDao();
    _userDao = getUserDao();
    _staffPurchaseDao = getStaffPurchaseDao();

    _loadData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _amountPaidController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    try {
      final staff = await _userDao.getAllUsers();
      final products = await _productDao.getAllProducts();
      final maxDebt = await _staffPurchaseDao.getMaxStaffDebt();

      if (!mounted) return;

      setState(() {
        _staff = staff
            .where(
              (user) =>
                  user.role.trim().toLowerCase() == 'staff' &&
                  user.isActive,
            )
            .toList();

        _products = products;
        _maxDebt = maxDebt;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showError('Failed to load staff purchase data.\n$e');
    }
  }

  // ============================================================
  // SELECT STAFF
  // ============================================================

  Future<void> _selectStaff(int? staffId) async {
    if (staffId == null) return;

    try {
      final debt = await _staffPurchaseDao.getStaffDebt(staffId);

      if (!mounted) return;

      setState(() {
        _selectedStaffId = staffId;
        _currentDebt = debt;
      });
    } catch (e) {
      if (!mounted) return;

      _showError('Failed to load staff debt.\n$e');
    }
  }

  // ============================================================
  // SELECT PRODUCT
  // ============================================================

  void _selectProduct(int? productId) {
    if (productId == null) return;

    Product? product;

    for (final item in _products) {
      if (item.id == productId) {
        product = item;
        break;
      }
    }

    setState(() {
      _selectedProductId = productId;
      _selectedProduct = product;
    });
  }

  // ============================================================
  // CALCULATIONS
  // ============================================================

  int get _quantity {
    return int.tryParse(_quantityController.text.trim()) ?? 0;
  }

  double get _unitPrice {
    return _selectedProduct?.sellingPrice ?? 0.0;
  }

  double get _totalAmount {
    return _unitPrice * _quantity;
  }

  double get _amountPaid {
    if (_paymentType == 'cash') {
      return _totalAmount;
    }

    return double.tryParse(
          _amountPaidController.text.trim(),
        ) ??
        0.0;
  }

  double get _debtAmount {
    final debt = _totalAmount - _amountPaid;

    return debt < 0 ? 0.0 : debt;
  }

  double get _remainingDebtAfterPurchase {
    return _maxDebt - (_currentDebt + _debtAmount);
  }

  bool get _wouldExceedDebtLimit {
    if (_paymentType != 'credit') {
      return false;
    }

    return (_currentDebt + _debtAmount) > _maxDebt;
  }

  // ============================================================
  // SAVE PURCHASE
  // ============================================================

  Future<void> _savePurchase() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStaffId == null) {
      _showError('Select a staff member.');
      return;
    }

    if (_selectedProductId == null) {
      _showError('Select a product.');
      return;
    }

    if (_quantity <= 0) {
      _showError('Enter a valid quantity.');
      return;
    }

    if (_selectedProduct == null) {
      _showError('Selected product could not be found.');
      return;
    }

    if (_selectedProduct!.stock < _quantity) {
      _showError(
        'Insufficient stock. '
        'Available: ${_selectedProduct!.stock}.',
      );
      return;
    }

    if (_paymentType == 'credit') {
      if (_amountPaid > _totalAmount) {
        _showError(
          'Amount paid cannot exceed the purchase total.',
        );
        return;
      }

      if (_wouldExceedDebtLimit) {
        _showError(
          'Staff debt limit exceeded.\n'
          'Current debt: ₦${_currentDebt.toStringAsFixed(2)}\n'
          'New debt: ₦${_debtAmount.toStringAsFixed(2)}\n'
          'Maximum: ₦${_maxDebt.toStringAsFixed(2)}',
        );
        return;
      }
    }

    setState(() {
      _saving = true;
    });

    try {
      await _staffPurchaseDao.createStaffPurchase(
        staffId: _selectedStaffId!,
        productId: _selectedProductId!,
        quantity: _quantity,
        paymentType: _paymentType,
        amountPaid: _paymentType == 'credit' ? _amountPaid : null,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _paymentType == 'cash'
                  ? 'Staff purchase completed successfully.'
                  : 'Staff credit purchase completed. '
                      'Debt added: '
                      '₦${_debtAmount.toStringAsFixed(2)}.',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      _showError('Purchase failed.\n$e');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.body,
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                responsive.verticalPadding,
                responsive.horizontalPadding,
                responsive.verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.contentMaxWidth,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageHeader(),

                        const SizedBox(height: AppSpacing.xxl),

                        _buildContent(responsive),

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      leading: const CentralBackButton(),
      titleSpacing: AppSpacing.xl,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Staff Purchase',
            style: AppTextStyles.title,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Record staff purchases and credit',
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return _panel(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizes.iconButton,
            height: AppSizes.iconButton,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.badge_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Staff Purchase',
                  style: AppTextStyles.heading,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Record products issued to staff as cash '
                  'purchases or credit purchases.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(Responsive responsive) {
    final form = _buildPurchaseForm();
    final management = _buildManagementCard();

    if (responsive.isCompact || responsive.isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          form,
          const SizedBox(height: AppSpacing.xxl),
          management,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: form,
        ),
        const SizedBox(width: AppSpacing.xxl),
        Expanded(
          flex: 5,
          child: management,
        ),
      ],
    );
  }

  // ============================================================
  // PURCHASE FORM
  // ============================================================

  Widget _buildPurchaseForm() {
    final responsive = context.responsive;

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purchase Details',
            style: AppTextStyles.heading,
          ),

          const SizedBox(height: AppSpacing.xs),

          const Text(
            'Select the staff member, product, quantity, '
            'and payment method.',
            style: AppTextStyles.small,
          ),

          const SizedBox(height: AppSpacing.xl),

          _buildStaffDropdown(),

          if (_selectedStaffId != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildDebtCard(),
          ],

          const SizedBox(height: AppSpacing.xl),

          _buildProductDropdown(),

          if (_selectedProduct != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildProductInfo(),
          ],

          const SizedBox(height: AppSpacing.xl),

          _buildQuantityField(responsive),

          const SizedBox(height: AppSpacing.xl),

          _buildPurchaseTotal(),

          const SizedBox(height: AppSpacing.xl),

          _buildPaymentType(),

          if (_paymentType == 'credit') ...[
            const SizedBox(height: AppSpacing.lg),
            _buildCreditDetails(),
          ],

          const SizedBox(height: AppSpacing.lg),

          _buildNoteField(),

          const SizedBox(height: AppSpacing.xl),

          _buildCompletePurchaseButton(responsive),
        ],
      ),
    );
  }

  // ============================================================
  // STAFF DROPDOWN
  // ============================================================

  Widget _buildStaffDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedStaffId,
      isExpanded: true,
      style: AppTextStyles.body,
      decoration: _inputDecoration(
        label: 'Staff Member',
        hint: 'Select staff member',
        icon: Icons.person_outline,
      ),
      items: _staff.map((staff) {
        return DropdownMenuItem<int>(
          value: staff.id,
          child: Text(
            '${staff.name} (${staff.loginId ?? ''})',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body,
          ),
        );
      }).toList(),
      onChanged: _saving ? null : _selectStaff,
      validator: (value) {
        if (value == null) {
          return 'Select staff member';
        }

        return null;
      },
    );
  }

  // ============================================================
  // PRODUCT DROPDOWN
  // ============================================================

  Widget _buildProductDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedProductId,
      isExpanded: true,
      style: AppTextStyles.body,
      decoration: _inputDecoration(
        label: 'Product',
        hint: 'Select product',
        icon: Icons.inventory_2_outlined,
      ),
      items: _products.map((product) {
        return DropdownMenuItem<int>(
          value: product.id,
          child: Text(
            '${product.name} • '
            'Stock: ${product.stock} ${product.unit}',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body,
          ),
        );
      }).toList(),
      onChanged: _saving ? null : _selectProduct,
      validator: (value) {
        if (value == null) {
          return 'Select product';
        }

        return null;
      },
    );
  }

  // ============================================================
  // QUANTITY
  // ============================================================

  Widget _buildQuantityField(Responsive responsive) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: responsive.controlHeight,
      ),
      child: TextFormField(
        controller: _quantityController,
        enabled: !_saving,
        style: AppTextStyles.body,
        decoration: _inputDecoration(
          label: 'Quantity',
          hint: 'Enter quantity',
          icon: Icons.numbers_rounded,
        ),
        keyboardType: TextInputType.number,
        onChanged: (_) {
          setState(() {});
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter quantity';
          }

          final quantity = int.tryParse(value.trim());

          if (quantity == null || quantity <= 0) {
            return 'Enter a valid quantity';
          }

          if (_selectedProduct != null &&
              quantity > _selectedProduct!.stock) {
            return 'Only ${_selectedProduct!.stock} available';
          }

          return null;
        },
      ),
    );
  }

  // ============================================================
  // PURCHASE TOTAL
  // ============================================================

  Widget _buildPurchaseTotal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.calculate_outlined,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchase Total',
                  style: AppTextStyles.bodySecondary,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Calculated from selling price × quantity',
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₦${_totalAmount.toStringAsFixed(2)}',
              style: AppTextStyles.price.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT TYPE
  // ============================================================

  Widget _buildPaymentType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Type',
          style: AppTextStyles.bodySecondary,
        ),

        const SizedBox(height: AppSpacing.sm),

        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(
                value: 'cash',
                label: Text('Cash'),
                icon: Icon(Icons.payments_outlined),
              ),
              ButtonSegment<String>(
                value: 'credit',
                label: Text('Credit'),
                icon: Icon(Icons.credit_card_outlined),
              ),
            ],
            selected: {_paymentType},
            onSelectionChanged: _saving
                ? null
                : (selection) {
                    setState(() {
                      _paymentType = selection.first;

                      if (_paymentType == 'cash') {
                        _amountPaidController.clear();
                      }
                    });
                  },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CREDIT DETAILS
  // ============================================================

  Widget _buildCreditDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Credit Details',
                style: AppTextStyles.title,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          TextFormField(
            controller: _amountPaidController,
            enabled: !_saving,
            style: AppTextStyles.body,
            decoration: _inputDecoration(
              label: 'Amount Paid',
              hint: '0.00',
              icon: Icons.payments_outlined,
              prefixText: '₦ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (_) {
              setState(() {});
            },
            validator: (value) {
              if (_paymentType != 'credit') {
                return null;
              }

              final amount = double.tryParse(
                value?.trim() ?? '',
              );

              if (amount == null || amount < 0) {
                return 'Enter a valid amount';
              }

              if (amount > _totalAmount) {
                return 'Cannot exceed purchase total';
              }

              return null;
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          _buildAmountRow(
            'Amount Paid',
            _amountPaid,
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildAmountRow(
            'New Debt',
            _debtAmount,
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildAmountRow(
            'Debt After Purchase',
            _currentDebt + _debtAmount,
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildAmountRow(
            'Debt Remaining',
            _remainingDebtAfterPurchase
                .clamp(0, double.infinity)
                .toDouble(),
          ),

          if (_wouldExceedDebtLimit) ...[
            const SizedBox(height: AppSpacing.md),
            _buildDebtWarning(),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // DEBT WARNING
  // ============================================================

  Widget _buildDebtWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Text(
              'This purchase exceeds the staff debt limit.',
              style: AppTextStyles.bodySecondary.copyWith(
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTE
  // ============================================================

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      enabled: !_saving,
      style: AppTextStyles.body,
      maxLines: 2,
      decoration: _inputDecoration(
        label: 'Note (Optional)',
        hint: 'Optional purchase note',
        icon: Icons.notes_outlined,
      ),
    );
  }

  // ============================================================
  // COMPLETE PURCHASE
  // ============================================================

  Widget _buildCompletePurchaseButton(Responsive responsive) {
    return SizedBox(
      width: double.infinity,
      height: responsive.buttonHeight,
      child: FilledButton.icon(
        onPressed: _saving ? null : _savePurchase,
        icon: _saving
            ? const SizedBox(
                width: AppSpacing.lg,
                height: AppSpacing.lg,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.surface,
                ),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(
          _saving
              ? 'Completing Purchase...'
              : 'Complete Purchase',
          style: AppTextStyles.body.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MANAGEMENT CARD
  // ============================================================

  Widget _buildManagementCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Staff Debt Management',
            style: AppTextStyles.heading,
          ),

          const SizedBox(height: AppSpacing.xs),

          const Text(
            'Manage repayments and review outstanding '
            'staff balances separately from purchases.',
            style: AppTextStyles.small,
          ),

          const SizedBox(height: AppSpacing.xl),

          _buildManagementInfo(),

          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: _saving
                  ? null
                  : () {
                      context.push('/staff-debt-management');
                    },
              icon: const Icon(
                Icons.account_balance_wallet_outlined,
              ),
              label: const Text(
                'Open Debt Management',
                style: AppTextStyles.body,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                  color: AppColors.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppRadius.lg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MANAGEMENT INFO
  // ============================================================

  Widget _buildManagementInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.info,
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Text(
              'Use Debt Management to record staff repayments, '
              'review balances, and monitor outstanding credit.',
              style: AppTextStyles.small.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DEBT CARD
  // ============================================================

  Widget _buildDebtCard() {
    final remaining = _maxDebt - _currentDebt;

    final safeRemaining = remaining < 0 ? 0.0 : remaining;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _currentDebt >= _maxDebt
              ? AppColors.danger
              : AppColors.primary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _currentDebt >= _maxDebt
                      ? AppColors.dangerLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: _currentDebt >= _maxDebt
                      ? AppColors.danger
                      : AppColors.primary,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              const Expanded(
                child: Text(
                  'Staff Debt',
                  style: AppTextStyles.title,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          _buildAmountRow(
            'Current Debt',
            _currentDebt,
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildAmountRow(
            'Maximum Debt',
            _maxDebt,
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildAmountRow(
            'Available Credit',
            safeRemaining,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT INFO
  // ============================================================

  Widget _buildProductInfo() {
    final product = _selectedProduct!;

    final stockColor = product.stock <= 0
        ? AppColors.danger
        : product.stock <= 10
        ? AppColors.warning
        : AppColors.success;

    final stockBackground = product.stock <= 0
        ? AppColors.dangerLight
        : product.stock <= 10
        ? AppColors.warningLight
        : AppColors.successLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          _buildAmountRow(
            'Selling Price',
            _unitPrice,
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: stockBackground,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_outlined,
                  size: 18,
                  color: stockColor,
                ),

                const SizedBox(width: AppSpacing.sm),

                const Expanded(
                  child: Text(
                    'Available Stock',
                    style: AppTextStyles.bodySecondary,
                  ),
                ),

                Text(
                  '${product.stock} ${product.unit}',
                  style: AppTextStyles.body.copyWith(
                    color: stockColor,
                    fontWeight: FontWeight.w600,
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
  // AMOUNT ROW
  // ============================================================

  Widget _buildAmountRow(
    String label,
    double amount,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.bodySecondary,
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Flexible(
          child: Text(
            '₦${amount.toStringAsFixed(2)}',
            textAlign: TextAlign.end,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      prefixText: prefixText,
      labelStyle: AppTextStyles.bodySecondary,
      hintStyle: AppTextStyles.small,
      filled: true,
      fillColor: AppColors.background,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.danger,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.danger,
          width: 1.5,
        ),
      ),

      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.divider,
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    );
  }

  // ============================================================
  // PANEL
  // ============================================================

  Widget _panel({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(AppSpacing.xl),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: child,
    );
  }
}

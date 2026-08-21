//lib/features/staff/staff_purchase_screen.dart

import 'package:flutter/material.dart';

import '../../core/theme/styles.dart';
import '../../core/widgets/back_button.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/staff_purchase_dao.dart';
import '../../database/daos/user_dao.dart';



import 'package:go_router/go_router.dart';

class StaffPurchaseScreen extends StatefulWidget {
  const StaffPurchaseScreen({super.key});

  @override
  State<StaffPurchaseScreen> createState() =>
      _StaffPurchaseScreenState();
}

class _StaffPurchaseScreenState
    extends State<StaffPurchaseScreen> {
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
      final maxDebt =
          await _staffPurchaseDao.getMaxStaffDebt();

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load staff purchase data: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SELECT STAFF
  // ============================================================

  Future<void> _selectStaff(int? staffId) async {
    if (staffId == null) return;

    try {
      final debt =
          await _staffPurchaseDao.getStaffDebt(staffId);

      if (!mounted) return;

      setState(() {
        _selectedStaffId = staffId;
        _currentDebt = debt;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load staff debt: $e',
          ),
        ),
      );
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
    return int.tryParse(
          _quantityController.text.trim(),
        ) ??
        0;
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
    return _maxDebt -
        (_currentDebt + _debtAmount);
  }

  bool get _wouldExceedDebtLimit {
    if (_paymentType != 'credit') {
      return false;
    }

    return (_currentDebt + _debtAmount) >
        _maxDebt;
  }

  // ============================================================
  // SAVE PURCHASE
  // ============================================================

  Future<void> _savePurchase() async {
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
        amountPaid:
            _paymentType == 'credit'
                ? _amountPaid
                : null,
        note:
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _paymentType == 'cash'
                ? 'Staff purchase completed successfully.'
                : 'Staff credit purchase completed. '
                  'Debt added: '
                  '₦${_debtAmount.toStringAsFixed(2)}.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Purchase failed: $e',
          ),
        ),
      );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        leading: const CentralBackButton(),

        title: const Text(
          'Staff Purchase',
          style: AppTextStyles.heading,
        ),

        backgroundColor: AppColors.primary,
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: AppTextStyles.screenPadding,

              child: Form(
                key: _formKey,

                child: ListView(
                  children: [

                    // ==================================================
                    // STAFF
                    // ==================================================

                    DropdownButtonFormField<int>(
                      initialValue: _selectedStaffId,

                      decoration: const InputDecoration(
                        labelText: 'Staff Member',
                      ),

                      items: _staff.map((staff) {
                        return DropdownMenuItem<int>(
                          value: staff.id,

                          child: Text(
                            '${staff.name} '
                            '(${staff.loginId ?? ''})',
                          ),
                        );
                      }).toList(),

                      onChanged: _selectStaff,

                      validator: (value) {
                        if (value == null) {
                          return 'Select staff member';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // CURRENT DEBT
                    // ==================================================

                    if (_selectedStaffId != null)
                      _buildDebtCard(),

                    const SizedBox(height: 16),

                    // ==================================================
                    // PRODUCT
                    // ==================================================

                    DropdownButtonFormField<int>(
                      initialValue: _selectedProductId,

                      decoration: const InputDecoration(
                        labelText: 'Product',
                      ),

                      items: _products.map((product) {
                        return DropdownMenuItem<int>(
                          value: product.id,

                          child: Text(
                            '${product.name} '
                            '- Stock: ${product.stock}',
                          ),
                        );
                      }).toList(),

                      onChanged: _selectProduct,

                      validator: (value) {
                        if (value == null) {
                          return 'Select product';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // PRODUCT PRICE
                    // ==================================================

                    if (_selectedProduct != null)
                      _buildProductInfo(),

                    const SizedBox(height: 16),

                    // ==================================================
                    // QUANTITY
                    // ==================================================

                    TextFormField(
                      controller: _quantityController,

                      decoration:
                          const InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'e.g. 2',
                      ),

                      keyboardType:
                          TextInputType.number,

                      onChanged: (_) {
                        setState(() {});
                      },

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter quantity';
                        }

                        final quantity =
                            int.tryParse(
                          value.trim(),
                        );

                        if (quantity == null ||
                            quantity <= 0) {
                          return 'Enter a valid quantity';
                        }

                        if (_selectedProduct != null &&
                            quantity >
                                _selectedProduct!.stock) {
                          return 'Only '
                              '${_selectedProduct!.stock} '
                              'available';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // TOTAL
                    // ==================================================

                    _buildAmountRow(
                      'Purchase Total',
                      _totalAmount,
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // PAYMENT TYPE
                    // ==================================================

                    const Text(
                      'Payment Type',
                      style: AppTextStyles.body,
                    ),

                    const SizedBox(height: 8),

                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'cash',
                          label: Text('Cash'),
                          icon: Icon(
                            Icons.payments,
                          ),
                        ),

                        ButtonSegment<String>(
                          value: 'credit',
                          label: Text('Credit'),
                          icon: Icon(
                            Icons.credit_card,
                          ),
                        ),
                      ],

                      selected: {
                        _paymentType,
                      },

                      onSelectionChanged:
                          (selection) {
                        setState(() {
                          _paymentType =
                              selection.first;

                          if (_paymentType ==
                              'cash') {
                            _amountPaidController
                                .clear();
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // CREDIT DETAILS
                    // ==================================================

                    if (_paymentType ==
                        'credit') ...[
                      TextFormField(
                        controller:
                            _amountPaidController,

                        decoration:
                            const InputDecoration(
                          labelText: 'Amount Paid',
                          prefixText: '₦ ',
                          hintText: '0',
                        ),

                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),

                        onChanged: (_) {
                          setState(() {});
                        },

                        validator: (value) {
                          if (_paymentType !=
                              'credit') {
                            return null;
                          }

                          final amount =
                              double.tryParse(
                            value?.trim() ?? '',
                          );

                          if (amount == null ||
                              amount < 0) {
                            return 'Enter a valid amount';
                          }

                          if (amount >
                              _totalAmount) {
                            return 'Cannot exceed '
                                'purchase total';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildAmountRow(
                        'Amount Paid',
                        _amountPaid,
                      ),

                      const SizedBox(height: 8),

                      _buildAmountRow(
                        'New Debt',
                        _debtAmount,
                      ),

                      const SizedBox(height: 8),

                      _buildAmountRow(
                        'Debt After Purchase',
                        _currentDebt +
                            _debtAmount,
                      ),

                      const SizedBox(height: 8),

                      _buildAmountRow(
                        'Debt Remaining',
                        _remainingDebtAfterPurchase
                            .clamp(
                              0,
                              double.infinity,
                            )
                            .toDouble(),
                      ),

                      const SizedBox(height: 12),

                      if (_wouldExceedDebtLimit)
                        Container(
                          padding:
                              const EdgeInsets.all(
                            12,
                          ),

                          decoration:
                              BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),

                            border: Border.all(
                              color: Colors.red,
                            ),
                          ),

                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.red,
                              ),

                              SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  'This purchase exceeds '
                                  'the staff debt limit.',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],

                    const SizedBox(height: 16),

                    // ==================================================
                    // NOTE
                    // ==================================================

                    TextFormField(
                      controller: _noteController,

                      decoration:
                          const InputDecoration(
                        labelText: 'Note (Optional)',
                        hintText:
                            'Optional purchase note',
                      ),

                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),


                    //Repaymnent 

                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.accent,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),

                      onPressed:
                          _saving
                              ? null
                              : _savePurchase,

                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Repayment',
                              style:
                                  AppTextStyles.body,
                            ),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                      onPressed: () {
                        context.push('/staff-debt-management');
                      },
                      child: const Text(
                        'Repayment',
                        style: AppTextStyles.body,
                      ),
                    ),

                    
                    // ==================================================
                    // SAVE
                    // ==================================================

                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.accent,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),

                      onPressed:
                          _saving
                              ? null
                              : _savePurchase,

                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Complete Purchase',
                              style:
                                  AppTextStyles.body,
                            ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // DEBT CARD
  // ============================================================

  Widget _buildDebtCard() {
    final remaining =
        _maxDebt - _currentDebt;

    final safeRemaining =
        remaining < 0 ? 0.0 : remaining;

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: AppColors.primary,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Staff Debt',
            style: AppTextStyles.body,
          ),

          const SizedBox(height: 10),

          _buildAmountRow(
            'Current Debt',
            _currentDebt,
          ),

          const SizedBox(height: 6),

          _buildAmountRow(
            'Maximum Debt',
            _maxDebt,
          ),

          const SizedBox(height: 6),

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
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: AppColors.primary,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            _selectedProduct!.name,
            style: AppTextStyles.body,
          ),

          const SizedBox(height: 8),

          _buildAmountRow(
            'Selling Price',
            _unitPrice,
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              const Text('Available Stock'),

              Text(
                '${_selectedProduct!.stock}',
              ),
            ],
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
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [
        Text(label),

        Text(
          '₦${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
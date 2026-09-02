// lib/features/users/create_user_screen.dart

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/session.dart';
import '../../core/theme/styles.dart';
import '../../core/responsive/responsive.dart';
import '../../database/app_database.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'staff';

  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE USER
  // ============================================================

  Future<void> _createUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (name.isEmpty) {
      _showMessage('Please enter the employee name.');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Please enter the employee email.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter a temporary password.');
      return;
    }

    if (password.length < 4) {
      _showMessage('Password must contain at least 4 characters.');
      return;
    }

    // ----------------------------------------------------------
    // PERMISSION CHECK
    // ----------------------------------------------------------

    if (!Session.isOwnerOrManager) {
      _showMessage('Only an owner or manager can create users.');
      return;
    }

    // Managers can create staff but not other managers.
    if (Session.isManager && _selectedRole == 'manager') {
      _showMessage('Managers can only create staff accounts.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userDao = getUserDao();

      // --------------------------------------------------------
      // EMAIL DUPLICATE CHECK
      // --------------------------------------------------------

      final existing = await userDao.getUserByEmail(email);

      if (existing != null) {
        _showMessage('An account already exists with this email.');
        return;
      }

      // --------------------------------------------------------
      // CREATE LOGIN ID
      // --------------------------------------------------------

      String loginId;

      if (_selectedRole == 'manager') {
        loginId = await userDao.generateManagerLoginId();
      } else {
        loginId = await userDao.generateStaffLoginId();
      }

      // --------------------------------------------------------
      // CREATE ACCOUNT
      // --------------------------------------------------------

      await userDao.insertUser(
        UsersCompanion.insert(
          name: name,
          loginId: Value(loginId),
          email: email,
          password: password,
          role: Value(_selectedRole),
        ),
      );

      if (!mounted) return;

      // --------------------------------------------------------
      // SHOW LOGIN DETAILS
      // --------------------------------------------------------

      await _showAccountCreatedDialog(
        name: name,
        loginId: loginId,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to create account. Please try again.');

      debugPrint('Create user error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // ACCOUNT CREATED DIALOG
  

  // ============================================================
  // ACCOUNT CREATED DIALOG
  // ============================================================

  Future<void> _showAccountCreatedDialog({
    required String name,
    required String loginId,
    required String password,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final responsive = dialogContext.responsive;
        final mediaQuery = MediaQuery.of(dialogContext);

        // Keep the dialog comfortably inside the available screen.
        final maxDialogHeight = mediaQuery.size.height * 0.82;

        final dialogWidth = responsive.isCompact
            ? mediaQuery.size.width - (AppSpacing.xl * 2)
            : 440.0;

        return AlertDialog(
          scrollable: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),

          titlePadding: EdgeInsets.fromLTRB(
            responsive.isCompact
                ? AppSpacing.lg
                : AppSpacing.xxl,
            responsive.isCompact
                ? AppSpacing.lg
                : AppSpacing.xxl,
            responsive.isCompact
                ? AppSpacing.lg
                : AppSpacing.xxl,
            0,
          ),

          contentPadding: EdgeInsets.zero,

          actionsPadding: EdgeInsets.fromLTRB(
            responsive.isCompact
                ? AppSpacing.lg
                : AppSpacing.xxl,
            AppSpacing.sm,
            responsive.isCompact
                ? AppSpacing.lg
                : AppSpacing.xxl,
            responsive.isCompact
                ? AppSpacing.lg
                : AppSpacing.xxl,
          ),

          // ======================================================
          // TITLE
          // ======================================================

          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 24,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              const Expanded(
                child: Text(
                  'Account Created',
                  style: AppTextStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // ======================================================
          // CONTENT
          // ======================================================

          content: SizedBox(
            width: dialogWidth,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxDialogHeight,
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.isCompact
                      ? AppSpacing.lg
                      : AppSpacing.xxl,
                  AppSpacing.lg,
                  responsive.isCompact
                      ? AppSpacing.lg
                      : AppSpacing.xxl,
                  AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // SUCCESS MESSAGE
                    // ==================================================

                    Text(
                      '$name has been added successfully.',
                      style: AppTextStyles.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ==================================================
                    // LOGIN ID LABEL
                    // ==================================================

                    const Text(
                      'Login ID',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // ==================================================
                    // LOGIN ID
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppRadius.md,
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),
                      child: SelectableText(
                        loginId,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: responsive.isCompact ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ==================================================
                    // PASSWORD LABEL
                    // ==================================================

                    const Text(
                      'Temporary Password',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // ==================================================
                    // PASSWORD
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(
                          AppRadius.md,
                        ),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: SelectableText(
                        password,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: responsive.isCompact ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ==================================================
                    // SECURITY MESSAGE
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(
                          AppRadius.md,
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                           Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.warning,
                          ),

                           SizedBox(
                            width: AppSpacing.sm,
                          ),

                           Expanded(
                            child: Text(
                              'Give these login details to the '
                              'employee securely. The employee '
                              'will use the Login ID and password '
                              'to access the system.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                height: 1.4,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ========================================================
          // DONE BUTTON
          // ========================================================

          actions: [
            SizedBox(
              width: double.infinity,
              height: responsive.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Done'),
              ),
            ),
          ],
        );
      },
    );
  }


  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
    );
  }

  // ============================================================
  // BUILD FORM
  // ============================================================

  Widget _buildForm(BuildContext context, Responsive responsive) {
    final isManager = Session.isManager;

    final horizontalCardPadding = responsive.isCompact
        ? AppSpacing.xl
        : responsive.isTablet
        ? AppSpacing.xxl
        : AppSpacing.xxxl;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(horizontalCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ======================================================
            // HEADER
            // ======================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: responsive.isCompact ? 48 : 56,
                  height: responsive.isCompact ? 48 : 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_outlined,
                    color: AppColors.primary,
                    size: responsive.isCompact ? 25 : 30,
                  ),
                ),

                const SizedBox(width: AppSpacing.lg),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Employee Account', style: AppTextStyles.heading),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Create a controlled login account '
                        'for a supermarket employee.',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // ======================================================
            // NAME
            // ======================================================
            TextField(
              controller: _nameController,
              enabled: !_isSaving,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Full Name',
                hint: 'e.g. John Doe',
                icon: Icons.person_outline,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ======================================================
            // EMAIL
            // ======================================================
            TextField(
              controller: _emailController,
              enabled: !_isSaving,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Email Address',
                hint: 'employee@example.com',
                icon: Icons.email_outlined,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ======================================================
            // ROLE
            // ======================================================
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: _inputDecoration(
                label: 'Employee Role',
                icon: Icons.badge_outlined,
              ),
              items: [
                const DropdownMenuItem(value: 'staff', child: Text('Staff')),
                if (!isManager)
                  const DropdownMenuItem(
                    value: 'manager',
                    child: Text('Manager'),
                  ),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedRole = value;
                      });
                    },
            ),

            const SizedBox(height: AppSpacing.lg),

            // ======================================================
            // PASSWORD
            // ======================================================
            TextField(
              controller: _passwordController,
              enabled: !_isSaving,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _createUser(),
              decoration: _inputDecoration(
                label: 'Temporary Password',
                hint: 'Minimum 4 characters',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: _isSaving
                      ? null
                      : () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            const Text(
              'The employee will use this password '
              'with their assigned Login ID.',
              style: AppTextStyles.small,
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // ======================================================
            // CREATE BUTTON
            // ======================================================
            SizedBox(
              height: responsive.buttonHeight,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _createUser,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Employee'),
              ),
            ),
          ],
        ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(title: const Text('Add Employee')),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.horizontalPadding,
                vertical: responsive.verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.isCompact ? double.infinity : 600,
                  ),
                  child: _buildForm(context, responsive),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

//lib/features/users/initial_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../core/session.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // CREATE OWNER
  // ============================================================

  Future<void> _createOwner() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (name.isEmpty) {
      _showMessage('Please enter the owner name.');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Please enter an email address.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please create a password.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userDao = getUserDao();

      // --------------------------------------------------------
      // SECURITY CHECK
      //
      // This screen is ONLY allowed when there are no users.
      // --------------------------------------------------------

      final userCount = await userDao.getUserCount();

      if (userCount > 0) {
        if (!mounted) return;

        _showMessage(
          'An owner account already exists. '
          'Please sign in.',
        );

        context.go('/');

        return;
      }

      // --------------------------------------------------------
      // CREATE OWNER
      // --------------------------------------------------------

      final userId = await userDao.createInitialOwner(
        name: name,
        email: email,
        password: password,
      );

      // --------------------------------------------------------
      // LOAD CREATED USER
      // --------------------------------------------------------

      final owner = await userDao.getUserById(userId);

      if (owner == null) {
        throw Exception('Owner account was created but could not be loaded.');
      }

      // --------------------------------------------------------
      // SAVE SESSION
      // --------------------------------------------------------

      await Session.saveUserSession(
        userId: owner.id,
        email: owner.email,
        loginId: owner.loginId ?? '',
        role: owner.role,
      );

      if (!mounted) return;

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      _showMessage('Owner account created successfully.');

      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;

      debugPrint('Initial owner creation error: $e');

      _showMessage(
        'Unable to create owner account. '
        'Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
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
  // SETUP CARD
  // ============================================================

  Widget _buildSetupCard(BuildContext context, Responsive responsive) {
    final bool isCompact = responsive.isCompact;

    final double cardPadding = isCompact ? AppSpacing.xxl : AppSpacing.xxxl;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.horizontalPadding,
        vertical: responsive.verticalPadding,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxFormWidth),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // ICON
                // ==================================================
                _buildSetupIcon(),

                SizedBox(height: AppSpacing.xxl),

                // ==================================================
                // TITLE
                // ==================================================
                Text(
                  'Set Up Your Supermarket',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: isCompact ? 22 : 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

                Text(
                  'Create the first owner account '
                  'to get started.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
                ),

                SizedBox(height: AppSpacing.xxl),

                // ==================================================
                // INFORMATION CARD
                // ==================================================
                _buildInformationCard(),

                SizedBox(height: AppSpacing.xxl),

                // ==================================================
                // OWNER NAME
                // ==================================================
                TextField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Owner Name',
                    hintText: 'e.g. Austine Okoh',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),

                SizedBox(height: AppSpacing.lg),

                // ==================================================
                // EMAIL
                // ==================================================
                TextField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'owner@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                SizedBox(height: AppSpacing.lg),

                // ==================================================
                // PASSWORD
                // ==================================================
                TextField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: _isLoading
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

                SizedBox(height: AppSpacing.lg),

                // ==================================================
                // CONFIRM PASSWORD
                // ==================================================
                TextField(
                  controller: _confirmPasswordController,
                  enabled: !_isLoading,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isLoading) {
                      _createOwner();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      tooltip: _obscureConfirmPassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xxl),

                // ==================================================
                // LOGIN ID PREVIEW
                // ==================================================
                _buildLoginIdPreview(),

                SizedBox(height: AppSpacing.xxl),

                // ==================================================
                // CREATE BUTTON
                // ==================================================
                SizedBox(
                  height: responsive.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createOwner,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Owner Account'),
                  ),
                ),

                SizedBox(height: AppSpacing.lg),

                // ==================================================
                // FOOTER
                // ==================================================
                Text(
                  'This setup screen is only available '
                  'when no user account exists.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.small.copyWith(
                    fontSize: isCompact ? 11 : 12,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SETUP ICON
  // ============================================================

  Widget _buildSetupIcon() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.admin_panel_settings_outlined,
          color: AppColors.primary,
          size: 34,
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.info, size: 20),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Text(
              'You will be the owner of this '
              'supermarket system. Your Login ID '
              'will be automatically assigned.',
              style: AppTextStyles.small.copyWith(
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGIN ID PREVIEW
  // ============================================================

  Widget _buildLoginIdPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.badge_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),

          const SizedBox(width: AppSpacing.md),

          const Expanded(
            child: Text('Your Login ID', style: AppTextStyles.small),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Text(
              'OWN001',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(child: _buildSetupCard(context, responsive)),
              ),
            );
          },
        ),
      ),
    );
  }
}

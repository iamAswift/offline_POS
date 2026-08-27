// lib/features/users/login_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/business/business_identity.dart';
import '../../core/session.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/settings_dao.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ============================================================
  // BUSINESS IDENTITY
  // ============================================================

  String _businessName = BusinessIdentity.defaultBusinessName;

  String? _businessLogo;

  bool _isBusinessIdentityLoading = true;

  final db = getDatabase();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadBusinessIdentity();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD BUSINESS IDENTITY
  // ============================================================

  Future<void> _loadBusinessIdentity() async {
    try {
      final settingsDao = SettingsDao(db);

      final businessName = await BusinessIdentity.getBusinessName(settingsDao);

      final businessLogo = await BusinessIdentity.getBusinessLogo(settingsDao);

      if (!mounted) return;

      setState(() {
        _businessName = businessName;
        _businessLogo = businessLogo;
        _isBusinessIdentityLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isBusinessIdentityLoading = false;
      });

      debugPrint('Business identity load failed: $e');
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _handleLogin() async {
    final loginId = _loginIdController.text.trim();

    final password = _passwordController.text;

    if (loginId.isEmpty || password.isEmpty) {
      _showMessage('Please enter your Login ID and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userDao = getUserDao();

      final user = await userDao.getUserByLoginId(loginId);

      if (!mounted) return;

      if (user == null) {
        _showMessage('No account found for Login ID $loginId.');
        return;
      }

      if (!user.isActive) {
        _showMessage(
          'Your account is inactive. '
          'Please contact the administrator.',
        );
        return;
      }

      if (user.password != password) {
        _showMessage('Invalid password.');
        return;
      }

      final role = user.role.trim().toLowerCase();

      // ========================================================
      // SAVE LOGIN SESSION
      // ========================================================

      await Session.saveUserSession(
        userId: user.id,
        loginId: user.loginId,
        email: user.email,
        role: role,
      );

      debugPrint(
        'LOGIN SESSION: '
        'userId=${Session.currentUserId}, '
        'loginId=${Session.currentUserLoginId}, '
        'email=${Session.currentUserEmail}, '
        'role=${Session.currentUserRole}',
      );

      if (!mounted) return;

      if (role == 'owner' || role == 'manager') {
        context.go('/dashboard');
      } else if (role == 'staff') {
        context.go('/sales');
      } else {
        _showMessage('Unknown user role: ${user.role}');
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Login failed. Please try again.');

      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUSINESS LOGO
  // ============================================================

  Widget _buildBusinessLogo() {
    final logoPath = _businessLogo;

    // ----------------------------------------------------------
    // NO LOGO
    // ----------------------------------------------------------

    if (logoPath == null || logoPath.trim().isEmpty) {
      return Icon(
        Icons.storefront_outlined,
        color: AppColors.primary,
        size: 30,
      );
    }

    final file = File(logoPath);

    // ----------------------------------------------------------
    // FILE DOES NOT EXIST
    // ----------------------------------------------------------

    if (!file.existsSync()) {
      return Icon(
        Icons.storefront_outlined,
        color: AppColors.primary,
        size: 30,
      );
    }

    // ----------------------------------------------------------
    // SVG
    // ----------------------------------------------------------

    if (logoPath.toLowerCase().endsWith('.svg')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SvgPicture.file(
          file,
          width: 58,
          height: 58,
          fit: BoxFit.contain,
          placeholderBuilder: (context) {
            return Icon(
              Icons.storefront_outlined,
              color: AppColors.primary,
              size: 30,
            );
          },
        ),
      );
    }

    // ----------------------------------------------------------
    // PNG / JPG / JPEG
    // ----------------------------------------------------------

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Image.file(
        file,
        width: 58,
        height: 58,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.storefront_outlined,
            color: AppColors.primary,
            size: 30,
          );
        },
      ),
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
  // RESPONSIVE LOGIN CARD
  // ============================================================

  Widget _buildLoginCard(BoxConstraints constraints) {
    final width = constraints.maxWidth;

    final bool isCompact = width < 600;

    final double horizontalPadding = isCompact
        ? AppSpacing.lg
        : AppSpacing.xxxl;

    final double cardPadding = isCompact ? AppSpacing.xxl : AppSpacing.xxxl;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppSpacing.xxl,
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
                // BUSINESS LOGO
                // ==================================================
                _buildLogoSection(),

                SizedBox(height: AppSpacing.xxl),

                // ==================================================
                // BUSINESS NAME
                // ==================================================
                Text(
                  _businessName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

                Text(
                  'Sign in to continue to your account.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                SizedBox(height: AppSpacing.xxxl),

                // ==================================================
                // LOGIN ID
                // ==================================================
                TextField(
                  controller: _loginIdController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Login ID',
                    hintText: 'e.g. ST001',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),

                SizedBox(height: AppSpacing.lg),

                // ==================================================
                // PASSWORD
                // ==================================================
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
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

                SizedBox(height: AppSpacing.xxl),

                // ==================================================
                // SIGN IN
                // ==================================================
                SizedBox(
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Sign In'),
                  ),
                ),

                SizedBox(height: AppSpacing.xl),

                // ==================================================
                // LOGIN INFORMATION
                // ==================================================
                Text(
                  'Your Login ID is assigned by your '
                  'supermarket administrator.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGO SECTION
  // ============================================================

  Widget _buildLogoSection() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        alignment: Alignment.center,
        child: _isBusinessIdentityLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : _buildBusinessLogo(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(child: _buildLoginCard(constraints)),
              ),
            );
          },
        ),
      ),
    );
  }
}

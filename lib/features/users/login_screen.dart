// lib/features/users/login_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../database/app_database.dart';
import '../../database/daos/settings_dao.dart';
import '../../core/session.dart';
import '../../core/business/business_identity.dart';

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

  String _businessName =
      BusinessIdentity.defaultBusinessName;

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
  // LOAD BUSINESS IDENTITY
  // ============================================================

  Future<void> _loadBusinessIdentity() async {
    try {
      final settingsDao = SettingsDao(db);

      final businessName =
          await BusinessIdentity.getBusinessName(
        settingsDao,
      );

      final businessLogo =
          await BusinessIdentity.getBusinessLogo(
        settingsDao,
      );

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

      debugPrint(
        'Business identity load failed: $e',
      );
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _handleLogin() async {
    final loginId =
        _loginIdController.text.trim();

    final password =
        _passwordController.text;

    if (loginId.isEmpty ||
        password.isEmpty) {
      _showMessage(
        "Please enter your Login ID and password.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userDao = getUserDao();

      final user =
          await userDao.getUserByLoginId(
        loginId,
      );

      if (!mounted) return;

      if (user == null) {
        _showMessage(
          "No account found for Login ID $loginId.",
        );
        return;
      }

      if (!user.isActive) {
        _showMessage(
          "Your account is inactive. Please contact the administrator.",
        );
        return;
      }

      if (user.password != password) {
        _showMessage(
          "Invalid password.",
        );
        return;
      }

      final role =
          user.role.trim().toLowerCase();

      // ========================================================
      // SAVE LOGIN SESSION
      // ========================================================

      await Session.saveUserSession(
        userId: user.id,
        loginId: user.loginId,
        email: user.email,
        role: role,
      );

      // DEBUG
      debugPrint(
        '✅ LOGIN SESSION: '
        'userId=${Session.currentUserId}, '
        'loginId=${Session.currentUserLoginId}, '
        'email=${Session.currentUserEmail}, '
        'role=${Session.currentUserRole}',
      );

      if (!mounted) return;

      if (role == "owner" ||
          role == "manager") {
        context.go('/dashboard');
      } else if (role == "staff") {
        context.go('/sales');
      } else {
        _showMessage(
          "Unknown user role: ${user.role}",
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        "Login failed. Please try again.",
      );

      debugPrint(
        "Login error: $e",
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
  // BUSINESS LOGO
  // ============================================================

  Widget _buildBusinessLogo() {
    final logoPath = _businessLogo;

    // ----------------------------------------------------------
    // NO LOGO
    // ----------------------------------------------------------

    if (logoPath == null ||
        logoPath.trim().isEmpty) {
      return const Icon(
        Icons.storefront_outlined,
        color: Colors.indigo,
        size: 30,
      );
    }

    final file = File(logoPath);

    // ----------------------------------------------------------
    // FILE DOES NOT EXIST
    // ----------------------------------------------------------

    if (!file.existsSync()) {
      return const Icon(
        Icons.storefront_outlined,
        color: Colors.indigo,
        size: 30,
      );
    }

    // ----------------------------------------------------------
    // SVG
    // ----------------------------------------------------------

    if (logoPath
        .toLowerCase()
        .endsWith('.svg')) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(13),
        child: SvgPicture.file(
          file,
          width: 58,
          height: 58,
          fit: BoxFit.contain,
          placeholderBuilder:
              (context) {
            return const Icon(
              Icons.storefront_outlined,
              color: Colors.indigo,
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
      borderRadius:
          BorderRadius.circular(13),
      child: Image.file(
        file,
        width: 58,
        height: 58,
        fit: BoxFit.contain,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Icon(
            Icons.storefront_outlined,
            color: Colors.indigo,
            size: 30,
          );
        },
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FA),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 420,
              ),

              child: Card(
                elevation: 0,
                color: Colors.white,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  side: BorderSide(
                    color:
                        Colors.grey.shade200,
                  ),
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    28,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,

                    children: [
                      // ==================================================
                      // BUSINESS LOGO
                      // ==================================================

                      Center(
                        child: Container(
                          width: 70,
                          height: 70,

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .indigo
                                .withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),

                          child:
                              _isBusinessIdentityLoading
                                  ? const Center(
                                      child:
                                          SizedBox(
                                        width: 22,
                                        height: 22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                          color:
                                              Colors.indigo,
                                        ),
                                      ),
                                    )
                                  : _buildBusinessLogo(),
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // ==================================================
                      // BUSINESS NAME
                      // ==================================================

                      Text(
                        _businessName,
                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Colors.black87,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      const Text(
                        "Sign in to continue to your account.",
                        textAlign:
                            TextAlign.center,

                        style:
                            TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // ==================================================
                      // LOGIN ID
                      // ==================================================

                      TextField(
                        controller:
                            _loginIdController,

                        textInputAction:
                            TextInputAction.next,

                        textCapitalization:
                            TextCapitalization
                                .characters,

                        decoration:
                            InputDecoration(
                          labelText:
                              "Login ID",

                          hintText:
                              "e.g. ST001",

                          prefixIcon:
                              const Icon(
                            Icons
                                .badge_outlined,
                          ),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // ==================================================
                      // PASSWORD
                      // ==================================================

                      TextField(
                        controller:
                            _passwordController,

                        obscureText:
                            _obscurePassword,

                        onSubmitted:
                            (_) =>
                                _handleLogin(),

                        decoration:
                            InputDecoration(
                          labelText:
                              "Password",

                          prefixIcon:
                              const Icon(
                            Icons
                                .lock_outline,
                          ),

                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },

                            icon:
                                Icon(
                              _obscurePassword
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // ==================================================
                      // SIGN IN
                      // ==================================================

                      SizedBox(
                        height: 50,

                        child:
                            ElevatedButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : _handleLogin,

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.indigo,

                            foregroundColor:
                                Colors.white,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                          ),

                          child:
                              _isLoading
                                  ? const SizedBox(
                                      width:
                                          22,
                                      height:
                                          22,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                        color:
                                            Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Sign In",
                                      style:
                                          TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                      ),
                                    ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ==================================================
                      // LOGIN INFORMATION
                      // ==================================================

                      const Text(
                        "Your Login ID is assigned by your "
                        "supermarket administrator.",

                        textAlign:
                            TextAlign.center,

                        style:
                            TextStyle(
                          fontSize: 11,
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

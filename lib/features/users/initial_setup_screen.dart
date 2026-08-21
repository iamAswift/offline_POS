import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../database/app_database.dart';
import '../../core/session.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() =>
      _InitialSetupScreenState();
}

class _InitialSetupScreenState
    extends State<InitialSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

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
    final confirmPassword =
        _confirmPasswordController.text;

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
      _showMessage(
        'Please enter a valid email address.',
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please create a password.');
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Password must be at least 6 characters.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Passwords do not match.',
      );
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

      final userCount =
          await userDao.getUserCount();

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

      final userId =
          await userDao.createInitialOwner(
        name: name,
        email: email,
        password: password,
      );

      // --------------------------------------------------------
      // LOAD CREATED USER
      // --------------------------------------------------------

      final owner =
          await userDao.getUserById(userId);

      if (owner == null) {
        throw Exception(
          'Owner account was created but could not be loaded.',
        );
      }

      // --------------------------------------------------------
      // SAVE SESSION
      //
      // We are still using the existing Session API for now.
      // We will upgrade Session to userId/loginId in the
      // next step.
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

      _showMessage(
        'Owner account created successfully.',
      );

      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'Initial owner creation error: $e',
      );

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
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
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
                maxWidth: 460,
              ),

              child: Card(
                elevation: 0,
                color: Colors.white,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),

                  side: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(30),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,

                    children: [
                      // ------------------------------------------------
                      // ICON
                      // ------------------------------------------------

                      Center(
                        child: Container(
                          width: 64,
                          height: 64,

                          decoration:
                              BoxDecoration(
                            color: Colors.indigo
                                .withValues(
                              alpha: 0.10,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              17,
                            ),
                          ),

                          child: const Icon(
                            Icons
                                .admin_panel_settings_outlined,
                            color:
                                Colors.indigo,
                            size: 34,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ------------------------------------------------
                      // TITLE
                      // ------------------------------------------------

                      const Text(
                        'Set Up Your Supermarket',
                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Create the first owner account '
                        'to get started.',

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 26),

                      // ------------------------------------------------
                      // INFORMATION CARD
                      // ------------------------------------------------

                      Container(
                        padding:
                            const EdgeInsets.all(14),

                        decoration:
                            BoxDecoration(
                          color: Colors.indigo
                              .withValues(
                            alpha: 0.06,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),

                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            const Icon(
                              Icons.info_outline,
                              color:
                                  Colors.indigo,
                              size: 20,
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: Text(
                                'You will be the owner of '
                                'this supermarket system. '
                                'Your Login ID will be '
                                'automatically assigned.',
                                style:
                                    TextStyle(
                                  fontSize: 12,
                                  color: Colors
                                      .indigo
                                      .shade900,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ------------------------------------------------
                      // NAME
                      // ------------------------------------------------

                      TextField(
                        controller:
                            _nameController,

                        textInputAction:
                            TextInputAction.next,

                        textCapitalization:
                            TextCapitalization.words,

                        decoration:
                            InputDecoration(
                          labelText:
                              'Owner Name',

                          hintText:
                              'e.g. Austine Okoh',

                          prefixIcon:
                              const Icon(
                            Icons
                                .person_outline,
                          ),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // EMAIL
                      // ------------------------------------------------

                      TextField(
                        controller:
                            _emailController,

                        keyboardType:
                            TextInputType
                                .emailAddress,

                        textInputAction:
                            TextInputAction.next,

                        decoration:
                            InputDecoration(
                          labelText:
                              'Email Address',

                          hintText:
                              'owner@example.com',

                          prefixIcon:
                              const Icon(
                            Icons
                                .email_outlined,
                          ),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // PASSWORD
                      // ------------------------------------------------

                      TextField(
                        controller:
                            _passwordController,

                        obscureText:
                            _obscurePassword,

                        textInputAction:
                            TextInputAction.next,

                        decoration:
                            InputDecoration(
                          labelText:
                              'Password',

                          prefixIcon:
                              const Icon(
                            Icons.lock_outline,
                          ),

                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },

                            icon: Icon(
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
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // CONFIRM PASSWORD
                      // ------------------------------------------------

                      TextField(
                        controller:
                            _confirmPasswordController,

                        obscureText:
                            _obscureConfirmPassword,

                        onSubmitted: (_) =>
                            _createOwner(),

                        decoration:
                            InputDecoration(
                          labelText:
                              'Confirm Password',

                          prefixIcon:
                              const Icon(
                            Icons
                                .lock_reset_outlined,
                          ),

                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },

                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ------------------------------------------------
                      // LOGIN ID PREVIEW
                      // ------------------------------------------------

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.grey.shade100,

                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.badge_outlined,
                              size: 20,
                              color:
                                  Colors.grey,
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            const Expanded(
                              child: Text(
                                'Your Login ID',
                                style:
                                    TextStyle(
                                  fontSize: 12,
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),

                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.indigo
                                        .withValues(
                                  alpha: 0.10,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  8,
                                ),
                              ),

                              child: const Text(
                                'OWN001',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.indigo,
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ------------------------------------------------
                      // CREATE BUTTON
                      // ------------------------------------------------

                      SizedBox(
                        height: 50,

                        child:
                            ElevatedButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : _createOwner,

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.indigo,

                            foregroundColor:
                                Colors.white,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),

                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,

                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Create Owner Account',
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'This setup screen is only available '
                        'when no user account exists.',
                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
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
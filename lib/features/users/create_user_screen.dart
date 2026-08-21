// lib/features/users/create_user_screen.dart

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/session.dart';
import '../../database/app_database.dart';
import '../../database/tables/user_table.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() =>
      _CreateUserScreenState();
}

class _CreateUserScreenState
    extends State<CreateUserScreen> {
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
      _showMessage(
        'Password must contain at least 4 characters.',
      );
      return;
    }

    // ----------------------------------------------------------
    // PERMISSION CHECK
    // ----------------------------------------------------------

    if (!Session.isOwnerOrManager) {
      _showMessage(
        'Only an owner or manager can create users.',
      );
      return;
    }

    // Managers can create staff but not other managers.
    if (Session.isManager &&
        _selectedRole == 'manager') {
      _showMessage(
        'Managers can only create staff accounts.',
      );
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

      final existing =
          await userDao.getUserByEmail(email);

      if (existing != null) {
        _showMessage(
          'An account already exists with this email.',
        );
        return;
      }

      // --------------------------------------------------------
      // CREATE ACCOUNT
      // --------------------------------------------------------

      String loginId;

      if (_selectedRole == 'manager') {
        loginId =
            await userDao.generateManagerLoginId();
      } else {
        loginId =
            await userDao.generateStaffLoginId();
      }

      final userId = await userDao.insertUser(
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

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                SizedBox(width: 10),
                Text('Account Created'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '$name has been added successfully.',
                ),
                const SizedBox(height: 20),
                const Text(
                  'Login ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  loginId,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Temporary Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  password,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to create account. Please try again.',
      );

      debugPrint(
        'Create user error: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
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
    final isManager = Session.isManager;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Employee',
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),

            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(24),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                  children: [
                    const Text(
                      'Employee Account',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Create a controlled login account '
                      'for a supermarket employee.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 28),

                    TextField(
                      controller:
                          _nameController,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Full Name',
                        prefixIcon:
                            Icon(
                          Icons.person_outline,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller:
                          _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Email Address',
                        prefixIcon:
                            Icon(
                          Icons.email_outlined,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<
                        String>(
                      initialValue:
                          _selectedRole,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Employee Role',
                        prefixIcon:
                            Icon(
                          Icons.badge_outlined,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),

                      items: [
                        const DropdownMenuItem(
                          value: 'staff',
                          child:
                              Text('Staff'),
                        ),

                        if (!isManager)
                          const DropdownMenuItem(
                            value: 'manager',
                            child: Text(
                              'Manager',
                            ),
                          ),
                      ],

                      onChanged:
                          (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedRole =
                              value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller:
                          _passwordController,
                      obscureText:
                          _obscurePassword,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Temporary Password',
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
                            const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'The employee will use this password '
                      'with their assigned Login ID.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 50,
                      child:
                          ElevatedButton(
                        onPressed:
                            _isSaving
                                ? null
                                : _createUser,

                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Text(
                                'Create Employee',
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

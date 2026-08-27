// lib/features/users/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;

import '../../database/app_database.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // ============================================================
  // PROFILE CONTROLLERS
  // ============================================================

  final _ninController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guarantorNameController = TextEditingController();
  final _guarantorPhoneController = TextEditingController();
  final _salaryController = TextEditingController();
  final _amountOwedController = TextEditingController();

  // ============================================================
  // PASSWORD
  // ============================================================

  final _newPasswordController = TextEditingController();

  // ============================================================
  // USER ACCOUNT
  // ============================================================

  User? _user;

  bool _isChangingPassword = false;
  bool _newPasswordObscured = true;
  bool _isSavingProfile = false;

  // ============================================================
  // PERMISSIONS
  // ============================================================

  bool _canReceiveStock = false;
  bool _canCountStock = false;

  // ============================================================
  // LOAD USER ACCOUNT
  // ============================================================

  Future<void> _loadUser() async {
    try {
      final userDao = getUserDao();

      final user = await userDao.getUserById(widget.userId);

      if (!mounted) return;

      setState(() {
        _user = user;
      });
    } catch (e) {
      debugPrint('Error loading user account: $e');
    }
  }

  // ============================================================
  // LOAD EMPLOYEE PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final profileDao = getUserProfileDao();

      final profile = await profileDao.getProfileByUserId(widget.userId);

      if (!mounted) return;

      if (profile != null) {
        _ninController.text = profile.nin ?? '';
        _phoneController.text = profile.phone ?? '';
        _guarantorNameController.text = profile.guarantorName ?? '';
        _guarantorPhoneController.text = profile.guarantorPhone ?? '';
        _salaryController.text = profile.salary.toString();
        _amountOwedController.text = profile.amountOwed.toString();

        _canReceiveStock = profile.canReceiveStock;
        _canCountStock = profile.canCountStock;
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error loading employee profile: $e');
    }
  }

  // ============================================================
  // SAVE EMPLOYEE PROFILE
  // ============================================================

  Future<void> _saveProfile() async {
    if (_isSavingProfile) return;

    setState(() {
      _isSavingProfile = true;
    });

    try {
      final profileDao = getUserProfileDao();

      await profileDao.upsertProfile(
        UserProfilesCompanion.insert(
          userId: widget.userId,

          nin: Value(_ninController.text.trim()),

          phone: Value(_phoneController.text.trim()),

          guarantorName: Value(_guarantorNameController.text.trim()),

          guarantorPhone: Value(_guarantorPhoneController.text.trim()),

          salary: Value(double.tryParse(_salaryController.text.trim()) ?? 0.0),

          amountOwed: Value(
            double.tryParse(_amountOwedController.text.trim()) ?? 0.0,
          ),

          canReceiveStock: Value(_canReceiveStock),

          canCountStock: Value(_canCountStock),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee profile saved successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error saving employee profile: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save employee profile.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingProfile = false;
        });
      }
    }
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _changePassword() async {
    final password = _newPasswordController.text.trim();

    if (password.isEmpty) {
      _showMessage('Please enter a new password.');
      return;
    }

    if (password.length < 4) {
      _showMessage('Password must contain at least 4 characters.');
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      final userDao = getUserDao();

      await userDao.updatePassword(widget.userId, password);

      _newPasswordController.clear();

      if (!mounted) return;

      _showMessage('Password changed successfully.');
    } catch (e) {
      debugPrint('Password change error: $e');

      if (!mounted) return;

      _showMessage('Unable to change password.');
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  // ============================================================
  // ACCOUNT STATUS
  // ============================================================

  Future<void> _changeAccountStatus(bool value) async {
    if (_user == null) return;

    try {
      final userDao = getUserDao();

      await userDao.setUserActive(widget.userId, value);

      await _loadUser();

      if (!mounted) return;

      _showMessage(
        value ? 'Employee account activated.' : 'Employee account deactivated.',
      );
    } catch (e) {
      debugPrint('Account status error: $e');

      if (!mounted) return;

      _showMessage('Unable to update account status.');
    }
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
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadUser();
    _loadProfile();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _ninController.dispose();
    _phoneController.dispose();
    _guarantorNameController.dispose();
    _guarantorPhoneController.dispose();
    _salaryController.dispose();
    _amountOwedController.dispose();
    _newPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        title: const Text(
          'Employee Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // EMPLOYEE HEADER
                // ==================================================
                if (_user != null) _buildEmployeeHeader(theme),

                if (_user != null) const SizedBox(height: 20),

                // ==================================================
                // ACCOUNT INFORMATION
                // ==================================================
                if (_user != null) _buildAccountInformation(),

                if (_user != null) const SizedBox(height: 20),

                // ==================================================
                // PASSWORD MANAGEMENT
                // ==================================================
                _buildPasswordManagement(),

                const SizedBox(height: 20),

                // ==================================================
                // PERSONAL INFORMATION
                // ==================================================
                _buildSectionCard(
                  title: 'Personal Information',
                  icon: Icons.person_outline,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _ninController,
                        label: 'NIN',
                        icon: Icons.badge_outlined,
                      ),

                      const SizedBox(height: 14),

                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 14),

                      _buildTextField(
                        controller: _guarantorNameController,
                        label: 'Guarantor Name',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 14),

                      _buildTextField(
                        controller: _guarantorPhoneController,
                        label: 'Guarantor Phone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // EMPLOYMENT INFORMATION
                // ==================================================
                _buildSectionCard(
                  title: 'Employment Information',
                  icon: Icons.work_outline,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _salaryController,
                        label: 'Salary',
                        icon: Icons.payments_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _buildTextField(
                        controller: _amountOwedController,
                        label: 'Current Amount Owed',
                        icon: Icons.account_balance_wallet_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PERMISSIONS
                // ==================================================
                _buildSectionCard(
                  title: 'Permissions',
                  icon: Icons.security_outlined,
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,

                        title: const Text(
                          'Receive Stock',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: const Text(
                          'Allow this employee to receive stock.',
                        ),

                        value: _canReceiveStock,

                        onChanged: (value) {
                          setState(() {
                            _canReceiveStock = value;
                          });
                        },
                      ),

                      const Divider(),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,

                        title: const Text(
                          'Count Stock',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: const Text(
                          'Allow this employee to perform stock counts.',
                        ),

                        value: _canCountStock,

                        onChanged: (value) {
                          setState(() {
                            _canCountStock = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // SAVE BUTTON
                // ==================================================
                SizedBox(
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: _isSavingProfile ? null : _saveProfile,

                    icon: _isSavingProfile
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),

                    label: Text(
                      _isSavingProfile ? 'Saving...' : 'Save Employee Profile',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPLOYEE HEADER
  // ============================================================

  Widget _buildEmployeeHeader(ThemeData theme) {
    final user = _user!;

    final role = user.role.trim().toLowerCase();

    Color roleColor;

    switch (role) {
      case 'owner':
        roleColor = Colors.deepPurple;
        break;

      case 'manager':
        roleColor = Colors.blue;
        break;

      default:
        roleColor = Colors.green;
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),

        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: roleColor.withValues(alpha: 0.10),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: user.isActive ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    user.loginId ?? 'No Login ID',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildBadge(label: role.toUpperCase(), color: roleColor),

                      _buildBadge(
                        label: user.isActive ? 'ACTIVE' : 'INACTIVE',
                        color: user.isActive ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACCOUNT INFORMATION
  // ============================================================

  Widget _buildAccountInformation() {
    final user = _user!;

    return _buildSectionCard(
      title: 'Account Information',
      icon: Icons.manage_accounts_outlined,
      child: Column(
        children: [
          _buildInfoRow('Full Name', user.name, Icons.person_outline),

          const Divider(height: 24),

          _buildInfoRow(
            'Login ID',
            user.loginId ?? 'Not assigned',
            Icons.badge_outlined,
          ),

          const Divider(height: 24),

          _buildInfoRow('Email', user.email, Icons.email_outlined),

          const Divider(height: 24),

          _buildInfoRow(
            'Role',
            user.role.toUpperCase(),
            Icons.admin_panel_settings_outlined,
          ),

          const SizedBox(height: 12),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,

            title: const Text(
              'Account Active',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),

            subtitle: Text(
              user.isActive
                  ? 'Employee can log in to the system.'
                  : 'Employee cannot log in to the system.',
            ),

            value: user.isActive,

            onChanged: _changeAccountStatus,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PASSWORD MANAGEMENT
  // ============================================================

  Widget _buildPasswordManagement() {
    return _buildSectionCard(
      title: 'Password Management',
      icon: Icons.lock_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Set a new password for this employee.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _newPasswordController,
            obscureText: _newPasswordObscured,

            decoration: InputDecoration(
              labelText: 'New Password',

              prefixIcon: const Icon(Icons.lock_outline),

              suffixIcon: IconButton(
                icon: Icon(
                  _newPasswordObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),

                onPressed: () {
                  setState(() {
                    _newPasswordObscured = !_newPasswordObscured;
                  });
                },
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 48,

            child: ElevatedButton.icon(
              onPressed: _isChangingPassword ? null : _changePassword,

              icon: _isChangingPassword
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.key_outlined),

              label: Text(
                _isChangingPassword
                    ? 'Changing Password...'
                    : 'Change Password',
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,

                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Icon(icon, color: Colors.indigo, size: 20),
                ),

                const SizedBox(width: 12),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            child,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 19, color: Colors.grey.shade600),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ============================================================
  // BADGE
  // ============================================================

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

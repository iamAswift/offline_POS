// lib/features/users/user_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../core/session.dart';
import '../../database/app_database.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> _usersFuture;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // ============================================================
  // LOAD USERS
  // ============================================================

  void _loadUsers() {
    _usersFuture = getUserDao().getAllUsers();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshUsers() async {
    setState(() {
      _loadUsers();
    });

    await _usersFuture;
  }

  // ============================================================
  // ADD EMPLOYEE
  // ============================================================

  Future<void> _openCreateUser() async {
    await context.push('/users/create');

    if (!mounted) return;

    setState(() {
      _loadUsers();
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final canManageUsers = Session.isOwnerOrManager;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Users & Employees'),
        actions: [if (canManageUsers) _buildAddEmployeeButton(responsive)],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState();
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _refreshUsers,
                  child: _buildUserContent(users, responsive, constraints),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // ADD EMPLOYEE BUTTON
  // ============================================================

  Widget _buildAddEmployeeButton(Responsive responsive) {
    if (responsive.isCompact) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: IconButton(
          tooltip: 'Add Employee',
          onPressed: _openCreateUser,
          icon: const Icon(Icons.person_add_outlined),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: ElevatedButton.icon(
        onPressed: _openCreateUser,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Employee'),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildUserContent(
    List<User> users,
    Responsive responsive,
    BoxConstraints constraints,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.horizontalPadding,
        vertical: responsive.verticalPadding,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.contentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(users, responsive),

                SizedBox(
                  height: responsive.isCompact ? AppSpacing.lg : AppSpacing.xl,
                ),

                _buildEmployeeCard(users, responsive),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(List<User> users, Responsive responsive) {
    final owners = users
        .where((u) => u.role.trim().toLowerCase() == 'owner')
        .length;

    final managers = users
        .where((u) => u.role.trim().toLowerCase() == 'manager')
        .length;

    final staff = users
        .where((u) => u.role.trim().toLowerCase() == 'staff')
        .length;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          responsive.isCompact ? AppSpacing.lg : AppSpacing.xl,
        ),
        child: Wrap(
          spacing: responsive.isCompact ? AppSpacing.lg : AppSpacing.xxxl,
          runSpacing: AppSpacing.lg,
          children: [
            _summaryItem(
              label: 'Total Users',
              value: users.length.toString(),
              icon: Icons.people_outline,
              iconColor: AppColors.primary,
              responsive: responsive,
            ),
            _summaryItem(
              label: 'Owners',
              value: owners.toString(),
              icon: Icons.admin_panel_settings_outlined,
              iconColor: Colors.deepPurple,
              responsive: responsive,
            ),
            _summaryItem(
              label: 'Managers',
              value: managers.toString(),
              icon: Icons.manage_accounts_outlined,
              iconColor: AppColors.info,
              responsive: responsive,
            ),
            _summaryItem(
              label: 'Staff',
              value: staff.toString(),
              icon: Icons.badge_outlined,
              iconColor: AppColors.success,
              responsive: responsive,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _summaryItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Responsive responsive,
  }) {
    final width = responsive.isCompact ? 140.0 : 150.0;

    return SizedBox(
      width: width,
      child: Row(
        children: [
          Container(
            width: responsive.isCompact ? 42 : 46,
            height: responsive.isCompact ? 42 : 46,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: responsive.isCompact ? 22 : 24,
              color: iconColor,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: responsive.isCompact ? 19 : 21,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPLOYEE CARD
  // ============================================================

  Widget _buildEmployeeCard(List<User> users, Responsive responsive) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildEmployeeHeader(responsive),

          const Divider(height: 1, color: AppColors.divider),

          ...users.asMap().entries.map((entry) {
            final user = entry.value;

            return _buildUserTile(
              context,
              user,
              entry.key == users.length - 1,
              responsive,
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // EMPLOYEE HEADER
  // ============================================================

  Widget _buildEmployeeHeader(Responsive responsive) {
    return Padding(
      padding: EdgeInsets.all(
        responsive.isCompact ? AppSpacing.lg : AppSpacing.xl,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.people_alt_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee Accounts',
                  style: AppTextStyles.title.copyWith(
                    fontSize: responsive.isCompact ? 16 : 18,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  'Manage supermarket user accounts.',
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // USER TILE
  // ============================================================

  Widget _buildUserTile(
    BuildContext context,
    User user,
    bool isLast,
    Responsive responsive,
  ) {
    final role = user.role.trim().toLowerCase();

    final roleColor = _roleColor(role);
    final roleIcon = _roleIcon(role);
    final isActive = user.isActive;

    if (responsive.isCompact) {
      return _buildCompactUserTile(
        context,
        user,
        isLast,
        role,
        roleColor,
        roleIcon,
        isActive,
      );
    }

    return _buildWideUserTile(
      context,
      user,
      isLast,
      role,
      roleColor,
      roleIcon,
      isActive,
    );
  }

  // ============================================================
  // WIDE USER TILE
  // ============================================================

  Widget _buildWideUserTile(
    BuildContext context,
    User user,
    bool isLast,
    String role,
    Color roleColor,
    IconData roleIcon,
    bool isActive,
  ) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          leading: _buildAvatar(user, roleColor, isActive),
          title: Text(
            user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title.copyWith(fontSize: 15),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: _buildUserDetails(user),
          ),
          trailing: _buildUserStatusSection(
            role,
            roleColor,
            roleIcon,
            isActive,
          ),
          onTap: () => _openUserProfile(context, user),
        ),

        if (!isLast)
          const Divider(
            height: 1,
            indent: AppSpacing.xl,
            endIndent: AppSpacing.xl,
            color: AppColors.divider,
          ),
      ],
    );
  }

  // ============================================================
  // COMPACT USER TILE
  // ============================================================

  Widget _buildCompactUserTile(
    BuildContext context,
    User user,
    bool isLast,
    String role,
    Color roleColor,
    IconData roleIcon,
    bool isActive,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () => _openUserProfile(context, user),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(user, roleColor, isActive),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(fontSize: 15),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      _buildUserDetails(user),

                      const SizedBox(height: AppSpacing.sm),

                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _buildRoleBadge(role, roleColor, roleIcon),
                          _buildStatusBadge(isActive),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.xs),

                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),

        if (!isLast)
          const Divider(
            height: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
            color: AppColors.divider,
          ),
      ],
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildAvatar(User user, Color roleColor, bool isActive) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: roleColor.withValues(alpha: 0.10),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: roleColor,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),

        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.textMuted,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // USER DETAILS
  // ============================================================

  Widget _buildUserDetails(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.badge_outlined,
              size: 14,
              color: AppColors.textMuted,
            ),

            const SizedBox(width: AppSpacing.xs),

            Flexible(
              child: Text(
                user.loginId ?? 'No Login ID',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.small.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          user.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.small,
        ),
      ],
    );
  }

  // ============================================================
  // USER STATUS SECTION
  // ============================================================

  Widget _buildUserStatusSection(
    String role,
    Color roleColor,
    IconData roleIcon,
    bool isActive,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRoleBadge(role, roleColor, roleIcon),

        const SizedBox(width: AppSpacing.md),

        _buildStatusBadge(isActive),
      ],
    );
  }

  // ============================================================
  // ROLE BADGE
  // ============================================================

  Widget _buildRoleBadge(String role, Color roleColor, IconData roleIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(roleIcon, size: 14, color: roleColor),

          const SizedBox(width: AppSpacing.xs),

          Text(
            role.toUpperCase(),
            style: TextStyle(
              color: roleColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(bool isActive) {
    final color = isActive ? AppColors.success : AppColors.textMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: AppSpacing.xs),

        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ROLE COLOR
  // ============================================================

  Color _roleColor(String role) {
    switch (role) {
      case 'owner':
        return Colors.deepPurple;

      case 'manager':
        return AppColors.info;

      default:
        return AppColors.success;
    }
  }

  // ============================================================
  // ROLE ICON
  // ============================================================

  IconData _roleIcon(String role) {
    switch (role) {
      case 'owner':
        return Icons.admin_panel_settings;

      case 'manager':
        return Icons.manage_accounts;

      default:
        return Icons.badge;
    }
  }

  // ============================================================
  // OPEN PROFILE
  // ============================================================

  void _openUserProfile(BuildContext context, User user) {
    context.push('/userProfile', extra: user.id);
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Icon(Icons.people_outline, size: 64, color: AppColors.textMuted),
          SizedBox(height: AppSpacing.lg),
          Center(child: Text('No users found', style: AppTextStyles.title)),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),

            const SizedBox(height: AppSpacing.md),

            const Text('Unable to load users.', style: AppTextStyles.title),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'Please try again.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),

            const SizedBox(height: AppSpacing.lg),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadUsers();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

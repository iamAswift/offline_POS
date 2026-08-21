// lib/features/users/user_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/session.dart';
import '../../database/app_database.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() =>
      _UserListScreenState();
}

class _UserListScreenState
    extends State<UserListScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    _usersFuture =
        getUserDao().getAllUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _loadUsers();
    });

    await _usersFuture;
  }

  @override
  Widget build(BuildContext context) {
    final canManageUsers =
        Session.isOwnerOrManager;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Users & Employees',
        ),

        actions: [
          if (canManageUsers)
            Padding(
              padding:
                  const EdgeInsets.only(
                right: 16,
              ),

              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.push(
                    '/users/create',
                  );

                  if (mounted) {
                    _loadUsers();
                    setState(() {});
                  }
                },

                icon: const Icon(
                  Icons.person_add_outlined,
                ),

                label: const Text(
                  'Add Employee',
                ),
              ),
            ),
        ],
      ),

      body: FutureBuilder<List<User>>(
        future: _usersFuture,

        builder:
            (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    const Text(
                      'Unable to load users.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      '${snapshot.error}',
                      textAlign:
                          TextAlign.center,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    ElevatedButton(
                      onPressed: () {
                        setState(
                          _loadUsers,
                        );
                      },
                      child:
                          const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final users =
              snapshot.data ?? [];

          if (users.isEmpty) {
            return RefreshIndicator(
              onRefresh:
                  _refreshUsers,

              child:
                  ListView(
                children: const [
                  SizedBox(
                    height: 180,
                  ),

                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  Center(
                    child: Text(
                      'No users found',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh:
                _refreshUsers,

            child: ListView(
              padding:
                  const EdgeInsets.all(
                20,
              ),

              children: [
                // ------------------------------------------------
                // SUMMARY
                // ------------------------------------------------

                _buildSummaryCard(
                  users,
                ),

                const SizedBox(
                  height: 20,
                ),

                // ------------------------------------------------
                // USER LIST
                // ------------------------------------------------

                Card(
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      16,
                    ),
                    side:
                        BorderSide(
                      color: Colors
                          .grey
                          .shade200,
                    ),
                  ),

                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets
                                .all(
                          20,
                        ),

                        child:
                            Row(
                          children: const [
                            Icon(
                              Icons
                                  .people_alt_outlined,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Employee Accounts',
                              style:
                                  TextStyle(
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(
                        height: 1,
                      ),

                      ...users
                          .asMap()
                          .entries
                          .map(
                            (entry) {
                              final user =
                                  entry
                                      .value;

                              return _buildUserTile(
                                context,
                                user,
                                entry.key ==
                                    users.length -
                                        1,
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(
    List<User> users,
  ) {
    final owners =
        users
            .where(
              (u) =>
                  u.role
                      .toLowerCase() ==
                  'owner',
            )
            .length;

    final managers =
        users
            .where(
              (u) =>
                  u.role
                      .toLowerCase() ==
                  'manager',
            )
            .length;

    final staff =
        users
            .where(
              (u) =>
                  u.role
                      .toLowerCase() ==
                  'staff',
            )
            .length;

    return Card(
      elevation: 0,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        side:
            BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Wrap(
          spacing: 32,
          runSpacing: 20,

          children: [
            _summaryItem(
              'Total Users',
              users.length
                  .toString(),
              Icons.people_outline,
            ),

            _summaryItem(
              'Owners',
              owners.toString(),
              Icons.admin_panel_settings_outlined,
            ),

            _summaryItem(
              'Managers',
              managers.toString(),
              Icons.manage_accounts_outlined,
            ),

            _summaryItem(
              'Staff',
              staff.toString(),
              Icons.badge_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(
    String label,
    String value,
    IconData icon,
  ) {
    return SizedBox(
      width: 130,

      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: Colors.indigo,
          ),

          const SizedBox(
            width: 10,
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style:
                    const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              Text(
                label,
                style:
                    const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
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
  ) {
    final role = user.role.trim().toLowerCase();

    Color roleColor;
    IconData roleIcon;

    switch (role) {
      case 'owner':
        roleColor = Colors.deepPurple;
        roleIcon = Icons.admin_panel_settings;
        break;

      case 'manager':
        roleColor = Colors.blue;
        roleIcon = Icons.manage_accounts;
        break;

      default:
        roleColor = Colors.green;
        roleIcon = Icons.badge;
    }

    final isActive = user.isActive;

    return Column(
      children: [
        ListTile(
          isThreeLine: true,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),

          // ======================================================
          // AVATAR
          // ======================================================

          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor:
                    roleColor.withValues(alpha: 0.10),
                child: Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),

              // Active indicator
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green
                        : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ======================================================
          // EMPLOYEE NAME
          // ======================================================

          title: Text(
            user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),

          // ======================================================
          // LOGIN ID + EMAIL
          // ======================================================

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        user.loginId ?? 'No Login ID',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // ROLE + STATUS
          // ======================================================

          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Role badge
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      roleColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      roleIcon,
                      size: 14,
                      color: roleColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      role.toUpperCase(),
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isActive
                        ? 'Active'
                        : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                      color: isActive
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ======================================================
          // OPEN EMPLOYEE PROFILE
          // ======================================================

          onTap: () {
            context.push(
              '/userProfile',
              extra: user.id,
            );
          },
        ),

        if (!isLast)
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}


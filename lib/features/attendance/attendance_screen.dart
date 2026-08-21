// lib/features/attendance/attendance_screen.dart

import 'package:flutter/material.dart';

import '../../database/app_database.dart';
import 'attendance_history_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState
    extends State<AttendanceScreen> {
  // ============================================================
  // STATE
  // ============================================================

  List<User> _users = [];

  User? _selectedUser;

  AttendanceData?
      _selectedUserOpenAttendance;

  List<AttendanceData>
      _selectedUserTodayAttendance = [];

  bool _isLoading = true;
  bool _isProcessing = false;

  String? _errorMessage;

  String _searchQuery = '';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadAttendance();
  }

  // ============================================================
  // LOAD ATTENDANCE
  // ============================================================

  Future<void> _loadAttendance() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userDao =
          getUserDao();

      final users =
          await userDao.getAllUsers();

      if (!mounted) return;

      setState(() {
        _users = users
            .where(
              (user) =>
                  user.isActive,
            )
            .toList();

        _isLoading = false;
      });

      if (_selectedUser != null) {
        final stillExists =
            _users.any(
          (user) =>
              user.id ==
              _selectedUser!.id,
        );

        if (stillExists) {
          final refreshedUser =
              _users.firstWhere(
            (user) =>
                user.id ==
                _selectedUser!.id,
          );

          await _selectUser(
            refreshedUser,
            showLoading: false,
          );
        } else {
          setState(() {
            _selectedUser = null;
            _selectedUserOpenAttendance =
                null;
            _selectedUserTodayAttendance =
                [];
          });
        }
      }
    } catch (e) {
      debugPrint(
        'Attendance loading error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load staff attendance.';
      });
    }
  }

  // ============================================================
  // SELECT EMPLOYEE
  // ============================================================

  Future<void> _selectUser(
    User user, {
    bool showLoading = true,
  }) async {
    if (showLoading) {
      setState(() {
        _selectedUser = user;
        _selectedUserOpenAttendance =
            null;
        _selectedUserTodayAttendance =
            [];
        _isProcessing = true;
      });
    }

    try {
      final attendanceDao =
          getAttendanceDao();

      final results =
          await Future.wait([
        attendanceDao
            .getOpenAttendance(
          user.id,
        ),
        attendanceDao
            .getTodayAttendance(
          user.id,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _selectedUser = user;

        _selectedUserOpenAttendance =
            results[0]
                as AttendanceData?;

        _selectedUserTodayAttendance =
            results[1]
                as List<AttendanceData>;

        _isProcessing = false;
      });
    } catch (e) {
      debugPrint(
        'Employee attendance loading error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _errorMessage =
            'Unable to load employee attendance.';
      });
    }
  }

  // ============================================================
  // CLOCK IN / OUT
  // ============================================================

  Future<void>
      _handleAttendanceAction() async {
    final user =
        _selectedUser;

    if (user == null) {
      _showMessage(
        'Select an employee first.',
        isError: true,
      );
      return;
    }

    if (_isProcessing) {
      return;
    }

    final isCurrentlyWorking =
        _selectedUserOpenAttendance !=
            null;

    final password =
        await _showPasswordDialog(
      user,
    );

    if (password == null ||
        !mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final userDao =
          getUserDao();

      // ========================================================
      // VERIFY EMPLOYEE PASSWORD
      // ========================================================

      // IMPORTANT:
      // verifyUserPassword() does not accept
      // "userId:" as a named argument in
      // the current DAO.

      final loginId = user.loginId; 
      
      if (loginId == null || loginId.trim().isEmpty) { 
        _showMessage( 
          'This employee does not have a valid login ID.', 
          isError: true, 
        ); 
        return; 
      }
      final verifiedUser =
          await userDao.verifyUserPassword(
        loginId: user.loginId ?? '',
        password: password,
      );

      if (!mounted) return;

      if (verifiedUser == null) {
        _showMessage(
          'Incorrect password. '
          'Attendance was not changed.',
          isError: true,
        );

        return;
      }

      // ========================================================
      // CLOCK OUT
      // ========================================================

      if (isCurrentlyWorking) {
        final attendanceDao =
            getAttendanceDao();

        final success =
            await attendanceDao.clockOut(
          user.id,
        );

        if (!mounted) return;

        if (!success) {
          _showMessage(
            'This employee is not currently clocked in.',
            isError: true,
          );

          return;
        }

        await _refreshSelectedEmployee();

        if (!mounted) return;

        _showMessage(
          '${user.name} clocked out successfully.',
        );

        return;
      }

      // ========================================================
      // CLOCK IN
      // ========================================================

      final attendanceDao =
          getAttendanceDao();

      await attendanceDao.clockIn(
        user.id,
      );

      if (!mounted) return;

      await _refreshSelectedEmployee();

      if (!mounted) return;

      _showMessage(
        '${user.name} clocked in successfully.',
      );
    } catch (e) {
      debugPrint(
        'Attendance action error: $e',
      );

      if (!mounted) return;

      final message =
          e.toString().toLowerCase();

      if (message.contains(
        'already clocked in',
      )) {
        _showMessage(
          '${user.name} is already clocked in.',
          isError: true,
        );
      } else {
        _showMessage(
          'Unable to update attendance. '
          'Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ============================================================
  // REFRESH SELECTED EMPLOYEE
  // ============================================================

  Future<void>
      _refreshSelectedEmployee() async {
    final user =
        _selectedUser;

    if (user == null) {
      return;
    }

    final attendanceDao =
        getAttendanceDao();

    final results =
        await Future.wait([
      attendanceDao
          .getOpenAttendance(
        user.id,
      ),
      attendanceDao
          .getTodayAttendance(
        user.id,
      ),
    ]);

    if (!mounted) return;

    setState(() {
      _selectedUserOpenAttendance =
          results[0]
              as AttendanceData?;

      _selectedUserTodayAttendance =
          results[1]
              as List<AttendanceData>;
    });
  }

  // ============================================================
  // PASSWORD DIALOG
  // ============================================================

  Future<String?>
      _showPasswordDialog(
    User user,
  ) async {
    final controller =
        TextEditingController();

    bool obscurePassword = true;

    final result =
        await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title:
                  const Text(
                'Verify Employee',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              content:
                  Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .all(12),
                    decoration:
                        BoxDecoration(
                      color: Colors
                          .indigo
                          .withValues(
                        alpha: 0.06,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              Colors
                                  .indigo
                                  .withValues(
                            alpha: 0.10,
                          ),
                          child: Text(
                            user.name
                                    .isNotEmpty
                                ? user
                                    .name[0]
                                    .toUpperCase()
                                : '?',
                            style:
                                const TextStyle(
                              color: Colors
                                  .indigo,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                user.name,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),

                              const SizedBox(
                                height: 2,
                              ),

                              Text(
                                user.loginId ??
                                    'No Login ID',
                                style:
                                    TextStyle(
                                  fontSize:
                                      11,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  const Text(
                    'Enter this employee\'s password '
                    'to continue.',
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  TextField(
                    controller:
                        controller,
                    obscureText:
                        obscurePassword,
                    autofocus: true,
                    decoration:
                        InputDecoration(
                      labelText:
                          'Password',
                      prefixIcon:
                          const Icon(
                        Icons
                            .lock_outline,
                      ),
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setDialogState(
                            () {
                              obscurePassword =
                                  !obscurePassword;
                            },
                          );
                        },
                        icon: Icon(
                          obscurePassword
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
                          10,
                        ),
                      ),
                    ),
                    onSubmitted: (_) {
                      final password =
                          controller
                              .text
                              .trim();

                      if (password
                          .isEmpty) {
                        return;
                      }

                      Navigator.of(
                        dialogContext,
                      ).pop(password);
                    },
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Only ${user.name} can authorize '
                    'this attendance action.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors
                          .grey
                          .shade600,
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    final password =
                        controller
                            .text
                            .trim();

                    if (password
                        .isEmpty) {
                      return;
                    }

                    Navigator.of(
                      dialogContext,
                    ).pop(password);
                  },
                  child:
                      const Text(
                    'Verify',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    return result;
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<User>
      get _filteredUsers {
    final query =
        _searchQuery
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      return _users;
    }

    return _users.where(
      (user) {
        final name =
            user.name
                .toLowerCase();

        final loginId =
            (user.loginId ?? '')
                .toLowerCase();

        final role =
            user.role
                .toLowerCase();

        return name.contains(
              query,
            ) ||
            loginId.contains(
              query,
            ) ||
            role.contains(
              query,
            );
      },
    ).toList();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        backgroundColor: isError
            ? Colors.red.shade700
            : Colors.green.shade700,
      ),
    );
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(
    DateTime time,
  ) {
    final hour =
        time.hour == 0
            ? 12
            : time.hour > 12
                ? time.hour - 12
                : time.hour;

    final minute =
        time.minute
            .toString()
            .padLeft(2, '0');

    final period =
        time.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
    DateTime date,
  ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }

  // ============================================================
  // FORMAT DURATION
  // ============================================================

  String _formatDuration(
    AttendanceData record,
  ) {
    final duration =
        getAttendanceDao()
            .calculateWorkedDuration(
      record,
    );

    if (duration == null) {
      return 'Currently working';
    }

    final hours =
        duration.inHours;

    final minutes =
        duration.inMinutes
            .remainder(60);

    if (hours == 0) {
      return '$minutes min';
    }

    if (minutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $minutes min';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Colors.white,
        foregroundColor:
            Colors.black87,

        title:
            const Text(
          'Staff Attendance',
          style: TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),

      
        

        actions: [
          IconButton(
            tooltip: 'Attendance History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const AttendanceHistoryScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.history_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading
                ? null
                : _loadAttendance,
            icon:
                const Icon(
              Icons
                  .refresh_outlined,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    final isWide =
                        constraints
                                .maxWidth >=
                            850;

                    return Padding(
                      padding:
                          const EdgeInsets
                              .all(20),
                      child: isWide
                          ? Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                SizedBox(
                                  width:
                                      350,
                                  child:
                                      _buildEmployeeList(),
                                ),

                                const SizedBox(
                                  width:
                                      20,
                                ),

                                Expanded(
                                  child:
                                      _buildEmployeeDetails(),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildEmployeeList(),

                                const SizedBox(
                                  height:
                                      20,
                                ),

                                Expanded(
                                  child:
                                      _buildEmployeeDetails(),
                                ),
                              ],
                            ),
                    );
                  },
                ),
    );
  }

  // ============================================================
  // EMPLOYEE LIST
  // ============================================================

  Widget _buildEmployeeList() {
    final users =
        _filteredUsers;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        side: BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .indigo
                        .withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons
                        .people_outline,
                    color:
                        Colors.indigo,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Employees',
                        style:
                            TextStyle(
                          fontSize:
                              17,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        'Select who is clocking in or out',
                        style:
                            TextStyle(
                          fontSize:
                              10,
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .grey
                        .shade100,
                    borderRadius:
                        BorderRadius
                            .circular(
                      8,
                    ),
                  ),
                  child:
                      Text(
                    '${_users.length}',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            TextField(
              decoration:
                  InputDecoration(
                hintText:
                    'Search employee...',
                prefixIcon:
                    const Icon(
                  Icons.search,
                  size: 20,
                ),
                isDense: true,
                filled: true,
                fillColor:
                    const Color(
                  0xFFF7F8FA,
                ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),
              onChanged:
                  (value) {
                setState(() {
                  _searchQuery =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 12,
            ),

            if (users.isEmpty)
              Padding(
                padding:
                    const EdgeInsets
                        .all(
                  25,
                ),
                child: Center(
                  child: Text(
                    'No employees found.',
                    style: TextStyle(
                      color: Colors
                          .grey
                          .shade600,
                    ),
                  ),
                ),
              )
            else
              ...users.map(
                _buildEmployeeListItem,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPLOYEE LIST ITEM
  // ============================================================

  Widget _buildEmployeeListItem(
    User user,
  ) {
    final selected =
        _selectedUser?.id ==
            user.id;

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        12,
      ),
      onTap: _isProcessing
          ? null
          : () => _selectUser(
                user,
              ),
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 7,
        ),
        padding:
            const EdgeInsets.all(
          11,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? Colors.indigo
                  .withValues(
                  alpha: 0.07,
                )
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          border:
              Border.all(
            color: selected
                ? Colors.indigo
                    .withValues(
                    alpha: 0.20,
                  )
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor:
                  selected
                      ? Colors.indigo
                          .withValues(
                          alpha: 0.12,
                        )
                      : Colors.grey
                          .withValues(
                          alpha: 0.10,
                        ),
              child: Text(
                user.name
                        .isNotEmpty
                    ? user.name[0]
                        .toUpperCase()
                    : '?',
                style: TextStyle(
                  color: selected
                      ? Colors.indigo
                      : Colors
                          .grey
                          .shade700,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    '${user.loginId ?? 'No ID'} • '
                    '${user.role.toUpperCase()}',
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors
                          .grey
                          .shade600,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              size: 20,
              color:
                  Colors.grey,
            ),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // EMPLOYEE DETAILS
  // ============================================================

  Widget _buildEmployeeDetails() {
    final user = _selectedUser;

    if (user == null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 300,
        ),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(
                        alpha: 0.08,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_search_outlined,
                      size: 34,
                      color: Colors.indigo,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Select an employee',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    'Choose an employee from the list '
                    'to view their attendance and '
                    'clock them in or out.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final isWorking =
        _selectedUserOpenAttendance != null;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSelectedEmployeeHeader(
            user,
          ),

          const SizedBox(height: 16),

          _buildAttendanceActionCard(
            user,
            isWorking,
          ),

          const SizedBox(height: 16),

          _buildTodaySummary(),

          const SizedBox(height: 16),

          _buildTodayHistory(),
        ],
      ),
    );
  }

  // ============================================================
  // SELECTED EMPLOYEE HEADER
  // ============================================================

  Widget _buildSelectedEmployeeHeader(
    User user,
  ) {
    final initial =
        user.name.isNotEmpty
            ? user.name[0]
                .toUpperCase()
            : '?';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        side: BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 29,
              backgroundColor:
                  Colors.indigo
                      .withValues(
                alpha: 0.10,
              ),
              child: Text(
                initial,
                style:
                    const TextStyle(
                  color:
                      Colors.indigo,
                  fontSize: 21,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    user.name,
                    style:
                        const TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    '${user.loginId ?? 'No Login ID'} • '
                    '${user.role.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors
                          .grey
                          .shade600,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color: user.isActive
                    ? Colors.green
                        .withValues(
                        alpha: 0.08,
                      )
                    : Colors.red
                        .withValues(
                        alpha: 0.08,
                      ),
                borderRadius:
                    BorderRadius.circular(
                  8,
                ),
              ),
              child: Text(
                user.isActive
                    ? 'ACTIVE'
                    : 'INACTIVE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight:
                      FontWeight
                          .w800,
                  color: user.isActive
                      ? Colors.green
                          .shade700
                      : Colors.red
                          .shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ATTENDANCE ACTION CARD
  // ============================================================

  Widget _buildAttendanceActionCard(
    User user,
    bool isWorking,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        side: BorderSide(
          color: isWorking
              ? Colors.green
                  .shade200
              : Colors.grey
                  .shade200,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
                  BoxDecoration(
                color: isWorking
                    ? Colors.green
                        .withValues(
                        alpha: 0.10,
                      )
                    : Colors.indigo
                        .withValues(
                        alpha: 0.10,
                      ),
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                isWorking
                    ? Icons
                        .work_history_outlined
                    : Icons
                        .access_time_outlined,
                size: 36,
                color: isWorking
                    ? Colors.green
                        .shade700
                    : Colors.indigo,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              isWorking
                  ? 'Currently Working'
                  : 'Not Clocked In',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.w800,
                color: isWorking
                    ? Colors.green
                        .shade800
                    : Colors.black87,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            if (isWorking)
              Text(
                'Clocked in at '
                '${_formatTime(_selectedUserOpenAttendance!.clockIn)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors
                      .grey
                      .shade600,
                ),
              )
            else
              Text(
                '${user.name} is not currently '
                'clocked in.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors
                      .grey
                      .shade600,
                ),
              ),

            const SizedBox(
              height: 22,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 52,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _isProcessing
                        ? null
                        : _handleAttendanceAction,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                          color:
                              Colors.white,
                        ),
                      )
                    : Icon(
                        isWorking
                            ? Icons
                                .logout_outlined
                            : Icons
                                .login_outlined,
                      ),
                label: Text(
                  _isProcessing
                      ? 'Please wait...'
                      : isWorking
                          ? 'Clock Out ${user.name}'
                          : 'Clock In ${user.name}',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      isWorking
                          ? Colors.red
                              .shade600
                          : Colors.indigo,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      Colors.grey
                          .shade400,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 13,
                  color: Colors.grey,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  'Employee password required',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors
                        .grey
                        .shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TODAY SUMMARY
  // ============================================================

  Widget _buildTodaySummary() {
    final completedSessions =
        _selectedUserTodayAttendance
            .where(
              (record) =>
                  record.clockOut !=
                  null,
            )
            .toList();

    Duration totalWorked =
        Duration.zero;

    for (final record
        in completedSessions) {
      final duration =
          getAttendanceDao()
              .calculateWorkedDuration(
        record,
      );

      if (duration != null) {
        totalWorked += duration;
      }
    }

    final openAttendance =
        _selectedUserOpenAttendance;

    if (openAttendance != null) {
      final currentDuration =
          DateTime.now()
              .difference(
        openAttendance.clockIn,
      );

      totalWorked +=
          currentDuration;
    }

    final hours =
        totalWorked.inHours;

    final minutes =
        totalWorked.inMinutes
            .remainder(60);

    final totalLabel = hours == 0
        ? '$minutes min'
        : minutes == 0
            ? '$hours hr'
            : '$hours hr $minutes min';

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons
                .event_available_outlined,
            label:
                'Sessions Today',
            value:
                _selectedUserTodayAttendance
                    .length
                    .toString(),
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: _summaryCard(
            icon: Icons
                .schedule_outlined,
            label:
                'Worked Today',
            value: totalLabel,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        side: BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color: Colors
                    .indigo
                    .withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: Icon(
                icon,
                color:
                    Colors.indigo,
                size: 22,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    value,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    label,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors
                          .grey
                          .shade600,
                    ),
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
  // TODAY HISTORY
  // ============================================================

  Widget _buildTodayHistory() {
    final now =
        DateTime.now();

    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        side: BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons
                      .history_outlined,
                  color:
                      Colors.indigo,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        "Today's Attendance",
                        style:
                            TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        _formatDate(
                          now,
                        ),
                        style:
                            TextStyle(
                          fontSize: 11,
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
          ),

          if (_selectedUserTodayAttendance
              .isEmpty)
            Padding(
              padding:
                  const EdgeInsets
                      .all(
                28,
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons
                          .event_busy_outlined,
                      size: 42,
                      color: Colors
                          .grey
                          .shade400,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      'No attendance recorded today.',
                      style:
                          TextStyle(
                        color: Colors
                            .grey
                            .shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._selectedUserTodayAttendance
                .asMap()
                .entries
                .map(
              (entry) {
                final record =
                    entry.value;

                final isOpen =
                    record.clockOut ==
                        null;

                return _buildAttendanceRow(
                  record,
                  isOpen,
                  entry.key ==
                      _selectedUserTodayAttendance
                              .length -
                          1,
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ATTENDANCE ROW
  // ============================================================

  Widget _buildAttendanceRow(
    AttendanceData record,
    bool isOpen,
    bool isLast,
  ) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color: isOpen
                      ? Colors.green
                          .withValues(
                          alpha: 0.10,
                        )
                      : Colors.indigo
                          .withValues(
                          alpha: 0.08,
                        ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
                child: Icon(
                  isOpen
                      ? Icons
                          .play_circle_outline
                      : Icons
                          .check_circle_outline,
                  color: isOpen
                      ? Colors.green
                          .shade700
                      : Colors.indigo,
                  size: 22,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      isOpen
                          ? 'Current Session'
                          : 'Work Session',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .w700,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Started '
                      '${_formatTime(record.clockIn)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors
                            .grey
                            .shade600,
                      ),
                    ),

                    if (record.clockOut !=
                        null) ...[
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        'Ended '
                        '${_formatTime(record.clockOut!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .end,
                children: [
                  Text(
                    isOpen
                        ? 'ACTIVE'
                        : _formatDuration(
                            record,
                          ),
                    style: TextStyle(
                      color: isOpen
                          ? Colors.green
                              .shade700
                          : Colors
                              .grey
                              .shade800,
                      fontSize: 11,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  if (isOpen) ...[
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Working',
                      style:
                          TextStyle(
                        fontSize: 10,
                        color: Colors
                            .grey
                            .shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        if (!isLast)
          Divider(
            height: 1,
            indent: 76,
            endIndent: 20,
            color:
                Colors.grey.shade200,
          ),
      ],
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 52,
              color:
                  Colors.red.shade400,
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Unable to load attendance',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              _errorMessage ??
                  'Something went wrong.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors
                    .grey
                    .shade600,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed:
                  _loadAttendance,
              icon:
                  const Icon(
                Icons.refresh,
              ),
              label:
                  const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}


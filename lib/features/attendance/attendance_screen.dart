// lib/features/attendance/attendance_screen.dart

import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import 'attendance_history_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
  });

  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // ============================================================
  // STATE
  // ============================================================

  List<User> _users = [];

  User? _selectedUser;

  AttendanceData? _selectedUserOpenAttendance;

  List<AttendanceData> _selectedUserTodayAttendance = [];

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

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final userDao = getUserDao();

      final users = await userDao.getAllUsers();

      if (!mounted) return;

      final activeUsers = users
          .where(
            (user) => user.isActive,
          )
          .toList();

      setState(() {
        _users = activeUsers;
        _isLoading = false;
      });

      if (_selectedUser != null) {
        final stillExists = _users.any(
          (user) => user.id == _selectedUser!.id,
        );

        if (stillExists) {
          final refreshedUser = _users.firstWhere(
            (user) => user.id == _selectedUser!.id,
          );

          await _selectUser(
            refreshedUser,
            showLoading: false,
          );
        } else {
          setState(() {
            _selectedUser = null;
            _selectedUserOpenAttendance = null;
            _selectedUserTodayAttendance = [];
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
        _selectedUserOpenAttendance = null;
        _selectedUserTodayAttendance = [];
        _isProcessing = true;
      });
    }

    try {
      final attendanceDao = getAttendanceDao();

      final results = await Future.wait([
        attendanceDao.getOpenAttendance(
          user.id,
        ),
        attendanceDao.getTodayAttendance(
          user.id,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _selectedUser = user;

        _selectedUserOpenAttendance =
            results[0] as AttendanceData?;

        _selectedUserTodayAttendance =
            results[1] as List<AttendanceData>;

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

  Future<void> _handleAttendanceAction() async {
    final user = _selectedUser;

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
        _selectedUserOpenAttendance != null;

    final password = await _showPasswordDialog(user);

    if (password == null || !mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final userDao = getUserDao();

      // ========================================================
      // VERIFY EMPLOYEE PASSWORD
      // ========================================================

      final loginId = user.loginId;

      if (loginId == null ||
          loginId.trim().isEmpty) {
        _showMessage(
          'This employee does not have a valid login ID.',
          isError: true,
        );
        return;
      }

      final verifiedUser =
          await userDao.verifyUserPassword(
        loginId: loginId,
        password: password,
      );

      if (!mounted) return;

      if (verifiedUser == null) {
        _showMessage(
          'Incorrect password. Attendance was not changed.',
          isError: true,
        );

        return;
      }

      // ========================================================
      // CLOCK OUT
      // ========================================================

      if (isCurrentlyWorking) {
        final attendanceDao = getAttendanceDao();

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

      final attendanceDao = getAttendanceDao();

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

      final message = e.toString().toLowerCase();

      if (message.contains(
        'already clocked in',
      )) {
        _showMessage(
          '${user.name} is already clocked in.',
          isError: true,
        );
      } else {
        _showMessage(
          'Unable to update attendance. Please try again.',
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

  Future<void> _refreshSelectedEmployee() async {
    final user = _selectedUser;

    if (user == null) {
      return;
    }

    final attendanceDao = getAttendanceDao();

    final results = await Future.wait([
      attendanceDao.getOpenAttendance(
        user.id,
      ),
      attendanceDao.getTodayAttendance(
        user.id,
      ),
    ]);

    if (!mounted) return;

    setState(() {
      _selectedUserOpenAttendance =
          results[0] as AttendanceData?;

      _selectedUserTodayAttendance =
          results[1] as List<AttendanceData>;
    });
  }

  // ============================================================
  // PASSWORD DIALOG
  // ============================================================
  //
  // IMPORTANT:
  // The password controller is owned by the Stateful dialog.
  // This prevents Flutter from using a controller after it has
  // already been disposed during dialog closing/rebuilding.
  //

  Future<String?> _showPasswordDialog(
    User user,
  ) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _AttendancePasswordDialog(
          user: user,
        );
      },
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<User> get _filteredUsers {
    final query =
        _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _users;
    }

    return _users.where((user) {
      final name = user.name.toLowerCase();

      final loginId =
          (user.loginId ?? '').toLowerCase();

      final role = user.role.toLowerCase();

      return name.contains(query) ||
          loginId.contains(query) ||
          role.contains(query);
    }).toList();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? AppColors.danger
            : AppColors.success,
      ),
    );
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(
    DateTime time,
  ) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
            ? time.hour - 12
            : time.hour;

    final minute = time.minute
        .toString()
        .padLeft(2, '0');

    final period =
        time.hour >= 12 ? 'PM' : 'AM';

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
        getAttendanceDao().calculateWorkedDuration(
      record,
    );

    if (duration == null) {
      return 'Currently working';
    }

    final hours = duration.inHours;

    final minutes =
        duration.inMinutes.remainder(60);

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
          AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor:
          AppColors.surface,
      foregroundColor:
          AppColors.textPrimary,
      surfaceTintColor:
          Colors.transparent,

      title: Text(
        'Staff Attendance',
        style: AppTextStyles.heading.copyWith(
          fontWeight: FontWeight.w700,
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
          onPressed:
              _isLoading ? null : _loadAttendance,
          icon: const Icon(
            Icons.refresh_outlined,
          ),
        ),

        const SizedBox(
          width: AppSpacing.sm,
        ),
      ],
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final responsive = context.responsive;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal:
            responsive.horizontalPadding,
        vertical:
            responsive.verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                responsive.contentMaxWidth,
          ),
          child: responsive.isDesktop
              ? _buildDesktopLayout()
              : responsive.isTablet
                  ? _buildTabletLayout()
                  : _buildMobileLayout(),
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 340,
          child: _buildEmployeeList(
            constrainHeight: true,
          ),
        ),

        const SizedBox(
          width: AppSpacing.lg,
        ),

        Expanded(
          child: _buildEmployeeDetails(),
        ),
      ],
    );
  }

  // ============================================================
  // TABLET
  // ============================================================

  Widget _buildTabletLayout() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        _buildEmployeeList(),

        const SizedBox(
          height: AppSpacing.lg,
        ),

        _buildEmployeeDetails(),
      ],
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        _buildEmployeeList(),

        const SizedBox(
          height: AppSpacing.md,
        ),

        _buildEmployeeDetails(),
      ],
    );
  }

  // ============================================================
  // EMPLOYEE LIST
  // ============================================================

  Widget _buildEmployeeList({
    bool constrainHeight = false,
  }) {
    final users = _filteredUsers;

    Widget content = Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildEmployeeListHeader(),

        const SizedBox(
          height: AppSpacing.md,
        ),

        TextField(
          decoration: InputDecoration(
            hintText:
                'Search employee...',
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
            ),
            isDense: true,
            filled: true,
            fillColor:
                AppColors.background,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.md,
              ),
              borderSide:
                  BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        if (users.isEmpty)
          Padding(
            padding:
                const EdgeInsets.all(
              AppSpacing.xl,
            ),
            child: Center(
              child: Text(
                'No employees found.',
                style:
                    AppTextStyles
                        .bodySecondary
                        .copyWith(
                  color: AppColors
                      .textSecondary,
                ),
              ),
            ),
          )
        else
          ...users.map(
            _buildEmployeeListItem,
          ),
      ],
    );

    if (constrainHeight) {
      content = ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxHeight: 720,
        ),
        child: SingleChildScrollView(
          child: content,
        ),
      );
    }

    return _buildCard(
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: content,
      ),
    );
  }

  // ============================================================
  // EMPLOYEE LIST HEADER
  // ============================================================

  Widget _buildEmployeeListHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color:
                AppColors.primary.withValues(
              alpha: 0.08,
            ),
            borderRadius:
                BorderRadius.circular(
              AppRadius.md,
            ),
          ),
          child: const Icon(
            Icons.people_outline,
            color:
                AppColors.primary,
          ),
        ),

        const SizedBox(
          width: AppSpacing.md,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Employees',
                style:
                    AppTextStyles.title
                        .copyWith(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              const Text(
                'Select who is clocking in or out',
                style:
                    AppTextStyles.small,
              ),
            ],
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 6,
          ),
          decoration:
              BoxDecoration(
            color:
                AppColors.background,
            borderRadius:
                BorderRadius.circular(
              AppRadius.sm,
            ),
          ),
          child: Text(
            '${_users.length}',
            style:
                AppTextStyles.small
                    .copyWith(
              fontWeight:
                  FontWeight.w700,
              color:
                  AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPLOYEE LIST ITEM
  // ============================================================

  Widget _buildEmployeeListItem(
    User user,
  ) {
    final selected =
        _selectedUser?.id == user.id;

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: AppSpacing.xs,
      ),
      child: Material(
        color:
            Colors.transparent,
        borderRadius:
            BorderRadius.circular(
          AppRadius.md,
        ),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(
            AppRadius.md,
          ),
          onTap: _isProcessing
              ? null
              : () => _selectUser(
                    user,
                  ),
          child: AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 160,
            ),
            padding:
                const EdgeInsets.all(
              AppSpacing.sm,
            ),
            decoration:
                BoxDecoration(
              color: selected
                  ? AppColors.primary
                      .withValues(
                      alpha: 0.07,
                    )
                  : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(
                AppRadius.md,
              ),
              border:
                  Border.all(
                color: selected
                    ? AppColors.primary
                        .withValues(
                        alpha: 0.18,
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
                          ? AppColors.primary
                              .withValues(
                              alpha: 0.12,
                            )
                          : AppColors.border
                              .withValues(
                              alpha: 0.45,
                            ),
                  child: Text(
                    user.name.isNotEmpty
                        ? user.name[0]
                            .toUpperCase()
                        : '?',
                    style:
                        AppTextStyles.body
                            .copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors
                              .textSecondary,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(
                  width: AppSpacing.sm,
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
                            AppTextStyles
                                .bodySecondary
                                .copyWith(
                          color: AppColors
                              .textPrimary,
                          fontWeight:
                              FontWeight
                                  .w600,
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
                        style:
                            AppTextStyles
                                .small
                                .copyWith(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: selected
                      ? AppColors.primary
                      : AppColors
                          .textSecondary,
                ),
              ],
            ),
          ),
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
      return _buildEmptySelection();
    }

    final isWorking =
        _selectedUserOpenAttendance != null;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        _buildSelectedEmployeeHeader(
          user,
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        _buildAttendanceActionCard(
          user,
          isWorking,
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        _buildTodaySummary(),

        const SizedBox(
          height: AppSpacing.md,
        ),

        _buildTodayHistory(),
      ],
    );
  }

  // ============================================================
  // EMPTY SELECTION
  // ============================================================

  Widget _buildEmptySelection() {
    return _buildCard(
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration:
                  BoxDecoration(
                color: AppColors
                    .primary
                    .withValues(
                  alpha: 0.08,
                ),
                shape:
                    BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_outlined,
                size: 36,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'Select an employee',
              textAlign:
                  TextAlign.center,
              style: AppTextStyles
                  .heading
                  .copyWith(
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              'Choose an employee from the list '
              'to view their attendance and '
              'clock them in or out.',
              textAlign:
                  TextAlign.center,
              style: AppTextStyles
                  .bodySecondary
                  .copyWith(
                color: AppColors
                    .textSecondary,
              ),
            ),
          ],
        ),
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
            ? user.name[0].toUpperCase()
            : '?';

    return _buildCard(
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.lg,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 29,
              backgroundColor:
                  AppColors.primary
                      .withValues(
                alpha: 0.10,
              ),
              child: Text(
                initial,
                style: AppTextStyles
                    .heading
                    .copyWith(
                  color:
                      AppColors.primary,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(
              width: AppSpacing.md,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        AppTextStyles
                            .heading
                            .copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    '${user.loginId ?? 'No Login ID'} • '
                    '${user.role.toUpperCase()}',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        AppTextStyles
                            .small
                            .copyWith(
                      color: AppColors
                          .textSecondary,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            _statusBadge(
              label: user.isActive
                  ? 'ACTIVE'
                  : 'INACTIVE',
              color: user.isActive
                  ? AppColors.success
                  : AppColors.danger,
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
    return _buildCard(
      borderColor: isWorking
          ? AppColors.success.withValues(
              alpha: 0.25,
            )
          : null,
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration:
                  BoxDecoration(
                color: isWorking
                    ? AppColors.success
                        .withValues(
                        alpha: 0.10,
                      )
                    : AppColors.primary
                        .withValues(
                        alpha: 0.10,
                      ),
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                isWorking
                    ? Icons.work_history_outlined
                    : Icons.access_time_outlined,
                size: 38,
                color: isWorking
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Text(
              isWorking
                  ? 'Currently Working'
                  : 'Not Clocked In',
              textAlign:
                  TextAlign.center,
              style: AppTextStyles
                  .heading
                  .copyWith(
                fontSize: 20,
                fontWeight:
                    FontWeight.w700,
                color: isWorking
                    ? AppColors.success
                    : AppColors.textPrimary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            if (isWorking)
              Text(
                'Clocked in at '
                '${_formatTime(_selectedUserOpenAttendance!.clockIn)}',
                textAlign:
                    TextAlign.center,
                style: AppTextStyles
                    .bodySecondary
                    .copyWith(
                  color: AppColors
                      .textSecondary,
                ),
              )
            else
              Text(
                '${user.name} is not currently clocked in.',
                textAlign:
                    TextAlign.center,
                style: AppTextStyles
                    .bodySecondary
                    .copyWith(
                  color: AppColors
                      .textSecondary,
                ),
              ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            SizedBox(
              width: double.infinity,
              height:
                  context.responsive.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: _isProcessing
                    ? null
                    : _handleAttendanceAction,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              AppColors.surface,
                        ),
                      )
                    : Icon(
                        isWorking
                            ? Icons.logout_outlined
                            : Icons.login_outlined,
                      ),
                label: Text(
                  _isProcessing
                      ? 'Please wait...'
                      : isWorking
                          ? 'Clock Out ${user.name}'
                          : 'Clock In ${user.name}',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: AppTextStyles
                      .body
                      .copyWith(
                    color:
                        AppColors.surface,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      isWorking
                          ? AppColors.danger
                          : AppColors.primary,
                  foregroundColor:
                      AppColors.surface,
                  disabledBackgroundColor:
                      AppColors.border,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.md,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 13,
                  color:
                      AppColors.textSecondary,
                ),

                const SizedBox(
                  width: 5,
                ),

                Flexible(
                  child: Text(
                    'Employee password required',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: AppTextStyles
                        .small
                        .copyWith(
                      color: AppColors
                          .textSecondary,
                    ),
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
                  record.clockOut != null,
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
      totalWorked += DateTime.now()
          .difference(
        openAttendance.clockIn,
      );
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
            icon:
                Icons.event_available_outlined,
            label: 'Sessions Today',
            value:
                _selectedUserTodayAttendance
                    .length
                    .toString(),
          ),
        ),

        const SizedBox(
          width: AppSpacing.md,
        ),

        Expanded(
          child: _summaryCard(
            icon:
                Icons.schedule_outlined,
            label: 'Worked Today',
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
    return _buildCard(
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color: AppColors.primary
                    .withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.md,
                ),
              ),
              child: Icon(
                icon,
                color:
                    AppColors.primary,
                size: 22,
              ),
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        AppTextStyles
                            .title
                            .copyWith(
                      fontWeight:
                          FontWeight.w700,
                      color: AppColors
                          .textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    label,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        AppTextStyles.small
                            .copyWith(
                      color: AppColors
                          .textSecondary,
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
    final now = DateTime.now();

    return _buildCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      BoxDecoration(
                    color: AppColors
                        .primary
                        .withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.md,
                    ),
                  ),
                  child: const Icon(
                    Icons.history_outlined,
                    color:
                        AppColors.primary,
                  ),
                ),

                const SizedBox(
                  width: AppSpacing.md,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        "Today's Attendance",
                        style:
                            AppTextStyles
                                .title
                                .copyWith(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        _formatDate(now),
                        style:
                            AppTextStyles
                                .small
                                .copyWith(
                          color: AppColors
                              .textSecondary,
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
            color:
                AppColors.border,
          ),

          if (_selectedUserTodayAttendance
              .isEmpty)
            Padding(
              padding:
                  const EdgeInsets.all(
                AppSpacing.xl,
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.event_busy_outlined,
                      size: 42,
                      color: AppColors
                          .textSecondary,
                    ),

                    const SizedBox(
                      height:
                          AppSpacing.sm,
                    ),

                    Text(
                      'No attendance recorded today.',
                      textAlign:
                          TextAlign.center,
                      style: AppTextStyles
                          .bodySecondary
                          .copyWith(
                        color: AppColors
                            .textSecondary,
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
                    record.clockOut == null;

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
              const EdgeInsets.symmetric(
            horizontal:
                AppSpacing.lg,
            vertical:
                AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color: isOpen
                      ? AppColors
                          .success
                          .withValues(
                          alpha: 0.10,
                        )
                      : AppColors
                          .primary
                          .withValues(
                          alpha: 0.08,
                        ),
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Icon(
                  isOpen
                      ? Icons.play_circle_outline
                      : Icons.check_circle_outline,
                  color: isOpen
                      ? AppColors.success
                      : AppColors.primary,
                  size: 22,
                ),
              ),

              const SizedBox(
                width: AppSpacing.md,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOpen
                          ? 'Current Session'
                          : 'Work Session',
                      style:
                          AppTextStyles
                              .bodySecondary
                              .copyWith(
                        color: AppColors
                            .textPrimary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Started '
                      '${_formatTime(record.clockIn)}',
                      style:
                          AppTextStyles
                              .small
                              .copyWith(
                        color: AppColors
                            .textSecondary,
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
                        style:
                            AppTextStyles
                                .small
                                .copyWith(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Flexible(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      isOpen
                          ? 'ACTIVE'
                          : _formatDuration(
                              record,
                            ),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppTextStyles
                              .small
                              .copyWith(
                        color: isOpen
                            ? AppColors
                                .success
                            : AppColors
                                .textPrimary,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    if (isOpen) ...[
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Working',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            AppTextStyles
                                .small
                                .copyWith(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        if (!isLast)
          const Divider(
            height: 1,
            indent: 76,
            endIndent:
                AppSpacing.lg,
            color:
                AppColors.border,
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
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 52,
              color:
                  AppColors.danger,
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Text(
              'Unable to load attendance',
              textAlign:
                  TextAlign.center,
              style: AppTextStyles
                  .heading
                  .copyWith(
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              _errorMessage ??
                  'Something went wrong.',
              textAlign:
                  TextAlign.center,
              style: AppTextStyles
                  .bodySecondary
                  .copyWith(
                color: AppColors
                    .textSecondary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            ElevatedButton.icon(
              onPressed:
                  _loadAttendance,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COMMON CARD
  // ============================================================

  Widget _buildCard({
    required Widget child,
    Color? borderColor,
  }) {
    return Card(
      elevation: 0,
      color:
          AppColors.surface,
      margin:
          EdgeInsets.zero,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
        side: BorderSide(
          color: borderColor ??
              AppColors.border,
        ),
      ),
      child: child,
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge({
    required String label,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(
          AppRadius.sm,
        ),
      ),
      child: Text(
        label,
        style:
            AppTextStyles.small.copyWith(
          fontSize: 9,
          fontWeight:
              FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ============================================================================
// ATTENDANCE PASSWORD DIALOG
// ============================================================================
//
// The TextEditingController belongs to this widget.
//
// It is created in initState() and disposed in dispose().
// The parent AttendanceScreen never disposes this controller.
//
// This prevents:
//   "A TextEditingController was used after being disposed"
//   "_dependents.isEmpty"
//   "Tried to build dirty widget in the wrong build scope"
//

class _AttendancePasswordDialog
    extends StatefulWidget {
  final User user;

  const _AttendancePasswordDialog({
    required this.user,
  });

  @override
  State<_AttendancePasswordDialog> createState() =>
      _AttendancePasswordDialogState();
}

class _AttendancePasswordDialogState
    extends State<_AttendancePasswordDialog> {
  // ============================================================
  // STATE
  // ============================================================

  late final TextEditingController _controller;

  bool _obscurePassword = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();

    _controller.addListener(
      _onPasswordChanged,
    );
  }

  // ============================================================
  // PASSWORD CHANGE
  // ============================================================

  void _onPasswordChanged() {
    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller.removeListener(
      _onPasswordChanged,
    );

    _controller.dispose();

    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    final password =
        _controller.text.trim();

    if (password.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      password,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final user = widget.user;

    final hasPassword =
        _controller.text.trim().isNotEmpty;

    return AlertDialog(
      title: Text(
        'Verify Employee',
        style:
            AppTextStyles.heading.copyWith(
          fontSize: 20,
          fontWeight:
              FontWeight.w700,
        ),
      ),

      // ========================================================
      // SCROLLABLE
      // ========================================================
      //
      // Prevents the dialog content from overflowing on smaller
      // logical screens / shorter available heights.
      //

      scrollable: true,

      content: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth:
              AppSizes.maxFormWidth,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ====================================================
            // EMPLOYEE INFORMATION
            // ====================================================

            Container(
              padding:
                  const EdgeInsets.all(
                AppSpacing.md,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primaryLight,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.md,
                ),
                border:
                    Border.all(
                  color: AppColors.primary
                      .withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor:
                        AppColors.primary
                            .withValues(
                      alpha: 0.10,
                    ),
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0]
                              .toUpperCase()
                          : '?',
                      style:
                          AppTextStyles.body
                              .copyWith(
                        color:
                            AppColors.primary,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width:
                        AppSpacing.md,
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
                              AppTextStyles
                                  .body
                                  .copyWith(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          user.loginId ??
                              'No Login ID',
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              AppTextStyles
                                  .small,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height:
                  AppSpacing.lg,
            ),

            // ====================================================
            // INSTRUCTION
            // ====================================================

            const Text(
              'Enter this employee\'s password to continue.',
              style:
                  AppTextStyles.bodySecondary,
            ),

            const SizedBox(
              height:
                  AppSpacing.md,
            ),

            // ====================================================
            // PASSWORD FIELD
            // ====================================================

            TextField(
              controller:
                  _controller,
              obscureText:
                  _obscurePassword,
              autofocus: true,
              textInputAction:
                  TextInputAction.done,
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
                  tooltip:
                      _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                  onPressed: () {
                    if (!mounted) return;

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
                    AppRadius.md,
                  ),
                ),
              ),

              onSubmitted: (_) {
                _submit();
              },
            ),

            const SizedBox(
              height:
                  AppSpacing.sm,
            ),

            // ====================================================
            // SECURITY MESSAGE
            // ====================================================

            Text(
              'Only ${user.name} can authorize this attendance action.',
              style:
                  AppTextStyles.small.copyWith(
                color:
                    AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // ACTIONS
      // ========================================================

      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child:
              const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed:
              hasPassword
                  ? _submit
                  : null,
          child:
              const Text('Verify'),
        ),
      ],
    );
  }
}


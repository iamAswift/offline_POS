
//lib/features/attendance/attendance_history_screen.dart
import 'package:flutter/material.dart';
import 'package:supermarket_inventory/database/daos/attendance_dao.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({
    super.key,
  });

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends State<AttendanceHistoryScreen> {
  // ============================================================
  // STATE
  // ============================================================

  List<AttendanceWithUser> _records = [];

  bool _isLoading = true;

  String? _errorMessage;

  DateTime _startDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime _endDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  String _searchQuery = '';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadHistory();
  }

  // ============================================================
  // LOAD HISTORY
  // ============================================================

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final attendanceDao = getAttendanceDao();

      final records =
          await attendanceDao.getAttendanceWithUsersBetweenDates(
        _startDate,
        _endDate,
      );

      if (!mounted) return;

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Attendance history error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load attendance history.';
      });
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<AttendanceWithUser> get _filteredRecords {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _records;
    }

    return _records.where((item) {
      final name = item.user.name.toLowerCase();

      final loginId =
          (item.user.loginId ?? '').toLowerCase();

      final role = item.user.role.toLowerCase();

      return name.contains(query) ||
          loginId.contains(query) ||
          role.contains(query);
    }).toList();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              secondary: AppColors.accent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      _startDate = result.start;
      _endDate = result.end;
    });

    await _loadHistory();
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
            ? time.hour - 12
            : time.hour;

    final minute = time.minute
        .toString()
        .padLeft(2, '0');

    final period = time.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // DURATION
  // ============================================================

  String _formatDuration(
    AttendanceData record,
  ) {
    if (record.clockOut == null) {
      return 'Working';
    }

    final duration =
        record.clockOut!.difference(record.clockIn);

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
  // CORRECTION INDICATOR
  // ============================================================

  bool _wasCorrected(
    AttendanceData record,
  ) {
    return record.correctedAt != null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,

        title: Text(
          'Attendance History',
          style: AppTextStyles.heading.copyWith(
            fontSize: responsive.isCompact ? 18 : 20,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _isLoading ? null : _loadHistory,
            icon: const Icon(
              Icons.refresh_outlined,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _errorMessage != null
              ? _buildError()
              : _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    final responsive = context.responsive;

    final records = _filteredRecords;

    final completed = records
        .where(
          (item) =>
              item.attendance.clockOut != null,
        )
        .toList();

    final currentlyWorking = records
        .where(
          (item) =>
              item.attendance.clockOut == null,
        )
        .length;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.horizontalPadding,
        vertical: responsive.verticalPadding,
      ),

      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: responsive.contentMaxWidth,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _buildControls(),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              _buildSummary(
                total: records.length,
                completed: completed.length,
                working: currentlyWorking,
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              SizedBox(
                height: responsive.isCompact
                    ? 500
                    : 560,
                child: records.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryTable(
                        records,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTROLS
  // ============================================================

  Widget _buildControls() {
    final responsive = context.responsive;

    final searchField = TextField(
      style: AppTextStyles.body.copyWith(
        fontSize: responsive.isCompact
            ? 13
            : 14,
      ),

      decoration: InputDecoration(
        hintText: 'Search employee...',
        hintStyle: AppTextStyles.bodySecondary,
        prefixIcon: const Icon(
          Icons.search_outlined,
          color: AppColors.textSecondary,
        ),

        filled: true,
        fillColor: AppColors.surfaceSoft,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.md,
          ),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.md,
          ),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.md,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),

      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );

    final dateButton = OutlinedButton.icon(
      onPressed: _selectDateRange,

      icon: const Icon(
        Icons.calendar_month_outlined,
        size: 19,
      ),

      label: Text(
        '${_formatDate(_startDate)} - '
        '${_formatDate(_endDate)}',
        overflow: TextOverflow.ellipsis,
      ),

      style: OutlinedButton.styleFrom(
        minimumSize: Size(
          0,
          responsive.controlHeight,
        ),

        foregroundColor:
            AppColors.textPrimary,

        side: const BorderSide(
          color: AppColors.border,
        ),

        backgroundColor:
            AppColors.surface,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppRadius.md,
          ),
        ),

        textStyle: AppTextStyles.bodySecondary.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return _buildCard(
      child: responsive.isCompact
          ? Column(
              children: [
                searchField,

                const SizedBox(
                  height: AppSpacing.md,
                ),

                SizedBox(
                  width: double.infinity,
                  child: dateButton,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: searchField,
                ),

                const SizedBox(
                  width: AppSpacing.md,
                ),

                SizedBox(
                  width: responsive.isTablet
                      ? 240
                      : 280,
                  child: dateButton,
                ),
              ],
            ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary({
    required int total,
    required int completed,
    required int working,
  }) {
    final responsive = context.responsive;

    final cards = [
      _SummaryData(
        icon: Icons.event_note_outlined,
        label: 'Attendance Sessions',
        value: total.toString(),
        color: AppColors.primary,
        lightColor: AppColors.primaryLight,
      ),

      _SummaryData(
        icon: Icons.check_circle_outline,
        label: 'Completed',
        value: completed.toString(),
        color: AppColors.success,
        lightColor: AppColors.successLight,
      ),

      _SummaryData(
        icon: Icons.work_history_outlined,
        label: 'Currently Working',
        value: working.toString(),
        color: AppColors.warning,
        lightColor: AppColors.warningLight,
      ),
    ];

    if (responsive.isCompact) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            _summaryCard(cards[i]),
            if (i != cards.length - 1)
              const SizedBox(
                height: AppSpacing.md,
              ),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(
            child: _summaryCard(cards[i]),
          ),

          if (i != cards.length - 1)
            const SizedBox(
              width: AppSpacing.md,
            ),
        ],
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard(
    _SummaryData data,
  ) {
    return _buildCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: data.lightColor,
              borderRadius:
                  BorderRadius.circular(
                AppRadius.md,
              ),
            ),

            child: Icon(
              data.icon,
              color: data.color,
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
                  data.value,
                  style:
                      AppTextStyles.dashboardCardValue,
                ),

                const SizedBox(
                  height: AppSpacing.xs,
                ),

                Text(
                  data.label,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyles.dashboardCardSubtitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HISTORY TABLE
  // ============================================================

  Widget _buildHistoryTable(
    List<AttendanceWithUser> records,
  ) {
    final responsive = context.responsive;

    return _buildCard(
      padding: EdgeInsets.zero,

      child: responsive.isCompact
          ? _buildCompactHistoryList(
              records,
            )
          : Column(
              children: [
                _buildTableHeader(),

                const Divider(
                  height: 1,
                  color: AppColors.divider,
                ),

                Expanded(
                  child: ListView.separated(
                    itemCount:
                        records.length,

                    separatorBuilder:
                        (_, __) =>
                            const Divider(
                      height: 1,
                      color:
                          AppColors.divider,
                    ),

                    itemBuilder:
                        (context, index) {
                      return _buildHistoryRow(
                        records[index],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // ============================================================
  // COMPACT HISTORY LIST
  // ============================================================

  Widget _buildCompactHistoryList(
    List<AttendanceWithUser> records,
  ) {
    return ListView.separated(
      padding:
          const EdgeInsets.all(
        AppSpacing.lg,
      ),

      itemCount: records.length,

      separatorBuilder: (_, __) =>
          const SizedBox(
        height: AppSpacing.md,
      ),

      itemBuilder: (context, index) {
        return _buildCompactHistoryCard(
          records[index],
        );
      },
    );
  }

  // ============================================================
  // COMPACT HISTORY CARD
  // ============================================================

  Widget _buildCompactHistoryCard(
    AttendanceWithUser item,
  ) {
    final record = item.attendance;
    final user = item.user;

    final corrected = _wasCorrected(record);
    final working = record.clockOut == null;

    return Container(
      padding:
          const EdgeInsets.all(
        AppSpacing.md,
      ),

      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,

        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),

        border:  Border.all(
          color: AppColors.border,
        ),
      ),

      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(user.name),

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
                          AppTextStyles.body.copyWith(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    Text(
                      user.loginId ?? 'No ID',
                      style:
                          AppTextStyles.small,
                    ),
                  ],
                ),
              ),

              if (corrected)
                Tooltip(
                  message:
                      record.correctionNote ??
                          'Attendance corrected',
                  child: const Icon(
                    Icons.edit_note_outlined,
                    size: 19,
                    color: AppColors.warning,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          const Divider(
            height: 1,
            color: AppColors.divider,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Row(
            children: [
              Expanded(
                child: _compactDetail(
                  'DATE',
                  _formatDate(
                    record.clockIn,
                  ),
                ),
              ),

              Expanded(
                child: _compactDetail(
                  'CLOCK IN',
                  _formatTime(
                    record.clockIn,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Row(
            children: [
              Expanded(
                child: _compactDetail(
                  'CLOCK OUT',
                  record.clockOut == null
                      ? '—'
                      : _formatTime(
                          record.clockOut!,
                        ),
                ),
              ),

              Expanded(
                child: Align(
                  alignment:
                      Alignment.centerRight,
                  child: _durationBadge(
                    record,
                    working,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPACT DETAIL
  // ============================================================

  Widget _compactDetail(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.small.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        Text(
          value,
          style: AppTextStyles.bodySecondary.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  Widget _buildTableHeader() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),

      child: Row(
        children: [
          const SizedBox(
            width: 240,
            child: _TableHeaderText(
              'EMPLOYEE',
            ),
          ),

          const Expanded(
            child: _TableHeaderText(
              'DATE',
            ),
          ),

          const Expanded(
            child: _TableHeaderText(
              'CLOCK IN',
            ),
          ),

          const Expanded(
            child: _TableHeaderText(
              'CLOCK OUT',
            ),
          ),

          const SizedBox(
            width: 120,
            child: _TableHeaderText(
              'DURATION',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HISTORY ROW
  // ============================================================

  Widget _buildHistoryRow(
    AttendanceWithUser item,
  ) {
    final record = item.attendance;
    final user = item.user;

    final corrected = _wasCorrected(record);
    final working = record.clockOut == null;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),

      child: Row(
        children: [
          SizedBox(
            width: 240,

            child: Row(
              children: [
                _buildAvatar(user.name),

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
                            AppTextStyles.bodySecondary.copyWith(
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(
                        height: AppSpacing.xs,
                      ),

                      Text(
                        user.loginId ?? 'No ID',
                        style:
                            AppTextStyles.small.copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Text(
              _formatDate(
                record.clockIn,
              ),
              style:
                  AppTextStyles.bodySecondary,
            ),
          ),

          Expanded(
            child: Text(
              _formatTime(
                record.clockIn,
              ),
              style:
                  AppTextStyles.bodySecondary,
            ),
          ),

          Expanded(
            child: Row(
              children: [
                Text(
                  record.clockOut == null
                      ? '—'
                      : _formatTime(
                          record.clockOut!,
                        ),
                  style:
                      AppTextStyles.bodySecondary,
                ),

                if (corrected) ...[
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  Tooltip(
                    message:
                        record.correctionNote ??
                            'Attendance corrected',

                    child: const Icon(
                      Icons.edit_note_outlined,
                      size: 18,
                      color:
                          AppColors.warning,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(
            width: 120,
            child: Align(
              alignment:
                  Alignment.centerRight,
              child: _durationBadge(
                record,
                working,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildAvatar(
    String name,
  ) {
    return CircleAvatar(
      radius: 20,

      backgroundColor:
          AppColors.primaryLight,

      child: Text(
        name.isNotEmpty
            ? name[0].toUpperCase()
            : '?',

        style:
            AppTextStyles.body.copyWith(
          color: AppColors.primary,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // DURATION BADGE
  // ============================================================

  Widget _durationBadge(
    AttendanceData record,
    bool working,
  ) {
    final backgroundColor = working
        ? AppColors.successLight
        : AppColors.surfaceSoft;

    final textColor = working
        ? AppColors.success
        : AppColors.textSecondary;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),

      decoration: BoxDecoration(
        color: backgroundColor,

        borderRadius:
            BorderRadius.circular(
          AppRadius.sm,
        ),
      ),

      child: Text(
        working
            ? 'WORKING'
            : _formatDuration(record),

        style: AppTextStyles.small.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.zero,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          AppRadius.xl,
        ),

        side: const BorderSide(
          color: AppColors.border,
        ),
      ),

      child: Padding(
        padding:
            padding ??
                const EdgeInsets.all(
                  AppSpacing.lg,
                ),

        child: child,
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return _buildCard(
      child: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(
            AppSpacing.xxl,
          ),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Container(
                width: 64,
                height: 64,

                decoration:
                    BoxDecoration(
                  color:
                      AppColors.surfaceSoft,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.lg,
                  ),
                ),

                child: const Icon(
                  Icons.event_busy_outlined,
                  size: 32,
                  color:
                      AppColors.textMuted,
                ),
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              Text(
                'No attendance records',
                style:
                    AppTextStyles.title,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                'No attendance was recorded '
                'for the selected period.',
                textAlign:
                    TextAlign.center,
                style:
                    AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.xxl,
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width: 64,
              height: 64,

              decoration:
                  const BoxDecoration(
                color:
                    AppColors.dangerLight,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.error_outline,
                size: 32,
                color:
                    AppColors.danger,
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'Unable to load attendance history',
              textAlign:
                  TextAlign.center,
              style:
                  AppTextStyles.title,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            ElevatedButton.icon(
              onPressed:
                  _loadHistory,

              icon: const Icon(
                Icons.refresh,
              ),

              label: const Text(
                'Try Again',
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    Colors.white,
                minimumSize:
                    const Size(
                  0,
                  AppSizes.buttonHeight,
                ),

                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      AppSpacing.xl,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// SUMMARY DATA
// ================================================================

class _SummaryData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color lightColor;

  const _SummaryData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.lightColor,
  });
}

// ================================================================
// TABLE HEADER TEXT
// ================================================================

class _TableHeaderText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;

  const _TableHeaderText(
    this.text, {
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: AppTextStyles.small.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 0.4,
      ),
    );
  }
}
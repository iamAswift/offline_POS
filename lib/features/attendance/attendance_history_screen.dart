import 'package:flutter/material.dart';
import 'package:supermarket_inventory/database/daos/attendance_dao.dart';

import '../../database/app_database.dart';

class AttendanceHistoryScreen
    extends StatefulWidget {
  const AttendanceHistoryScreen({
    super.key,
  });

  @override
  State<AttendanceHistoryScreen>
      createState() =>
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
      final attendanceDao =
          getAttendanceDao();

      final records =
          await attendanceDao
              .getAttendanceWithUsersBetweenDates(
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

  List<AttendanceWithUser>
      get _filteredRecords {
    final query =
        _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _records;
    }

    return _records.where((item) {
      final name =
          item.user.name.toLowerCase();

      final loginId =
          (item.user.loginId ?? '')
              .toLowerCase();

      final role =
          item.user.role.toLowerCase();

      return name.contains(query) ||
          loginId.contains(query) ||
          role.contains(query);
    }).toList();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDateRange() async {
    final result =
        await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      initialDateRange:
          DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
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

  String _formatDate(
    DateTime date,
  ) {
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
  // DURATION
  // ============================================================

  String _formatDuration(
    AttendanceData record,
  ) {
    if (record.clockOut == null) {
      return 'Working';
    }

    final duration =
        record.clockOut!
            .difference(record.clockIn);

    final hours =
        duration.inHours;

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
        title: const Text(
          'Attendance History',
          style: TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _isLoading
                    ? null
                    : _loadHistory,
            icon: const Icon(
              Icons.refresh_outlined,
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
              ? _buildError()
              : _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    final records =
        _filteredRecords;

    final completed =
        records
            .where(
              (item) =>
                  item.attendance.clockOut !=
                  null,
            )
            .toList();

    final currentlyWorking =
        records
            .where(
              (item) =>
                  item.attendance.clockOut ==
                  null,
            )
            .length;

    return Padding(
      padding:
          const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildControls(),

          const SizedBox(
            height: 16,
          ),

          _buildSummary(
            total: records.length,
            completed:
                completed.length,
            working:
                currentlyWorking,
          ),

          const SizedBox(
            height: 16,
          ),

          Expanded(
            child:
                records.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryTable(
                        records,
                      ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTROLS
  // ============================================================

  Widget _buildControls() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration:
                    InputDecoration(
                  hintText:
                      'Search employee...',
                  prefixIcon:
                      const Icon(
                    Icons.search,
                  ),
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
            ),

            const SizedBox(
              width: 12,
            ),

            OutlinedButton.icon(
              onPressed:
                  _selectDateRange,
              icon:
                  const Icon(
                Icons
                    .calendar_month_outlined,
              ),
              label:
                  Text(
                '${_formatDate(_startDate)} - '
                '${_formatDate(_endDate)}',
              ),
              style:
                  OutlinedButton
                      .styleFrom(
                minimumSize:
                    const Size(
                  230,
                  48,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
              ),
            ),
          ],
        ),
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
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon:
                Icons.event_note_outlined,
            label:
                'Attendance Sessions',
            value:
                total.toString(),
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: _summaryCard(
            icon:
                Icons.check_circle_outline,
            label:
                'Completed',
            value:
                completed.toString(),
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: _summaryCard(
            icon:
                Icons.work_history_outlined,
            label:
                'Currently Working',
            value:
                working.toString(),
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
            BorderRadius.circular(14),
        side: BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color: Colors.indigo
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
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    label,
                    overflow:
                        TextOverflow.ellipsis,
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
    );
  }

  // ============================================================
  // HISTORY TABLE
  // ============================================================

  Widget _buildHistoryTable(
    List<AttendanceWithUser> records,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildTableHeader(),

          const Divider(
            height: 1,
          ),

          Expanded(
            child: ListView.separated(
              itemCount:
                  records.length,
              separatorBuilder:
                  (_, __) =>
                      Divider(
                height: 1,
                color: Colors
                    .grey
                    .shade200,
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
  // TABLE HEADER
  // ============================================================

  Widget _buildTableHeader() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 210,
            child: Text(
              'EMPLOYEE',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w800,
                color: Colors.grey,
              ),
            ),
          ),

          const Expanded(
            child: Text(
              'DATE',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w800,
                color: Colors.grey,
              ),
            ),
          ),

          const Expanded(
            child: Text(
              'CLOCK IN',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w800,
                color: Colors.grey,
              ),
            ),
          ),

          const Expanded(
            child: Text(
              'CLOCK OUT',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w800,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(
            width: 110,
            child: Text(
              'DURATION',
              textAlign:
                  TextAlign.right,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w800,
                color: Colors.grey,
              ),
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
    final record =
        item.attendance;

    final user =
        item.user;

    final corrected =
        _wasCorrected(record);

    final working =
        record.clockOut == null;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 210,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor:
                      Colors.indigo
                          .withValues(
                    alpha: 0.08,
                  ),
                  child: Text(
                    user.name.isNotEmpty
                        ? user.name[0]
                            .toUpperCase()
                        : '?',
                    style:
                        const TextStyle(
                      color:
                          Colors.indigo,
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
                          fontWeight:
                              FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      Text(
                        user.loginId ??
                            'No ID',
                        style:
                            TextStyle(
                          fontSize: 10,
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

          Expanded(
            child: Text(
              _formatDate(
                record.clockIn,
              ),
              style:
                  const TextStyle(
                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            child: Text(
              _formatTime(
                record.clockIn,
              ),
              style:
                  const TextStyle(
                fontSize: 12,
              ),
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
                      const TextStyle(
                    fontSize: 12,
                  ),
                ),

                if (corrected) ...[
                  const SizedBox(
                    width: 6,
                  ),
                  Tooltip(
                    message:
                        record.correctionNote ??
                            'Attendance corrected',
                    child: Icon(
                      Icons
                          .edit_note_outlined,
                      size: 17,
                      color:
                          Colors.orange
                              .shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(
            width: 110,
            child: Align(
              alignment:
                  Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color: working
                      ? Colors.green
                          .withValues(
                          alpha: 0.08,
                        )
                      : Colors.grey
                          .withValues(
                          alpha: 0.08,
                        ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    7,
                  ),
                ),
                child: Text(
                  working
                      ? 'WORKING'
                      : _formatDuration(
                          record,
                        ),
                  style:
                      TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                    color: working
                        ? Colors.green
                            .shade700
                        : Colors.grey
                            .shade800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 52,
              color:
                  Colors.grey.shade400,
            ),

            const SizedBox(
              height: 14,
            ),

            const Text(
              'No attendance records',
              style:
                  TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'No attendance was recorded '
              'for the selected period.',
              style:
                  TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
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
            height: 14,
          ),

          const Text(
            'Unable to load attendance history',
            style:
                TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          ElevatedButton.icon(
            onPressed:
                _loadHistory,
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
    );
  }
}
// lib/database/daos/attendance_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/attendance_table.dart';
import '../tables/user_table.dart';

part 'attendance_dao.g.dart';

/// Combined attendance + employee record used by attendance screens.
class AttendanceWithUser {
  final AttendanceData attendance;
  final User user;

  AttendanceWithUser({
    required this.attendance,
    required this.user,
  });
}

@DriftAccessor(
  tables: [
    Attendance,
    Users,
  ],
)
class AttendanceDao extends DatabaseAccessor<AppDatabase>
    with _$AttendanceDaoMixin {
  AttendanceDao(super.db);

  // ============================================================
  // CLOCK IN
  // ============================================================

  /// Creates a new attendance record for the employee.
  ///
  /// An employee cannot have more than one open attendance
  /// record at the same time.
  Future<AttendanceData> clockIn(int userId) async {
    final existingOpenAttendance =
        await getOpenAttendance(userId);

    if (existingOpenAttendance != null) {
      throw Exception(
        'Employee is already clocked in.',
      );
    }

    final id = await into(attendance).insert(
      AttendanceCompanion.insert(
        userId: userId,
        clockIn: DateTime.now(),
      ),
    );

    final record = await getAttendanceById(id);

    if (record == null) {
      throw Exception(
        'Attendance was created but could not be loaded.',
      );
    }

    return record;
  }

  // ============================================================
  // CLOCK OUT
  // ============================================================

  /// Closes the employee's current open attendance record.
  Future<bool> clockOut(int userId) async {
    final openAttendance =
        await getOpenAttendance(userId);

    if (openAttendance == null) {
      return false;
    }

    await (update(attendance)
          ..where(
            (a) => a.id.equals(openAttendance.id),
          ))
        .write(
      AttendanceCompanion(
        clockOut: Value(DateTime.now()),
      ),
    );

    return true;
  }

  // ============================================================
  // GET CURRENT OPEN ATTENDANCE
  // ============================================================

  Future<AttendanceData?> getOpenAttendance(
    int userId,
  ) {
    return (select(attendance)
          ..where(
            (a) =>
                a.userId.equals(userId) &
                a.clockOut.isNull(),
          )
          ..orderBy([
            (a) => OrderingTerm(
                  expression: a.clockIn,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  // ============================================================
  // CHECK IF EMPLOYEE IS CLOCKED IN
  // ============================================================

  Future<bool> isClockedIn(
    int userId,
  ) async {
    final record =
        await getOpenAttendance(userId);

    return record != null;
  }

  // ============================================================
  // GET TODAY'S LATEST ATTENDANCE
  // ============================================================

  Future<AttendanceData?> getTodayLatestAttendance(
    int userId,
  ) async {
    final now = DateTime.now();

    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    return (select(attendance)
          ..where(
            (a) =>
                a.userId.equals(userId) &
                a.clockIn.isBiggerOrEqualValue(
                  startOfDay,
                ) &
                a.clockIn.isSmallerThanValue(
                  endOfDay,
                ),
          )
          ..orderBy([
            (a) => OrderingTerm(
                  expression: a.clockIn,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  // ============================================================
  // GET TODAY'S ATTENDANCE FOR USER
  // ============================================================

  Future<List<AttendanceData>> getTodayAttendance(
    int userId,
  ) async {
    final now = DateTime.now();

    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    return (select(attendance)
          ..where(
            (a) =>
                a.userId.equals(userId) &
                a.clockIn.isBiggerOrEqualValue(
                  startOfDay,
                ) &
                a.clockIn.isSmallerThanValue(
                  endOfDay,
                ),
          )
          ..orderBy([
            (a) => OrderingTerm(
                  expression: a.clockIn,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // GET USER ATTENDANCE HISTORY
  // ============================================================

  Future<List<AttendanceData>> getUserAttendance(
    int userId,
  ) {
    return (select(attendance)
          ..where(
            (a) => a.userId.equals(userId),
          )
          ..orderBy([
            (a) => OrderingTerm(
                  expression: a.clockIn,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // GET ALL ATTENDANCE
  // ============================================================

  Future<List<AttendanceData>> getAllAttendance() {
    return (select(attendance)
          ..orderBy([
            (a) => OrderingTerm(
                  expression: a.clockIn,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // GET TODAY'S ALL ATTENDANCE
  // ============================================================

  Future<List<AttendanceData>>
      getAllTodayAttendance() async {
    final now = DateTime.now();

    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    return (select(attendance)
          ..where(
            (a) =>
                a.clockIn.isBiggerOrEqualValue(
                  startOfDay,
                ) &
                a.clockIn.isSmallerThanValue(
                  endOfDay,
                ),
          )
          ..orderBy([
            (a) => OrderingTerm(
                  expression: a.clockIn,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  // ============================================================
  // GET ATTENDANCE BY ID
  // ============================================================

  Future<AttendanceData?> getAttendanceById(
    int id,
  ) {
    return (select(attendance)
          ..where(
            (a) => a.id.equals(id),
          ))
        .getSingleOrNull();
  }

  // ============================================================
  // GET ATTENDANCE + USER BETWEEN DATES
  // ============================================================

  /// Returns attendance records together with the employee/user.
  ///
  /// The end date is treated as inclusive.
  ///
  /// Example:
  /// start = Aug 1
  /// end   = Aug 3
  ///
  /// Returns:
  /// Aug 1 00:00 → Aug 4 00:00
  Future<List<AttendanceWithUser>>
      getAttendanceWithUsersBetweenDates(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final endExclusive = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).add(
      const Duration(days: 1),
    );

    final query = select(attendance).join([
      innerJoin(
        users,
        users.id.equalsExp(attendance.userId),
      ),
    ]);

    query.where(
      attendance.clockIn.isBiggerOrEqualValue(start) &
          attendance.clockIn
              .isSmallerThanValue(endExclusive),
    );

    query.orderBy([
      OrderingTerm(
        expression: attendance.clockIn,
        mode: OrderingMode.desc,
      ),
    ]);

    final rows = await query.get();

    return rows.map((row) {
      return AttendanceWithUser(
        attendance:
            row.readTable(attendance),
        user:
            row.readTable(users),
      );
    }).toList();
  }

  // ============================================================
  // CALCULATE WORKED DURATION
  // ============================================================

  Duration? calculateWorkedDuration(
    AttendanceData record,
  ) {
    if (record.clockOut == null) {
      return null;
    }

    return record.clockOut!.difference(
      record.clockIn,
    );
  }

  // ============================================================
  // FORMAT WORKED DURATION
  // ============================================================

  String formatWorkedDuration(
    AttendanceData record,
  ) {
    final duration =
        calculateWorkedDuration(record);

    if (duration == null) {
      return 'Currently working';
    }

    final hours = duration.inHours;

    final minutes =
        duration.inMinutes.remainder(60);

    if (hours == 0) {
      return '$minutes min';
    }

    return '$hours hr $minutes min';
  }
}

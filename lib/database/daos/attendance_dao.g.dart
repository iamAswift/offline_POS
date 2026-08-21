// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_dao.dart';

// ignore_for_file: type=lint
mixin _$AttendanceDaoMixin on DatabaseAccessor<AppDatabase> {
  $AttendanceTable get attendance => attachedDatabase.attendance;
  $UsersTable get users => attachedDatabase.users;
  AttendanceDaoManager get managers => AttendanceDaoManager(this);
}

class AttendanceDaoManager {
  final _$AttendanceDaoMixin _db;
  AttendanceDaoManager(this._db);
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db.attachedDatabase, _db.attendance);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
}

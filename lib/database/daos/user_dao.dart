//lib/database/daos/user_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/user_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase>
    with _$UserDaoMixin {
  UserDao(super.db);

  // ============================================================
  // CREATE USER
  // ============================================================

  Future<int> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  // ============================================================
  // GET USER COUNT
  // ============================================================

  Future<int> getUserCount() async {
    final count = users.id.count();

    final query = selectOnly(users)
      ..addColumns([count]);

    return await query.map((row) {
      return row.read(count) ?? 0;
    }).getSingle();
  }

  // ============================================================
  // CREATE INITIAL OWNER
  //
  // ONLY works when there are no users.
  // ============================================================

  Future<int> createInitialOwner({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCount = await getUserCount();

    if (userCount > 0) {
      throw Exception(
        'Initial owner account already exists.',
      );
    }

    return into(users).insert(
      UsersCompanion.insert(
        name: name.trim(),
        loginId: const Value('OWN001'),
        email: email.trim(),
        password: password,
        role: const Value('owner'),
      ),
    );
  }

  // ============================================================
  // GET USER BY EMAIL
  // ============================================================

  Future<User?> getUserByEmail(String email) {
    return (select(users)
          ..where(
            (u) => u.email.equals(email.trim()),
          ))
        .getSingleOrNull();
  }

  // ============================================================
  // GET USER BY LOGIN ID
  // ============================================================

  Future<User?> getUserByLoginId(String loginId) {
    return (select(users)
          ..where(
            (u) => u.loginId.equals(loginId.trim()),
          ))
        .getSingleOrNull();
  }

  // ============================================================
  // CHECK LOGIN ID
  // ============================================================

  Future<bool> loginIdExists(String loginId) async {
    final user = await getUserByLoginId(loginId);

    return user != null;
  }

  // ============================================================
  // GENERATE STAFF LOGIN ID
  //
  // ST001
  // ST002
  // ST003
  // ...
  // ============================================================

  Future<String> generateStaffLoginId() async {
    final staffUsers = await (select(users)
          ..where(
            (u) => u.role.equals('staff'),
          ))
        .get();

    int nextNumber = 1;

    for (final user in staffUsers) {
      final loginId = user.loginId;

      if (loginId == null) {
        continue;
      }

      if (!loginId.startsWith('ST')) {
        continue;
      }

      final number = int.tryParse(
        loginId.substring(2),
      );

      if (number != null && number >= nextNumber) {
        nextNumber = number + 1;
      }
    }

    return 'ST${nextNumber.toString().padLeft(3, '0')}';
  }

  // ============================================================
  // GENERATE MANAGER LOGIN ID
  //
  // MG001
  // MG002
  // MG003
  // ...
  // ============================================================

  Future<String> generateManagerLoginId() async {
    final managerUsers = await (select(users)
          ..where(
            (u) => u.role.equals('manager'),
          ))
        .get();

    int nextNumber = 1;

    for (final user in managerUsers) {
      final loginId = user.loginId;

      if (loginId == null) {
        continue;
      }

      if (!loginId.startsWith('MG')) {
        continue;
      }

      final number = int.tryParse(
        loginId.substring(2),
      );

      if (number != null && number >= nextNumber) {
        nextNumber = number + 1;
      }
    }

    return 'MG${nextNumber.toString().padLeft(3, '0')}';
  }

  // ============================================================
  // GET USER BY ID
  // ============================================================

  Future<User?> getUserById(int id) {
    return (select(users)
          ..where(
            (u) => u.id.equals(id),
          ))
        .getSingleOrNull();
  }

  // ============================================================
  // GET ALL USERS
  // ============================================================

  Future<List<User>> getAllUsers() {
    return select(users).get();
  }

  // ============================================================
  // UPDATE ACCOUNT STATUS
  // ============================================================

  Future<void> setUserActive(
    int userId,
    bool isActive,
  ) async {
    await (update(users)
          ..where(
            (u) => u.id.equals(userId),
          ))
        .write(
      UsersCompanion(
        isActive: Value(isActive),
      ),
    );
  }

  // ============================================================
  // ACTIVATE USER
  // ============================================================

  Future<void> activateUser(int userId) {
    return setUserActive(userId, true);
  }

  // ============================================================
  // DEACTIVATE USER
  // ============================================================

  Future<void> deactivateUser(int userId) {
    return setUserActive(userId, false);
  }

  // ============================================================
  // UPDATE PASSWORD
  // ============================================================

  Future<void> updatePassword(
    int userId,
    String newPassword,
  ) async {
    await (update(users)
          ..where(
            (u) => u.id.equals(userId),
          ))
        .write(
      UsersCompanion(
        password: Value(newPassword),
      ),
    );
  }

  // ============================================================
  // ROLE CHECK
  // ============================================================

  Future<bool> isOwnerOrManager(String email) async {
    final user = await getUserByEmail(email);

    if (user == null) {
      return false;
    }

    final role = user.role.trim().toLowerCase();

    return role == 'owner' || role == 'manager';
  }

  // ============================================================
  // STAFF CHECK
  // ============================================================

  Future<bool> isStaff(String email) async {
    final user = await getUserByEmail(email);

    if (user == null) {
      return false;
    }

    return user.role.trim().toLowerCase() == 'staff';
  }


  // ============================================================
  // VERIFY USER PASSWORD
  // ============================================================
  //
  // Used for sensitive actions such as:
  // - Clock in
  // - Clock out
  // - Future manager approvals
  //
  // The currently logged-in cashier is NOT replaced.
  // This only verifies the employee performing the action.
  // ============================================================

  Future<User?> verifyUserPassword({
    required String loginId,
    required String password,
  }) async {
    final user = await getUserByLoginId(loginId);

    if (user == null) {
      return null;
    }

    if (!user.isActive) {
      return null;
    }

    if (user.password != password) {
      return null;
    }

    return user;
  }
}


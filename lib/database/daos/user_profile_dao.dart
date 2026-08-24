import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/user_profiles_table.dart';
import '../models/user_profile_model.dart';
part 'user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfiles])
class UserProfileDao extends DatabaseAccessor<AppDatabase> with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  //============================================================
  // GET ALL USER PROFILES FOR SNAPSHOT
  //===========================================================
  Future<List<UserProfileModel>> getAllUserProfilesForSnapshot() async {
    final rows = await select(userProfiles).get();

    return rows.map((row) => UserProfileModel(
          id: row.id,
          userId: row.userId,
          nin: row.nin,
          phone: row.phone,
          guarantorName: row.guarantorName,
          guarantorPhone: row.guarantorPhone,
          salary: row.salary,
          amountOwed: row.amountOwed,
          canReceiveStock: row.canReceiveStock,
          canCountStock: row.canCountStock,
        )).toList();
  }


  // Fetch a profile by userId
  Future<UserProfile?> getProfileByUserId(int userId) {
    return (select(userProfiles)
          ..where((p) => p.userId.equals(userId)))
          .getSingleOrNull();
  }

  // Insert or update profile (upsert)
  Future<void> upsertProfile(UserProfilesCompanion profile) async {
    await into(userProfiles).insertOnConflictUpdate(profile);
  }

  // Get all profiles
  Future<List<UserProfile>> getAllProfiles() => select(userProfiles).get();

  // Delete profile
  Future<int> deleteProfile(int userId) {
    return (delete(userProfiles)..where((p) => p.userId.equals(userId))).go();
  }

  
}

// lib/core/session.dart

import 'package:shared_preferences/shared_preferences.dart';

class Session {
  // ============================================================
  // CURRENT USER
  // ============================================================

  static int? currentUserId;
  static String? currentUserLoginId;
  static String? currentUserEmail;
  static String? currentUserRole;

  // ============================================================
  // SAVE USER SESSION
  // ============================================================

  static Future<void> saveUserSession({
    required int userId,
    required String? loginId,
    required String email,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'userId',
      userId,
    );

    if (loginId != null && loginId.isNotEmpty) {
      await prefs.setString(
        'userLoginId',
        loginId,
      );
    } else {
      await prefs.remove('userLoginId');
    }

    await prefs.setString(
      'userEmail',
      email,
    );

    await prefs.setString(
      'userRole',
      role,
    );

    // Update in-memory session
    currentUserId = userId;
    currentUserLoginId = loginId;
    currentUserEmail = email;
    currentUserRole = role;
  }

  // ============================================================
  // LOAD USER SESSION
  // ============================================================

  static Future<Map<String, dynamic>?> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt('userId');
    final loginId = prefs.getString('userLoginId');
    final email = prefs.getString('userEmail');
    final role = prefs.getString('userRole');

    if (userId == null ||
        email == null ||
        role == null) {
      return null;
    }

    // Restore in-memory session
    currentUserId = userId;
    currentUserLoginId = loginId;
    currentUserEmail = email;
    currentUserRole = role;

    return {
      'userId': userId,
      'loginId': loginId,
      'email': email,
      'role': role,
    };
  }

  // ============================================================
  // CHECK LOGIN STATUS
  // ============================================================

  static bool get isLoggedIn {
    return currentUserId != null;
  }

  // ============================================================
  // CURRENT ROLE
  // ============================================================

  static String get role {
    return currentUserRole?.trim().toLowerCase() ?? '';
  }

  // ============================================================
  // ROLE CHECKS
  // ============================================================

  static bool get isOwner {
    return role == 'owner';
  }

  static bool get isManager {
    return role == 'manager';
  }

  static bool get isStaff {
    return role == 'staff';
  }

  static bool get isOwnerOrManager {
    return isOwner || isManager;
  }

  // ============================================================
  // CLEAR SESSION / LOGOUT
  // This is the ONE logout method the application should use.
  //
  // It:
  // 1. Removes the persisted login session.
  // 2. Clears the in-memory session.
  // 3. Prevents the previous user from remaining logged in
  // ============================================================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('userId');
    await prefs.remove('userLoginId');
    await prefs.remove('userEmail');
    await prefs.remove('userRole');
    // Clear in-memory session
    currentUserId = null;
    currentUserLoginId = null;
    currentUserEmail = null;
    currentUserRole = null;
  }

  // ============================================================
  // BACKWARDS COMPATIBILITY
  //
  // Existing screens may still call clearSession().
  // Keep it so we don't break existing code.
  // ============================================================

  static Future<void> clearSession() async {
    await logout();
  }
}
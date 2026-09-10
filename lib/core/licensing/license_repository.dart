//lib/core/licensing/license_repository.dart

import 'license_provider.dart';
import 'license_state.dart';

class LicenseRepository {
  LicenseRepository({required this._provider});
  final LicenseProvider _provider;

  /// Initializes and returns the current licensing state.
  ///
  /// The repository does not know whether the provider is the
  /// local demo service or a future private commercial API.
  Future<LicenseState> initialize() {
    return _provider.initialize();
  }

  /// Returns whether the application currently has access.
  Future<bool> hasAccess() {
    return _provider.hasAccess();
  }
}

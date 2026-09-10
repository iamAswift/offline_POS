//lib/core/licensing/license_provider.dart

import 'license_state.dart';

abstract class LicenseProvider {
  Future<LicenseState> initialize();

  Future<bool> hasAccess();
}

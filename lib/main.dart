// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'database/app_database.dart';
import 'database/business_settings.dart';
import 'database/daos/settings_dao.dart';
import 'core/email/sale_email_worker.dart';
import 'core/system/installation_registration_service.dart';
import 'core/licensing/demo_license_service.dart';
import 'core/licensing/license_repository.dart';
import 'core/licensing/license_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------------------
  // DEDICATED INVENTORY TERMINAL
  // ------------------------------------------------------------
  //
  // Keep the tablet focused on the inventory application.
  //
  // Android will additionally need Lock Task / kiosk mode
  // configuration at the native Android level.
  //

  await _configureDedicatedTerminal();

  // ------------------------------------------------------------
  // INITIALIZE DATABASE
  // ------------------------------------------------------------

  final db = getDatabase();

  debugPrint('Database initialized');

  // Force database to open.
  await db.customSelect('SELECT 1').get();

  final settingsDao = SettingsDao(db);

  try {
    await InstallationRegistrationService.register(settingsDao);

    debugPrint('Creator Yard installation registered successfully.');
  } catch (e, stackTrace) {
    debugPrint('Creator Yard installation registration failed: $e');
    debugPrint('$stackTrace');
  }

  // ------------------------------------------------------------
  // INITIALIZE LOCAL DEMO LICENSING
  // ------------------------------------------------------------
  //
  // Establishes the 14-day demo state on first installation
  // and reuses the existing state on subsequent launches.
  //
  // Commercial license authority will remain outside the
  // public Flutter application.
  //

  final licenseRepository = LicenseRepository(
    provider: DemoLicenseService(settingsDao: settingsDao),
  );

  LicenseState? licenseState;

  try {
    licenseState = await licenseRepository.initialize();

    debugPrint(
      'Creator Yard license state: '
      '${licenseState.status.name}',
    );

    debugPrint(
      'Creator Yard license installation: '
      '${licenseState.installationId}',
    );

    if (licenseState.demoExpiresAt != null) {
      debugPrint(
        'Creator Yard demo expires: '
        '${licenseState.demoExpiresAt!.toIso8601String()}',
      );
    }
  } catch (e, stackTrace) {
    // Licensing initialization must not prevent the application
    // from starting. Access enforcement will be introduced
    // separately after this persistence layer is verified.
    debugPrint('Creator Yard licensing initialization failed: $e');
    debugPrint('$stackTrace');
  }

  // ------------------------------------------------------------
  // PROCESS PENDING SALE EMAILS
  // ------------------------------------------------------------
  //
  // Run independently so email delivery never delays app startup.
  //

  unawaited(SaleEmailWorker().processPendingJobs());

  // ------------------------------------------------------------
  // CHECK WHETHER THE SYSTEM HAS AN OWNER
  // ------------------------------------------------------------

  final userDao = getUserDao();

  final userCount = await userDao.getUserCount();

  debugPrint('Existing user accounts: $userCount');

  // ------------------------------------------------------------
  // START APP
  // ------------------------------------------------------------

  runApp(
    SupermarketApp(
      needsInitialSetup: userCount == 0,
      settingsDao: settingsDao,
      licenseState: licenseState,
    ),
  );
}

// ============================================================
// DEDICATED TERMINAL CONFIGURATION
// ============================================================

Future<void> _configureDedicatedTerminal() async {
  try {
    // ----------------------------------------------------------
    // Keep screen awake while the inventory terminal is active.
    // ----------------------------------------------------------

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // ----------------------------------------------------------
    // Force portrait orientation.
    //
    // If your supermarket tablet should operate in landscape,
    // change this to landscapeLeft / landscapeRight.
    // ----------------------------------------------------------

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    debugPrint('Dedicated inventory terminal configured');
  } catch (e) {
    debugPrint('Failed to configure dedicated terminal: $e');
  }
}

// ============================================================
// APPLICATION
// ============================================================

class SupermarketApp extends StatefulWidget {
  final bool needsInitialSetup;
  final SettingsDao settingsDao;
  final LicenseState? licenseState;

  const SupermarketApp({
    super.key,
    required this.needsInitialSetup,
    required this.settingsDao,
    required this.licenseState,
  });

  @override
  State<SupermarketApp> createState() => _SupermarketAppState();
}

// ============================================================
// APPLICATION STATE
// ============================================================

class _SupermarketAppState extends State<SupermarketApp> {
  ThemeMode _themeMode = ThemeMode.system;

  bool _themeLoaded = false;

  @override
  void initState() {
    super.initState();

    _loadTheme();
  }

  // ============================================================
  // LOAD THEME
  // ============================================================

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await widget.settingsDao.getSetting(
        BusinessSettings.themeMode,
      );

      ThemeMode themeMode;

      switch (savedTheme) {
        case 'light':
          themeMode = ThemeMode.light;
          break;

        case 'dark':
          themeMode = ThemeMode.dark;
          break;

        case 'system':
        default:
          themeMode = ThemeMode.system;
          break;
      }

      if (!mounted) return;

      setState(() {
        _themeMode = themeMode;
        _themeLoaded = true;
      });
    } catch (e) {
      debugPrint('Failed to load theme setting: $e');

      if (!mounted) return;

      setState(() {
        _themeMode = ThemeMode.system;
        _themeLoaded = true;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------
    // Keep the application alive while loading the theme.
    // ----------------------------------------------------------

    if (!_themeLoaded) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp.router(
      title: 'Creator Yard',

      // --------------------------------------------------------
      // THEMES
      // --------------------------------------------------------
      theme: AppTheme.light,

      darkTheme: AppTheme.dark,

      themeMode: _themeMode,

      // --------------------------------------------------------
      // ROUTER
      // --------------------------------------------------------
      routerConfig: appRouter(
        needsInitialSetup: widget.needsInitialSetup,
        licenseState: widget.licenseState,
      ),

      debugShowCheckedModeBanner: false,
    );
  }
}

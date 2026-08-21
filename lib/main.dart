// lib/main.dart

import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'database/app_database.dart';
import 'database/business_settings.dart';
import 'database/daos/settings_dao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------------------
  // INITIALIZE DATABASE
  // ------------------------------------------------------------

  final db = getDatabase();

  debugPrint('Database initialized');

  // Force database to open.
  await db.customSelect('SELECT 1').get();

  // ------------------------------------------------------------
  // CHECK WHETHER THE SYSTEM HAS AN OWNER
  // ------------------------------------------------------------

  final userDao = getUserDao();

  final userCount = await userDao.getUserCount();

  debugPrint(
    'Existing user accounts: $userCount',
  );

  // ------------------------------------------------------------
  // START APP
  // ------------------------------------------------------------

  runApp(
    SupermarketApp(
      needsInitialSetup: userCount == 0,
      settingsDao: SettingsDao(db),
    ),
  );
}

// ============================================================
// APPLICATION
// ============================================================

class SupermarketApp extends StatefulWidget {
  final bool needsInitialSetup;
  final SettingsDao settingsDao;

  const SupermarketApp({
    super.key,
    required this.needsInitialSetup,
    required this.settingsDao,
  });

  @override
  State<SupermarketApp> createState() =>
      _SupermarketAppState();
}

// ============================================================
// APPLICATION STATE
// ============================================================

class _SupermarketAppState
    extends State<SupermarketApp> {
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
      final savedTheme =
          await widget.settingsDao.getSetting(
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
      debugPrint(
        'Failed to load theme setting: $e',
      );

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
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Supermarket Inventory',

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
        needsInitialSetup:
            widget.needsInitialSetup,
      ),

      debugShowCheckedModeBanner: false,
    );
  }
}
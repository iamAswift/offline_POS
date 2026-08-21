// lib/core/theme/theme.dart

import 'package:flutter/material.dart';

import 'styles.dart';

class AppTheme {
  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      colorScheme: colorScheme,

      scaffoldBackgroundColor:
          AppColors.background,

      fontFamily: 'Poppins',

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      // ========================================================
      // CARD
      // ========================================================

      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),

      // ========================================================
      // INPUT FIELDS
      // ========================================================

      inputDecorationTheme:
          const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: AppColors.danger,
          ),
        ),

        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: AppColors.danger,
            width: 2,
          ),
        ),

        contentPadding:
            EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),

      // ========================================================
      // ELEVATED BUTTON
      // ========================================================

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,

          elevation: 0,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              AppColors.primary,

          side: const BorderSide(
            color: AppColors.primary,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================

      textButtonTheme:
          TextButtonThemeData(
        style:
            TextButton.styleFrom(
          foregroundColor:
              AppColors.primary,
        ),
      ),

      // ========================================================
      // DIVIDERS
      // ========================================================

      dividerTheme:
          const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),

      // ========================================================
      // SWITCH
      // ========================================================

      switchTheme:
          SwitchThemeData(
        thumbColor:
            WidgetStateProperty
                .resolveWith<Color?>(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }

            return null;
          },
        ),
      ),

      // ========================================================
      // CHECKBOX
      // ========================================================

      checkboxTheme:
          CheckboxThemeData(
        fillColor:
            WidgetStateProperty
                .resolveWith<Color?>(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }

            return null;
          },
        ),
      ),

      // ========================================================
      // RADIO
      // ========================================================

      radioTheme:
          RadioThemeData(
        fillColor:
            WidgetStateProperty
                .resolveWith<Color?>(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }

            return null;
          },
        ),
      ),

      // ========================================================
      // DROPDOWN
      // ========================================================

      dropdownMenuTheme:
          const DropdownMenuThemeData(
        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(),
        ),
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================

      snackBarTheme:
          const SnackBarThemeData(
        behavior:
            SnackBarBehavior.floating,
      ),

      // ========================================================
      // LIST TILE
      // ========================================================

      listTileTheme:
          const ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: AppColors.textPrimary,
      ),

      // ========================================================
      // TEXT THEME
      // ========================================================

      textTheme: const TextTheme(
        headlineSmall:
            AppTextStyles.heading,

        titleLarge:
            AppTextStyles.title,

        bodyLarge:
            AppTextStyles.body,

        bodyMedium:
            AppTextStyles.bodySecondary,

        bodySmall:
            AppTextStyles.small,
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      colorScheme: colorScheme,

      scaffoldBackgroundColor:
          const Color(0xFF101418),

      fontFamily: 'Poppins',

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme:
          const AppBarTheme(
        backgroundColor:
            Color(0xFF171C21),
        foregroundColor:
            Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      // ========================================================
      // CARD
      // ========================================================

      cardTheme:
          const CardThemeData(
        color: Color(0xFF171C21),
        elevation: 1,
        margin: EdgeInsets.zero,
        surfaceTintColor:
            Colors.transparent,
      ),

      // ========================================================
      // INPUT FIELDS
      // ========================================================

      inputDecorationTheme:
          const InputDecorationTheme(
        filled: true,
        fillColor:
            Color(0xFF1D242B),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: Color(0xFF343B43),
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: Color(0xFF343B43),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: AppColors.danger,
          ),
        ),

        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: AppColors.danger,
            width: 2,
          ),
        ),

        contentPadding:
            EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),

      // ========================================================
      // ELEVATED BUTTON
      // ========================================================

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,

          elevation: 0,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              AppColors.primary,

          side: const BorderSide(
            color: AppColors.primary,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================

      textButtonTheme:
          TextButtonThemeData(
        style:
            TextButton.styleFrom(
          foregroundColor:
              colorScheme.primary,
        ),
      ),

      // ========================================================
      // DIVIDERS
      // ========================================================

      dividerTheme:
          const DividerThemeData(
        color: Color(0xFF343B43),
        thickness: 1,
      ),

      // ========================================================
      // SWITCH
      // ========================================================

      switchTheme:
          SwitchThemeData(
        thumbColor:
            WidgetStateProperty
                .resolveWith<Color?>(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }

            return null;
          },
        ),
      ),

      // ========================================================
      // CHECKBOX
      // ========================================================

      checkboxTheme:
          CheckboxThemeData(
        fillColor:
            WidgetStateProperty
                .resolveWith<Color?>(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }

            return null;
          },
        ),
      ),

      // ========================================================
      // RADIO
      // ========================================================

      radioTheme:
          RadioThemeData(
        fillColor:
            WidgetStateProperty
                .resolveWith<Color?>(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }

            return null;
          },
        ),
      ),

      // ========================================================
      // DROPDOWN
      // ========================================================

      dropdownMenuTheme:
          const DropdownMenuThemeData(
        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor:
              Color(0xFF1D242B),
          border: OutlineInputBorder(),
        ),
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================

      snackBarTheme:
          const SnackBarThemeData(
        behavior:
            SnackBarBehavior.floating,
      ),

      // ========================================================
      // LIST TILE
      // ========================================================

      listTileTheme:
          const ListTileThemeData(
        iconColor:
            AppColors.primary,
        textColor: Colors.white,
      ),

      // ========================================================
      // TEXT THEME
      // ========================================================

      textTheme:
          const TextTheme(
        headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight:
              FontWeight.w700,
          color: Colors.white,
        ),

        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 17,
          fontWeight:
              FontWeight.w600,
          color: Colors.white,
        ),

        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          color: Colors.white,
        ),

        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color:
              Color(0xFFB0B8C1),
        ),

        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color:
              Color(0xFF98A2B3),
        ),
      ),
    );
  }
}
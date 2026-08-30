// lib/core/theme/styles.dart

import 'package:flutter/material.dart';

class AppColors {
  // ============================================================
  // BRAND
  // ============================================================

  static const primary = Color(0xFF1976D2);
  static const primaryDark = Color(0xFF1259A5);
  static const primaryLight = Color(0xFFEAF3FF);

  static const accent = Color(0xFFFFA000);
  static const accentLight = Color(0xFFFFF4D6);
  static const accentDark = Color(0xFFC67100);

  // ============================================================
  // BACKGROUNDS
  // ============================================================

  static const background = Color(0xFFF6F8FB);
  static const surface = Colors.white;
  static const surfaceSoft = Color(0xFFF9FAFC);

  // ============================================================
  // TEXT
  // ============================================================

  static const textPrimary = Color(0xFF17202A);
  static const textSecondary = Color(0xFF667085);
  static const textMuted = Color(0xFF98A2B3);

  // ============================================================
  // BORDERS / DIVIDERS
  // ============================================================

  static const border = Color(0xFFE4E7EC);
  static const divider = Color(0xFFEAECF0);

  // ============================================================
  // STATUS
  // ============================================================

  static const success = Color(0xFF12B76A);
  static const successLight = Color(0xFFE9F9F1);

  static const warning = Color(0xFFF79009);
  static const warningLight = Color(0xFFFFF4E5);

  static const danger = Color(0xFFF04438);
  static const dangerLight = Color(0xFFFFEFED);

  static const info = Color(0xFF2E90FA);
  static const infoLight = Color(0xFFEFF8FF);

  // ============================================================
  // REPORT COLORS
  // ============================================================

  static const sales = Colors.deepOrange;
  static const products = Colors.blueGrey;
  static const lowstocks = Colors.red;
  static const outstocks = Colors.redAccent;
  static const profit = Colors.green;
  static const inventory = Colors.indigo;

  // ============================================================
  // POS
  // ============================================================

  static const productCard = Colors.white;
  static const productText = textPrimary;
  static const productSubtitle = textSecondary;

  static const cash = Color(0xFF12B76A);
  static const pos = Color(0xFF7F56D9);
  static const transfer = Color(0xFF2E90FA);
  static const split = Color(0xFFF79009);
}

// ================================================================
// APP SPACING
// ================================================================

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double section = 48;
}

// ================================================================
// APP RADII
// ================================================================

class AppRadius {
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double round = 999;
}

// ================================================================
// APP SIZES
// ================================================================

class AppSizes {

  // General
  static const double buttonHeight = 48;
  static const double inputHeight = 52;

  static const double iconButton = 44;

  // Cards

  static const double cardMinHeight = 80;

  static const double maxContentWidth = 1200;

  static const double maxFormWidth = 440;
}

class AppTextStyles {
  static const heading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const title = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static const bodySecondary = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const small = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const price = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );


  // ============================================================
  // DASHBOARD
  // ============================================================

  static const dashboardTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 23,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const dashboardSubtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const dashboardCardTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const dashboardCardValue = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const dashboardCardSubtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    color: AppColors.textSecondary,
  );

  static const dashboardSectionTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const dashboardSectionSubtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    color: AppColors.textSecondary,
  );

  static const attendanceTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const attendanceSubtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    color: AppColors.textSecondary,
  );


  

  // ============================================================
  // FORM / OTHER
  // ============================================================


  static const EdgeInsets screenPadding = EdgeInsets.all(16);

  static const Color primaryColor = AppColors.primary;
}

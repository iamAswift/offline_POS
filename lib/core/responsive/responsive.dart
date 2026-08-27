//lib/core/responsive/responsive.dart

import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  double get width => MediaQuery.sizeOf(context).width;

  double get height => MediaQuery.sizeOf(context).height;

  // ============================================================
  // BREAKPOINTS
  // ============================================================

  bool get isCompact => width < AppBreakpoints.compact;

  bool get isTablet =>
      width >= AppBreakpoints.compact && width < AppBreakpoints.desktop;

  bool get isDesktop => width >= AppBreakpoints.desktop;

  bool get isLargeDesktop => width >= AppBreakpoints.largeDesktop;

  // ============================================================
  // LAYOUT
  // ============================================================

  double get horizontalPadding {
    if (isCompact) {
      return 16;
    }

    if (isTablet) {
      return 24;
    }

    if (isDesktop) {
      return 32;
    }

    return 40;
  }

  double get verticalPadding {
    if (isCompact) {
      return 16;
    }

    if (isTablet) {
      return 24;
    }

    return 32;
  }

  double get contentMaxWidth {
    if (isCompact) {
      return double.infinity;
    }

    if (isTablet) {
      return 720;
    }

    if (isDesktop) {
      return 1200;
    }

    return 1400;
  }

  // ============================================================
  // TOUCH / DENSITY
  // ============================================================

  bool get useLargeTouchTargets => isCompact || isTablet;

  double get controlHeight => useLargeTouchTargets ? 52 : 48;

  double get buttonHeight => useLargeTouchTargets ? 52 : 48;

  // ============================================================
  // COLUMNS
  // ============================================================

  int get gridColumns {
    if (isCompact) {
      return 2;
    }

    if (isTablet) {
      return 3;
    }

    if (isDesktop) {
      return 4;
    }

    return 5;
  }

  // ============================================================
  // PRODUCT GRID
  // ============================================================

  double get productCardAspectRatio {
    if (isCompact) {
      return 0.92;
    }

    if (isTablet) {
      return 1.02;
    }

    if (isDesktop) {
      return 1.12;
    }

    return 1.18;
  }

  // ============================================================
  // HELPER
  // ============================================================

  T value<T>({required T compact, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) {
      return desktop;
    }

    if (isTablet && tablet != null) {
      return tablet;
    }

    return compact;
  }
}

extension ResponsiveContext on BuildContext {
  Responsive get responsive => Responsive(this);
}

import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import '../theme/styles.dart';

class InventoryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const InventoryCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    final cardPadding =
        padding ??
        EdgeInsets.all(
          responsive.value(
            compact: AppSpacing.md,
            tablet: AppSpacing.lg,
            desktop: AppSpacing.lg,
          ),
        );

    final radius = responsive.value(
      compact: AppRadius.md,
      tablet: AppRadius.lg,
      desktop: AppRadius.lg,
    );

    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: cardPadding,
        child: child,
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}

class InventoryStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;

  const InventoryStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    final horizontalPadding = responsive.value(
      compact: AppSpacing.sm,
      tablet: AppSpacing.md,
      desktop: AppSpacing.md,
    );

    final verticalPadding = responsive.value(
      compact: 5.0,
      tablet: 6.0,
      desktop: 6.0,
    );

    final iconSize = responsive.value(
      compact: 13.0,
      tablet: 14.0,
      desktop: 14.0,
    );

    final spacing = responsive.value(
      compact: 5.0,
      tablet: 6.0,
      desktop: 6.0,
    );

    final radius = responsive.value(
      compact: AppRadius.sm,
      tablet: AppRadius.md,
      desktop: AppRadius.md,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: color,
            ),
            SizedBox(width: spacing),
          ],
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class InventorySectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const InventorySectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    final titleStyle = responsive.value(
      compact: AppTextStyles.title,
      tablet: AppTextStyles.title,
      desktop: AppTextStyles.heading,
    );

    final subtitleSpacing = responsive.value(
      compact: 3.0,
      tablet: AppSpacing.xs,
      desktop: AppSpacing.xs,
    );

    final columnSpacing = responsive.value(
      compact: AppSpacing.sm,
      tablet: AppSpacing.md,
      desktop: AppSpacing.md,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: titleStyle,
              ),
              if (subtitle != null) ...[
                SizedBox(height: subtitleSpacing),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: columnSpacing),
          trailing!,
        ],
      ],
    );
  }
}

class InventoryEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const InventoryEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return LayoutBuilder(
      builder: (context, constraints) {
        /*
         * The widget may be placed inside a very short area.
         *
         * Your original implementation used:
         *
         *   Padding.all(40)
         *
         * which consumes 80px vertically before the content
         * even begins.
         *
         * On the device Flutter reported a maximum height of
         * approximately 125px, which caused the 82px overflow.
         */

        final availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : double.infinity;

        final isVeryShort =
            availableHeight.isFinite && availableHeight < 150;

        final isCompactHeight =
            availableHeight.isFinite && availableHeight < 220;

        final horizontalPadding = responsive.value(
          compact: AppSpacing.lg,
          tablet: AppSpacing.xxl,
          desktop: AppSpacing.xxxl,
        );

        final verticalPadding = isVeryShort
            ? AppSpacing.sm
            : isCompactHeight
                ? AppSpacing.md
                : responsive.value(
                    compact: AppSpacing.xxl,
                    tablet: AppSpacing.xxxl,
                    desktop: AppSpacing.xxxl,
                  );

        final iconSize = isVeryShort
            ? 40.0
            : isCompactHeight
                ? 52.0
                : responsive.value(
                    compact: 64.0,
                    tablet: 72.0,
                    desktop: 72.0,
                  );

        final iconGraphicSize = isVeryShort
            ? 22.0
            : isCompactHeight
                ? 26.0
                : responsive.value(
                    compact: 30.0,
                    tablet: 34.0,
                    desktop: 34.0,
                  );

        final iconRadius = isVeryShort
            ? AppRadius.md
            : isCompactHeight
                ? AppRadius.lg
                : AppRadius.xl;

        final titleStyle = isVeryShort
            ? AppTextStyles.small.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              )
            : isCompactHeight
                ? AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : responsive.value(
                    compact: AppTextStyles.title,
                    tablet: AppTextStyles.title,
                    desktop: AppTextStyles.heading,
                  );

        final iconTitleSpacing = isVeryShort
            ? AppSpacing.sm
            : isCompactHeight
                ? AppSpacing.sm
                : AppSpacing.lg;

        final actionSpacing = isCompactHeight
            ? AppSpacing.sm
            : AppSpacing.lg;

        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(iconRadius),
              ),
              child: Icon(
                icon,
                size: iconGraphicSize,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: iconTitleSpacing),

            Text(
              title,
              style: titleStyle,
              textAlign: TextAlign.center,
            ),

            if (!isVeryShort) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],

            if (action != null) ...[
              SizedBox(height: actionSpacing),
              action!,
            ],
          ],
        );

        /*
         * If the parent gives us a very small bounded height,
         * allow the empty state to scroll instead of overflowing.
         */
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: content,
          ),
        );
      },
    );
  }
}
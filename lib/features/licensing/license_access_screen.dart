// lib/features/licensing/license_access_screen.dart

import 'package:flutter/material.dart';

import '../../core/licensing/license_state.dart';
import '../../core/theme/styles.dart';

class LicenseAccessScreen extends StatelessWidget {
  const LicenseAccessScreen({super.key, required this.licenseState});

  final LicenseState licenseState;

  @override
  Widget build(BuildContext context) {
    final isClockTampered = licenseState.status == LicenseStatus.clockTampered;

    final title = isClockTampered
        ? 'License Access Temporarily Blocked'
        : 'Demo Period Expired';

    final message = isClockTampered
        ? 'The system clock appears to have been moved backwards. '
              'Please restore the correct date and time, then restart Creator Yard.'
        : 'Your 14-day Creator Yard demo period has ended. '
              'Please activate a license to continue using the application.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxFormWidth,
              ),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isClockTampered ? Icons.schedule : Icons.lock_outline,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Installation ID',
                              style: AppTextStyles.small,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            SelectableText(
                              licenseState.installationId,
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'Contact Creator Yard support to activate this installation.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

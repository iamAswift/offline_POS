// lib/core/email/sale_email_worker.dart

import 'package:flutter/foundation.dart';

import '../../core/system/installation_identity.dart';
import '../../database/app_database.dart';
import '../../database/daos/sale_email_queue_dao.dart';
import '../../database/daos/settings_dao.dart';
import 'email_service.dart';

class SaleEmailWorker {
  final SaleEmailQueueDao _queueDao;
  final SettingsDao _settingsDao;

  static bool _isRunning = false;

  SaleEmailWorker({SaleEmailQueueDao? queueDao, SettingsDao? settingsDao})
    : _queueDao = queueDao ?? getSaleEmailQueueDao(),
      _settingsDao = settingsDao ?? SettingsDao(getDatabase());

  /// Processes pending sale-email jobs.
  ///
  /// This worker is deliberately independent from the sale transaction.
  /// Email failures must never affect a completed sale.
  ///
  /// The backend generates the deterministic usage reference from the
  /// queue job ID:
  ///
  ///     SALE-EMAIL-{job.id}
  ///
  /// This allows the backend to safely recognize retries and prevent
  /// the same email job from consuming more than one credit.
  ///
  /// Only one worker run is allowed at a time.
  ///
  /// Retryable failures are returned to "pending" so a later worker run
  /// can retry them. We intentionally process only one batch per run to
  /// avoid repeatedly hammering the email provider during an outage.
  Future<void> processPendingJobs({int limit = 20}) async {
    if (_isRunning) {
      debugPrint(
        'SaleEmailWorker: Already running. '
        'Skipping duplicate trigger.',
      );
      return;
    }

    _isRunning = true;

    try {
      final installationId = await InstallationIdentity.getInstallationId(
        _settingsDao,
      );

      debugPrint(
        'SaleEmailWorker: Using installation '
        '$installationId.',
      );

      // Recover jobs that were left in "sending" because the
      // application previously stopped or crashed.
      await _queueDao.resetSendingJobs();

      final jobs = await _queueDao.getPendingJobs(limit: limit);

      if (jobs.isEmpty) {
        debugPrint('SaleEmailWorker: No pending email jobs.');
        return;
      }

      debugPrint(
        'SaleEmailWorker: Processing '
        '${jobs.length} pending email job(s).',
      );

      for (final job in jobs) {
        await _processJob(job, installationId);
      }
    } catch (e, stackTrace) {
      debugPrint('SaleEmailWorker: Failed to process email queue: $e');
      debugPrint('$stackTrace');
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _processJob(SaleEmailQueue job, String installationId) async {
    final claimed = await _queueDao.markSending(job.id);

    if (!claimed) {
      debugPrint('SaleEmailWorker: Could not claim job #${job.id}.');
      return;
    }

    try {
      debugPrint(
        'SaleEmailWorker: Sending job #${job.id} '
        'for sale #${job.saleId}.',
      );

      await EmailService.sendSaleEmail(
        installationId: installationId,
        jobId: job.id,
        recipient: job.recipient,
        subject: job.subject,
        body: job.body,
      );

      await _queueDao.markSent(job.id);

      debugPrint('SaleEmailWorker: Job #${job.id} sent successfully.');
    } on EmailServiceException catch (e, stackTrace) {
      if (e.retryable) {
        // The backend may already have reserved the credit and
        // Resend may have accepted the email before the failure
        // became visible to the app.
        //
        // Keep the same job ID so the next attempt uses the same
        // SALE-EMAIL-{job.id} reference and the same Resend
        // idempotency key.
        await _queueDao.retrySendingJob(job.id);

        debugPrint(
          'SaleEmailWorker: Job #${job.id} '
          'will be retried. Error: ${e.message}',
        );
        debugPrint('$stackTrace');
        return;
      }

      final error = e.toString();

      await _queueDao.markFailed(job.id, error);

      debugPrint(
        'SaleEmailWorker: Job #${job.id} failed permanently: '
        '$error',
      );
      debugPrint('$stackTrace');
    } catch (e, stackTrace) {
      // Unexpected local errors are treated as retryable.
      //
      // We deliberately do not refund anything here because the
      // provider state may be unknown. The same job ID can safely
      // be retried through the backend idempotency mechanism.
      final error = e.toString();

      await _queueDao.retrySendingJob(job.id);

      debugPrint(
        'SaleEmailWorker: Job #${job.id} encountered an '
        'unexpected error and will be retried: $error',
      );
      debugPrint('$stackTrace');
    }
  }
}

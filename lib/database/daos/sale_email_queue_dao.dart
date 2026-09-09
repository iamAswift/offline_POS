// lib/database/daos/sale_email_queue_dao.dart

import 'package:drift/drift.dart';

import '../app_database.dart';

import '../tables/sale_email_queue_table.dart';

part 'sale_email_queue_dao.g.dart';

@DriftAccessor(tables: [SaleEmailQueues])
class SaleEmailQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SaleEmailQueueDaoMixin {
  SaleEmailQueueDao(super.db);

  // ============================================================
  // CREATE
  // ============================================================

  Future<int> createJob({
    required int saleId,
    required String recipient,
    required String subject,
    required String body,
  }) {
    return into(saleEmailQueues).insert(
      SaleEmailQueuesCompanion.insert(
        saleId: saleId,
        recipient: recipient,
        subject: subject,
        body: body,
      ),
    );
  }

  // ============================================================
  // READ
  // ============================================================

  Future<List<SaleEmailQueue>> getPendingJobs({int limit = 20}) {
    final query = select(saleEmailQueues)
      ..where((t) => t.status.equals('pending'))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
      ..limit(limit);

    return query.get();
  }

  Future<SaleEmailQueue?> getJobById(int id) {
    return (select(
      saleEmailQueues,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> countPendingJobs() async {
    final query = selectOnly(saleEmailQueues)
      ..addColumns([saleEmailQueues.id.count()])
      ..where(saleEmailQueues.status.equals('pending'));

    final row = await query.getSingle();

    return row.read(saleEmailQueues.id.count()) ?? 0;
  }

  // ============================================================
  // SENDING
  // ============================================================

  Future<bool> markSending(int id) async {
    final job = await getJobById(id);

    if (job == null) {
      return false;
    }

    final updated =
        await (update(saleEmailQueues)..where((t) => t.id.equals(id))).write(
          SaleEmailQueuesCompanion(
            status: const Value('sending'),
            attempts: Value(job.attempts + 1),
            lastAttemptAt: Value(DateTime.now()),
            lastError: const Value(null),
          ),
        );

    return updated > 0;
  }

  // ============================================================
  // SUCCESS
  // ============================================================

  Future<bool> markSent(int id) async {
    final updated =
        await (update(saleEmailQueues)..where((t) => t.id.equals(id))).write(
          SaleEmailQueuesCompanion(
            status: const Value('sent'),
            sentAt: Value(DateTime.now()),
            lastError: const Value(null),
          ),
        );

    return updated > 0;
  }

  // ============================================================
  // FAILURE
  // ============================================================

  Future<bool> markFailed(int id, String error) async {
    final updated =
        await (update(saleEmailQueues)..where((t) => t.id.equals(id))).write(
          SaleEmailQueuesCompanion(
            status: const Value('failed'),
            lastError: Value(error),
          ),
        );

    return updated > 0;
  }

  // ============================================================
  // RETRY
  // ============================================================

  Future<bool> retryFailedJob(int id) async {
    final updated =
        await (update(
          saleEmailQueues,
        )..where((t) => t.id.equals(id) & t.status.equals('failed'))).write(
          const SaleEmailQueuesCompanion(
            status: Value('pending'),
            lastError: Value(null),
          ),
        );

    return updated > 0;
  }

  Future<int> retryAllFailedJobs() {
    return (update(
      saleEmailQueues,
    )..where((t) => t.status.equals('failed'))).write(
      const SaleEmailQueuesCompanion(
        status: Value('pending'),
        lastError: Value(null),
      ),
    );
  }

  Future<bool> retrySendingJob(int id) async {
    final updated =
        await (update(
          saleEmailQueues,
        )..where((t) => t.id.equals(id) & t.status.equals('sending'))).write(
          const SaleEmailQueuesCompanion(
            status: Value('pending'),
            lastError: Value(null),
          ),
        );

    return updated > 0;
  }

  // ============================================================
  // RECOVERY
  // ============================================================

  Future<int> resetSendingJobs() {
    return (update(saleEmailQueues)..where((t) => t.status.equals('sending')))
        .write(const SaleEmailQueuesCompanion(status: Value('pending')));
  }
}

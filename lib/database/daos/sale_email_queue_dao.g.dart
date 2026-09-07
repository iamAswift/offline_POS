// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_email_queue_dao.dart';

// ignore_for_file: type=lint
mixin _$SaleEmailQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $SaleEmailQueuesTable get saleEmailQueues => attachedDatabase.saleEmailQueues;
  SaleEmailQueueDaoManager get managers => SaleEmailQueueDaoManager(this);
}

class SaleEmailQueueDaoManager {
  final _$SaleEmailQueueDaoMixin _db;
  SaleEmailQueueDaoManager(this._db);
  $$SaleEmailQueuesTableTableManager get saleEmailQueues =>
      $$SaleEmailQueuesTableTableManager(
        _db.attachedDatabase,
        _db.saleEmailQueues,
      );
}

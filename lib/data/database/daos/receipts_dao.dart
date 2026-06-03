import 'package:drift/drift.dart';
import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/tables/receipts_table.dart';

part 'receipts_dao.g.dart';

@DriftAccessor(tables: [ReceiptsTable])
class ReceiptsDao extends DatabaseAccessor<AppDatabase>
    with _$ReceiptsDaoMixin {
  ReceiptsDao(super.db);

  Future<int> insertReceipt(ReceiptsTableCompanion entry) =>
      into(db.receiptsTable).insert(entry);

  Future<List<ReceiptsTableData>> getReceiptsForDelivery(int deliveryId) =>
      (select(db.receiptsTable)
            ..where((t) => t.deliveryId.equals(deliveryId)))
          .get();
}

import 'package:drift/drift.dart';
import 'package:controle_entregas/data/database/tables/deliveries_table.dart';

class ReceiptsTable extends Table {
  @override
  String get tableName => 'receipts';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get deliveryId =>
      integer().references(DeliveriesTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get imagePath => text()();
  TextColumn get ocrRawText => text().nullable()();
  TextColumn get ocrConfidenceJson => text().nullable()();
  TextColumn get captureAttemptedAt => text()();
  BoolColumn get wasRetaken => boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text()();
}

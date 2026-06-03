import 'package:drift/drift.dart';
import 'package:controle_entregas/data/database/tables/routes_table.dart';
import 'package:controle_entregas/data/database/tables/shifts_table.dart';

class EarningsEntriesTable extends Table {
  @override
  String get tableName => 'earnings_entries';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get routeId =>
      integer().references(RoutesTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get shiftId =>
      integer().references(ShiftsTable, #id, onDelete: KeyAction.cascade)();
  // 'normal' | 'long_single_delivery'
  TextColumn get earningsType => text()();
  IntColumn get rateAppliedCents => integer()();
  IntColumn get routeDeliveryCount => integer()();
  RealColumn get routeDistanceKm => real().nullable()();
  TextColumn get classificationReason => text()();
  TextColumn get configSnapshot => text()(); // JSON
  TextColumn get createdAt => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {routeId},
      ];
}

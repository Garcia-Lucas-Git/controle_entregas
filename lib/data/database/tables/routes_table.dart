import 'package:drift/drift.dart';
import 'package:controle_entregas/data/database/tables/shifts_table.dart';

class RoutesTable extends Table {
  @override
  String get tableName => 'routes';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get shiftId =>
      integer().references(ShiftsTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get routeNumber => integer()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get startedAt => text()();
  TextColumn get closedAt => text().nullable()();
  IntColumn get deliveryCountAtClose => integer().nullable()();
  TextColumn get createdAt => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {shiftId, routeNumber},
      ];
}

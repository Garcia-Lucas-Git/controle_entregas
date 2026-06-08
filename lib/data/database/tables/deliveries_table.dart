import 'package:drift/drift.dart';
import 'package:controle_entregas/data/database/tables/routes_table.dart';
import 'package:controle_entregas/data/database/tables/shifts_table.dart';

class DeliveriesTable extends Table {
  @override
  String get tableName => 'deliveries';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get routeId =>
      integer().references(RoutesTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get shiftId =>
      integer().references(ShiftsTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get sequenceNumber => integer().withDefault(const Constant(1))();
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // pending|in_progress|completed
  TextColumn get customerName => text().nullable()();
  TextColumn get addressText => text()();
  RealColumn get distanceKm => real().nullable()();
  TextColumn get orderNumber => text().nullable()();
  IntColumn get orderValueCents => integer().nullable()();
  TextColumn get ocrRawText => text().nullable()();
  TextColumn get completedAt => text().nullable()();
  TextColumn get createdAt => text()();

  // iFood fields
  BoolColumn get needsIfoodConfirmation =>
      boolean().withDefault(const Constant(false))();
  TextColumn get deliveryIdentifier => text().nullable()();
  TextColumn get partnerCollectionCode => text().nullable()();
  BoolColumn get ifoodConfirmationSuccess => boolean().nullable()();
  TextColumn get ifoodConfirmedAt => text().nullable()();

  // Delivery flags
  BoolColumn get hasDrinks => boolean().withDefault(const Constant(false))();
  BoolColumn get needsCard => boolean().withDefault(const Constant(false))();
  BoolColumn get needsChange => boolean().withDefault(const Constant(false))();
  IntColumn get changeAmountCents => integer().nullable()();

  // Operational fields (v6)
  TextColumn get pizzaNumber => text().nullable()();
  TextColumn get houseNumber => text().nullable()();
  TextColumn get complement => text().nullable()();
  TextColumn get neighborhood => text().nullable()();
  TextColumn get drinkType => text().nullable()();
}

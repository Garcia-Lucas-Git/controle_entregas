import 'package:drift/drift.dart';
import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/tables/deliveries_table.dart';

part 'deliveries_dao.g.dart';

@DriftAccessor(tables: [DeliveriesTable])
class DeliveriesDao extends DatabaseAccessor<AppDatabase>
    with _$DeliveriesDaoMixin {
  DeliveriesDao(super.db);

  Future<int> insertDelivery(DeliveriesTableCompanion entry) =>
      into(db.deliveriesTable).insert(entry);

  Future<bool> updateDelivery(DeliveriesTableCompanion entry) =>
      update(db.deliveriesTable).replace(entry);

  Stream<List<DeliveriesTableData>> watchDeliveriesForRoute(int routeId) =>
      (select(db.deliveriesTable)
            ..where((t) => t.routeId.equals(routeId))
            ..orderBy([(t) => OrderingTerm.asc(t.sequenceNumber)]))
          .watch();

  Future<List<DeliveriesTableData>> getDeliveriesForRoute(int routeId) =>
      (select(db.deliveriesTable)
            ..where((t) => t.routeId.equals(routeId))
            ..orderBy([(t) => OrderingTerm.asc(t.sequenceNumber)]))
          .get();

  Future<DeliveriesTableData?> getDeliveryById(int id) =>
      (select(db.deliveriesTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<DeliveriesTableData?> watchDeliveryById(int id) =>
      (select(db.deliveriesTable)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<int> countCompletedInRoute(int routeId) async {
    final rows = await (select(db.deliveriesTable)
          ..where((t) =>
              t.routeId.equals(routeId) & t.status.equals('completed')))
        .get();
    return rows.length;
  }

  Future<int> completeDelivery({
    required int id,
    required String completedAt,
    double? distanceKm,
  }) =>
      (update(db.deliveriesTable)..where((t) => t.id.equals(id))).write(
        DeliveriesTableCompanion(
          status: const Value('completed'),
          completedAt: Value(completedAt),
          distanceKm: Value(distanceKm),
        ),
      );

  Future<int> setInProgress(int id) =>
      (update(db.deliveriesTable)..where((t) => t.id.equals(id))).write(
        const DeliveriesTableCompanion(
          status: Value('in_progress'),
        ),
      );

  Future<int> updateIfoodConfirmation({
    required int id,
    required bool success,
    required String confirmedAt,
  }) =>
      (update(db.deliveriesTable)..where((t) => t.id.equals(id))).write(
        DeliveriesTableCompanion(
          ifoodConfirmationSuccess: Value(success),
          ifoodConfirmedAt: Value(confirmedAt),
        ),
      );

  Future<List<DeliveriesTableData>> getDeliveriesForShift(int shiftId) =>
      (select(db.deliveriesTable)
            ..where((t) =>
                t.shiftId.equals(shiftId) & t.status.equals('completed'))
            ..orderBy([(t) => OrderingTerm.asc(t.completedAt)]))
          .get();
}

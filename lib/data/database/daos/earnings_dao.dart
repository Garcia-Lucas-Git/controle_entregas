import 'package:drift/drift.dart';
import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/tables/earnings_entries_table.dart';
import 'package:controle_entregas/data/database/tables/earnings_config_table.dart';

part 'earnings_dao.g.dart';

@DriftAccessor(tables: [EarningsEntriesTable, EarningsConfigTable])
class EarningsDao extends DatabaseAccessor<AppDatabase>
    with _$EarningsDaoMixin {
  EarningsDao(super.db);

  Future<int> insertEarningsEntry(EarningsEntriesTableCompanion entry) =>
      into(db.earningsEntriesTable).insert(entry);

  Future<List<EarningsEntriesTableData>> getEntriesForShift(int shiftId) =>
      (select(
        db.earningsEntriesTable,
      )..where((t) => t.shiftId.equals(shiftId))).get();

  Stream<List<EarningsEntriesTableData>> watchEntriesForShift(int shiftId) =>
      (select(
        db.earningsEntriesTable,
      )..where((t) => t.shiftId.equals(shiftId))).watch();

  Future<EarningsEntriesTableData?> getEntryForRoute(int routeId) =>
      (select(db.earningsEntriesTable)
            ..where((t) => t.routeId.equals(routeId))
            ..limit(1))
          .getSingleOrNull();

  Future<int> updateEntryDeliveryCount(int routeId, int newCount) =>
      (update(
        db.earningsEntriesTable,
      )..where((t) => t.routeId.equals(routeId))).write(
        EarningsEntriesTableCompanion(routeDeliveryCount: Value(newCount)),
      );

  Future<int> updateRouteEntry({
    required int routeId,
    required String earningsType,
    required int rateAppliedCents,
    required int routeDeliveryCount,
    required double? routeDistanceKm,
    required String classificationReason,
    required String configSnapshot,
  }) =>
      (update(
        db.earningsEntriesTable,
      )..where((t) => t.routeId.equals(routeId))).write(
        EarningsEntriesTableCompanion(
          earningsType: Value(earningsType),
          rateAppliedCents: Value(rateAppliedCents),
          routeDeliveryCount: Value(routeDeliveryCount),
          routeDistanceKm: Value(routeDistanceKm),
          classificationReason: Value(classificationReason),
          configSnapshot: Value(configSnapshot),
        ),
      );

  Future<int> deleteEntryForRoute(int routeId) => (delete(
    db.earningsEntriesTable,
  )..where((t) => t.routeId.equals(routeId))).go();

  Future<EarningsConfigTableData?> getCurrentConfig() =>
      (select(db.earningsConfigTable)
            ..where((t) => t.isCurrent.equals(true))
            ..limit(1))
          .getSingleOrNull();

  Future<int> insertConfig(EarningsConfigTableCompanion entry) =>
      into(db.earningsConfigTable).insert(entry);

  Future<int> updateCurrentConfig({
    required int baseRateCents,
    required int longSingleDeliveryRateCents,
    required String effectiveFrom,
  }) async {
    await (update(db.earningsConfigTable)
          ..where((t) => t.isCurrent.equals(true)))
        .write(const EarningsConfigTableCompanion(isCurrent: Value(false)));
    return into(db.earningsConfigTable).insert(
      EarningsConfigTableCompanion(
        baseRateCents: Value(baseRateCents),
        longSingleDeliveryRateCents: Value(longSingleDeliveryRateCents),
        effectiveFrom: Value(effectiveFrom),
        isCurrent: const Value(true),
        createdAt: Value(effectiveFrom),
      ),
    );
  }
}

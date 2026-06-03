import 'package:drift/drift.dart';
import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/tables/routes_table.dart';

part 'routes_dao.g.dart';

@DriftAccessor(tables: [RoutesTable])
class RoutesDao extends DatabaseAccessor<AppDatabase> with _$RoutesDaoMixin {
  RoutesDao(super.db);

  Future<int> insertRoute(RoutesTableCompanion entry) =>
      into(db.routesTable).insert(entry);

  Stream<List<RoutesTableData>> watchRoutesForShift(int shiftId) =>
      (select(db.routesTable)
            ..where((t) => t.shiftId.equals(shiftId))
            ..orderBy([(t) => OrderingTerm.asc(t.routeNumber)]))
          .watch();

  Future<List<RoutesTableData>> getRoutesForShift(int shiftId) =>
      (select(db.routesTable)
            ..where((t) => t.shiftId.equals(shiftId))
            ..orderBy([(t) => OrderingTerm.asc(t.routeNumber)]))
          .get();

  Future<RoutesTableData?> getRouteById(int id) =>
      (select(db.routesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<RoutesTableData?> watchRouteById(int id) => (select(
    db.routesTable,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<int> getNextRouteNumber(int shiftId) async {
    final routes = await getRoutesForShift(shiftId);
    return routes.isEmpty ? 1 : routes.last.routeNumber + 1;
  }

  Future<int> closeRoute({
    required int id,
    required String closedAt,
    required int deliveryCountAtClose,
  }) => (update(db.routesTable)..where((t) => t.id.equals(id))).write(
    RoutesTableCompanion(
      status: const Value('closed'),
      closedAt: Value(closedAt),
      deliveryCountAtClose: Value(deliveryCountAtClose),
    ),
  );
}

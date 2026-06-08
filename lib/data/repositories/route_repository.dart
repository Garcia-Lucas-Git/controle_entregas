import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/daos/routes_dao.dart';
import 'package:controle_entregas/domain/entities/route_entity.dart';
import 'package:controle_entregas/domain/enums/route_status.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:drift/drift.dart';

class RouteRepository {
  final RoutesDao _dao;

  RouteRepository(AppDatabase db) : _dao = db.routesDao;

  Stream<List<RouteEntity>> watchRoutesForShift(int shiftId) =>
      _dao.watchRoutesForShift(shiftId).map((r) => r.map(_fromRow).toList());

  Future<List<RouteEntity>> getRoutesForShift(int shiftId) async {
    final rows = await _dao.getRoutesForShift(shiftId);
    return rows.map(_fromRow).toList();
  }

  Future<RouteEntity?> getById(int id) async {
    final row = await _dao.getRouteById(id);
    return row != null ? _fromRow(row) : null;
  }

  Stream<RouteEntity?> watchById(int id) =>
      _dao.watchRouteById(id).map((r) => r != null ? _fromRow(r) : null);

  Future<int> createRoute(int shiftId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final number = await _dao.getNextRouteNumber(shiftId);
    final id = await _dao.insertRoute(
      RoutesTableCompanion(
        shiftId: Value(shiftId),
        routeNumber: Value(number),
        status: const Value('open'),
        startedAt: Value(now),
        createdAt: Value(now),
      ),
    );
    AppLogger.log(
      LogEvents.routeCreated,
      module: 'RouteRepository',
      metadata: {'route_id': id, 'shift_id': shiftId, 'route_number': number},
    );
    return id;
  }

  Future<void> closeRoute({
    required int id,
    required int deliveryCountAtClose,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _dao.closeRoute(
      id: id,
      closedAt: now,
      deliveryCountAtClose: deliveryCountAtClose,
    );
    AppLogger.log(
      LogEvents.routeClosed,
      module: 'RouteRepository',
      metadata: {'route_id': id, 'delivery_count': deliveryCountAtClose},
    );
  }

  Future<void> deleteRoute(int id) async {
    final sid = SessionManager.generate('ROUTE');
    AppLogger.info(
      LogEvents.routeDeleteRequest,
      module: 'RouteRepository',
      sessionId: sid,
      metadata: {'route_id': id},
    );
    await _dao.deleteRouteById(id);
    AppLogger.info(
      LogEvents.routeDeleteSuccess,
      module: 'RouteRepository',
      sessionId: sid,
      metadata: {'route_id': id},
    );
  }

  static RouteEntity _fromRow(RoutesTableData r) => RouteEntity(
    id: r.id,
    shiftId: r.shiftId,
    routeNumber: r.routeNumber,
    status: RouteStatus.fromJson(r.status),
    startedAt: DateTime.parse(r.startedAt),
    closedAt: r.closedAt != null ? DateTime.parse(r.closedAt!) : null,
    deliveryCountAtClose: r.deliveryCountAtClose,
    createdAt: DateTime.parse(r.createdAt),
  );
}

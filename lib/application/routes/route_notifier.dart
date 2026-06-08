import 'package:controle_entregas/application/earnings/earnings_notifier.dart';
import 'package:controle_entregas/application/shifts/shift_notifier.dart';
import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:controle_entregas/domain/entities/route_entity.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'route_notifier.g.dart';

@riverpod
Stream<List<RouteEntity>> routesForShift(RoutesForShiftRef ref, int shiftId) =>
    ref.watch(routeRepositoryProvider).watchRoutesForShift(shiftId);

@riverpod
Stream<RouteEntity?> routeById(RouteByIdRef ref, int routeId) =>
    ref.watch(routeRepositoryProvider).watchById(routeId);

@riverpod
class RouteNotifier extends _$RouteNotifier {
  @override
  Future<void> build() async {}

  Future<int> createRoute(int shiftId) =>
      ref.read(routeRepositoryProvider).createRoute(shiftId);

  /// Closes the route and records the earnings entry.
  Future<void> closeRoute(int routeId) async {
    final deliveries = await ref
        .read(deliveryRepositoryProvider)
        .getDeliveriesForRoute(routeId);

    final completed = deliveries.where((d) => d.isCompleted).toList();

    await ref
        .read(routeRepositoryProvider)
        .closeRoute(id: routeId, deliveryCountAtClose: completed.length);

    // Fetch the route to get shiftId
    final route = await ref.read(routeRepositoryProvider).getById(routeId);
    if (route == null) return;

    await ref
        .read(earningsRepositoryProvider)
        .classifyAndSaveRoute(
          routeId: routeId,
          shiftId: route.shiftId,
          deliveryCountAtClose: completed.length,
          completedDeliveries: completed,
        );
    ref.invalidate(routesForShiftProvider(route.shiftId));
    ref.invalidate(routeByIdProvider(routeId));
  }

  Future<void> delete(int routeId, {required int shiftId}) async {
    await ref.read(routeRepositoryProvider).deleteRoute(routeId);
    // Remove earnings entry explicitly; CASCADE may not fire without PRAGMA foreign_keys = ON.
    await ref.read(earningsRepositoryProvider).deleteEntryForRoute(routeId);
    final totals = await _syncShiftTotalsFromLiveRoutes(shiftId);

    AppLogger.log(
      LogEvents.ocrRouteDeleted,
      module: 'RouteNotifier',
      metadata: {
        'route_id': routeId,
        'shift_id': shiftId,
        'new_total_cents': totals.totalCents,
        'new_delivery_count': totals.deliveryCount,
      },
    );
    AppLogger.log(
      LogEvents.shiftTotalsRecalculated,
      module: 'RouteNotifier',
      metadata: {
        'shift_id': shiftId,
        'delivery_count': totals.deliveryCount,
        'total_cents': totals.totalCents,
      },
    );
    ref.invalidate(routesForShiftProvider(shiftId));
    ref.invalidate(routeByIdProvider(routeId));
    ref.invalidate(allShiftsProvider);
    ref.invalidate(shiftReportDataProvider(shiftId));
  }

  Future<({int totalCents, int deliveryCount})> _syncShiftTotalsFromLiveRoutes(
    int shiftId,
  ) async {
    final routes = await ref
        .read(routeRepositoryProvider)
        .getRoutesForShift(shiftId);
    final closedRoutes = routes.where((r) => r.isClosed).toList();
    final earningsRepo = ref.read(earningsRepositoryProvider);

    for (final route in closedRoutes) {
      final deliveries = await ref
          .read(deliveryRepositoryProvider)
          .getDeliveriesForRoute(route.id);
      final completed = deliveries.where((d) => d.isCompleted).toList();
      await earningsRepo.syncRouteEntry(
        routeId: route.id,
        shiftId: shiftId,
        completedDeliveries: completed,
      );
    }

    final closedRouteIds = closedRoutes.map((r) => r.id).toSet();
    final entries = await earningsRepo.getEntriesForShift(shiftId);
    for (final entry in entries.where(
      (e) => !closedRouteIds.contains(e.routeId),
    )) {
      await earningsRepo.deleteEntryForRoute(entry.routeId);
    }
    final liveEntries = entries.where(
      (e) => closedRouteIds.contains(e.routeId),
    );
    final newTotal = liveEntries.fold(0, (s, e) => s + e.routeTotal.cents);
    final newCount = liveEntries.fold(0, (s, e) => s + e.routeDeliveryCount);
    await ref
        .read(shiftRepositoryProvider)
        .updateTotals(
          id: shiftId,
          totalEarningsCents: newTotal,
          deliveryCount: newCount,
        );
    return (totalCents: newTotal, deliveryCount: newCount);
  }
}

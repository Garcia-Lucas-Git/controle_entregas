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
    // CASCADE removes earnings entry; recalculate shift totals from what remains.
    final entries = await ref
        .read(earningsRepositoryProvider)
        .getEntriesForShift(shiftId);
    final newTotal = entries.fold(0, (s, e) => s + e.routeTotal.cents);
    final newCount = entries.fold(0, (s, e) => s + e.routeDeliveryCount);
    await ref
        .read(shiftRepositoryProvider)
        .updateTotals(
          id: shiftId,
          totalEarningsCents: newTotal,
          deliveryCount: newCount,
        );
    AppLogger.log(
      LogEvents.ocrRouteDeleted,
      module: 'RouteNotifier',
      metadata: {
        'route_id': routeId,
        'shift_id': shiftId,
        'new_total_cents': newTotal,
        'new_delivery_count': newCount,
      },
    );
    ref.invalidate(routesForShiftProvider(shiftId));
    ref.invalidate(routeByIdProvider(routeId));
    ref.invalidate(allShiftsProvider);
  }
}

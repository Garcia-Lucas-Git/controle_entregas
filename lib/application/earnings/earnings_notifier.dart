import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:controle_entregas/services/report_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'earnings_notifier.g.dart';

@riverpod
Future<ShiftReportData> shiftReportData(
  ShiftReportDataRef ref,
  int shiftId,
) async {
  final shiftRepo = ref.watch(shiftRepositoryProvider);
  final routeRepo = ref.watch(routeRepositoryProvider);
  final earningsRepo = ref.watch(earningsRepositoryProvider);
  final deliveryRepo = ref.watch(deliveryRepositoryProvider);

  final shift = await shiftRepo.getById(shiftId);
  if (shift == null) throw StateError('Shift $shiftId not found');

  final routes = await routeRepo.getRoutesForShift(shiftId);
  final entries = await earningsRepo.getEntriesForShift(shiftId);

  final routesWithEarnings = routes
      .where((r) => r.isClosed)
      .map((r) {
        final entry = entries.where((e) => e.routeId == r.id).firstOrNull;
        if (entry == null) return null;
        return RouteWithEarnings(route: r, entry: entry);
      })
      .whereType<RouteWithEarnings>()
      .toList();

  final neighborhoods = <int, List<String>>{};
  for (final route in routesWithEarnings) {
    final deliveries = await deliveryRepo.getDeliveriesForRoute(route.route.id);
    neighborhoods[route.route.id] = deliveries
        .map((d) => d.neighborhood?.trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();
  }

  return ShiftReportData(
    shift: shift,
    routes: routesWithEarnings,
    routeNeighborhoods: neighborhoods,
  );
}

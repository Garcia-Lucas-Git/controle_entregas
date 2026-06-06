import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shift_notifier.g.dart';

@riverpod
Stream<Shift?> openShift(OpenShiftRef ref) =>
    ref.watch(shiftRepositoryProvider).watchOpenShift();

@riverpod
Stream<List<Shift>> allShifts(AllShiftsRef ref) =>
    ref.watch(shiftRepositoryProvider).watchAllShifts();

@riverpod
class ShiftNotifier extends _$ShiftNotifier {
  @override
  Future<Shift?> build() => ref.watch(shiftRepositoryProvider).getOpenShift();

  Future<int> openShift() async {
    final settings = await ref.read(settingsRepositoryProvider).getSettings();
    final id = await ref
        .read(shiftRepositoryProvider)
        .openShift(settings.driverName);
    ref.invalidateSelf();
    return id;
  }

  Future<void> closeShift({int? fuelExpenseCents}) async {
    final shift = await future;
    if (shift == null) return;

    final entries = await ref
        .read(earningsRepositoryProvider)
        .getEntriesForShift(shift.id);

    AppLogger.info(
      LogEvents.financialCalcStart,
      module: 'ShiftNotifier',
      metadata: {'shift_id': shift.id, 'route_count': entries.length},
    );

    int totalCents = 0;
    int deliveryCount = 0;
    for (final e in entries) {
      final routeTotal = e.routeTotal.cents;
      totalCents += routeTotal;
      deliveryCount += e.routeDeliveryCount;
      AppLogger.info(
        LogEvents.financialDeliveryValue,
        module: 'ShiftNotifier',
        metadata: {
          'route_id': e.routeId,
          'delivery_count': e.routeDeliveryCount,
          'rate_cents': e.rateApplied.cents,
        },
      );
      AppLogger.info(
        LogEvents.financialRouteTotal,
        module: 'ShiftNotifier',
        metadata: {
          'route_id': e.routeId,
          'route_total_cents': routeTotal,
        },
      );
    }

    AppLogger.info(
      LogEvents.financialCalcComplete,
      module: 'ShiftNotifier',
      metadata: {
        'shift_id': shift.id,
        'total_cents': totalCents,
        'total_deliveries': deliveryCount,
      },
    );

    if (fuelExpenseCents != null && fuelExpenseCents > 0) {
      AppLogger.info(
        LogEvents.fuelExpenseRecorded,
        module: 'ShiftNotifier',
        metadata: {
          'shift_id': shift.id,
          'fuel_cents': fuelExpenseCents,
          'revenue_cents': totalCents,
          'profit_cents': totalCents - fuelExpenseCents,
        },
      );
    }

    await ref
        .read(shiftRepositoryProvider)
        .closeShift(
          id: shift.id,
          totalEarningsCents: totalCents,
          deliveryCount: deliveryCount,
          fuelExpenseCents: fuelExpenseCents,
        );

    ref.invalidateSelf();
  }
}

@riverpod
class HistoricalEntryNotifier extends _$HistoricalEntryNotifier {
  @override
  Future<void> build() async {}

  Future<void> save({
    required DateTime date,
    required int deliveryCount,
    required int earningsCents,
    double? hoursWorked,
    String? notes,
    int? fuelExpenseCents,
  }) async {
    final settings = await ref.read(settingsRepositoryProvider).getSettings();
    await ref
        .read(shiftRepositoryProvider)
        .insertHistoricalEntry(
          driverName: settings.driverName,
          date: date,
          deliveryCount: deliveryCount,
          earningsCents: earningsCents,
          hoursWorked: hoursWorked,
          notes: notes,
          fuelExpenseCents: fuelExpenseCents,
        );
    AppLogger.info(
      LogEvents.historyEntryCreated,
      module: 'HistoricalEntryNotifier',
      metadata: {'deliveries': deliveryCount, 'earnings_cents': earningsCents},
    );
  }

  Future<void> updateEntry({
    required int id,
    required DateTime date,
    required int deliveryCount,
    required int earningsCents,
    double? hoursWorked,
    String? notes,
    int? fuelExpenseCents,
  }) async {
    await ref
        .read(shiftRepositoryProvider)
        .updateHistoricalEntry(
          id: id,
          date: date,
          deliveryCount: deliveryCount,
          earningsCents: earningsCents,
          hoursWorked: hoursWorked,
          notes: notes,
          fuelExpenseCents: fuelExpenseCents,
        );
    AppLogger.info(
      LogEvents.historyEntryUpdated,
      module: 'HistoricalEntryNotifier',
      metadata: {'id': id},
    );
  }

  Future<void> delete(int id) async {
    await ref.read(shiftRepositoryProvider).deleteHistoricalEntry(id);
    AppLogger.info(
      LogEvents.historyEntryDeleted,
      module: 'HistoricalEntryNotifier',
      metadata: {'id': id},
    );
    ref.invalidate(allShiftsProvider);
  }

  Future<void> clearHistory() async {
    await ref.read(shiftRepositoryProvider).clearHistory();
    ref.invalidate(allShiftsProvider);
  }
}

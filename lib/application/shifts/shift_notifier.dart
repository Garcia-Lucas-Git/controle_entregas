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

  Future<void> closeShift() async {
    final shift = await future;
    if (shift == null) return;

    final entries = await ref
        .read(earningsRepositoryProvider)
        .getEntriesForShift(shift.id);

    final totalCents = entries.fold(0, (sum, e) => sum + e.rateApplied.cents);
    final deliveryCount = entries.fold(
      0,
      (sum, e) => sum + e.routeDeliveryCount,
    );

    await ref
        .read(shiftRepositoryProvider)
        .closeShift(
          id: shift.id,
          totalEarningsCents: totalCents,
          deliveryCount: deliveryCount,
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
  }
}

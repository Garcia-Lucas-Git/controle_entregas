import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/daos/shifts_dao.dart';
import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/domain/enums/shift_status.dart';
import 'package:controle_entregas/domain/value_objects/money.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:drift/drift.dart';

class ShiftRepository {
  final ShiftsDao _dao;

  ShiftRepository(AppDatabase db) : _dao = db.shiftsDao;

  Stream<List<Shift>> watchAllShifts() =>
      _dao.watchAllShifts().map((rows) => rows.map(_fromRow).toList());

  Stream<Shift?> watchOpenShift() =>
      _dao.watchOpenShift().map((r) => r != null ? _fromRow(r) : null);

  Future<Shift?> getOpenShift() async {
    final row = await _dao.getOpenShift();
    return row != null ? _fromRow(row) : null;
  }

  Future<Shift?> getById(int id) async {
    final row = await _dao.getShiftById(id);
    return row != null ? _fromRow(row) : null;
  }

  Future<int> openShift(String driverName) {
    final now = DateTime.now().toUtc().toIso8601String();
    return _dao.insertShift(
      ShiftsTableCompanion(
        driverName: Value(driverName),
        startedAt: Value(now),
        status: const Value('open'),
        createdAt: Value(now),
      ),
    );
  }

  Future<void> closeShift({
    required int id,
    required int totalEarningsCents,
    required int deliveryCount,
    int? fuelExpenseCents,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return _dao.closeShift(
      id: id,
      endedAt: now,
      totalEarningsCents: totalEarningsCents,
      deliveryCount: deliveryCount,
      fuelExpenseCents: fuelExpenseCents,
    );
  }

  Future<int> insertHistoricalEntry({
    required String driverName,
    required DateTime date,
    required int deliveryCount,
    required int earningsCents,
    double? hoursWorked,
    String? notes,
  }) {
    final dateStr = DateTime(
      date.year,
      date.month,
      date.day,
    ).toUtc().toIso8601String();
    final now = DateTime.now().toUtc().toIso8601String();
    return _dao.insertShift(
      ShiftsTableCompanion(
        driverName: Value(driverName),
        startedAt: Value(dateStr),
        endedAt: Value(dateStr),
        status: const Value('closed'),
        totalEarningsCents: Value(earningsCents),
        deliveryCount: Value(deliveryCount),
        notes: Value(notes),
        source: const Value('historical'),
        hoursWorked: Value(hoursWorked),
        createdAt: Value(now),
      ),
    );
  }

  Future<void> updateHistoricalEntry({
    required int id,
    required DateTime date,
    required int deliveryCount,
    required int earningsCents,
    double? hoursWorked,
    String? notes,
  }) {
    final dateStr = DateTime(
      date.year,
      date.month,
      date.day,
    ).toUtc().toIso8601String();
    return _dao.updateHistoricalShift(
      id: id,
      dateStr: dateStr,
      deliveryCount: deliveryCount,
      earningsCents: earningsCents,
      hoursWorked: hoursWorked,
      notes: notes,
    );
  }

  Future<void> deleteHistoricalEntry(int id) async {
    AppLogger.info(
      LogEvents.historyDeleteRequest,
      module: 'ShiftRepository',
      metadata: {'shift_id': id},
    );
    await _dao.deleteShiftById(id);
    AppLogger.info(
      LogEvents.historyDeleteSuccess,
      module: 'ShiftRepository',
      metadata: {'shift_id': id},
    );
  }

  Future<void> clearHistory() async {
    AppLogger.info(LogEvents.cleanupStart, module: 'ShiftRepository');
    AppLogger.info(LogEvents.historyDeleteRequest, module: 'ShiftRepository');
    final count = await _dao.deleteClosedShifts();
    AppLogger.info(
      LogEvents.historyDeleteSuccess,
      module: 'ShiftRepository',
      metadata: {'deleted': count},
    );
    AppLogger.info(
      LogEvents.cleanupComplete,
      module: 'ShiftRepository',
      metadata: {'deleted': count},
    );
  }

  static Shift _fromRow(ShiftsTableData r) => Shift(
    id: r.id,
    driverName: r.driverName,
    startedAt: DateTime.parse(r.startedAt),
    endedAt: r.endedAt != null ? DateTime.parse(r.endedAt!) : null,
    status: ShiftStatus.fromJson(r.status),
    totalEarnings: Money(r.totalEarningsCents ?? 0),
    deliveryCount: r.deliveryCount ?? 0,
    notes: r.notes,
    createdAt: DateTime.parse(r.createdAt),
    source: r.source,
    hoursWorked: r.hoursWorked,
    fuelExpenseCents: r.fuelExpenseCents,
  );
}

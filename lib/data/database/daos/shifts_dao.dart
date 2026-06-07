import 'package:drift/drift.dart';
import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/tables/shifts_table.dart';

part 'shifts_dao.g.dart';

@DriftAccessor(tables: [ShiftsTable])
class ShiftsDao extends DatabaseAccessor<AppDatabase> with _$ShiftsDaoMixin {
  ShiftsDao(super.db);

  Future<int> insertShift(ShiftsTableCompanion entry) =>
      into(db.shiftsTable).insert(entry);

  Future<bool> updateShift(ShiftsTableCompanion entry) =>
      update(db.shiftsTable).replace(entry);

  Stream<List<ShiftsTableData>> watchAllShifts() => (select(
    db.shiftsTable,
  )..orderBy([(t) => OrderingTerm.desc(t.startedAt)])).watch();

  Future<ShiftsTableData?> getOpenShift() =>
      (select(db.shiftsTable)
            ..where((t) => t.status.equals('open'))
            ..limit(1))
          .getSingleOrNull();

  Stream<ShiftsTableData?> watchOpenShift() =>
      (select(db.shiftsTable)
            ..where((t) => t.status.equals('open'))
            ..limit(1))
          .watchSingleOrNull();

  Future<ShiftsTableData?> getShiftById(int id) =>
      (select(db.shiftsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> updateTotals({
    required int id,
    required int totalEarningsCents,
    required int deliveryCount,
  }) => (update(db.shiftsTable)..where((t) => t.id.equals(id))).write(
    ShiftsTableCompanion(
      totalEarningsCents: Value(totalEarningsCents),
      deliveryCount: Value(deliveryCount),
    ),
  );

  Future<int> closeShift({
    required int id,
    required String endedAt,
    required int totalEarningsCents,
    required int deliveryCount,
    int? fuelExpenseCents,
  }) => (update(db.shiftsTable)..where((t) => t.id.equals(id))).write(
    ShiftsTableCompanion(
      endedAt: Value(endedAt),
      status: const Value('closed'),
      totalEarningsCents: Value(totalEarningsCents),
      deliveryCount: Value(deliveryCount),
      fuelExpenseCents: Value(fuelExpenseCents),
    ),
  );

  Future<int> updateHistoricalShift({
    required int id,
    required String dateStr,
    required int deliveryCount,
    required int earningsCents,
    double? hoursWorked,
    String? notes,
    int? fuelExpenseCents,
  }) => (update(db.shiftsTable)..where((t) => t.id.equals(id))).write(
    ShiftsTableCompanion(
      startedAt: Value(dateStr),
      endedAt: Value(dateStr),
      totalEarningsCents: Value(earningsCents),
      deliveryCount: Value(deliveryCount),
      notes: Value(notes),
      hoursWorked: Value(hoursWorked),
      fuelExpenseCents: Value(fuelExpenseCents),
    ),
  );

  Future<int> deleteShiftById(int id) =>
      (delete(db.shiftsTable)..where((t) => t.id.equals(id))).go();

  Future<int> deleteClosedShifts() =>
      (delete(db.shiftsTable)..where((t) => t.status.equals('closed'))).go();
}

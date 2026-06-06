import 'package:drift/drift.dart';

class ShiftsTable extends Table {
  @override
  String get tableName => 'shifts';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get driverName => text()();
  TextColumn get startedAt => text()(); // ISO 8601 UTC
  TextColumn get endedAt => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  IntColumn get totalEarningsCents => integer().nullable()();
  IntColumn get deliveryCount => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get source => text().withDefault(const Constant('app'))();
  RealColumn get hoursWorked => real().nullable()();
  IntColumn get fuelExpenseCents => integer().nullable()();
}

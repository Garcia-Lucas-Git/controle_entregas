import 'package:drift/drift.dart';

class EarningsConfigTable extends Table {
  @override
  String get tableName => 'earnings_config';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get baseRateCents => integer().withDefault(const Constant(800))();
  IntColumn get longSingleDeliveryRateCents =>
      integer().withDefault(const Constant(1000))();
  TextColumn get effectiveFrom => text()();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();
}

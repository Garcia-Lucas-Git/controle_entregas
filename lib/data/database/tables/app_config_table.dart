import 'package:drift/drift.dart';

class AppConfigTable extends Table {
  @override
  String get tableName => 'app_config';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get driverName => text().withDefault(const Constant(''))();
  TextColumn get pizzeriaAddress => text().withDefault(const Constant(''))();
  TextColumn get ifoodUrl => text().withDefault(
    const Constant('https://confirmacao-entrega-propria.ifood.com.br/'),
  )();
  TextColumn get ifoodFieldSelector => text().withDefault(const Constant(''))();
  BoolColumn get ocrContrastEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get activeRouteId => integer().nullable()();
  IntColumn get activeDeliveryIndex => integer().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

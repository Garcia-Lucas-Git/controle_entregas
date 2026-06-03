import 'package:drift/drift.dart';
import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/tables/app_config_table.dart';

part 'config_dao.g.dart';

@DriftAccessor(tables: [AppConfigTable])
class ConfigDao extends DatabaseAccessor<AppDatabase>
    with _$ConfigDaoMixin {
  ConfigDao(super.db);

  Future<AppConfigTableData?> getConfig() =>
      (select(db.appConfigTable)..limit(1)).getSingleOrNull();

  Stream<AppConfigTableData?> watchConfig() =>
      (select(db.appConfigTable)..limit(1)).watchSingleOrNull();

  Future<void> upsertConfig(AppConfigTableCompanion entry) async {
    final existing = await getConfig();
    if (existing == null) {
      await into(db.appConfigTable).insert(entry);
    } else {
      await (update(db.appConfigTable)..where((t) => t.id.equals(existing.id)))
          .write(entry);
    }
  }

  Future<void> setActiveRoute({
    required int? routeId,
    required int? deliveryIndex,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await upsertConfig(AppConfigTableCompanion(
      activeRouteId: Value(routeId),
      activeDeliveryIndex: Value(deliveryIndex),
      updatedAt: Value(now),
    ));
  }

  Future<void> clearActiveRoute() => setActiveRoute(
        routeId: null,
        deliveryIndex: null,
      );
}

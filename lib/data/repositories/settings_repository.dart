import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/daos/config_dao.dart';
import 'package:controle_entregas/domain/entities/app_settings.dart';
import 'package:controle_entregas/domain/value_objects/earnings_rules.dart';
import 'package:drift/drift.dart';

class SettingsRepository {
  final ConfigDao _dao;

  SettingsRepository(AppDatabase db) : _dao = db.configDao;

  Stream<AppSettings> watchSettings() => _dao.watchConfig().map(
    (r) => r != null ? _fromRow(r) : AppSettings.defaults,
  );

  Future<AppSettings> getSettings() async {
    final row = await _dao.getConfig();
    return row != null ? _fromRow(row) : AppSettings.defaults;
  }

  Future<void> saveSettings(AppSettings settings) {
    final now = DateTime.now().toUtc().toIso8601String();
    return _dao.upsertConfig(
      AppConfigTableCompanion(
        driverName: Value(settings.driverName),
        pizzeriaAddress: Value(settings.pizzeriaAddress),
        ifoodUrl: Value(settings.ifoodUrl),
        ifoodFieldSelector: Value(settings.ifoodFieldSelector),
        ocrContrastEnabled: Value(settings.ocrContrastEnabled),
        activeRouteId: Value(settings.activeRouteId),
        activeDeliveryIndex: Value(settings.activeDeliveryIndex),
        dailyGoalCents: Value(settings.dailyGoalCents),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> setActiveRoute({int? routeId, int? deliveryIndex}) =>
      _dao.setActiveRoute(routeId: routeId, deliveryIndex: deliveryIndex);

  Future<void> clearActiveRoute() => _dao.clearActiveRoute();

  static AppSettings _fromRow(AppConfigTableData r) => AppSettings(
    driverName: r.driverName,
    pizzeriaAddress: r.pizzeriaAddress,
    ifoodUrl: r.ifoodUrl,
    ifoodFieldSelector: r.ifoodFieldSelector,
    ocrContrastEnabled: r.ocrContrastEnabled,
    earningsConfig: const EarningsConfig.defaults(),
    activeRouteId: r.activeRouteId,
    activeDeliveryIndex: r.activeDeliveryIndex,
    dailyGoalCents: r.dailyGoalCents,
  );
}

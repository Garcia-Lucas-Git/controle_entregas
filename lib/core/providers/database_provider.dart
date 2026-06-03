import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/repositories/delivery_repository.dart';
import 'package:controle_entregas/data/repositories/earnings_repository.dart';
import 'package:controle_entregas/data/repositories/route_repository.dart';
import 'package:controle_entregas/data/repositories/settings_repository.dart';
import 'package:controle_entregas/data/repositories/shift_repository.dart';
import 'package:controle_entregas/services/export_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
ShiftRepository shiftRepository(ShiftRepositoryRef ref) =>
    ShiftRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
RouteRepository routeRepository(RouteRepositoryRef ref) =>
    RouteRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
DeliveryRepository deliveryRepository(DeliveryRepositoryRef ref) =>
    DeliveryRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
EarningsRepository earningsRepository(EarningsRepositoryRef ref) =>
    EarningsRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(SettingsRepositoryRef ref) =>
    SettingsRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
ExportService exportService(ExportServiceRef ref) => ExportService(
      shifts: ref.watch(shiftRepositoryProvider),
      routes: ref.watch(routeRepositoryProvider),
      deliveries: ref.watch(deliveryRepositoryProvider),
      earnings: ref.watch(earningsRepositoryProvider),
    );

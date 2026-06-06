import 'dart:io';

import 'package:controle_entregas/services/app_logger.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:controle_entregas/data/database/daos/config_dao.dart';
import 'package:controle_entregas/data/database/daos/deliveries_dao.dart';
import 'package:controle_entregas/data/database/daos/earnings_dao.dart';
import 'package:controle_entregas/data/database/daos/receipts_dao.dart';
import 'package:controle_entregas/data/database/daos/routes_dao.dart';
import 'package:controle_entregas/data/database/daos/shifts_dao.dart';
import 'package:controle_entregas/data/database/tables/app_config_table.dart';
import 'package:controle_entregas/data/database/tables/deliveries_table.dart';
import 'package:controle_entregas/data/database/tables/earnings_config_table.dart';
import 'package:controle_entregas/data/database/tables/earnings_entries_table.dart';
import 'package:controle_entregas/data/database/tables/receipts_table.dart';
import 'package:controle_entregas/data/database/tables/routes_table.dart';
import 'package:controle_entregas/data/database/tables/shifts_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ShiftsTable,
    RoutesTable,
    DeliveriesTable,
    ReceiptsTable,
    EarningsEntriesTable,
    EarningsConfigTable,
    AppConfigTable,
  ],
  daos: [
    ShiftsDao,
    RoutesDao,
    DeliveriesDao,
    ReceiptsDao,
    EarningsDao,
    ConfigDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      AppLogger.info(
        LogEvents.dbOpen,
        module: 'AppDatabase',
        metadata: {'schema_version': schemaVersion, 'action': 'onCreate'},
      );
      await m.createAll();
      await _seedInitialData();
    },
    onUpgrade: (m, from, to) async {
      AppLogger.log(
        LogEvents.dbMigrationStart,
        module: 'AppDatabase',
        metadata: {'from': from, 'to': to},
      );
      try {
        if (from < 2) {
          await m.addColumn(
            shiftsTable,
            shiftsTable.source as GeneratedColumn<Object>,
          );
          await m.addColumn(
            shiftsTable,
            shiftsTable.hoursWorked as GeneratedColumn<Object>,
          );
        }
        if (from < 3) {
          await m.addColumn(
            shiftsTable,
            shiftsTable.fuelExpenseCents as GeneratedColumn<Object>,
          );
        }
        if (from < 4) {
          await m.addColumn(
            appConfigTable,
            appConfigTable.dailyGoalCents as GeneratedColumn<Object>,
          );
        }
        AppLogger.info(
          LogEvents.dbMigrationSuccess,
          module: 'AppDatabase',
          metadata: {'from': from, 'to': to},
        );
      } catch (e, st) {
        AppLogger.error(
          LogEvents.dbMigrationFail,
          module: 'AppDatabase',
          metadata: {'from': from, 'to': to},
          exception: e,
          stackTrace: st,
        );
        rethrow;
      }
    },
  );

  Future<void> _seedInitialData() async {
    final now = DateTime.now().toUtc().toIso8601String();

    // Seed earnings config with defaults
    await into(earningsConfigTable).insert(
      EarningsConfigTableCompanion(
        baseRateCents: const Value(800),
        longSingleDeliveryRateCents: const Value(1000),
        effectiveFrom: Value(now),
        isCurrent: const Value(true),
        createdAt: Value(now),
      ),
    );

    // Seed app config with empty defaults
    await into(appConfigTable).insert(
      AppConfigTableCompanion(
        driverName: const Value(''),
        pizzeriaAddress: const Value(''),
        ifoodUrl: const Value(
          'https://confirmacao-entrega-propria.ifood.com.br/',
        ),
        ifoodFieldSelector: const Value(''),
        ocrContrastEnabled: const Value(false),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'deliveryflow.db'));
    return NativeDatabase.createInBackground(file);
  });
}

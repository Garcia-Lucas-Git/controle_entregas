import 'package:controle_entregas/data/database/app_database.dart';
import 'package:drift/drift.dart';

class TestDataCleanupSummary {
  final int deliveriesDeleted;
  final int routesDeleted;
  final int shiftsDeleted;

  const TestDataCleanupSummary({
    required this.deliveriesDeleted,
    required this.routesDeleted,
    required this.shiftsDeleted,
  });

  int get totalDeleted => deliveriesDeleted + routesDeleted + shiftsDeleted;
}

class TestDataCleanupService {
  static const automationMarker = '[AUTOMATION]';
  static const devtoolsMarker = '[DEVTOOLS]';
  static const legacyAutomationMarker = '[DEVTOOLS_AUTOMATION]';

  final AppDatabase _db;

  const TestDataCleanupService(this._db);

  Future<int> cleanupAutomationDeliveries() async {
    return _db.customUpdate(
      '''delete from deliveries
where coalesce(customer_name, '') like ?
   or address_text like ?
   or coalesce(ocr_raw_text, '') like ?
   or coalesce(delivery_identifier, '') like ?
   or coalesce(partner_collection_code, '') like ?''',
      variables: _markerVariables(),
    );
  }

  Future<int> cleanupAutomationRoutes() async {
    return _db.customUpdate('''delete from routes
where shift_id in (
  select id from shifts
  where driver_name like ?
     or coalesce(notes, '') like ?
     or source like ?
)''', variables: _shiftMarkerVariables());
  }

  Future<int> cleanupAutomationHistory() async {
    return _db.customUpdate('''delete from shifts
where driver_name like ?
   or coalesce(notes, '') like ?
   or source like ?''', variables: _shiftMarkerVariables());
  }

  Future<TestDataCleanupSummary> cleanupAll() async {
    final deliveries = await cleanupAutomationDeliveries();
    final routes = await cleanupAutomationRoutes();
    final shifts = await cleanupAutomationHistory();
    return TestDataCleanupSummary(
      deliveriesDeleted: deliveries,
      routesDeleted: routes,
      shiftsDeleted: shifts,
    );
  }

  Future<Map<String, int>> countAutomationRecords() async {
    return {
      'deliveries': await _count('''select count(*) as c from deliveries
where coalesce(customer_name, '') like ?
   or address_text like ?
   or coalesce(ocr_raw_text, '') like ?
   or coalesce(delivery_identifier, '') like ?
   or coalesce(partner_collection_code, '') like ?''', _markerVariables()),
      'routes': await _count('''select count(*) as c from routes
where shift_id in (
  select id from shifts
  where driver_name like ?
     or coalesce(notes, '') like ?
     or source like ?
)''', _shiftMarkerVariables()),
      'shifts': await _count('''select count(*) as c from shifts
where driver_name like ?
   or coalesce(notes, '') like ?
   or source like ?''', _shiftMarkerVariables()),
    };
  }

  Future<int> _count(String sql, List<Variable<String>> variables) async {
    final row = await _db.customSelect(sql, variables: variables).getSingle();
    return row.data['c'] as int? ?? 0;
  }

  List<Variable<String>> _markerVariables() => [
    Variable<String>('%$automationMarker%'),
    Variable<String>('%$devtoolsMarker%'),
    Variable<String>('%$legacyAutomationMarker%'),
    const Variable<String>('%automation_run_id%'),
    const Variable<String>('%automation_run_id%'),
  ];

  List<Variable<String>> _shiftMarkerVariables() => [
    Variable<String>('%$automationMarker%'),
    Variable<String>('%$devtoolsMarker%'),
    const Variable<String>('automation%'),
  ];
}

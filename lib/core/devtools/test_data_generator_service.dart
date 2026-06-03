import 'package:controle_entregas/core/devtools/test_data_cleanup_service.dart';
import 'package:controle_entregas/data/database/app_database.dart';
import 'package:drift/drift.dart';

class TestDataGeneratorService {
  static const marker = '[DEVTOOLS]';

  final AppDatabase _db;

  const TestDataGeneratorService(this._db);

  Future<int> createOpenShift() async {
    final existing = await _db.shiftsDao.getOpenShift();
    if (existing != null && !existing.driverName.startsWith(marker)) {
      throw StateError('Existe um turno real aberto. Feche-o antes de gerar.');
    }
    if (existing != null) return existing.id;
    return _insertShift(status: 'open');
  }

  Future<int> createClosedShift() async {
    return _insertShift(
      status: 'closed',
      deliveryCount: 8,
      totalEarningsCents: 6400,
      endedAt: DateTime.now().toUtc(),
      notes: '$marker turno fechado gerado',
    );
  }

  Future<int> createEmptyRoute() async {
    final shiftId = await createOpenShift();
    return _insertRoute(shiftId: shiftId);
  }

  Future<int> createActiveRoute() async {
    final shiftId = await createOpenShift();
    final routeId = await _insertRoute(shiftId: shiftId);
    await _insertDelivery(
      shiftId: shiftId,
      routeId: routeId,
      sequenceNumber: 1,
      status: 'in_progress',
      customerName: '$marker Cliente ativo',
      addressText: '$marker Rua Ativa, 123',
    );
    return routeId;
  }

  Future<int> createCompletedRoute() async {
    final shiftId = await createClosedShift();
    final routeId = await _insertRoute(
      shiftId: shiftId,
      status: 'closed',
      closedAt: DateTime.now().toUtc(),
      deliveryCountAtClose: 3,
    );
    for (var i = 1; i <= 3; i++) {
      await _insertDelivery(
        shiftId: shiftId,
        routeId: routeId,
        sequenceNumber: i,
        status: 'completed',
        customerName: '$marker Cliente $i',
        addressText: '$marker Rua Completa, $i',
        completedAt: DateTime.now().toUtc(),
        distanceKm: 2.5 + i,
      );
    }
    return routeId;
  }

  Future<int> createManualDelivery() async {
    final routeId = await createEmptyRoute();
    final shiftId = (await _db.routesDao.getRouteById(routeId))!.shiftId;
    return _insertDelivery(
      shiftId: shiftId,
      routeId: routeId,
      sequenceNumber: 1,
      customerName: '$marker Manual',
      addressText: '$marker Rua Manual, 45',
      partnerCollectionCode: 'DEV1234',
    );
  }

  Future<int> createOcrDelivery() async {
    final routeId = await createEmptyRoute();
    final shiftId = (await _db.routesDao.getRouteById(routeId))!.shiftId;
    return _insertDelivery(
      shiftId: shiftId,
      routeId: routeId,
      sequenceNumber: 1,
      customerName: '$marker OCR',
      addressText: '$marker Rua OCR, 88',
      orderNumber: '778899',
      ocrRawText: '$marker OCR fixture\nENDERECO: Rua OCR, 88\nCOD: DEV7788',
      partnerCollectionCode: 'DEV7788',
    );
  }

  Future<int> createIfoodDelivery() async {
    final routeId = await createEmptyRoute();
    final shiftId = (await _db.routesDao.getRouteById(routeId))!.shiftId;
    return _insertDelivery(
      shiftId: shiftId,
      routeId: routeId,
      sequenceNumber: 1,
      customerName: '$marker iFood',
      addressText: '$marker Rua iFood, 99',
      needsIfoodConfirmation: true,
      deliveryIdentifier: 'IFOOD-DEV',
      partnerCollectionCode: 'IFD1234',
      ocrRawText: '$marker iFood fixture',
    );
  }

  Future<int> createMixedRoute() async {
    final routeId = await createEmptyRoute();
    final shiftId = (await _db.routesDao.getRouteById(routeId))!.shiftId;
    await _insertDelivery(
      shiftId: shiftId,
      routeId: routeId,
      sequenceNumber: 1,
      customerName: '$marker Manual',
      addressText: '$marker Rua Mista Manual, 1',
      partnerCollectionCode: 'MIX0001',
    );
    await _insertDelivery(
      shiftId: shiftId,
      routeId: routeId,
      sequenceNumber: 2,
      customerName: '$marker OCR',
      addressText: '$marker Rua Mista OCR, 2',
      ocrRawText: '$marker OCR mixed fixture',
      partnerCollectionCode: 'MIX0002',
    );
    await _insertDelivery(
      shiftId: shiftId,
      routeId: routeId,
      sequenceNumber: 3,
      customerName: '$marker iFood',
      addressText: '$marker Rua Mista iFood, 3',
      needsIfoodConfirmation: true,
      partnerCollectionCode: 'MIX0003',
    );
    return routeId;
  }

  Future<void> createHistoryDays(int days) async {
    final now = DateTime.now();
    for (var i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      await _insertShift(
        status: 'closed',
        startedAt: date.toUtc(),
        endedAt: date.toUtc(),
        deliveryCount: 12 + (i % 8),
        totalEarningsCents: (12 + (i % 8)) * 800,
        source: 'historical',
        hoursWorked: 7.0 + (i % 3),
        notes: '$marker histórico gerado',
      );
    }
  }

  Future<TestDataCleanupSummary> cleanupGeneratedData() {
    return TestDataCleanupService(_db).cleanupAll();
  }

  Future<int> _insertShift({
    String status = 'open',
    DateTime? startedAt,
    DateTime? endedAt,
    int? deliveryCount,
    int? totalEarningsCents,
    String source = 'app',
    double? hoursWorked,
    String? notes,
  }) {
    final now = DateTime.now().toUtc();
    return _db.shiftsDao.insertShift(
      ShiftsTableCompanion(
        driverName: Value('$marker Motorista teste'),
        startedAt: Value((startedAt ?? now).toIso8601String()),
        endedAt: Value(endedAt?.toIso8601String()),
        status: Value(status),
        totalEarningsCents: Value(totalEarningsCents),
        deliveryCount: Value(deliveryCount),
        notes: Value(notes),
        source: Value(source == 'app' ? 'devtools' : source),
        hoursWorked: Value(hoursWorked),
        createdAt: Value(now.toIso8601String()),
      ),
    );
  }

  Future<int> _insertRoute({
    required int shiftId,
    String status = 'open',
    DateTime? closedAt,
    int? deliveryCountAtClose,
  }) async {
    final now = DateTime.now().toUtc();
    final number = await _db.routesDao.getNextRouteNumber(shiftId);
    return _db.routesDao.insertRoute(
      RoutesTableCompanion(
        shiftId: Value(shiftId),
        routeNumber: Value(number),
        status: Value(status),
        startedAt: Value(now.toIso8601String()),
        closedAt: Value(closedAt?.toIso8601String()),
        deliveryCountAtClose: Value(deliveryCountAtClose),
        createdAt: Value(now.toIso8601String()),
      ),
    );
  }

  Future<int> _insertDelivery({
    required int shiftId,
    required int routeId,
    required int sequenceNumber,
    required String customerName,
    required String addressText,
    String status = 'pending',
    String? orderNumber,
    String? ocrRawText,
    String? deliveryIdentifier,
    String? partnerCollectionCode,
    bool needsIfoodConfirmation = false,
    DateTime? completedAt,
    double? distanceKm,
  }) {
    final now = DateTime.now().toUtc();
    return _db.deliveriesDao.insertDelivery(
      DeliveriesTableCompanion(
        routeId: Value(routeId),
        shiftId: Value(shiftId),
        sequenceNumber: Value(sequenceNumber),
        status: Value(status),
        customerName: Value(customerName),
        addressText: Value(addressText),
        orderNumber: Value(orderNumber),
        ocrRawText: Value(ocrRawText),
        completedAt: Value(completedAt?.toIso8601String()),
        createdAt: Value(now.toIso8601String()),
        distanceKm: Value(distanceKm),
        needsIfoodConfirmation: Value(needsIfoodConfirmation),
        deliveryIdentifier: Value(deliveryIdentifier),
        partnerCollectionCode: Value(partnerCollectionCode),
      ),
    );
  }
}

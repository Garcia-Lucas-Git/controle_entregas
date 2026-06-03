import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/daos/deliveries_dao.dart';
import 'package:controle_entregas/domain/entities/delivery.dart';
import 'package:controle_entregas/domain/enums/delivery_status.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:drift/drift.dart';

class DeliveryRepository {
  final DeliveriesDao _dao;

  DeliveryRepository(AppDatabase db) : _dao = db.deliveriesDao;

  Stream<List<Delivery>> watchDeliveriesForRoute(int routeId) =>
      _dao.watchDeliveriesForRoute(routeId).map((r) => r.map(_fromRow).toList());

  Future<List<Delivery>> getDeliveriesForRoute(int routeId) async {
    final rows = await _dao.getDeliveriesForRoute(routeId);
    return rows.map(_fromRow).toList();
  }

  Future<List<Delivery>> getCompletedDeliveriesForShift(int shiftId) async {
    final rows = await _dao.getDeliveriesForShift(shiftId);
    return rows.map(_fromRow).toList();
  }

  Future<Delivery?> getById(int id) async {
    final row = await _dao.getDeliveryById(id);
    return row != null ? _fromRow(row) : null;
  }

  Stream<Delivery?> watchById(int id) =>
      _dao.watchDeliveryById(id).map((r) => r != null ? _fromRow(r) : null);

  Future<int> countCompletedInRoute(int routeId) =>
      _dao.countCompletedInRoute(routeId);

  Future<int> createDelivery({
    required int routeId,
    required int shiftId,
    required int sequenceNumber,
    required String addressText,
    String? customerName,
    String? orderNumber,
    int? orderValueCents,
    String? ocrRawText,
    bool needsIfoodConfirmation = false,
    String? deliveryIdentifier,
    String? partnerCollectionCode,
    bool hasDrinks = false,
    bool needsCard = false,
    bool needsChange = false,
    int? changeAmountCents,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final sid = SessionManager.delivery();
    try {
      final id = await _dao.insertDelivery(DeliveriesTableCompanion(
        routeId: Value(routeId),
        shiftId: Value(shiftId),
        sequenceNumber: Value(sequenceNumber),
        status: const Value('pending'),
        addressText: Value(addressText),
        customerName: Value(customerName),
        orderNumber: Value(orderNumber),
        orderValueCents: Value(orderValueCents),
        ocrRawText: Value(ocrRawText),
        needsIfoodConfirmation: Value(needsIfoodConfirmation),
        deliveryIdentifier: Value(deliveryIdentifier),
        partnerCollectionCode: Value(partnerCollectionCode),
        hasDrinks: Value(hasDrinks),
        needsCard: Value(needsCard),
        needsChange: Value(needsChange),
        changeAmountCents: Value(changeAmountCents),
        createdAt: Value(now),
      ));
      AppLogger.log(
        LogEvents.dbDeliveryInsertSuccess,
        module: 'DeliveryRepository',
        className: 'DeliveryRepository',
        method: 'createDelivery',
        sessionId: sid,
        metadata: {
          'id': id,
          'route_id': routeId,
          'shift_id': shiftId,
          'seq': sequenceNumber,
          'has_locator': partnerCollectionCode != null,
          'needs_ifood': needsIfoodConfirmation,
        },
      );
      return id;
    } catch (e, st) {
      AppLogger.error(
        LogEvents.dbDeliveryInsertFail,
        module: 'DeliveryRepository',
        className: 'DeliveryRepository',
        method: 'createDelivery',
        sessionId: sid,
        metadata: {'route_id': routeId, 'shift_id': shiftId},
        exception: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> setInProgress(int id) => _dao.setInProgress(id);

  Future<void> completeDelivery({
    required int id,
    double? distanceKm,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return _dao.completeDelivery(
      id: id,
      completedAt: now,
      distanceKm: distanceKm,
    );
  }

  Future<void> updateIfoodConfirmation({
    required int id,
    required bool success,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return _dao.updateIfoodConfirmation(
      id: id,
      success: success,
      confirmedAt: now,
    );
  }

  static Delivery _fromRow(DeliveriesTableData r) => Delivery(
        id: r.id,
        routeId: r.routeId,
        shiftId: r.shiftId,
        sequenceNumber: r.sequenceNumber,
        status: DeliveryStatus.fromJson(r.status),
        customerName: r.customerName,
        addressText: r.addressText,
        distanceKm: r.distanceKm,
        orderNumber: r.orderNumber,
        orderValueCents: r.orderValueCents,
        ocrRawText: r.ocrRawText,
        completedAt:
            r.completedAt != null ? DateTime.parse(r.completedAt!) : null,
        createdAt: DateTime.parse(r.createdAt),
        needsIfoodConfirmation: r.needsIfoodConfirmation,
        deliveryIdentifier: r.deliveryIdentifier,
        partnerCollectionCode: r.partnerCollectionCode,
        ifoodConfirmationSuccess: r.ifoodConfirmationSuccess,
        ifoodConfirmedAt: r.ifoodConfirmedAt != null
            ? DateTime.parse(r.ifoodConfirmedAt!)
            : null,
        hasDrinks: r.hasDrinks,
        needsCard: r.needsCard,
        needsChange: r.needsChange,
        changeAmountCents: r.changeAmountCents,
      );
}

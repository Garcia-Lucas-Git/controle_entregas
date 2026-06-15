import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/daos/deliveries_dao.dart';
import 'package:controle_entregas/domain/entities/delivery.dart';
import 'package:controle_entregas/domain/enums/delivery_status.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:drift/drift.dart';

class DeliveryRepository {
  final DeliveriesDao _dao;

  DeliveryRepository(AppDatabase db) : _dao = db.deliveriesDao;

  Stream<List<Delivery>> watchDeliveriesForRoute(int routeId) => _dao
      .watchDeliveriesForRoute(routeId)
      .map((r) => r.map(_fromRow).toList());

  Future<List<Delivery>> getDeliveriesForRoute(int routeId) async {
    final rows = await _dao.getDeliveriesForRoute(routeId);
    return rows.map(_fromRow).toList();
  }

  Future<List<Delivery>> getCompletedDeliveriesForShift(int shiftId) async {
    final rows = await _dao.getDeliveriesForShift(shiftId);
    return rows.map(_fromRow).toList();
  }

  Stream<List<Delivery>> watchCompletedDeliveriesForShift(int shiftId) => _dao
      .watchCompletedDeliveriesForShift(shiftId)
      .map((r) => r.map(_fromRow).toList());

  Future<Delivery?> getById(int id) async {
    final row = await _dao.getDeliveryById(id);
    return row != null ? _fromRow(row) : null;
  }

  Stream<Delivery?> watchById(int id) =>
      _dao.watchDeliveryById(id).map((r) => r != null ? _fromRow(r) : null);

  Future<int> countCompletedInRoute(int routeId) =>
      _dao.countCompletedInRoute(routeId);

  Future<int> nextSequenceForRoute(int routeId) async {
    final deliveries = await getDeliveriesForRoute(routeId);
    if (deliveries.isEmpty) return 1;
    return deliveries
            .map((d) => d.sequenceNumber)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  Future<void> updateRouteOrder(List<Delivery> deliveries) async {
    for (var i = 0; i < deliveries.length; i++) {
      await _dao.updateSequenceNumber(
        id: deliveries[i].id,
        sequenceNumber: i + 1,
      );
    }
  }

  Future<void> updateDeliveryFields({
    required int id,
    String? customerName,
    String? addressText,
    String? houseNumber,
    String? complement,
    String? neighborhood,
    String? orderNumber,
    String? deliveryIdentifier,
    String? pizzaNumber,
    bool? needsIfoodConfirmation,
    bool? hasDrinks,
    String? drinkType,
    bool? needsCard,
    int? cardAmountCents,
    bool clearCardAmount = false,
    bool? needsChange,
  }) async {
    await _dao.updateDeliveryFields(
      id: id,
      customerName: customerName != null
          ? Value(customerName)
          : const Value.absent(),
      addressText: addressText != null
          ? Value(addressText)
          : const Value.absent(),
      houseNumber: houseNumber != null
          ? Value(houseNumber)
          : const Value.absent(),
      complement: complement != null ? Value(complement) : const Value.absent(),
      neighborhood: neighborhood != null
          ? Value(neighborhood)
          : const Value.absent(),
      orderNumber: orderNumber != null
          ? Value(orderNumber)
          : const Value.absent(),
      deliveryIdentifier: deliveryIdentifier != null
          ? Value(deliveryIdentifier)
          : const Value.absent(),
      pizzaNumber: pizzaNumber != null
          ? Value(pizzaNumber)
          : const Value.absent(),
      needsIfoodConfirmation: needsIfoodConfirmation != null
          ? Value(needsIfoodConfirmation)
          : const Value.absent(),
      hasDrinks: hasDrinks != null ? Value(hasDrinks) : const Value.absent(),
      drinkType: drinkType != null ? Value(drinkType) : const Value.absent(),
      needsCard: needsCard != null ? Value(needsCard) : const Value.absent(),
      cardAmountCents: clearCardAmount
          ? const Value(null)
          : cardAmountCents != null
          ? Value(cardAmountCents)
          : const Value.absent(),
      needsChange: needsChange != null
          ? Value(needsChange)
          : const Value.absent(),
    );
  }

  Future<int> createDelivery({
    required int routeId,
    required int shiftId,
    required int sequenceNumber,
    required String addressText,
    String? houseNumber,
    String? complement,
    String? neighborhood,
    String? customerName,
    String? orderNumber,
    int? orderValueCents,
    String? ocrRawText,
    bool needsIfoodConfirmation = false,
    String? deliveryIdentifier,
    String? partnerCollectionCode,
    bool hasDrinks = false,
    String? drinkType,
    bool needsCard = false,
    int? cardAmountCents,
    bool needsChange = false,
    int? changeAmountCents,
    String? pizzaNumber,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final sid = SessionManager.delivery();
    try {
      final id = await _dao.insertDelivery(
        DeliveriesTableCompanion(
          routeId: Value(routeId),
          shiftId: Value(shiftId),
          sequenceNumber: Value(sequenceNumber),
          status: const Value('pending'),
          addressText: Value(addressText),
          houseNumber: Value(houseNumber),
          complement: Value(complement),
          neighborhood: Value(neighborhood),
          customerName: Value(customerName),
          orderNumber: Value(orderNumber),
          orderValueCents: Value(orderValueCents),
          ocrRawText: Value(ocrRawText),
          needsIfoodConfirmation: Value(needsIfoodConfirmation),
          deliveryIdentifier: Value(deliveryIdentifier),
          partnerCollectionCode: Value(partnerCollectionCode),
          hasDrinks: Value(hasDrinks),
          drinkType: Value(drinkType),
          needsCard: Value(needsCard),
          cardAmountCents: Value(cardAmountCents),
          needsChange: Value(needsChange),
          changeAmountCents: Value(changeAmountCents),
          pizzaNumber: Value(pizzaNumber),
          createdAt: Value(now),
        ),
      );
      final locator = deliveryIdentifier;
      if (locator != null && locator.isNotEmpty) {
        AppLogger.log(
          LogEvents.locatorStored,
          module: 'DeliveryRepository',
          className: 'DeliveryRepository',
          method: 'createDelivery',
          sessionId: sid,
          metadata: {
            'value': locator,
            'length': locator.length,
            'delivery_id': id,
            'route_id': routeId,
          },
        );
      }
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
          'has_locator': locator != null,
          'needs_ifood': needsIfoodConfirmation,
        },
      );
      AppLogger.log(
        LogEvents.deliveryCreated,
        module: 'DeliveryRepository',
        metadata: {
          'delivery_id': id,
          'route_id': routeId,
          'shift_id': shiftId,
          'address': addressText,
          'house_number': houseNumber,
          'pizza_number': pizzaNumber,
          'locator': deliveryIdentifier,
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

  Future<void> deleteDelivery(int id) async {
    final sid = SessionManager.delivery();
    AppLogger.info(
      LogEvents.deliveryDeleteRequest,
      module: 'DeliveryRepository',
      sessionId: sid,
      metadata: {'delivery_id': id},
    );
    await _dao.deleteDeliveryById(id);
    AppLogger.info(
      LogEvents.deliveryDeleteSuccess,
      module: 'DeliveryRepository',
      sessionId: sid,
      metadata: {'delivery_id': id},
    );
  }

  Future<void> completeDelivery({required int id, double? distanceKm}) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _dao.completeDelivery(
      id: id,
      completedAt: now,
      distanceKm: distanceKm,
    );
    AppLogger.log(
      LogEvents.deliveryCompleted,
      module: 'DeliveryRepository',
      metadata: {'delivery_id': id, 'distance_km': distanceKm},
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
    houseNumber: r.houseNumber,
    complement: r.complement,
    neighborhood: r.neighborhood,
    distanceKm: r.distanceKm,
    orderNumber: r.orderNumber,
    orderValueCents: r.orderValueCents,
    ocrRawText: r.ocrRawText,
    completedAt: r.completedAt != null ? DateTime.parse(r.completedAt!) : null,
    createdAt: DateTime.parse(r.createdAt),
    needsIfoodConfirmation: r.needsIfoodConfirmation,
    deliveryIdentifier: r.deliveryIdentifier,
    partnerCollectionCode: r.partnerCollectionCode,
    ifoodConfirmationSuccess: r.ifoodConfirmationSuccess,
    ifoodConfirmedAt: r.ifoodConfirmedAt != null
        ? DateTime.parse(r.ifoodConfirmedAt!)
        : null,
    hasDrinks: r.hasDrinks,
    drinkType: r.drinkType,
    needsCard: r.needsCard,
    cardAmountCents: r.cardAmountCents,
    needsChange: r.needsChange,
    changeAmountCents: r.changeAmountCents,
    pizzaNumber: r.pizzaNumber,
  );
}

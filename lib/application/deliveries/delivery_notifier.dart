import 'package:controle_entregas/application/shifts/shift_notifier.dart';
import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:controle_entregas/domain/entities/delivery.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:controle_entregas/services/ocr_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delivery_notifier.g.dart';

@riverpod
Stream<List<Delivery>> deliveriesForRoute(
  DeliveriesForRouteRef ref,
  int routeId,
) => ref.watch(deliveryRepositoryProvider).watchDeliveriesForRoute(routeId);

@riverpod
Stream<Delivery?> deliveryById(DeliveryByIdRef ref, int deliveryId) =>
    ref.watch(deliveryRepositoryProvider).watchById(deliveryId);

@riverpod
class DeliveryNotifier extends _$DeliveryNotifier {
  @override
  Future<void> build() async {}

  Future<int> createFromOcr({
    required int routeId,
    required int shiftId,
    required int sequenceNumber,
    required OcrResult ocr,
  }) => ref
      .read(deliveryRepositoryProvider)
      .createDelivery(
        routeId: routeId,
        shiftId: shiftId,
        sequenceNumber: sequenceNumber,
        addressText: ocr.addressText ?? '',
        houseNumber: ocr.houseNumber,
        customerName: ocr.customerName,
        orderNumber: ocr.orderNumber,
        ocrRawText: ocr.rawText,
        needsIfoodConfirmation: ocr.needsIfoodConfirmation,
        deliveryIdentifier: ocr.deliveryIdentifier,
        partnerCollectionCode: ocr.partnerCollectionCode,
        hasDrinks: ocr.hasDrinks,
        needsCard: ocr.needsCard,
        needsChange: ocr.needsChange,
        changeAmountCents: ocr.changeAmountCents,
        pizzaNumber: ocr.pizzaNumber,
      );

  Future<int> createManual({
    required int routeId,
    required int shiftId,
    required int sequenceNumber,
    required String addressText,
    String? houseNumber,
    String? customerName,
    String? orderNumber,
    String? deliveryIdentifier,
    String? partnerCollectionCode,
    String? pizzaNumber,
  }) => ref
      .read(deliveryRepositoryProvider)
      .createDelivery(
        routeId: routeId,
        shiftId: shiftId,
        sequenceNumber: sequenceNumber,
        addressText: addressText,
        houseNumber: houseNumber,
        customerName: customerName,
        orderNumber: orderNumber,
        deliveryIdentifier: deliveryIdentifier,
        partnerCollectionCode: partnerCollectionCode,
        pizzaNumber: pizzaNumber,
      );

  Future<void> updateFields({
    required int id,
    String? customerName,
    String? addressText,
    String? houseNumber,
    String? orderNumber,
    String? deliveryIdentifier,
    String? pizzaNumber,
    bool? needsIfoodConfirmation,
    bool? hasDrinks,
    bool? needsCard,
    bool? needsChange,
    required int routeId,
  }) async {
    await ref.read(deliveryRepositoryProvider).updateDeliveryFields(
      id: id,
      customerName: customerName,
      addressText: addressText,
      houseNumber: houseNumber,
      orderNumber: orderNumber,
      deliveryIdentifier: deliveryIdentifier,
      pizzaNumber: pizzaNumber,
      needsIfoodConfirmation: needsIfoodConfirmation,
      hasDrinks: hasDrinks,
      needsCard: needsCard,
      needsChange: needsChange,
    );
    ref.invalidate(deliveriesForRouteProvider(routeId));
    ref.invalidate(deliveryByIdProvider(id));
  }

  Future<void> setInProgress(int id) =>
      ref.read(deliveryRepositoryProvider).setInProgress(id);

  Future<void> complete(int id, {double? distanceKm}) => ref
      .read(deliveryRepositoryProvider)
      .completeDelivery(id: id, distanceKm: distanceKm);

  Future<void> updateIfood(int id, {required bool success}) => ref
      .read(deliveryRepositoryProvider)
      .updateIfoodConfirmation(id: id, success: success);

  Future<void> delete(
    int id, {
    required int routeId,
    required int shiftId,
  }) async {
    await ref.read(deliveryRepositoryProvider).deleteDelivery(id);
    ref.invalidate(deliveriesForRouteProvider(routeId));
    ref.invalidate(deliveryByIdProvider(id));
    await _recalculateShiftTotals(shiftId, routeId: routeId);
  }

  Future<void> _recalculateShiftTotals(int shiftId, {int? routeId}) async {
    // Decrement the route's earnings entry if the route had one (closed route).
    if (routeId != null) {
      await ref
          .read(earningsRepositoryProvider)
          .decrementRouteDelivery(routeId);
    }
    // Re-sum all remaining earnings entries and update the shift record.
    final entries = await ref
        .read(earningsRepositoryProvider)
        .getEntriesForShift(shiftId);
    final newTotal = entries.fold(0, (s, e) => s + e.routeTotal.cents);
    final newCount = entries.fold(0, (s, e) => s + e.routeDeliveryCount);
    await ref
        .read(shiftRepositoryProvider)
        .updateTotals(
          id: shiftId,
          totalEarningsCents: newTotal,
          deliveryCount: newCount,
        );
    AppLogger.log(
      LogEvents.historyTotalsRecalculated,
      module: 'DeliveryNotifier',
      metadata: {
        'shift_id': shiftId,
        'new_total_cents': newTotal,
        'new_delivery_count': newCount,
      },
    );
    ref.invalidate(allShiftsProvider);
  }
}

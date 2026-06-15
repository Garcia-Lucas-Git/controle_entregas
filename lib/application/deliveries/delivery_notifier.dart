import 'package:controle_entregas/application/earnings/earnings_notifier.dart';
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
        complement: ocr.complement,
        neighborhood: ocr.neighborhood,
        customerName: ocr.customerName,
        orderNumber: ocr.orderNumber,
        ocrRawText: ocr.rawText,
        needsIfoodConfirmation: ocr.needsIfoodConfirmation,
        deliveryIdentifier: ocr.deliveryIdentifier,
        partnerCollectionCode: ocr.partnerCollectionCode,
        hasDrinks: ocr.hasDrinks,
        drinkType: ocr.drinkType,
        needsCard: ocr.needsCard,
        cardAmountCents: ocr.cardAmountCents,
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
    String? complement,
    String? neighborhood,
    String? customerName,
    String? orderNumber,
    String? deliveryIdentifier,
    String? partnerCollectionCode,
    String? pizzaNumber,
    bool hasDrinks = false,
    String? drinkType,
    bool needsCard = false,
    int? cardAmountCents,
  }) => ref
      .read(deliveryRepositoryProvider)
      .createDelivery(
        routeId: routeId,
        shiftId: shiftId,
        sequenceNumber: sequenceNumber,
        addressText: addressText,
        houseNumber: houseNumber,
        complement: complement,
        neighborhood: neighborhood,
        customerName: customerName,
        orderNumber: orderNumber,
        deliveryIdentifier: deliveryIdentifier,
        partnerCollectionCode: partnerCollectionCode,
        pizzaNumber: pizzaNumber,
        hasDrinks: hasDrinks,
        drinkType: drinkType,
        needsCard: needsCard,
        cardAmountCents: cardAmountCents,
      );

  Future<int> nextSequenceForRoute(int routeId) =>
      ref.read(deliveryRepositoryProvider).nextSequenceForRoute(routeId);

  Future<void> reorderRouteDeliveries({
    required int routeId,
    required List<Delivery> deliveries,
  }) async {
    await ref.read(deliveryRepositoryProvider).updateRouteOrder(deliveries);
    ref.invalidate(deliveriesForRouteProvider(routeId));
  }

  Future<void> updateFields({
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
    required int routeId,
  }) async {
    await ref
        .read(deliveryRepositoryProvider)
        .updateDeliveryFields(
          id: id,
          customerName: customerName,
          addressText: addressText,
          houseNumber: houseNumber,
          complement: complement,
          neighborhood: neighborhood,
          orderNumber: orderNumber,
          deliveryIdentifier: deliveryIdentifier,
          pizzaNumber: pizzaNumber,
          needsIfoodConfirmation: needsIfoodConfirmation,
          hasDrinks: hasDrinks,
          drinkType: drinkType,
          needsCard: needsCard,
          cardAmountCents: cardAmountCents,
          clearCardAmount: clearCardAmount,
          needsChange: needsChange,
        );
    AppLogger.log(
      LogEvents.deliveryUpdated,
      module: 'DeliveryNotifier',
      metadata: {
        'delivery_id': id,
        'route_id': routeId,
        'address': addressText,
        'house_number': houseNumber,
        'pizza_number': pizzaNumber,
        'locator': deliveryIdentifier,
      },
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
    final totals = await _syncShiftTotalsFromLiveRoutes(shiftId);
    AppLogger.log(
      LogEvents.historyTotalsRecalculated,
      module: 'DeliveryNotifier',
      metadata: {
        'shift_id': shiftId,
        'route_id': routeId,
        'new_total_cents': totals.totalCents,
        'new_delivery_count': totals.deliveryCount,
      },
    );
    AppLogger.log(
      LogEvents.shiftTotalsRecalculated,
      module: 'DeliveryNotifier',
      metadata: {
        'shift_id': shiftId,
        'delivery_count': totals.deliveryCount,
        'total_cents': totals.totalCents,
      },
    );
    ref.invalidate(allShiftsProvider);
    ref.invalidate(shiftReportDataProvider(shiftId));
  }

  Future<({int totalCents, int deliveryCount})> _syncShiftTotalsFromLiveRoutes(
    int shiftId,
  ) async {
    final routes = await ref
        .read(routeRepositoryProvider)
        .getRoutesForShift(shiftId);
    final closedRoutes = routes.where((r) => r.isClosed).toList();
    final earningsRepo = ref.read(earningsRepositoryProvider);

    for (final route in closedRoutes) {
      final deliveries = await ref
          .read(deliveryRepositoryProvider)
          .getDeliveriesForRoute(route.id);
      final completed = deliveries.where((d) => d.isCompleted).toList();
      await earningsRepo.syncRouteEntry(
        routeId: route.id,
        shiftId: shiftId,
        completedDeliveries: completed,
      );
    }

    final closedRouteIds = closedRoutes.map((r) => r.id).toSet();
    final entries = await earningsRepo.getEntriesForShift(shiftId);
    for (final entry in entries.where(
      (e) => !closedRouteIds.contains(e.routeId),
    )) {
      await earningsRepo.deleteEntryForRoute(entry.routeId);
    }
    final liveEntries = entries.where(
      (e) => closedRouteIds.contains(e.routeId),
    );
    final newTotal = liveEntries.fold(0, (s, e) => s + e.routeTotal.cents);
    final newCount = liveEntries.fold(0, (s, e) => s + e.routeDeliveryCount);
    await ref
        .read(shiftRepositoryProvider)
        .updateTotals(
          id: shiftId,
          totalEarningsCents: newTotal,
          deliveryCount: newCount,
        );
    return (totalCents: newTotal, deliveryCount: newCount);
  }
}

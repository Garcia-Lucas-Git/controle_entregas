import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:controle_entregas/domain/entities/delivery.dart';
import 'package:controle_entregas/services/ocr_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delivery_notifier.g.dart';

@riverpod
Stream<List<Delivery>> deliveriesForRoute(
  DeliveriesForRouteRef ref,
  int routeId,
) =>
    ref.watch(deliveryRepositoryProvider).watchDeliveriesForRoute(routeId);

@riverpod
Stream<Delivery?> deliveryById(
  DeliveryByIdRef ref,
  int deliveryId,
) =>
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
  }) =>
      ref.read(deliveryRepositoryProvider).createDelivery(
            routeId: routeId,
            shiftId: shiftId,
            sequenceNumber: sequenceNumber,
            addressText: ocr.addressText ?? '',
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
          );

  Future<int> createManual({
    required int routeId,
    required int shiftId,
    required int sequenceNumber,
    required String addressText,
    String? customerName,
    String? orderNumber,
  }) =>
      ref.read(deliveryRepositoryProvider).createDelivery(
            routeId: routeId,
            shiftId: shiftId,
            sequenceNumber: sequenceNumber,
            addressText: addressText,
            customerName: customerName,
            orderNumber: orderNumber,
          );

  Future<void> setInProgress(int id) =>
      ref.read(deliveryRepositoryProvider).setInProgress(id);

  Future<void> complete(int id, {double? distanceKm}) =>
      ref.read(deliveryRepositoryProvider).completeDelivery(
            id: id,
            distanceKm: distanceKm,
          );

  Future<void> updateIfood(int id, {required bool success}) =>
      ref.read(deliveryRepositoryProvider).updateIfoodConfirmation(
            id: id,
            success: success,
          );
}

import 'package:controle_entregas/domain/enums/delivery_status.dart';

class Delivery {
  final int id;
  final int routeId;
  final int shiftId;
  final int sequenceNumber;
  final DeliveryStatus status;
  final String? customerName;
  final String addressText;
  final double? distanceKm;
  final String? orderNumber;
  final int? orderValueCents;
  final String? ocrRawText;
  final DateTime? completedAt;
  final DateTime createdAt;

  // iFood fields
  final bool needsIfoodConfirmation;
  final String? deliveryIdentifier;
  final String? partnerCollectionCode;
  final bool? ifoodConfirmationSuccess;
  final DateTime? ifoodConfirmedAt;

  // Delivery flags
  final bool hasDrinks;
  final bool needsCard;
  final bool needsChange;
  final int? changeAmountCents;

  const Delivery({
    required this.id,
    required this.routeId,
    required this.shiftId,
    required this.sequenceNumber,
    required this.status,
    this.customerName,
    required this.addressText,
    this.distanceKm,
    this.orderNumber,
    this.orderValueCents,
    this.ocrRawText,
    this.completedAt,
    required this.createdAt,
    this.needsIfoodConfirmation = false,
    this.deliveryIdentifier,
    this.partnerCollectionCode,
    this.ifoodConfirmationSuccess,
    this.ifoodConfirmedAt,
    this.hasDrinks = false,
    this.needsCard = false,
    this.needsChange = false,
    this.changeAmountCents,
  });

  bool get isCompleted => status == DeliveryStatus.completed;
  bool get isPending => status == DeliveryStatus.pending;
}

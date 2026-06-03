import 'package:controle_entregas/domain/enums/earnings_type.dart';
import 'package:controle_entregas/domain/value_objects/money.dart';

class EarningsEntry {
  final int id;
  final int routeId;
  final int shiftId;
  final EarningsType earningsType;
  final Money rateApplied;
  final int routeDeliveryCount;
  final double? routeDistanceKm;
  final String classificationReason;
  final String configSnapshot;
  final DateTime createdAt;

  const EarningsEntry({
    required this.id,
    required this.routeId,
    required this.shiftId,
    required this.earningsType,
    required this.rateApplied,
    required this.routeDeliveryCount,
    this.routeDistanceKm,
    required this.classificationReason,
    required this.configSnapshot,
    required this.createdAt,
  });
}

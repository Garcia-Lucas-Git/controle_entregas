import 'package:controle_entregas/domain/enums/route_status.dart';

class RouteEntity {
  final int id;
  final int shiftId;
  final int routeNumber;
  final RouteStatus status;
  final DateTime startedAt;
  final DateTime? closedAt;
  final int? deliveryCountAtClose;
  final DateTime createdAt;

  const RouteEntity({
    required this.id,
    required this.shiftId,
    required this.routeNumber,
    required this.status,
    required this.startedAt,
    this.closedAt,
    this.deliveryCountAtClose,
    required this.createdAt,
  });

  bool get isOpen => status == RouteStatus.open;
  bool get isClosed => status == RouteStatus.closed;
}

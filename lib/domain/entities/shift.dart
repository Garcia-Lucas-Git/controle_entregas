import 'package:controle_entregas/domain/enums/shift_status.dart';
import 'package:controle_entregas/domain/value_objects/money.dart';

class Shift {
  final int id;
  final String driverName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final ShiftStatus status;
  final Money totalEarnings;
  final int deliveryCount;
  final String? notes;
  final DateTime createdAt;
  final String source;
  final double? hoursWorked;
  final int? fuelExpenseCents;

  const Shift({
    required this.id,
    required this.driverName,
    required this.startedAt,
    this.endedAt,
    required this.status,
    required this.totalEarnings,
    required this.deliveryCount,
    this.notes,
    required this.createdAt,
    this.source = 'app',
    this.hoursWorked,
    this.fuelExpenseCents,
  });

  bool get isOpen => status == ShiftStatus.open;
  bool get isHistorical => source == 'historical';
}

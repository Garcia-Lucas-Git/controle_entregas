import 'package:controle_entregas/domain/entities/earnings_entry.dart';
import 'package:controle_entregas/domain/entities/route_entity.dart';
import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/domain/enums/earnings_type.dart';
import 'package:controle_entregas/domain/value_objects/money.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:intl/intl.dart';

String _fmt2(int cents) => 'R\$ ${(cents / 100).toStringAsFixed(2)}';

class ShiftReportData {
  final Shift shift;
  final List<RouteWithEarnings> routes;
  final Map<int, List<String>> routeNeighborhoods;

  const ShiftReportData({
    required this.shift,
    required this.routes,
    this.routeNeighborhoods = const {},
  });

  int get totalDeliveries =>
      routes.fold(0, (sum, r) => sum + r.entry.routeDeliveryCount);

  int get normalCount => routes
      .where((r) => r.entry.earningsType == EarningsType.normal)
      .fold(0, (sum, r) => sum + r.entry.routeDeliveryCount);

  int get longCount => routes
      .where((r) => r.entry.earningsType == EarningsType.longSingleDelivery)
      .length;

  Money get totalEarnings =>
      routes.fold(Money.zero, (sum, r) => sum + r.entry.routeTotal);
}

class RouteWithEarnings {
  final RouteEntity route;
  final EarningsEntry entry;

  const RouteWithEarnings({required this.route, required this.entry});
}

abstract final class ReportGenerator {
  static String generate(ShiftReportData data) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');
    final date = dateFmt.format(data.shift.startedAt.toLocal());

    final sb = StringBuffer();
    sb.writeln('RELATÓRIO DE TURNO — DELIVERYFLOW');
    sb.writeln('');
    sb.writeln('Motorista: ${data.shift.driverName}');
    sb.writeln('Data: $date');
    sb.writeln('');
    sb.writeln('Total de entregas: ${data.totalDeliveries}');
    sb.writeln('');

    for (final rwe in data.routes) {
      final neighborhoods = data.routeNeighborhoods[rwe.route.id] ?? const [];
      final label = neighborhoods.isEmpty
          ? 'Bairro não informado'
          : neighborhoods.join(' • ');
      sb.writeln('Rota ${rwe.route.routeNumber}: $label');
      sb.writeln('');
    }

    sb.writeln('🛵 Gerado pelo DeliveryFlow');

    final report = sb.toString();
    AppLogger.log(
      LogEvents.reportGenerated,
      module: 'ReportGenerator',
      metadata: {
        'shift_id': data.shift.id,
        'delivery_count': data.totalDeliveries,
        'total_cents': data.totalEarnings.cents,
        'format': 'compact',
      },
    );
    return report;
  }

  static String generateManual(Shift shift, {int dailyGoalCents = 12000}) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');
    final sb = StringBuffer();
    sb.writeln('RESUMO DO DIA — DELIVERYFLOW');
    sb.writeln('');
    sb.writeln('Motorista: ${shift.driverName}');
    sb.writeln('Data: ${dateFmt.format(shift.startedAt.toLocal())}');
    sb.writeln('');
    sb.writeln('Entregas: ${shift.deliveryCount}');
    sb.writeln('Ganhos: ${shift.totalEarnings.format()}');
    final fuelCents = shift.fuelExpenseCents;
    if (fuelCents != null && fuelCents > 0) {
      sb.writeln('Combustível: ${_fmt2(fuelCents)}');
      sb.writeln('Líquido: ${_fmt2(shift.totalEarnings.cents - fuelCents)}');
    }
    if (dailyGoalCents > 0) {
      final pct = (shift.totalEarnings.cents / dailyGoalCents * 100).round();
      final goalStr = 'R\$ ${(dailyGoalCents / 100).toStringAsFixed(0)}';
      sb.writeln(
        'Meta diária: $pct% (${shift.totalEarnings.format()} / $goalStr)',
      );
    }
    sb.writeln('');
    sb.writeln('─────────────────────────────────');
    sb.writeln('Gerado pelo DeliveryFlow');
    return sb.toString();
  }
}

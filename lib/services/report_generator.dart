import 'package:controle_entregas/domain/entities/earnings_entry.dart';
import 'package:controle_entregas/domain/entities/route_entity.dart';
import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/domain/enums/earnings_type.dart';
import 'package:controle_entregas/domain/value_objects/money.dart';
import 'package:intl/intl.dart';

String _fmt2(int cents) => 'R\$ ${(cents / 100).toStringAsFixed(2)}';

class ShiftReportData {
  final Shift shift;
  final List<RouteWithEarnings> routes;

  const ShiftReportData({required this.shift, required this.routes});

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
    sb.writeln('─────────────────────────────────');
    sb.writeln('RESUMO');
    sb.writeln('─────────────────────────────────');
    sb.writeln('Total de entregas: ${data.totalDeliveries}');

    if (data.normalCount > 0) {
      sb.writeln('Entregas normais (R\$ 8,00): ${data.normalCount} × R\$ 8,00');
    }
    if (data.longCount > 0) {
      sb.writeln(
        'Entregas longa distância (R\$ 10,00): ${data.longCount} × R\$ 10,00',
      );
    }

    sb.writeln('');
    sb.writeln('Ganhos estimados: ${data.totalEarnings.format()}');
    final fuelCents = data.shift.fuelExpenseCents;
    if (fuelCents != null && fuelCents > 0) {
      sb.writeln('Combustível: ${_fmt2(fuelCents)}');
      sb.writeln('Líquido: ${_fmt2(data.totalEarnings.cents - fuelCents)}');
    }
    sb.writeln('');
    sb.writeln('─────────────────────────────────');
    sb.writeln('DETALHAMENTO POR ROTA');
    sb.writeln('─────────────────────────────────');

    for (final rwe in data.routes) {
      final r = rwe.route;
      final e = rwe.entry;
      sb.writeln('');
      sb.writeln('ROTA ${r.routeNumber}');
      sb.writeln('Entregas: ${e.routeDeliveryCount}');
      sb.writeln('Classificação: ${_typeLabel(e.earningsType)}');
      sb.writeln(
        'Valor: ${e.routeDeliveryCount} × ${e.rateApplied.format()} = ${e.routeTotal.format()}',
      );

      if (e.routeDistanceKm != null) {
        sb.writeln(
          'Distância aprox.: ${e.routeDistanceKm!.toStringAsFixed(1)} km',
        );
      }
    }

    sb.writeln('');
    sb.writeln('─────────────────────────────────');
    sb.writeln('Gerado pelo DeliveryFlow');

    return sb.toString();
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
      sb.writeln('Meta diária: $pct% (${shift.totalEarnings.format()} / $goalStr)');
    }
    sb.writeln('');
    sb.writeln('─────────────────────────────────');
    sb.writeln('Gerado pelo DeliveryFlow');
    return sb.toString();
  }

  static String _typeLabel(EarningsType type) => switch (type) {
    EarningsType.longSingleDelivery => 'Longa distância',
    EarningsType.normal => 'Normal',
  };
}

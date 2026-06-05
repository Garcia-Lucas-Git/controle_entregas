import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/domain/enums/shift_status.dart';
import 'package:controle_entregas/domain/value_objects/money.dart';

class PaymentCycleSummary {
  final Money earningsToday;
  final Money earningsThisWeek;
  final int deliveriesToday;
  final int deliveriesThisWeek;
  final DateTime nextPaymentDate;
  final Money forecastedPayment;

  const PaymentCycleSummary({
    required this.earningsToday,
    required this.earningsThisWeek,
    required this.deliveriesToday,
    required this.deliveriesThisWeek,
    required this.nextPaymentDate,
    required this.forecastedPayment,
  });
}

class PaymentPeriod {
  final DateTime weekStart;
  final DateTime weekEnd;
  final DateTime paymentDate;
  final Money totalEarnings;
  final int deliveryCount;

  const PaymentPeriod({
    required this.weekStart,
    required this.weekEnd,
    required this.paymentDate,
    required this.totalEarnings,
    required this.deliveryCount,
  });
}

// Semana operacional: Segunda → Domingo
// Pagamento: quarta-feira da semana seguinte (domingo da semana + 3 dias)
abstract final class PaymentCycleService {
  static DateTime weekStart(DateTime date) {
    final d = date.toLocal();
    final daysSinceMonday = d.weekday - DateTime.monday;
    return DateTime(d.year, d.month, d.day - daysSinceMonday);
  }

  static DateTime weekEnd(DateTime date) =>
      weekStart(date).add(const Duration(days: 6));

  static DateTime paymentDateForWeek(DateTime anyDayInWeek) =>
      weekEnd(anyDayInWeek).add(const Duration(days: 3));

  static DateTime nextPaymentDate(DateTime today) => paymentDateForWeek(today);

  static bool isSameDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  static bool isSameWeek(DateTime a, DateTime b) =>
      weekStart(a) == weekStart(b);

  static PaymentCycleSummary buildSummary(List<Shift> shifts, DateTime today) {
    final closed = shifts.where((s) => s.status == ShiftStatus.closed);
    final todayShifts = closed.where((s) => isSameDay(s.startedAt, today));
    final weekShifts = closed.where((s) => isSameWeek(s.startedAt, today));

    return PaymentCycleSummary(
      earningsToday: Money(
        todayShifts.fold(0, (sum, s) => sum + s.totalEarnings.cents),
      ),
      earningsThisWeek: Money(
        weekShifts.fold(0, (sum, s) => sum + s.totalEarnings.cents),
      ),
      deliveriesToday: todayShifts.fold(0, (sum, s) => sum + s.deliveryCount),
      deliveriesThisWeek: weekShifts.fold(0, (sum, s) => sum + s.deliveryCount),
      nextPaymentDate: nextPaymentDate(today),
      forecastedPayment: Money(
        weekShifts.fold(0, (sum, s) => sum + s.totalEarnings.cents),
      ),
    );
  }

  static List<PaymentPeriod> buildHistory(List<Shift> shifts) {
    final weekMap = <DateTime, List<Shift>>{};
    for (final s in shifts.where((s) => s.status == ShiftStatus.closed)) {
      final ws = weekStart(s.startedAt);
      weekMap.putIfAbsent(ws, () => []).add(s);
    }
    final periods = weekMap.entries.map((e) {
      final ws = e.key;
      final list = e.value;
      return PaymentPeriod(
        weekStart: ws,
        weekEnd: weekEnd(ws),
        paymentDate: paymentDateForWeek(ws),
        totalEarnings: Money(
          list.fold(0, (sum, s) => sum + s.totalEarnings.cents),
        ),
        deliveryCount: list.fold(0, (sum, s) => sum + s.deliveryCount),
      );
    }).toList();
    periods.sort((a, b) => b.weekStart.compareTo(a.weekStart));
    return periods;
  }
}

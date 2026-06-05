// Calendário de referência usado nos testes:
// junho/2026: seg 1, ter 2, qua 3, qui 4, sex 5, sáb 6, dom 7, seg 8...
// maio/2026:  seg 25, ter 26, qua 27, qui 28, sex 29, sáb 30, dom 31

import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/domain/enums/shift_status.dart';
import 'package:controle_entregas/domain/services/payment_cycle_service.dart';
import 'package:controle_entregas/domain/value_objects/money.dart';
import 'package:flutter_test/flutter_test.dart';

Shift _shift(DateTime date, {int earningsCents = 800, int deliveries = 1}) =>
    Shift(
      id: 0,
      driverName: 'test',
      startedAt: date,
      status: ShiftStatus.closed,
      totalEarnings: Money(earningsCents),
      deliveryCount: deliveries,
      createdAt: date,
    );

void main() {
  group('PaymentCycleService — weekStart', () {
    test('segunda-feira é início da semana', () {
      final monday = DateTime(2026, 6, 1);
      expect(PaymentCycleService.weekStart(monday), equals(monday));
    });

    test('quarta-feira pertence à mesma semana que sua segunda', () {
      final monday = DateTime(2026, 6, 1);
      final wednesday = DateTime(2026, 6, 3);
      expect(PaymentCycleService.weekStart(wednesday), equals(monday));
    });

    test('domingo é o último dia da semana', () {
      final sunday = DateTime(2026, 6, 7);
      expect(PaymentCycleService.weekEnd(sunday), equals(sunday));
    });

    test('virada de mês: domingo 31/05 pertence à semana que começa em 25/05', () {
      final sunday = DateTime(2026, 5, 31);
      final expectedMonday = DateTime(2026, 5, 25);
      expect(PaymentCycleService.weekStart(sunday), equals(expectedMonday));
    });
  });

  group('PaymentCycleService — isSameWeek', () {
    test('sábado e domingo são da mesma semana', () {
      final saturday = DateTime(2026, 6, 6);
      final sunday = DateTime(2026, 6, 7);
      expect(PaymentCycleService.isSameWeek(saturday, sunday), isTrue);
    });

    test('domingo e segunda seguinte são semanas diferentes (virada)', () {
      final sunday = DateTime(2026, 6, 7);
      final nextMonday = DateTime(2026, 6, 8);
      expect(PaymentCycleService.isSameWeek(sunday, nextMonday), isFalse);
    });
  });

  group('PaymentCycleService — paymentDateForWeek', () {
    // Semana: seg 01/06 → dom 07/06 → pagamento: qua 10/06
    test('semana 01/06→07/06 tem pagamento na quarta 10/06', () {
      final monday = DateTime(2026, 6, 1);
      expect(
        PaymentCycleService.paymentDateForWeek(monday),
        equals(DateTime(2026, 6, 10)),
      );
    });

    // Caso de domingo isolado: trabalhou dom 07/06 → pagamento na quarta 10/06
    test('domingo isolado 07/06 tem pagamento na quarta 10/06', () {
      final sunday = DateTime(2026, 6, 7);
      expect(
        PaymentCycleService.paymentDateForWeek(sunday),
        equals(DateTime(2026, 6, 10)),
      );
    });

    // Virada de mês: semana 25/05→31/05 → pagamento qua 03/06
    test('semana 25/05→31/05 tem pagamento na quarta 03/06', () {
      final sunday = DateTime(2026, 5, 31);
      expect(
        PaymentCycleService.paymentDateForWeek(sunday),
        equals(DateTime(2026, 6, 3)),
      );
    });
  });

  group('PaymentCycleService — nextPaymentDate', () {
    test('de uma quinta-feira o próximo pagamento é a quarta da semana seguinte', () {
      final thursday = DateTime(2026, 6, 4); // qui 04/06
      // Semana: seg 01/06 → dom 07/06 → pagamento: qua 10/06
      expect(
        PaymentCycleService.nextPaymentDate(thursday),
        equals(DateTime(2026, 6, 10)),
      );
    });

    test('cálculo da próxima quarta a partir de uma segunda-feira', () {
      final monday = DateTime(2026, 6, 8); // seg 08/06
      // Semana: seg 08/06 → dom 14/06 → pagamento: qua 17/06
      expect(
        PaymentCycleService.nextPaymentDate(monday),
        equals(DateTime(2026, 6, 17)),
      );
    });
  });

  group('PaymentCycleService — buildSummary', () {
    test('agrupa corretamente ganhos de hoje e da semana', () {
      final today = DateTime(2026, 6, 4); // qui 04/06 (semana: 01/06→07/06)
      final shifts = [
        _shift(DateTime(2026, 6, 4), earningsCents: 800, deliveries: 1),
        _shift(DateTime(2026, 6, 3), earningsCents: 1600, deliveries: 2),
        _shift(DateTime(2026, 5, 28), earningsCents: 800, deliveries: 1), // outra semana
      ];
      final summary = PaymentCycleService.buildSummary(shifts, today);
      expect(summary.earningsToday.cents, equals(800));
      expect(summary.earningsThisWeek.cents, equals(2400)); // 800 + 1600
      expect(summary.deliveriesToday, equals(1));
      expect(summary.deliveriesThisWeek, equals(3));
    });

    test('próximo pagamento calculado corretamente', () {
      final today = DateTime(2026, 6, 4); // qui 04/06
      final summary = PaymentCycleService.buildSummary([], today);
      expect(summary.nextPaymentDate, equals(DateTime(2026, 6, 10)));
    });
  });

  group('PaymentCycleService — buildHistory', () {
    test('agrupa turnos por semana e ordena do mais recente para o mais antigo', () {
      final shifts = [
        // Semana seg 01/06 → dom 07/06
        _shift(DateTime(2026, 6, 1), earningsCents: 3200, deliveries: 4),
        // Semana seg 25/05 → dom 31/05
        _shift(DateTime(2026, 5, 27), earningsCents: 1600, deliveries: 2),
        _shift(DateTime(2026, 5, 28), earningsCents: 800, deliveries: 1),
      ];
      final history = PaymentCycleService.buildHistory(shifts);
      expect(history.length, equals(2));
      // Mais recente: semana 01/06→07/06
      expect(history.first.weekStart, equals(DateTime(2026, 6, 1)));
      expect(history.first.totalEarnings.cents, equals(3200));
      expect(history.first.deliveryCount, equals(4));
      expect(history.first.paymentDate, equals(DateTime(2026, 6, 10)));
      // Mais antigo: semana 25/05→31/05
      expect(history.last.weekStart, equals(DateTime(2026, 5, 25)));
      expect(history.last.totalEarnings.cents, equals(2400)); // 1600 + 800
      expect(history.last.deliveryCount, equals(3));
      expect(history.last.paymentDate, equals(DateTime(2026, 6, 3)));
    });

    test('ignora turnos abertos', () {
      final open = Shift(
        id: 99,
        driverName: 'test',
        startedAt: DateTime(2026, 6, 5),
        status: ShiftStatus.open,
        totalEarnings: Money(800),
        deliveryCount: 1,
        createdAt: DateTime(2026, 6, 5),
      );
      final history = PaymentCycleService.buildHistory([open]);
      expect(history, isEmpty);
    });
  });
}

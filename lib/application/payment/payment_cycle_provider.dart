import 'package:controle_entregas/application/shifts/shift_notifier.dart';
import 'package:controle_entregas/domain/services/payment_cycle_service.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final paymentCycleSummaryProvider =
    Provider.autoDispose<AsyncValue<PaymentCycleSummary>>((ref) {
      return ref.watch(allShiftsProvider).whenData((shifts) {
        final summary = PaymentCycleService.buildSummary(
          shifts,
          DateTime.now(),
        );
        AppLogger.log(
          LogEvents.paymentForecastUpdated,
          module: 'PaymentCycleProvider',
          metadata: {
            'earnings_today_cents': summary.earningsToday.cents,
            'earnings_week_cents': summary.earningsThisWeek.cents,
            'deliveries_today': summary.deliveriesToday,
            'deliveries_week': summary.deliveriesThisWeek,
            'next_payment_date': summary.nextPaymentDate.toIso8601String(),
          },
        );
        return summary;
      });
    });

final paymentHistoryProvider =
    Provider.autoDispose<AsyncValue<List<PaymentPeriod>>>((ref) {
      return ref.watch(allShiftsProvider).whenData((shifts) {
        final history = PaymentCycleService.buildHistory(shifts);
        AppLogger.log(
          LogEvents.paymentHistoryGenerated,
          module: 'PaymentCycleProvider',
          metadata: {'period_count': history.length},
        );
        return history;
      });
    });

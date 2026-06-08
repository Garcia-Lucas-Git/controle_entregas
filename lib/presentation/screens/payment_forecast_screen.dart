import 'package:controle_entregas/application/payment/payment_cycle_provider.dart';
import 'package:controle_entregas/application/shifts/shift_notifier.dart';
import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/domain/services/payment_cycle_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class PaymentForecastScreen extends ConsumerWidget {
  const PaymentForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(paymentCycleSummaryProvider);
    final historyAsync = ref.watch(paymentHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Previsão de Pagamento')),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader('Semana Atual'),
            const SizedBox(height: 8),
            Row(
              children: [
                _MetricCard(
                  label: 'Ganhos Hoje',
                  value: summary.earningsToday.format(),
                  icon: Icons.today_outlined,
                ),
                const SizedBox(width: 12),
                _MetricCard(
                  label: 'Entregas Hoje',
                  value: '${summary.deliveriesToday}',
                  icon: Icons.local_shipping_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetricCard(
                  label: 'Ganhos Semana',
                  value: summary.earningsThisWeek.format(),
                  icon: Icons.date_range_outlined,
                  highlight: true,
                ),
                const SizedBox(width: 12),
                _MetricCard(
                  label: 'Entregas Semana',
                  value: '${summary.deliveriesThisWeek}',
                  icon: Icons.inventory_2_outlined,
                ),
              ],
            ),
            if (summary.fuelThisWeek.cents > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetricCard(
                    label: 'Combustível Semana',
                    value: summary.fuelThisWeek.format(),
                    icon: Icons.local_gas_station_outlined,
                  ),
                  const SizedBox(width: 12),
                  _MetricCard(
                    label: 'Líquido Semana',
                    value: summary.netThisWeek.format(),
                    icon: Icons.account_balance_wallet_outlined,
                    highlight: true,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            _SectionHeader('Próximo Pagamento'),
            const SizedBox(height: 8),
            _NextPaymentCard(summary: summary),
            const SizedBox(height: 24),
            _SectionHeader('Histórico por Semana'),
            const SizedBox(height: 8),
            historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
              data: (history) => history.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nenhum turno encerrado ainda.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      children: history
                          .map((p) => _PeriodCard(period: p))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Next payment card ─────────────────────────────────────────────────────────

class _NextPaymentCard extends StatelessWidget {
  final PaymentCycleSummary summary;

  const _NextPaymentCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');
    final today = DateTime.now();
    final daysUntil = summary.nextPaymentDate
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;

    final weekStart = PaymentCycleService.weekStart(today);
    final weekEnd = PaymentCycleService.weekEnd(today);

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFmt.format(summary.nextPaymentDate),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _DaysChip(daysUntil),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Semana: ${DateFormat('dd/MM', 'pt_BR').format(weekStart)}'
              ' → ${DateFormat('dd/MM', 'pt_BR').format(weekEnd)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Valor previsto',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            Text(
              summary.forecastedPayment.format(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaysChip extends StatelessWidget {
  final int days;
  const _DaysChip(this.days);

  @override
  Widget build(BuildContext context) {
    final label = days == 0
        ? 'Hoje'
        : days == 1
        ? 'Amanhã'
        : 'em $days dias';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

// ── Period history card ───────────────────────────────────────────────────────

class _PeriodCard extends StatelessWidget {
  final PaymentPeriod period;

  const _PeriodCard({required this.period});

  @override
  Widget build(BuildContext context) {
    final shortFmt = DateFormat('dd/MM', 'pt_BR');
    final longFmt = DateFormat('dd/MM/yyyy', 'pt_BR');
    final today = DateTime.now();
    final isPaid = period.paymentDate.isBefore(
      DateTime(today.year, today.month, today.day),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push(
          '/history/week-details',
          extra: {'start': period.weekStart, 'end': period.weekEnd},
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semana: ${shortFmt.format(period.weekStart)}'
                      ' → ${shortFmt.format(period.weekEnd)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${period.deliveryCount} entregas · '
                      '${period.totalEarnings.format()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (period.fuelTotal.cents > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Comb. ${period.fuelTotal.format()} · '
                        'Líq. ${period.netTotal.format()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isPaid ? Icons.check_circle_outline : Icons.schedule,
                          size: 13,
                          color: isPaid
                              ? Colors.green.shade700
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPaid
                              ? 'Pago em ${longFmt.format(period.paymentDate)}'
                              : 'Pagamento: ${longFmt.format(period.paymentDate)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isPaid
                                    ? Colors.green.shade700
                                    : Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                period.totalEarnings.format(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeekDetailsScreen extends ConsumerWidget {
  final DateTime weekStart;
  final DateTime weekEnd;

  const WeekDetailsScreen({
    super.key,
    required this.weekStart,
    required this.weekEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(allShiftsProvider);
    final fmt = DateFormat('dd/MM', 'pt_BR');
    return Scaffold(
      appBar: AppBar(
        title: Text('Semana ${fmt.format(weekStart)} - ${fmt.format(weekEnd)}'),
      ),
      body: shiftsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (shifts) {
          final weekShifts = shifts.where((shift) {
            final day = DateTime(
              shift.startedAt.year,
              shift.startedAt.month,
              shift.startedAt.day,
            );
            return !day.isBefore(weekStart) && !day.isAfter(weekEnd);
          }).toList();
          if (weekShifts.isEmpty) {
            return const Center(child: Text('Nenhum turno nesta semana.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: weekShifts.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _WeekShiftTile(shift: weekShifts[index]),
          );
        },
      ),
    );
  }
}

class _WeekShiftTile extends StatelessWidget {
  final Shift shift;

  const _WeekShiftTile({required this.shift});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy', 'pt_BR');
    return ListTile(
      dense: true,
      leading: const Icon(Icons.calendar_today_outlined, size: 18),
      title: Text(fmt.format(shift.startedAt.toLocal())),
      subtitle: Text(
        '${shift.deliveryCount} entregas · ${shift.totalEarnings.format()}',
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () => context.push('/shift/${shift.id}/details'),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: highlight
            ? Theme.of(context).colorScheme.secondaryContainer
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

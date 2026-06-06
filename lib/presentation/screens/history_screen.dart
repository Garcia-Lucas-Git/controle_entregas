import 'package:controle_entregas/application/shifts/shift_notifier.dart';
import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/domain/enums/shift_status.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(allShiftsProvider);

    ref.listen<AsyncValue<List<Shift>>>(allShiftsProvider, (_, next) {
      next.whenData((shifts) {
        if (shifts.isEmpty) {
          AppLogger.info(LogEvents.historyLoadEmpty, module: 'HistoryScreen');
        } else {
          final closed = shifts
              .where((s) => s.status == ShiftStatus.closed)
              .length;
          AppLogger.log(
            LogEvents.historyRowsFound,
            module: 'HistoryScreen',
            metadata: {
              'total': shifts.length,
              'closed': closed,
              'open': shifts.length - closed,
            },
          );
          _logPeriodReports(shifts);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.payments_outlined),
            tooltip: 'Previsão de Pagamento',
            onPressed: () => context.push('/history/payment-forecast'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpar histórico',
            onPressed: () => _confirmClearHistory(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.add_chart),
            tooltip: 'Adicionar Histórico',
            onPressed: () => context.push('/history/add'),
          ),
        ],
      ),
      body: shiftsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
        data: (shifts) {
          if (shifts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhum registro ainda.\n\nInicie e encerre um turno para ver o histórico.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final now = DateTime.now();
          final weekStart = _weekStart(now);
          final weekShifts = shifts
              .where((s) => !s.startedAt.toLocal().isBefore(weekStart))
              .toList();
          final grouped = _groupByMonth(shifts);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length + 1,
            itemBuilder: (ctx, i) {
              if (i == 0) return _WeekSummaryCard(shifts: weekShifts);
              final entry = grouped[i - 1];
              return _MonthGroup(monthLabel: entry.key, shifts: entry.value);
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar histórico?'),
        content: const Text(
          'Todos os registros fechados do histórico serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(historicalEntryNotifierProvider.notifier).clearHistory();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Histórico limpo.')));
  }

  List<MapEntry<String, List<Shift>>> _groupByMonth(List<Shift> shifts) {
    final map = <String, List<Shift>>{};
    final fmt = DateFormat('MMMM yyyy', 'pt_BR');
    for (final s in shifts) {
      final key = fmt.format(s.startedAt.toLocal());
      map.putIfAbsent(key, () => []).add(s);
    }
    return map.entries.toList();
  }

  static DateTime _weekStart(DateTime now) {
    final local = now.toLocal();
    return DateTime(local.year, local.month, local.day - (local.weekday - 1));
  }

  static void _logPeriodReports(List<Shift> shifts) {
    final now = DateTime.now();
    final weekStart = _weekStart(now);
    final monthStart = DateTime(now.year, now.month, 1);

    _logPeriod(
      'week',
      shifts
          .where((s) => !s.startedAt.toLocal().isBefore(weekStart))
          .toList(),
    );
    _logPeriod(
      'month',
      shifts
          .where((s) => !s.startedAt.toLocal().isBefore(monthStart))
          .toList(),
    );
  }

  static void _logPeriod(String period, List<Shift> shifts) {
    if (shifts.isEmpty) return;
    final revenue = shifts.fold(0, (sum, s) => sum + s.totalEarnings.cents);
    final fuel = shifts.fold(
      0,
      (sum, s) => sum + (s.fuelExpenseCents ?? 0),
    );
    AppLogger.log(
      LogEvents.periodReport,
      module: 'HistoryScreen',
      metadata: {
        'period': period,
        'revenue': revenue,
        'fuel': fuel,
        'net': revenue - fuel,
      },
    );
  }
}

class _WeekSummaryCard extends StatelessWidget {
  final List<Shift> shifts;
  const _WeekSummaryCard({required this.shifts});

  @override
  Widget build(BuildContext context) {
    if (shifts.isEmpty) return const SizedBox.shrink();

    final revenue = shifts.fold(0, (sum, s) => sum + s.totalEarnings.cents);
    final fuel = shifts.fold(0, (sum, s) => sum + (s.fuelExpenseCents ?? 0));
    final net = revenue - fuel;
    final hasFuel = fuel > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ESTA SEMANA',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _SummaryCell(
                  label: 'Receita',
                  value: 'R\$ ${(revenue / 100).toStringAsFixed(2)}',
                ),
                if (hasFuel) ...[
                  const SizedBox(width: 24),
                  _SummaryCell(
                    label: 'Combustível',
                    value: 'R\$ ${(fuel / 100).toStringAsFixed(2)}',
                  ),
                  const SizedBox(width: 24),
                  _SummaryCell(
                    label: 'Líquido',
                    value: 'R\$ ${(net / 100).toStringAsFixed(2)}',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

class _MonthGroup extends StatefulWidget {
  final String monthLabel;
  final List<Shift> shifts;
  const _MonthGroup({required this.monthLabel, required this.shifts});

  @override
  State<_MonthGroup> createState() => _MonthGroupState();
}

class _MonthGroupState extends State<_MonthGroup> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final totalEarnings = widget.shifts.fold(
      0,
      (sum, s) => sum + s.totalEarnings.cents,
    );
    final totalDeliveries = widget.shifts.fold(
      0,
      (sum, s) => sum + s.deliveryCount,
    );
    final totalFuel = widget.shifts.fold(
      0,
      (sum, s) => sum + (s.fuelExpenseCents ?? 0),
    );
    final netRevenue = totalEarnings - totalFuel;
    final hasFuel = totalFuel > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.monthLabel.toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            subtitle: Text(
              hasFuel
                  ? '$totalDeliveries entregas · '
                    'R\$ ${(totalEarnings / 100).toStringAsFixed(2)} · '
                    'Comb. R\$ ${(totalFuel / 100).toStringAsFixed(2)} · '
                    'Líq. R\$ ${(netRevenue / 100).toStringAsFixed(2)}'
                  : '$totalDeliveries entregas · '
                    'R\$ ${(totalEarnings / 100).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) ...widget.shifts.map((s) => _ShiftTile(shift: s)),
        ],
      ),
    );
  }
}

class _ShiftTile extends ConsumerWidget {
  final Shift shift;
  const _ShiftTile({required this.shift});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');
    final date = dateFmt.format(shift.startedAt.toLocal());
    final colorScheme = Theme.of(context).colorScheme;

    // Historical (manual) entry
    if (shift.isHistorical) {
      final subtitle = StringBuffer(
        '${shift.deliveryCount} entregas · ${shift.totalEarnings.format()}',
      );
      if (shift.hoursWorked != null) {
        subtitle.write(' · ${shift.hoursWorked!.toStringAsFixed(0)}h');
      }
      if (shift.notes != null) subtitle.write('\n${shift.notes}');

      return ListTile(
        leading: const Icon(Icons.history_edu, size: 20),
        title: Row(
          children: [
            Text(date),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Manual',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          subtitle.toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<_HistoryAction>(
          onSelected: (action) => _handleAction(context, ref, action),
          itemBuilder: (_) => const [
            PopupMenuItem(value: _HistoryAction.edit, child: Text('Editar')),
            PopupMenuItem(value: _HistoryAction.delete, child: Text('Excluir')),
          ],
        ),
        onTap: () => context.push('/history/add', extra: shift),
      );
    }

    // Open (in-progress) shift
    if (shift.status == ShiftStatus.open) {
      return ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 20),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Text(date),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Em andamento',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        subtitle: shift.deliveryCount > 0
            ? Text(
                '${shift.deliveryCount} entregas registradas',
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
      );
    }

    // Closed shift
    return ListTile(
      leading: const Icon(Icons.calendar_today, size: 20),
      title: Text(date),
      subtitle: Text(
        '${shift.deliveryCount} entregas · ${shift.totalEarnings.format()}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/history/shift/${shift.id}/report'),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _HistoryAction action,
  ) async {
    if (action == _HistoryAction.edit) {
      context.push('/history/add', extra: shift);
      return;
    }

    AppLogger.info(
      LogEvents.historyDeleteItem,
      module: 'HistoryScreen',
      metadata: {'shift_id': shift.id},
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro?'),
        content: const Text('Este registro histórico será excluído.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    AppLogger.info(
      LogEvents.historyDeleteItemConfirmed,
      module: 'HistoryScreen',
      metadata: {'shift_id': shift.id},
    );

    // Capture data before deletion so UNDO can re-insert.
    final savedShift = shift;
    await ref.read(historicalEntryNotifierProvider.notifier).delete(shift.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Registro removido'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DESFAZER',
          onPressed: () async {
            AppLogger.info(
              LogEvents.historyRestoreItem,
              module: 'HistoryScreen',
              metadata: {'shift_id': savedShift.id},
            );
            await ref.read(historicalEntryNotifierProvider.notifier).save(
              date: savedShift.startedAt,
              deliveryCount: savedShift.deliveryCount,
              earningsCents: savedShift.totalEarnings.cents,
              hoursWorked: savedShift.hoursWorked,
              notes: savedShift.notes,
            );
          },
        ),
      ),
    );
  }
}

enum _HistoryAction { edit, delete }

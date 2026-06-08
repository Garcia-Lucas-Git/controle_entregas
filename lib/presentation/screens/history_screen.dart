import 'dart:math';

import 'package:controle_entregas/application/settings/settings_notifier.dart';
import 'package:controle_entregas/application/shifts/shift_notifier.dart';
import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/domain/enums/shift_status.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:controle_entregas/services/report_generator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Visual hierarchy brown palette
const _kMonthHeaderBg = Color(0xFF3E1F0A); // dark brown — Level 1
const _kWeekHeaderBg = Color(0xFF6B3D20); // medium brown — Level 2
const _kRevenueBg = Color(0xFF2C1508); // deepest brown — Revenue emphasis

// Week label → list of shifts within that week
typedef _WeekEntry = MapEntry<String, List<Shift>>;
// Month label → list of week entries for that month
typedef _MonthEntry = MapEntry<String, List<_WeekEntry>>;

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
          final thisWeek = _weekStart(now);
          final weekShifts = shifts
              .where((s) => !s.startedAt.toLocal().isBefore(thisWeek))
              .toList();
          final grouped = _groupByMonthAndWeek(shifts);

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: grouped.length + 1,
            itemBuilder: (ctx, i) {
              if (i == 0) return _WeekSummaryCard(shifts: weekShifts);
              final entry = grouped[i - 1];
              return _MonthGroup(monthLabel: entry.key, weekData: entry.value);
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

  // Groups shifts into a 2-level hierarchy: month → week → shifts (all descending).
  List<_MonthEntry> _groupByMonthAndWeek(List<Shift> shifts) {
    final now = DateTime.now().toLocal();
    final thisWeek = _weekStart(now);
    final fmtMonth = DateFormat('MMMM yyyy', 'pt_BR');

    // Preserve order: shifts arrive most-recent-first, so months and weeks
    // will naturally be ordered descending as well.
    final monthOrder = <String>[];
    final monthMap = <String, List<Shift>>{};
    for (final s in shifts) {
      final key = fmtMonth.format(s.startedAt.toLocal());
      if (!monthMap.containsKey(key)) {
        monthOrder.add(key);
        monthMap[key] = [];
      }
      monthMap[key]!.add(s);
    }

    return monthOrder.map((monthKey) {
      final monthShifts = monthMap[monthKey]!;

      final weekOrder = <DateTime>[];
      final weekMap = <DateTime, List<Shift>>{};
      for (final s in monthShifts) {
        final ws = _weekStart(s.startedAt.toLocal());
        if (!weekMap.containsKey(ws)) {
          weekOrder.add(ws);
          weekMap[ws] = [];
        }
        weekMap[ws]!.add(s);
      }

      // Most-recent week first.
      weekOrder.sort((a, b) => b.compareTo(a));

      final weeks = <_WeekEntry>[];
      for (int i = 0; i < weekOrder.length; i++) {
        final ws = weekOrder[i];
        final label = ws == thisWeek ? 'Semana Atual' : 'Semana ${i + 1}';
        final weekShifts = weekMap[ws]!
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        weeks.add(MapEntry(label, weekShifts));
      }

      return MapEntry(monthKey, weeks);
    }).toList();
  }

  static DateTime _weekStart(DateTime dt) {
    final local = dt.toLocal();
    return DateTime(local.year, local.month, local.day - (local.weekday - 1));
  }

  static void _logPeriodReports(List<Shift> shifts) {
    final now = DateTime.now();
    final weekStart = _weekStart(now);
    final monthStart = DateTime(now.year, now.month, 1);
    _logPeriod(
      'week',
      shifts.where((s) => !s.startedAt.toLocal().isBefore(weekStart)).toList(),
    );
    _logPeriod(
      'month',
      shifts.where((s) => !s.startedAt.toLocal().isBefore(monthStart)).toList(),
    );
  }

  static void _logPeriod(String period, List<Shift> shifts) {
    if (shifts.isEmpty) return;
    final revenue = shifts.fold(0, (sum, s) => sum + s.totalEarnings.cents);
    final fuel = shifts.fold(0, (sum, s) => sum + (s.fuelExpenseCents ?? 0));
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

// ── Weekly summary card ───────────────────────────────────────────────────────

class _WeekSummaryCard extends ConsumerWidget {
  final List<Shift> shifts;
  const _WeekSummaryCard({required this.shifts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStreamProvider);
    final dailyGoalCents = settings.valueOrNull?.dailyGoalCents ?? 12000;
    const workingDays = 6;
    final weeklyGoalCents = dailyGoalCents * workingDays;

    final now = DateTime.now();
    final weekStart = HistoryScreen._weekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final rangeFmt = DateFormat('dd/MM', 'pt_BR');

    final revenue = shifts.fold(0, (sum, s) => sum + s.totalEarnings.cents);
    final fuel = shifts.fold(0, (sum, s) => sum + (s.fuelExpenseCents ?? 0));
    final net = revenue - fuel;
    final deliveries = shifts.fold(0, (sum, s) => sum + s.deliveryCount);
    final progress = weeklyGoalCents > 0
        ? (net / weeklyGoalCents).clamp(0.0, 1.0)
        : 0.0;
    final goalReached = weeklyGoalCents > 0 && net >= weeklyGoalCents;
    final pct = weeklyGoalCents > 0 ? (net / weeklyGoalCents * 100).round() : 0;
    final remainingCents = max(0, weeklyGoalCents - net);

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTA SEMANA',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${rangeFmt.format(weekStart)} a ${rangeFmt.format(weekEnd)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: goalReached
                        ? colorScheme.primary
                        : colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.15,
                          ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$pct%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: goalReached
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: _kRevenueBg,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Receita',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  Text(
                    'R\$ ${(revenue / 100).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCell(
                    label: 'Meta semanal',
                    value: 'R\$ ${(weeklyGoalCents / 100).toStringAsFixed(0)}',
                  ),
                ),
                Expanded(
                  child: _SummaryCell(
                    label: 'Combustível',
                    value: 'R\$ ${(fuel / 100).toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _SummaryCell(
                    label: 'Faltam',
                    value: 'R\$ ${(remainingCents / 100).toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.18,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(
                  goalReached ? colorScheme.primary : _kWeekHeaderBg,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$deliveries entregas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'R\$ ${(net / 100).toStringAsFixed(2)} líquido',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  goalReached ? 'Meta batida' : 'Em andamento',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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

// ── Month group ───────────────────────────────────────────────────────────────

class _MonthGroup extends StatefulWidget {
  final String monthLabel;
  final List<_WeekEntry> weekData;
  const _MonthGroup({required this.monthLabel, required this.weekData});

  @override
  State<_MonthGroup> createState() => _MonthGroupState();
}

class _MonthGroupState extends State<_MonthGroup> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final allShifts = widget.weekData.expand((w) => w.value).toList();
    final totalEarnings = allShifts.fold(
      0,
      (sum, s) => sum + s.totalEarnings.cents,
    );
    final totalDeliveries = allShifts.fold(
      0,
      (sum, s) => sum + s.deliveryCount,
    );
    final totalFuel = allShifts.fold(
      0,
      (sum, s) => sum + (s.fuelExpenseCents ?? 0),
    );
    final hasFuel = totalFuel > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Month header — Level 1 (darkest brown)
          Container(
            color: _kMonthHeaderBg,
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(
                widget.monthLabel.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              subtitle: Text(
                hasFuel
                    ? '$totalDeliveries entregas · '
                          'R\$ ${(totalEarnings / 100).toStringAsFixed(2)} · '
                          'Comb. R\$ ${(totalFuel / 100).toStringAsFixed(2)}'
                    : '$totalDeliveries entregas · '
                          'R\$ ${(totalEarnings / 100).toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              trailing: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white70,
              ),
              onTap: () => setState(() => _expanded = !_expanded),
            ),
          ),
          if (_expanded)
            ...widget.weekData.map(
              (w) => _WeekGroup(weekLabel: w.key, shifts: w.value),
            ),
        ],
      ),
    );
  }
}

// ── Week group ────────────────────────────────────────────────────────────────

class _WeekGroup extends StatefulWidget {
  final String weekLabel;
  final List<Shift> shifts;
  const _WeekGroup({required this.weekLabel, required this.shifts});

  @override
  State<_WeekGroup> createState() => _WeekGroupState();
}

class _WeekGroupState extends State<_WeekGroup> {
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
    final hasFuel = totalFuel > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week header — Level 2 (medium brown)
        ListTile(
          dense: true,
          tileColor: _kWeekHeaderBg,
          contentPadding: const EdgeInsets.only(left: 16, right: 16),
          leading: const Icon(
            Icons.calendar_view_week_outlined,
            size: 18,
            color: Colors.white70,
          ),
          title: Text(
            widget.weekLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            hasFuel
                ? '$totalDeliveries entregas · '
                      'R\$ ${(totalEarnings / 100).toStringAsFixed(2)} · '
                      'Comb. R\$ ${(totalFuel / 100).toStringAsFixed(2)}'
                : '$totalDeliveries entregas · '
                      'R\$ ${(totalEarnings / 100).toStringAsFixed(2)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          trailing: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            size: 18,
            color: Colors.white70,
          ),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded) ...widget.shifts.map((s) => _ShiftTile(shift: s)),
      ],
    );
  }
}

// ── Shift tile ────────────────────────────────────────────────────────────────

class _ShiftTile extends ConsumerWidget {
  final Shift shift;
  const _ShiftTile({required this.shift});

  // Returns "Hoje", "Ontem", or the full weekday name — all with DD/MM/YYYY.
  static String _smartLabel(DateTime dateTime) {
    final now = DateTime.now().toLocal();
    final local = dateTime.toLocal();
    final todayDate = DateTime(now.year, now.month, now.day);
    final shiftDate = DateTime(local.year, local.month, local.day);
    final fmtDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(local);

    if (shiftDate == todayDate) return 'Hoje • $fmtDate';
    if (shiftDate == todayDate.subtract(const Duration(days: 1))) {
      return 'Ontem • $fmtDate';
    }
    final weekday = DateFormat('EEEE', 'pt_BR').format(local);
    return '${weekday[0].toUpperCase()}${weekday.substring(1)} • $fmtDate';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = _smartLabel(shift.startedAt);
    final count = shift.deliveryCount;
    final goalEmoji = count >= 19
        ? '🔵'
        : count >= 16
        ? '🟢'
        : count >= 14
        ? '🟠'
        : count >= 10
        ? '🟡'
        : '🔴';

    // ── Historical (manual) ───────────────────────────────────────────────────
    if (shift.isHistorical) {
      final subtitle = StringBuffer(
        '${shift.deliveryCount} entregas · ${shift.totalEarnings.format()}',
      );
      if ((shift.fuelExpenseCents ?? 0) > 0) {
        subtitle.write(
          ' · Comb. R\$ ${(shift.fuelExpenseCents! / 100).toStringAsFixed(2)}',
        );
      }
      if (shift.notes != null) subtitle.write('\n${shift.notes}');

      return ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: const Icon(Icons.history_edu, size: 18),
        title: Row(
          children: [
            Flexible(child: Text(label)),
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
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Meta $goalEmoji',
                style: const TextStyle(fontSize: 10),
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
            PopupMenuItem(
              value: _HistoryAction.share,
              child: Text('Compartilhar'),
            ),
            PopupMenuItem(value: _HistoryAction.edit, child: Text('Editar')),
            PopupMenuItem(value: _HistoryAction.delete, child: Text('Excluir')),
          ],
        ),
        onTap: () => context.push('/history/add', extra: shift),
      );
    }

    // ── Open (in-progress) ────────────────────────────────────────────────────
    if (shift.status == ShiftStatus.open) {
      return ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
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
            Flexible(child: Text(label)),
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

    // ── Closed (route-generated) ──────────────────────────────────────────────
    final closedFuelPart = (shift.fuelExpenseCents ?? 0) > 0
        ? ' · Comb. R\$ ${(shift.fuelExpenseCents! / 100).toStringAsFixed(2)}'
        : '';
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.calendar_today, size: 18),
      title: Row(
        children: [
          Flexible(child: Text(label)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'OCR',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Meta $goalEmoji',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
      subtitle: Text(
        '${shift.deliveryCount} entregas · ${shift.totalEarnings.format()}$closedFuelPart',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: PopupMenuButton<_HistoryAction>(
        onSelected: (action) => _handleAction(context, ref, action),
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: _HistoryAction.viewDetails,
            child: Text('Ver detalhes'),
          ),
          PopupMenuItem(
            value: _HistoryAction.editDeliveries,
            child: Text('Editar entregas'),
          ),
          PopupMenuItem(
            value: _HistoryAction.viewReport,
            child: Text('Ver Relatório'),
          ),
          PopupMenuItem(value: _HistoryAction.delete, child: Text('Excluir')),
        ],
      ),
      onTap: () => context.push('/shift/${shift.id}/details'),
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

    if (action == _HistoryAction.viewDetails ||
        action == _HistoryAction.editDeliveries) {
      AppLogger.log(
        LogEvents.ocrHistoryEditOpened,
        module: 'HistoryScreen',
        metadata: {'shift_id': shift.id, 'source': shift.source},
      );
      context.push('/shift/${shift.id}/details');
      return;
    }

    if (action == _HistoryAction.viewReport) {
      context.push('/history/shift/${shift.id}/report');
      return;
    }

    if (action == _HistoryAction.share) {
      final goalCents =
          ref.read(settingsStreamProvider).valueOrNull?.dailyGoalCents ?? 12000;
      final text = ReportGenerator.generateManual(
        shift,
        dailyGoalCents: goalCents,
      );
      await Share.share(text, subject: 'Resumo do dia — DeliveryFlow');
      return;
    }

    // ── Delete flow ───────────────────────────────────────────────────────────
    AppLogger.info(
      LogEvents.historyDeleteItem,
      module: 'HistoryScreen',
      metadata: {'shift_id': shift.id},
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro?'),
        content: const Text('Este registro será excluído permanentemente.'),
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
            await ref
                .read(historicalEntryNotifierProvider.notifier)
                .save(
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

enum _HistoryAction {
  edit,
  delete,
  viewReport,
  share,
  viewDetails,
  editDeliveries,
}

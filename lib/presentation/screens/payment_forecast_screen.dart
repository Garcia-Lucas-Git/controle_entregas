import 'dart:math';

import 'package:controle_entregas/application/settings/settings_notifier.dart';
import 'package:controle_entregas/application/shifts/shift_notifier.dart';
import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/domain/enums/shift_status.dart';
import 'package:controle_entregas/domain/services/payment_cycle_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

const _dashBg = Color(0xFFFFF7F1);
const _dashCard = Color(0xFFFFE4DC);
const _dashCardSoft = Color(0xFFFFF0E8);
const _dashBrown = Color(0xFF3E1F0A);
const _dashWarm = Color(0xFFC46A35);
const _dashGreen = Color(0xFF2E7D32);

enum _DashboardPeriod { today, week, month }

enum _PickerOption { day, week, month, custom }

class PaymentForecastScreen extends ConsumerStatefulWidget {
  const PaymentForecastScreen({super.key});

  @override
  ConsumerState<PaymentForecastScreen> createState() =>
      _PaymentForecastScreenState();
}

class _PaymentForecastScreenState extends ConsumerState<PaymentForecastScreen> {
  _DashboardPeriod _selected = _DashboardPeriod.week;
  DateTime _anchorDate = DateTime.now();
  DateTime? _customStart;
  DateTime? _customEnd;

  bool get _isCustom => _customStart != null && _customEnd != null;

  void _movePrevious() {
    setState(() {
      if (_isCustom) {
        final days = _customEnd!.difference(_customStart!).inDays + 1;
        _customStart = _customStart!.subtract(Duration(days: days));
        _customEnd = _customEnd!.subtract(Duration(days: days));
        return;
      }
      _anchorDate = switch (_selected) {
        _DashboardPeriod.today => _anchorDate.subtract(const Duration(days: 1)),
        _DashboardPeriod.week => _anchorDate.subtract(const Duration(days: 7)),
        _DashboardPeriod.month => DateTime(
          _anchorDate.year,
          _anchorDate.month - 1,
          1,
        ),
      };
    });
  }

  void _moveNext() {
    setState(() {
      if (_isCustom) {
        final days = _customEnd!.difference(_customStart!).inDays + 1;
        _customStart = _customStart!.add(Duration(days: days));
        _customEnd = _customEnd!.add(Duration(days: days));
        return;
      }
      _anchorDate = switch (_selected) {
        _DashboardPeriod.today => _anchorDate.add(const Duration(days: 1)),
        _DashboardPeriod.week => _anchorDate.add(const Duration(days: 7)),
        _DashboardPeriod.month => DateTime(
          _anchorDate.year,
          _anchorDate.month + 1,
          1,
        ),
      };
    });
  }

  Future<void> _pickPeriod() async {
    final option = await showModalBottomSheet<_PickerOption>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.today_outlined),
              title: const Text('Dia específico'),
              onTap: () => Navigator.pop(ctx, _PickerOption.day),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_week_outlined),
              title: const Text('Semana específica'),
              onTap: () => Navigator.pop(ctx, _PickerOption.week),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Mês específico'),
              onTap: () => Navigator.pop(ctx, _PickerOption.month),
            ),
            ListTile(
              leading: const Icon(Icons.date_range_outlined),
              title: const Text('Período personalizado'),
              onTap: () => Navigator.pop(ctx, _PickerOption.custom),
            ),
          ],
        ),
      ),
    );
    if (!mounted || option == null) return;

    final now = DateTime.now();
    if (option == _PickerOption.custom) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 5),
        lastDate: DateTime(now.year + 2, 12, 31),
        initialDateRange: DateTimeRange(
          start: _customStart ?? _periodStart(_selected, _anchorDate),
          end: _customEnd ?? _periodEnd(_selected, _anchorDate),
        ),
      );
      if (range == null) return;
      setState(() {
        _customStart = _dayOnly(range.start);
        _customEnd = _dayOnly(range.end);
      });
      return;
    }

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2, 12, 31),
      initialDate: _anchorDate,
    );
    if (picked == null) return;
    setState(() {
      _customStart = null;
      _customEnd = null;
      _anchorDate = picked;
      _selected = switch (option) {
        _PickerOption.day => _DashboardPeriod.today,
        _PickerOption.week => _DashboardPeriod.week,
        _PickerOption.month => _DashboardPeriod.month,
        _PickerOption.custom => _selected,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final shiftsAsync = ref.watch(allShiftsProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);
    final dailyGoalCents = settingsAsync.valueOrNull?.dailyGoalCents ?? 12000;

    return Scaffold(
      backgroundColor: _dashBg,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: _dashBg,
        surfaceTintColor: _dashBg,
      ),
      body: shiftsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (shifts) {
          final now = DateTime.now();
          final stats = _isCustom
              ? _customStats(
                  shifts,
                  _customStart!,
                  _customEnd!,
                  _goalForRange(_customStart!, _customEnd!, dailyGoalCents),
                  'PERÍODO PERSONALIZADO',
                )
              : _statsFor(shifts, _selected, _anchorDate, dailyGoalCents);
          final weekStats = _statsFor(
            shifts,
            _DashboardPeriod.week,
            now,
            dailyGoalCents,
          );
          final previousWeekStats = _customStats(
            shifts,
            PaymentCycleService.weekStart(
              now,
            ).subtract(const Duration(days: 7)),
            PaymentCycleService.weekStart(
              now,
            ).subtract(const Duration(days: 1)),
            dailyGoalCents * 6,
            'SEMANA PASSADA',
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _PeriodNavigator(
                selected: _selected,
                anchorDate: _anchorDate,
                customStart: _customStart,
                customEnd: _customEnd,
                onPrevious: _movePrevious,
                onNext: _moveNext,
                onPick: _pickPeriod,
              ),
              const SizedBox(height: 10),
              _PeriodSelector(
                selected: _selected,
                onChanged: (value) => setState(() {
                  _selected = value;
                  _customStart = null;
                  _customEnd = null;
                }),
              ),
              const SizedBox(height: 14),
              _PerformanceCard(stats: stats),
              const SizedBox(height: 12),
              _NextPaymentCard(stats: stats),
              const SizedBox(height: 12),
              _CurrentWeekCard(
                stats: weekStats,
                previousDeliveries: previousWeekStats.deliveries,
              ),
              const SizedBox(height: 12),
              _PaceStatusCard(stats: stats),
              const SizedBox(height: 18),
              _QuickStatsSection(stats: stats),
            ],
          );
        },
      ),
    );
  }
}

DateTime _dayOnly(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day);
}

DateTime _periodStart(_DashboardPeriod period, DateTime anchor) {
  final local = anchor.toLocal();
  return switch (period) {
    _DashboardPeriod.today => DateTime(local.year, local.month, local.day),
    _DashboardPeriod.week => PaymentCycleService.weekStart(local),
    _DashboardPeriod.month => DateTime(local.year, local.month),
  };
}

DateTime _periodEnd(_DashboardPeriod period, DateTime anchor) {
  final start = _periodStart(period, anchor);
  return switch (period) {
    _DashboardPeriod.today => start,
    _DashboardPeriod.week => PaymentCycleService.weekEnd(anchor),
    _DashboardPeriod.month => DateTime(start.year, start.month + 1, 0),
  };
}

int _goalForRange(DateTime start, DateTime end, int dailyGoalCents) {
  final days = max(1, _dayOnly(end).difference(_dayOnly(start)).inDays + 1);
  return dailyGoalCents * days;
}

_DashboardStats _statsFor(
  List<Shift> shifts,
  _DashboardPeriod period,
  DateTime now,
  int dailyGoalCents,
) {
  final start = _periodStart(period, now);
  final end = _periodEnd(period, now);
  final goal = switch (period) {
    _DashboardPeriod.today => dailyGoalCents,
    _DashboardPeriod.week => dailyGoalCents * 6,
    _DashboardPeriod.month => _goalForRange(start, end, dailyGoalCents),
  };
  final currentStart = _periodStart(period, DateTime.now());
  final label = switch (period) {
    _DashboardPeriod.today => start == currentStart ? 'HOJE' : 'DIA',
    _DashboardPeriod.week => start == currentStart ? 'SEMANA ATUAL' : 'SEMANA',
    _DashboardPeriod.month => start == currentStart ? 'MÊS ATUAL' : 'MÊS',
  };
  return _customStats(shifts, start, end, goal, label);
}

_DashboardStats _customStats(
  List<Shift> shifts,
  DateTime start,
  DateTime end,
  int goalCents,
  String label,
) {
  final filtered = shifts.where((shift) {
    if (shift.status != ShiftStatus.closed) return false;
    final local = shift.startedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }).toList();
  final gross = filtered.fold(
    0,
    (sum, shift) => sum + shift.totalEarnings.cents,
  );
  final fuel = filtered.fold(
    0,
    (sum, shift) => sum + (shift.fuelExpenseCents ?? 0),
  );
  final deliveries = filtered.fold(
    0,
    (sum, shift) => sum + shift.deliveryCount,
  );
  final hours = filtered.fold<double>(
    0,
    (sum, shift) => sum + (shift.hoursWorked ?? 0),
  );
  final activeDays = filtered
      .map((shift) {
        final local = shift.startedAt.toLocal();
        return DateTime(local.year, local.month, local.day).toIso8601String();
      })
      .toSet()
      .length;

  return _DashboardStats(
    label: label,
    start: start,
    end: end,
    grossCents: gross,
    fuelCents: fuel,
    deliveries: deliveries,
    goalCents: goalCents,
    hours: hours,
    activeDays: activeDays,
    shifts: filtered,
  );
}

class _DashboardStats {
  final String label;
  final DateTime start;
  final DateTime end;
  final int grossCents;
  final int fuelCents;
  final int deliveries;
  final int goalCents;
  final double hours;
  final int activeDays;
  final List<Shift> shifts;

  const _DashboardStats({
    required this.label,
    required this.start,
    required this.end,
    required this.grossCents,
    required this.fuelCents,
    required this.deliveries,
    required this.goalCents,
    required this.hours,
    required this.activeDays,
    required this.shifts,
  });

  int get netCents => grossCents - fuelCents;
  int get remainingCents => max(0, goalCents - netCents);
  int get overGoalCents => max(0, netCents - goalCents);
  bool get goalReached => goalCents > 0 && netCents >= goalCents;
  int get percent => goalCents > 0 ? (netCents / goalCents * 100).round() : 0;
  double get progress =>
      goalCents > 0 ? (netCents / goalCents).clamp(0.0, 1.0) : 0.0;
}

String _fmtCents(int cents) => 'R\$ ${(cents / 100).toStringAsFixed(2)}';
String _fmtMaybe(num? value, {String suffix = ''}) =>
    value == null ? '--' : '${value.toStringAsFixed(1)}$suffix';

class _PeriodNavigator extends StatelessWidget {
  final _DashboardPeriod selected;
  final DateTime anchorDate;
  final DateTime? customStart;
  final DateTime? customEnd;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPick;

  const _PeriodNavigator({
    required this.selected,
    required this.anchorDate,
    required this.customStart,
    required this.customEnd,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
  });

  bool get _isCustom => customStart != null && customEnd != null;

  @override
  Widget build(BuildContext context) {
    final center = _centerLabel();
    final previous = _previousLabel();
    final next = _nextLabel();

    return _SoftCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: Text(previous, overflow: TextOverflow.ellipsis),
                  style: TextButton.styleFrom(foregroundColor: _dashBrown),
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 120),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  center,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _dashBrown,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: onNext,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: Text(next, overflow: TextOverflow.ellipsis),
                  style: TextButton.styleFrom(foregroundColor: _dashBrown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: const Text('Escolher período'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _dashBrown,
              side: const BorderSide(color: _dashBrown),
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ],
      ),
    );
  }

  String _centerLabel() {
    if (_isCustom) {
      final fmt = DateFormat('dd/MM/yyyy', 'pt_BR');
      return '${fmt.format(customStart!)} → ${fmt.format(customEnd!)}';
    }
    return _labelFor(anchorDate);
  }

  String _previousLabel() {
    if (_isCustom) return 'Anterior';
    final date = switch (selected) {
      _DashboardPeriod.today => anchorDate.subtract(const Duration(days: 1)),
      _DashboardPeriod.week => anchorDate.subtract(const Duration(days: 7)),
      _DashboardPeriod.month => DateTime(anchorDate.year, anchorDate.month - 1),
    };
    return _sideLabel(date);
  }

  String _nextLabel() {
    if (_isCustom) return 'Seguinte';
    final date = switch (selected) {
      _DashboardPeriod.today => anchorDate.add(const Duration(days: 1)),
      _DashboardPeriod.week => anchorDate.add(const Duration(days: 7)),
      _DashboardPeriod.month => DateTime(anchorDate.year, anchorDate.month + 1),
    };
    return _sideLabel(date);
  }

  String _labelFor(DateTime date) {
    final dayFmt = DateFormat('dd/MM/yyyy', 'pt_BR');
    final monthFmt = DateFormat('MMMM yyyy', 'pt_BR');
    return switch (selected) {
      _DashboardPeriod.today => dayFmt.format(date),
      _DashboardPeriod.week => _weekLabel(date),
      _DashboardPeriod.month => _capitalize(monthFmt.format(date)),
    };
  }

  String _sideLabel(DateTime date) {
    final dayFmt = DateFormat('dd/MM', 'pt_BR');
    final monthFmt = DateFormat('MMMM yyyy', 'pt_BR');
    return switch (selected) {
      _DashboardPeriod.today => dayFmt.format(date),
      _DashboardPeriod.week => _weekLabel(date),
      _DashboardPeriod.month => _capitalize(monthFmt.format(date)),
    };
  }

  String _weekLabel(DateTime date) {
    final fmt = DateFormat('dd/MM', 'pt_BR');
    final start = PaymentCycleService.weekStart(date);
    final end = PaymentCycleService.weekEnd(date);
    return '${fmt.format(start)} → ${fmt.format(end)}';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _PeriodSelector extends StatelessWidget {
  final _DashboardPeriod selected;
  final ValueChanged<_DashboardPeriod> onChanged;

  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: 'Hoje',
            selected: selected == _DashboardPeriod.today,
            onTap: () => onChanged(_DashboardPeriod.today),
          ),
          _SegmentButton(
            label: 'Semana',
            selected: selected == _DashboardPeriod.week,
            onTap: () => onChanged(_DashboardPeriod.week),
          ),
          _SegmentButton(
            label: 'Mês',
            selected: selected == _DashboardPeriod.month,
            onTap: () => onChanged(_DashboardPeriod.month),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _dashBrown : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : _dashBrown,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final _DashboardStats stats;

  const _PerformanceCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final progressColor = stats.goalReached ? _dashGreen : _dashWarm;
    return Card(
      elevation: 0,
      color: _dashCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  stats.label,
                  style: const TextStyle(
                    color: _dashBrown,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                if (stats.goalReached)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _dashGreen,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '🏆 Meta atingida!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Ganhos líquidos', style: TextStyle(color: _dashBrown)),
            const SizedBox(height: 4),
            Text(
              _fmtCents(stats.netCents),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: _dashBrown,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Meta: ${_fmtCents(stats.goalCents)}',
                  style: const TextStyle(color: _dashBrown),
                ),
                const Spacer(),
                Text(
                  '${stats.percent}%',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: stats.progress,
                minHeight: 9,
                backgroundColor: Colors.white.withValues(alpha: 0.65),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _TinyMetric(label: 'Entregas', value: '${stats.deliveries}'),
                _TinyMetric(label: 'Bruto', value: _fmtCents(stats.grossCents)),
                _TinyMetric(
                  label: 'Combustível',
                  value: _fmtCents(stats.fuelCents),
                ),
                _TinyMetric(label: 'Líquido', value: _fmtCents(stats.netCents)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyMetric extends StatelessWidget {
  final String label;
  final String value;

  const _TinyMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: _dashBrown)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: _dashBrown,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextPaymentCard extends StatelessWidget {
  final _DashboardStats stats;

  const _NextPaymentCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final shortFmt = DateFormat('dd/MM', 'pt_BR');
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final paymentWeekStart = PaymentCycleService.weekStart(stats.start);
    final paymentWeekEnd = PaymentCycleService.weekEnd(stats.start);
    final paymentDate = PaymentCycleService.paymentDateForWeek(stats.start);
    final daysUntil = paymentDate.difference(day).inDays;
    final daysLabel = daysUntil < 0
        ? 'já passou'
        : daysUntil == 0
        ? 'hoje'
        : '$daysUntil dias';

    return _SoftCard(
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, color: _dashBrown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Próximo pagamento',
                  style: TextStyle(
                    color: _dashBrown,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Faltam $daysLabel',
                  style: const TextStyle(color: _dashBrown, fontSize: 12),
                ),
                Text(
                  'Período: ${shortFmt.format(paymentWeekStart)} → ${shortFmt.format(paymentWeekEnd)}',
                  style: const TextStyle(color: _dashBrown, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Previsão:',
                style: TextStyle(color: _dashBrown, fontSize: 12),
              ),
              Text(
                _fmtCents(stats.grossCents),
                style: const TextStyle(
                  color: _dashBrown,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentWeekCard extends StatelessWidget {
  final _DashboardStats stats;
  final int previousDeliveries;

  const _CurrentWeekCard({
    required this.stats,
    required this.previousDeliveries,
  });

  @override
  Widget build(BuildContext context) {
    final diff = previousDeliveries == 0
        ? null
        : stats.deliveries - previousDeliveries;
    return _SoftCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SEMANA ATUAL',
                  style: TextStyle(
                    color: _dashBrown,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${stats.deliveries}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: _dashBrown,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text('entregas', style: TextStyle(color: _dashBrown)),
                const SizedBox(height: 8),
                Text(
                  diff == null
                      ? 'Sem comparação anterior'
                      : '${diff >= 0 ? '+' : ''}$diff entregas vs semana passada',
                  style: const TextStyle(color: _dashBrown, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _WeekLine(label: 'Bruto', value: _fmtCents(stats.grossCents)),
              _WeekLine(
                label: 'Combustível',
                value: _fmtCents(stats.fuelCents),
              ),
              _WeekLine(label: 'Líquido', value: _fmtCents(stats.netCents)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekLine extends StatelessWidget {
  final String label;
  final String value;

  const _WeekLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: _dashBrown, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PaceStatusCard extends StatelessWidget {
  final _DashboardStats stats;

  const _PaceStatusCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final title = stats.goalReached
        ? 'Meta atingida! Você superou em ${_fmtCents(stats.overGoalCents)}'
        : stats.progress >= 0.7
        ? 'Você está no caminho certo!'
        : 'Você está abaixo da meta';
    final subtitle = stats.goalReached
        ? 'Continue acompanhando seu ritmo.'
        : 'Faltam ${_fmtCents(stats.remainingCents)} para sua meta';

    return _SoftCard(
      child: Row(
        children: [
          Icon(
            stats.goalReached
                ? Icons.emoji_events_outlined
                : Icons.speed_outlined,
            color: stats.goalReached ? _dashGreen : _dashWarm,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _dashBrown,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: _dashBrown)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsSection extends StatelessWidget {
  final _DashboardStats stats;

  const _QuickStatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final profitPerDelivery = stats.deliveries > 0
        ? stats.netCents / stats.deliveries / 100
        : null;
    final fuelPerDelivery = stats.deliveries > 0
        ? stats.fuelCents / stats.deliveries / 100
        : null;
    final profitPerHour = stats.hours > 0
        ? stats.netCents / stats.hours / 100
        : null;
    final deliveriesPerDay = stats.activeDays > 0
        ? stats.deliveries / stats.activeDays
        : null;
    final bestDay = _bestWeekday(stats.shifts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'ESTATÍSTICAS RÁPIDAS',
              style: TextStyle(
                color: _dashBrown,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            TextButton(onPressed: null, child: const Text('Ver todas')),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.55,
          children: [
            _QuickStatCard(
              label: 'Lucro por entrega',
              value: profitPerDelivery == null
                  ? '--'
                  : 'R\$ ${profitPerDelivery.toStringAsFixed(2)}',
            ),
            _QuickStatCard(
              label: 'Combustível por entrega',
              value: fuelPerDelivery == null
                  ? '--'
                  : 'R\$ ${fuelPerDelivery.toStringAsFixed(2)}',
            ),
            _QuickStatCard(
              label: 'Lucro por hora',
              value: profitPerHour == null
                  ? '--'
                  : 'R\$ ${profitPerHour.toStringAsFixed(2)}',
            ),
            _QuickStatCard(
              label: 'Entregas por dia média',
              value: _fmtMaybe(deliveriesPerDay),
            ),
            _QuickStatCard(
              label: 'Melhor dia da semana',
              value: bestDay ?? '--',
            ),
            const _QuickStatCard(label: 'Melhores horários', value: '--'),
          ],
        ),
      ],
    );
  }

  String? _bestWeekday(List<Shift> shifts) {
    if (shifts.isEmpty) return null;
    final totals = <int, int>{};
    for (final shift in shifts) {
      totals.update(
        shift.startedAt.toLocal().weekday,
        (value) => value + shift.totalEarnings.cents,
        ifAbsent: () => shift.totalEarnings.cents,
      );
    }
    final best = totals.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    const names = {
      DateTime.monday: 'Segunda',
      DateTime.tuesday: 'Terça',
      DateTime.wednesday: 'Quarta',
      DateTime.thursday: 'Quinta',
      DateTime.friday: 'Sexta',
      DateTime.saturday: 'Sábado',
      DateTime.sunday: 'Domingo',
    };
    return names[best];
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final String value;

  const _QuickStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: _dashBrown, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: _dashBrown,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: _dashCardSoft,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(padding: padding, child: child),
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

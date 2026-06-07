import 'dart:math';

import 'package:controle_entregas/application/shifts/shift_notifier.dart';
import 'package:controle_entregas/application/settings/settings_notifier.dart';
import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/presentation/router/app_router.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openShift = ref.watch(openShiftProvider);
    final settings = ref.watch(settingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DeliveryFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (s) {
          if (!s.isSetupComplete) {
            return _SetupPrompt(
              onSetup: () => context.push(AppRoutes.settings),
            );
          }
          return openShift.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (shift) => shift == null
                ? _NoShiftView(driverName: s.driverName)
                : _ActiveShiftView(shift: shift),
          );
        },
      ),
    );
  }
}

class _SetupPrompt extends StatelessWidget {
  final VoidCallback onSetup;
  const _SetupPrompt({required this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delivery_dining,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Bem-vindo ao DeliveryFlow',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Configure seu nome e o endereço da pizzaria para começar.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onSetup,
              icon: const Icon(Icons.settings),
              label: const Text('Configurar agora'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoShiftView extends ConsumerWidget {
  final String driverName;
  const _NoShiftView({required this.driverName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.moped_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Olá, $driverName!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhum turno aberto.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                await ref.read(shiftNotifierProvider.notifier).openShift();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar Turno'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.shiftHistory),
              icon: const Icon(Icons.history),
              label: const Text('Histórico'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveShiftView extends ConsumerWidget {
  final Shift shift;
  const _ActiveShiftView({required this.shift});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── Active shift banner (tap → shift details) ─────────────────
        InkWell(
          onTap: () => context.push('/shift/${shift.id}/details'),
          child: Container(
            width: double.infinity,
            color: colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.circle, size: 10, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Turno ativo — ${_formatTime(shift.startedAt)}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),

        // ── Stats + goal (scrollable if content is tall) ──────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _ActiveShiftStats(shiftId: shift.id),
          ),
        ),

        // ── Bottom actions — wrapped in SafeArea ──────────────────────────
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.newRoute.replaceAll(':shiftId', '${shift.id}'),
                  ),
                  icon: const Icon(Icons.add_road),
                  label: const Text('Nova Rota'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.shiftHistory),
                  icon: const Icon(Icons.history),
                  label: const Text('Histórico'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => _confirmClose(context, ref),
                  child: Text(
                    'Fechar Turno',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClose(BuildContext context, WidgetRef ref) async {
    AppLogger.info(
      LogEvents.shiftEndManualCheck,
      module: 'HomeScreen',
      screen: 'HomeScreen',
    );

    // true = add manual, false = close shift, null = dismissed
    final addManual = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar turno?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Adicionar Entrega Manual'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Encerrar Turno'),
          ),
        ],
      ),
    );

    if (addManual == true) {
      AppLogger.info(
        LogEvents.shiftEndManualAdded,
        module: 'HomeScreen',
        screen: 'HomeScreen',
      );
      if (context.mounted) {
        context.push('/shift/${shift.id}/manual');
      }
      return;
    }

    if (addManual == null) return; // dismissed

    if (!context.mounted) return;

    // ── Shift review ──────────────────────────────────────────────────────
    AppLogger.log(
      LogEvents.shiftReviewOpened,
      module: 'HomeScreen',
      metadata: {'shift_id': shift.id},
    );
    final reviewConfirmed = await _showShiftReview(context, ref);
    if (reviewConfirmed != true) return;
    if (!context.mounted) return;

    AppLogger.log(
      LogEvents.shiftReviewCompleted,
      module: 'HomeScreen',
      metadata: {'shift_id': shift.id},
    );

    // ── Fuel input dialog ─────────────────────────────────────────────────
    final fuelCents = await _askFuelExpense(context, ref);
    if (!context.mounted) return;

    AppLogger.info(
      LogEvents.shiftEndCompleted,
      module: 'HomeScreen',
      screen: 'HomeScreen',
    );
    await ref
        .read(shiftNotifierProvider.notifier)
        .closeShift(fuelExpenseCents: fuelCents);
  }

  Future<int?> _askFuelExpense(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Combustível hoje'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Gasto com combustível',
            prefixText: 'R\$ ',
            hintText: '0,00',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Pular'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null || result.trim().isEmpty) return null;
    final value = double.tryParse(result.trim().replaceAll(',', '.'));
    if (value == null || value <= 0) return null;
    return (value * 100).round();
  }

  Future<bool?> _showShiftReview(BuildContext context, WidgetRef ref) async {
    final routes = await ref
        .read(routeRepositoryProvider)
        .getRoutesForShift(shift.id);

    final openRoutes = routes.where((r) => r.isOpen).toList();
    final closedRoutes = routes.where((r) => !r.isOpen).toList();
    final totalDeliveries = routes.fold(
      0,
      (sum, r) => sum + (r.deliveryCountAtClose ?? 0),
    );

    if (!context.mounted) return null;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revisão do Turno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReviewRow(
              label: 'Rotas fechadas',
              value: '${closedRoutes.length}',
            ),
            if (openRoutes.isNotEmpty)
              _ReviewRow(
                label: 'Rotas ainda abertas',
                value: '${openRoutes.length}',
                isWarning: true,
              ),
            _ReviewRow(
              label: 'Entregas registradas',
              value: '$totalDeliveries',
            ),
            if (openRoutes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Existem rotas abertas. Tem certeza que deseja encerrar o turno?',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar Fechamento'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

// ── Stats + daily goal ────────────────────────────────────────────────────────

class _ActiveShiftStats extends ConsumerWidget {
  final int shiftId;

  const _ActiveShiftStats({required this.shiftId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryStream = ref
        .watch(deliveryRepositoryProvider)
        .watchCompletedDeliveriesForShift(shiftId);
    final earningsStream = ref
        .watch(earningsRepositoryProvider)
        .watchEntriesForShift(shiftId);

    return StreamBuilder(
      stream: deliveryStream,
      builder: (context, deliverySnapshot) {
        return StreamBuilder(
          stream: earningsStream,
          builder: (context, earningsSnapshot) {
            final deliveries = deliverySnapshot.data?.length ?? 0;
            final cents =
                earningsSnapshot.data?.fold<int>(
                  0,
                  (sum, e) => sum + e.routeTotal.cents,
                ) ??
                0;
            final earnings = 'R\$ ${(cents / 100).toStringAsFixed(2)}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatCard(
                      label: 'Entregas Hoje',
                      value: deliveries.toString(),
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Ganhos Estimados',
                      value: earnings,
                      icon: Icons.attach_money,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DailyGoalCard(earningsCents: cents, deliveryCount: deliveries),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Daily goal helpers ────────────────────────────────────────────────────────

/// Returns emoji + color for delivery count (Task 15 — 5-level badge).
/// Thresholds: 0-9 🔴, 10-13 🟡, 14-15 🟠, 16-18 🟢, 19+ 🔵
String deliveryBadgeEmoji(int count) {
  if (count >= 19) return '🔵';
  if (count >= 16) return '🟢';
  if (count >= 14) return '🟠';
  if (count >= 10) return '🟡';
  return '🔴';
}

// ── Daily goal card ───────────────────────────────────────────────────────────

class _DailyGoalCard extends ConsumerWidget {
  final int earningsCents;
  final int deliveryCount;

  const _DailyGoalCard({
    required this.earningsCents,
    required this.deliveryCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final goalCents =
        ref.watch(settingsStreamProvider).valueOrNull?.dailyGoalCents ?? 12000;
    final progress = (earningsCents / goalCents).clamp(0.0, 2.0);
    final goalReached = earningsCents >= goalCents;

    final remainingCents = max(0, goalCents - earningsCents);
    final remainingDeliveries = (remainingCents / 800).ceil();

    final pct = (progress * 100).round();
    final badge = deliveryBadgeEmoji(deliveryCount);

    AppLogger.log(
      LogEvents.dailyGoalProgress,
      module: 'HomeScreen',
      metadata: {
        'earnings_cents': earningsCents,
        'goal_cents': goalCents,
        'pct': pct,
        'goal_reached': goalReached,
        'delivery_count': deliveryCount,
      },
    );
    if (goalReached) {
      AppLogger.log(
        LogEvents.dailyGoalReached,
        module: 'HomeScreen',
        metadata: {'earnings_cents': earningsCents, 'pct': pct},
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  goalReached ? Icons.flag : Icons.outlined_flag,
                  size: 18,
                  color: goalReached
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  goalReached ? '🎯 Meta Atingida' : 'Meta Diária',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: goalReached
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '$badge $deliveryCount entregas · $pct%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: goalReached
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  goalReached ? colorScheme.primary : colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R\$ ${(earningsCents / 100).toStringAsFixed(2)} / '
                  'R\$ ${(goalCents / 100).toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (!goalReached && remainingCents > 0)
                  Text(
                    'Faltam $remainingDeliveries entrega${remainingDeliveries != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isWarning ? colorScheme.error : colorScheme.onSurface,
              fontWeight: isWarning ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWarning ? colorScheme.error : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

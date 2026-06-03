import 'package:controle_entregas/application/shifts/shift_notifier.dart';
import 'package:controle_entregas/application/settings/settings_notifier.dart';
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
        // Shift status banner
        Container(
          width: double.infinity,
          color: colorScheme.primaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.circle, size: 12, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Turno ativo — ${_formatTime(shift.startedAt)}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),

        // Stats row
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              _StatCard(
                label: 'Entregas hoje',
                value: shift.deliveryCount.toString(),
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 16),
              _StatCard(
                label: 'Ganhos estimados',
                value: shift.totalEarnings.format(),
                icon: Icons.attach_money,
              ),
            ],
          ),
        ),

        const Spacer(),

        // Actions
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              FilledButton.icon(
                onPressed: () => context.push(
                  AppRoutes.newRoute.replaceAll(':shiftId', '${shift.id}'),
                ),
                icon: const Icon(Icons.add_road),
                label: const Text('Nova Rota'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 72),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.shiftHistory),
                icon: const Icon(Icons.history),
                label: const Text('Histórico'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
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
      ],
    );
  }

  Future<void> _confirmClose(BuildContext context, WidgetRef ref) async {
    AppLogger.info(
      LogEvents.shiftEndManualCheck,
      module: 'HomeScreen',
      screen: 'HomeScreen',
    );

    final addManual = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Antes de encerrar o turno'),
        content: const Text(
          'Deseja adicionar alguma entrega manualmente antes de encerrar o turno?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim'),
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

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fechar turno?'),
        content: const Text(
          'O turno será encerrado e os ganhos serão calculados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      AppLogger.info(
        LogEvents.shiftEndCompleted,
        module: 'HomeScreen',
        screen: 'HomeScreen',
      );
      await ref.read(shiftNotifierProvider.notifier).closeShift();
    }
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:controle_entregas/application/deliveries/delivery_notifier.dart';
import 'package:controle_entregas/application/routes/route_notifier.dart';
import 'package:controle_entregas/domain/entities/delivery.dart';
import 'package:controle_entregas/domain/entities/route_entity.dart';
import 'package:controle_entregas/domain/enums/delivery_status.dart';
import 'package:controle_entregas/domain/enums/route_status.dart';
import 'package:controle_entregas/presentation/screens/delivery_quick_panel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ShiftDetailsScreen extends ConsumerWidget {
  final int shiftId;

  const ShiftDetailsScreen({super.key, required this.shiftId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routesForShiftProvider(shiftId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Turno'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_road),
            tooltip: 'Nova Rota',
            onPressed: () => context.push(
              '/shift/$shiftId/route/new',
            ),
          ),
        ],
      ),
      body: routesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (routes) {
          if (routes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.route_outlined,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma rota neste turno.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/shift/$shiftId/route/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Primeira Rota'),
                  ),
                ],
              ),
            );
          }

          final sorted = [...routes]
            ..sort((a, b) => a.routeNumber.compareTo(b.routeNumber));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (ctx, i) =>
                _RouteSummaryTile(route: sorted[i], shiftId: shiftId),
          );
        },
      ),
    );
  }
}

class _RouteSummaryTile extends ConsumerWidget {
  final RouteEntity route;
  final int shiftId;

  const _RouteSummaryTile({required this.route, required this.shiftId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync =
        ref.watch(deliveriesForRouteProvider(route.id));
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route header row
          InkWell(
            onTap: () => context.push(
              '/shift/$shiftId/route/${route.id}/active',
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: route.isOpen
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    radius: 16,
                    child: Text(
                      '${route.routeNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: route.isOpen
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rota ${route.routeNumber}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: route.isOpen ? null : colorScheme.outline,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: route.isOpen
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      route.status == RouteStatus.open
                          ? 'Aberta'
                          : 'Fechada',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: route.isOpen
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),

          // Deliveries list
          deliveriesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            ),
            error: (e, _) => const SizedBox.shrink(),
            data: (deliveries) {
              if (deliveries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'Sem entregas',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
                    ),
                  ),
                );
              }

              final completed = deliveries
                  .where((d) => d.status == DeliveryStatus.completed)
                  .length;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                    child: Row(
                      children: [
                        Text(
                          '$completed de ${deliveries.length} entregas',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.outline),
                        ),
                        const Spacer(),
                        if (deliveries.isNotEmpty)
                          SizedBox(
                            width: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: deliveries.isEmpty
                                    ? 0
                                    : completed / deliveries.length,
                                minHeight: 4,
                                backgroundColor: colorScheme
                                    .surfaceContainerHighest,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ...deliveries.map(
                    (d) => _DeliveryRow(
                      delivery: d,
                      shiftId: shiftId,
                      routeId: route.id,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DeliveryRow extends StatelessWidget {
  final Delivery delivery;
  final int shiftId;
  final int routeId;

  const _DeliveryRow({
    required this.delivery,
    required this.shiftId,
    required this.routeId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final done = delivery.status == DeliveryStatus.completed;

    return InkWell(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => DeliveryQuickPanel(
          delivery: delivery,
          shiftId: shiftId,
          routeId: routeId,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: done ? colorScheme.primary : colorScheme.outline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.fullAddress,
                    style: TextStyle(
                      fontSize: 13,
                      color: done ? colorScheme.outline : null,
                      decoration:
                          done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (delivery.pizzaNumber != null &&
                      delivery.pizzaNumber!.isNotEmpty)
                    Text(
                      '🍕 ${delivery.pizzaNumber}',
                      style: const TextStyle(fontSize: 11),
                    ),
                ],
              ),
            ),
            const Icon(Icons.expand_more, size: 16),
          ],
        ),
      ),
    );
  }
}

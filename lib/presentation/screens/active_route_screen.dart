import 'package:controle_entregas/application/deliveries/delivery_notifier.dart';
import 'package:controle_entregas/application/routes/route_notifier.dart';
import 'package:controle_entregas/application/settings/settings_notifier.dart';
import 'package:controle_entregas/application/wakelock/wakelock_controller.dart';
import 'package:controle_entregas/domain/entities/delivery.dart';
import 'package:controle_entregas/domain/entities/route_entity.dart';
import 'package:controle_entregas/domain/enums/delivery_status.dart';
import 'package:controle_entregas/presentation/screens/delivery_quick_panel.dart';
import 'package:controle_entregas/services/maps_launcher.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ActiveRouteScreen extends ConsumerStatefulWidget {
  final int shiftId;
  final int routeId;

  const ActiveRouteScreen({
    super.key,
    required this.shiftId,
    required this.routeId,
  });

  @override
  ConsumerState<ActiveRouteScreen> createState() => _ActiveRouteScreenState();
}

class _ActiveRouteScreenState extends ConsumerState<ActiveRouteScreen>
    with WidgetsBindingObserver {
  late final WakeLockController _wakeLock;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wakeLock = ref.read(wakeLockControllerProvider.notifier);
    _wakeLock.acquire();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _wakeLock.release();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!mounted) return;
      ref.invalidate(deliveriesForRouteProvider(widget.routeId));
    }
  }

  Future<void> _openMaps(List<Delivery> pending) async {
    final addresses = pending
        .map((d) => d.fullAddress)
        .where((a) => a.isNotEmpty)
        .toList();
    if (addresses.isEmpty) return;
    if (!mounted) return;

    final settings = ref.read(settingsStreamProvider).valueOrNull;
    final finalAddresses = await pickFinalDestination(
      context,
      addresses: addresses,
      pizzeriaAddress: settings?.pizzeriaAddress ?? '',
      homeAddress: settings?.homeAddress ?? '',
    );
    if (!mounted) return;

    await MapsLauncher.navigateTo(finalAddresses);
  }

  Future<void> _addDelivery() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Adicionar por OCR'),
              onTap: () => Navigator.pop(ctx, 'ocr'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_location_alt_outlined),
              title: const Text('Adicionar manualmente'),
              onTap: () => Navigator.pop(ctx, 'manual'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'manual') {
      context.push(
        '/shift/${widget.shiftId}/manual',
        extra: {'routeId': widget.routeId},
      );
      return;
    }
    context.push(
      '/shift/${widget.shiftId}/route/new',
      extra: {'routeId': widget.routeId},
    );
  }

  Future<void> _moveDelivery(
    List<Delivery> deliveries,
    int index,
    int delta,
  ) async {
    final next = index + delta;
    if (next < 0 || next >= deliveries.length) return;
    final ordered = [...deliveries];
    final item = ordered.removeAt(index);
    ordered.insert(next, item);
    await ref
        .read(deliveryNotifierProvider.notifier)
        .reorderRouteDeliveries(routeId: widget.routeId, deliveries: ordered);
  }

  Future<void> _deleteRoute(RouteEntity route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir rota?'),
        content: const Text('A rota e suas entregas serão removidas.'),
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
    await ref
        .read(routeNotifierProvider.notifier)
        .delete(route.id, shiftId: widget.shiftId);
    if (!mounted) return;
    context.go('/');
  }

  Future<void> _closeRoute(RouteEntity route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fechar rota?'),
        content: const Text(
          'Os ganhos desta rota serão calculados e registrados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Fechar Rota'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(routeNotifierProvider.notifier).closeRoute(widget.routeId);
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(routeByIdProvider(widget.routeId));
    final deliveriesAsync = ref.watch(
      deliveriesForRouteProvider(widget.routeId),
    );

    // Keep settings loaded so _openMaps can read them synchronously.
    ref.watch(settingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: routeAsync.when(
          data: (r) => Text('Rota ${r?.routeNumber ?? ''}'),
          loading: () => const Text('Rota'),
          error: (e, s) => const Text('Rota'),
        ),
        actions: [
          routeAsync.when(
            data: (route) => route == null
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Excluir rota',
                    onPressed: () => _deleteRoute(route),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar entrega',
            onPressed: _addDelivery,
          ),
          deliveriesAsync.when(
            data: (deliveries) {
              final pending = deliveries
                  .where((d) => d.status != DeliveryStatus.completed)
                  .toList();
              if (pending.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.map),
                tooltip: 'Abrir no Maps',
                onPressed: () => _openMaps(pending),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: deliveriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (deliveries) {
          final pending = deliveries
              .where((d) => d.status != DeliveryStatus.completed)
              .toList();
          final completed = deliveries
              .where((d) => d.status == DeliveryStatus.completed)
              .toList();

          return Column(
            children: [
              // Progress bar
              _ProgressBar(
                completed: completed.length,
                total: deliveries.length,
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (pending.isNotEmpty) ...[
                      Text(
                        'Pendentes (${pending.length})',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...pending.asMap().entries.map(
                        (entry) => _DeliveryTile(
                          delivery: entry.value,
                          shiftId: widget.shiftId,
                          routeId: widget.routeId,
                          canMoveUp: entry.key > 0,
                          canMoveDown: entry.key < pending.length - 1,
                          onMoveUp: () => _moveDelivery(pending, entry.key, -1),
                          onMoveDown: () =>
                              _moveDelivery(pending, entry.key, 1),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (completed.isNotEmpty) ...[
                      Text(
                        'Concluídas (${completed.length})',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...completed.map(
                        (d) => _DeliveryTile(
                          delivery: d,
                          shiftId: widget.shiftId,
                          routeId: widget.routeId,
                          muted: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: OutlinedButton.icon(
                  onPressed: _addDelivery,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Entrega'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),

              // Bottom: close route when all done
              if (pending.isEmpty && deliveries.isNotEmpty)
                routeAsync.when(
                  data: (route) => route != null && route.isOpen
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: FilledButton.icon(
                            onPressed: () => _closeRoute(route),
                            icon: const Icon(Icons.flag),
                            label: const Text('Fechar Rota'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 64),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressBar({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : completed / total,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$completed de $total',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _DeliveryTile extends ConsumerWidget {
  final Delivery delivery;
  final int shiftId;
  final int routeId;
  final bool muted;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _DeliveryTile({
    required this.delivery,
    required this.shiftId,
    required this.routeId,
    this.muted = false,
    this.canMoveUp = false,
    this.canMoveDown = false,
    this.onMoveUp,
    this.onMoveDown,
  });

  Widget? _buildSubtitle(
    Delivery delivery,
    ColorScheme colorScheme,
    bool muted,
  ) {
    final locator = delivery.deliveryIdentifier?.isNotEmpty == true
        ? delivery.deliveryIdentifier
        : null;
    final parts = <String>[];
    if (delivery.pizzaNumber != null && delivery.pizzaNumber!.isNotEmpty) {
      parts.add('🍕 ${delivery.pizzaNumber}');
    }
    if (delivery.complement != null && delivery.complement!.isNotEmpty) {
      parts.add('📝 ${delivery.complement}');
    }
    final drink = delivery.drinkLabel;
    if (drink != null) parts.add('🥤 $drink');
    if (delivery.customerName != null) parts.add(delivery.customerName!);
    if (locator != null) parts.add('# $locator');
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' · '),
      style: TextStyle(fontSize: 12, color: muted ? colorScheme.outline : null),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: muted ? colorScheme.surfaceContainerHighest : null,
      child: ListTile(
        leading: muted
            ? Icon(Icons.check_circle, color: colorScheme.primary)
            : CircleAvatar(
                child: Text(
                  '${delivery.sequenceNumber}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
        title: Text(
          delivery.fullAddress,
          style: TextStyle(
            fontSize: 15,
            color: muted ? colorScheme.outline : null,
          ),
        ),
        subtitle: _buildSubtitle(delivery, colorScheme, muted),
        trailing: muted
            ? const Icon(Icons.expand_more)
            : SizedBox(
                width: 88,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 18),
                      tooltip: 'Mover para cima',
                      onPressed: canMoveUp ? onMoveUp : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 18),
                      tooltip: 'Mover para baixo',
                      onPressed: canMoveDown ? onMoveDown : null,
                    ),
                  ],
                ),
              ),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.88,
            child: DeliveryQuickPanel(
              delivery: delivery,
              shiftId: shiftId,
              routeId: routeId,
            ),
          ),
        ),
      ),
    );
  }
}

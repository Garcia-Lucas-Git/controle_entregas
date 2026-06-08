import 'package:controle_entregas/application/deliveries/delivery_notifier.dart';
import 'package:controle_entregas/application/wakelock/wakelock_controller.dart';
import 'package:controle_entregas/domain/entities/delivery.dart';
import 'package:controle_entregas/domain/enums/delivery_status.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryCardScreen extends ConsumerStatefulWidget {
  final int shiftId;
  final int routeId;
  final int deliveryId;

  const DeliveryCardScreen({
    super.key,
    required this.shiftId,
    required this.routeId,
    required this.deliveryId,
  });

  @override
  ConsumerState<DeliveryCardScreen> createState() => _DeliveryCardScreenState();
}

class _DeliveryCardScreenState extends ConsumerState<DeliveryCardScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(wakeLockControllerProvider.notifier).acquire();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(deliveryNotifierProvider.notifier)
          .setInProgress(widget.deliveryId);
    });
  }

  @override
  void dispose() {
    ref.read(wakeLockControllerProvider.notifier).release();
    super.dispose();
  }

  Future<void> _complete(Delivery delivery) async {
    await ref.read(deliveryNotifierProvider.notifier).complete(delivery.id);
    AppLogger.log(
      LogEvents.deliveryCompleted,
      module: 'DeliveryCardScreen',
      metadata: {'delivery_id': delivery.id},
    );
    if (!mounted) return;
    context.pop();
  }

  Future<void> _openIfood(Delivery delivery) async {
    final locator = delivery.deliveryIdentifier;
    if (locator != null && locator.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: locator));
      AppLogger.log(
        LogEvents.ifoodLocatorClipboardCopy,
        module: 'DeliveryCardScreen',
        metadata: {'code': locator, 'delivery_id': delivery.id},
      );
    }
    AppLogger.log(
      LogEvents.ifoodOpenStart,
      module: 'DeliveryCardScreen',
      metadata: {'delivery_id': delivery.id},
    );
    const ifoodUrl = 'https://confirmacao-entrega-propria.ifood.com.br/';
    final uri = Uri.parse(ifoodUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryAsync = ref.watch(deliveryByIdProvider(widget.deliveryId));

    return Scaffold(
      body: deliveryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
        data: (delivery) {
          if (delivery == null) {
            return const Center(child: Text('Entrega não encontrada.'));
          }
          return _DeliveryCardContent(
            delivery: delivery,
            onComplete: () => _complete(delivery),
            onOpenIfood: () => _openIfood(delivery),
          );
        },
      ),
    );
  }
}

// ── Content ────────────────────────────────────────────────────────────────

class _DeliveryCardContent extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback onComplete;
  final VoidCallback onOpenIfood;

  const _DeliveryCardContent({
    required this.delivery,
    required this.onComplete,
    required this.onOpenIfood,
  });

  String? get _locatorCode => delivery.deliveryIdentifier?.isNotEmpty == true
      ? delivery.deliveryIdentifier
      : null;

  @override
  Widget build(BuildContext context) {
    final isCompleted = delivery.status == DeliveryStatus.completed;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          // ── Locator code panel (primary, always on top) ────────────────
          if (_locatorCode != null)
            _LocatorPanel(code: _locatorCode!, colorScheme: colorScheme),

          // ── Warnings banner ────────────────────────────────────────────
          if (_hasFlags)
            _WarningsBanner(delivery: delivery, onIfood: onOpenIfood),

          // ── Address + details ──────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        radius: 16,
                        child: Text(
                          '${delivery.sequenceNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Entrega ${delivery.sequenceNumber}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (delivery.pizzaNumber != null &&
                      delivery.pizzaNumber!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text('🍕', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PIZZA',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.2,
                                  color: colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                delivery.pizzaNumber!,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  Text(
                    '📍 ${delivery.addressText}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (delivery.houseNumber != null &&
                      delivery.houseNumber!.isNotEmpty)
                    Text(
                      '🏠 ${delivery.houseNumber}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  if (delivery.complement != null &&
                      delivery.complement!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '📝 ${delivery.complement}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  if (delivery.drinkLabel != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '🥤 ${delivery.drinkLabel}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  const SizedBox(height: 12),

                  if (delivery.customerName != null) ...[
                    Text(
                      delivery.customerName!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (delivery.orderNumber != null)
                    Text(
                      'Pedido: ${delivery.orderNumber}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),

                  if (delivery.ifoodConfirmationSuccess == true) ...[
                    const SizedBox(height: 12),
                    Chip(
                      avatar: Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        size: 16,
                      ),
                      label: const Text('iFood confirmado'),
                      backgroundColor: colorScheme.primaryContainer,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Action button ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: isCompleted
                ? FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Concluída'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 72),
                    ),
                  )
                : FilledButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check),
                    label: const Text('Entrega Concluída'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 72),
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  bool get _hasFlags =>
      delivery.needsIfoodConfirmation ||
      delivery.hasDrinks ||
      delivery.needsCard ||
      delivery.needsChange;
}

// ── Locator code panel ────────────────────────────────────────────────────

class _LocatorPanel extends StatelessWidget {
  final String code;
  final ColorScheme colorScheme;

  const _LocatorPanel({required this.code, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: colorScheme.inverseSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CÓDIGO LOCALIZADOR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onInverseSurface.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onInverseSurface,
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              AppLogger.log(
                LogEvents.locatorClipboardCopy,
                module: 'DeliveryCardScreen',
                metadata: {'value': code, 'length': code.length},
              );
              AppLogger.log(
                LogEvents.ifoodLocatorClipboardCopy,
                module: 'DeliveryCardScreen',
                metadata: {'code': code},
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Código copiado: $code'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.inversePrimary.withValues(
                alpha: 0.25,
              ),
              foregroundColor: colorScheme.onInverseSurface,
              minimumSize: const Size(56, 48),
            ),
            child: const Icon(Icons.copy, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── Warnings banner ────────────────────────────────────────────────────────

class _WarningsBanner extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback onIfood;

  const _WarningsBanner({required this.delivery, required this.onIfood});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = delivery.ifoodConfirmationSuccess == true;

    return Container(
      width: double.infinity,
      color: colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (delivery.needsIfoodConfirmation && !confirmed)
            _BannerItem(
              icon: '🔐',
              label: 'Confirmação iFood necessária',
              onTap: onIfood,
              isAction: true,
            ),
          if (delivery.needsIfoodConfirmation && confirmed)
            _BannerItem(icon: '✅', label: 'iFood confirmado'),
          if (delivery.drinkLabel != null)
            _BannerItem(icon: '🥤', label: delivery.drinkLabel!),
          if (delivery.needsCard)
            _BannerItem(icon: '💳', label: 'Maquininha necessária'),
          if (delivery.needsChange)
            _BannerItem(
              icon: '💵',
              label: delivery.changeAmountCents != null
                  ? 'Troco para R\$ ${(delivery.changeAmountCents! / 100).toStringAsFixed(2)}'
                  : 'Troco necessário',
            ),
        ],
      ),
    );
  }
}

class _BannerItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool isAction;

  const _BannerItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontWeight: isAction ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
            if (isAction)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: colorScheme.onErrorContainer,
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:controle_entregas/application/deliveries/delivery_notifier.dart';
import 'package:controle_entregas/application/wakelock/wakelock_controller.dart';
import 'package:controle_entregas/domain/entities/delivery.dart';
import 'package:controle_entregas/domain/enums/delivery_status.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Bottom sheet panel shown when a driver taps a pending delivery.
/// Exposes all operational actions in a single view — no screen navigation needed.
class DeliveryQuickPanel extends ConsumerStatefulWidget {
  final Delivery delivery;
  final int shiftId;
  final int routeId;

  const DeliveryQuickPanel({
    super.key,
    required this.delivery,
    required this.shiftId,
    required this.routeId,
  });

  @override
  ConsumerState<DeliveryQuickPanel> createState() =>
      _DeliveryQuickPanelState();
}

class _DeliveryQuickPanelState extends ConsumerState<DeliveryQuickPanel> {
  bool _completing = false;

  String? get _locator =>
      widget.delivery.partnerCollectionCode?.isNotEmpty == true
          ? widget.delivery.partnerCollectionCode
          : widget.delivery.deliveryIdentifier?.isNotEmpty == true
              ? widget.delivery.deliveryIdentifier
              : null;

  @override
  void initState() {
    super.initState();
    ref.read(wakeLockControllerProvider.notifier).acquire();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(deliveryNotifierProvider.notifier)
          .setInProgress(widget.delivery.id);
    });
  }

  @override
  void dispose() {
    ref.read(wakeLockControllerProvider.notifier).release();
    super.dispose();
  }

  Future<void> _copyLocator() async {
    final code = _locator;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
    AppLogger.log(LogEvents.ifoodLocatorClipboardCopy,
        module: 'DeliveryQuickPanel', metadata: {'code': code});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código copiado: $code'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Copies locator to clipboard automatically, then opens iFood confirmation.
  /// Driver just needs to paste — no manual typing required.
  Future<void> _openIfood() async {
    final code = _locator;
    if (code != null) {
      await Clipboard.setData(ClipboardData(text: code));
      AppLogger.log(LogEvents.ifoodLocatorClipboardCopy,
          module: 'DeliveryQuickPanel',
          metadata: {'code': code, 'trigger': 'pre-ifood'});
    }
    AppLogger.log(LogEvents.ifoodOpenStart,
        module: 'DeliveryQuickPanel',
        metadata: {'delivery_id': widget.delivery.id});
    if (!mounted) return;
    Navigator.of(context).pop();
    context.push(
      '/shift/${widget.shiftId}/route/${widget.routeId}'
      '/delivery/${widget.delivery.id}/ifood',
      extra: {
        'deliveryIdentifier': widget.delivery.deliveryIdentifier,
        'partnerCollectionCode': widget.delivery.partnerCollectionCode,
      },
    );
  }

  Future<void> _complete() async {
    setState(() => _completing = true);
    await ref
        .read(deliveryNotifierProvider.notifier)
        .complete(widget.delivery.id);
    AppLogger.log(LogEvents.deliveryCompleted,
        module: 'DeliveryQuickPanel',
        metadata: {'delivery_id': widget.delivery.id});
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final d = widget.delivery;
    final isCompleted = d.status == DeliveryStatus.completed;
    final ifoodDone = d.ifoodConfirmationSuccess == true;
    final needsIfood = d.needsIfoodConfirmation && !ifoodDone;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Locator code (primary) ────────────────────────────────────
            if (_locator != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
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
                              letterSpacing: 1.2,
                              color: colorScheme.onInverseSurface
                                  .withValues(alpha: 0.65),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _locator!,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: colorScheme.onInverseSurface,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy,
                          color: colorScheme.onInverseSurface, size: 22),
                      tooltip: 'Copiar código',
                      onPressed: _copyLocator,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ── Address ───────────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    '${d.sequenceNumber}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    d.addressText,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (d.customerName != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  d.customerName!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],

            // ── Flags ─────────────────────────────────────────────────────
            if (d.hasDrinks || d.needsCard || d.needsChange) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (d.hasDrinks)
                    _Flag(Icons.local_drink_outlined, 'Bebidas',
                        colorScheme.secondaryContainer,
                        colorScheme.onSecondaryContainer),
                  if (d.needsCard)
                    _Flag(Icons.credit_card, 'Maquininha',
                        colorScheme.tertiaryContainer,
                        colorScheme.onTertiaryContainer),
                  if (d.needsChange)
                    _Flag(
                      Icons.payments_outlined,
                      d.changeAmountCents != null
                          ? 'Troco R\$ ${(d.changeAmountCents! / 100).toStringAsFixed(2)}'
                          : 'Troco',
                      colorScheme.tertiaryContainer,
                      colorScheme.onTertiaryContainer,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // ── Actions ───────────────────────────────────────────────────
            if (!isCompleted) ...[
              // iFood confirmation — shown only when needed
              if (needsIfood) ...[
                FilledButton.icon(
                  onPressed: _openIfood,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Abrir iFood (código já copiado)'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Complete delivery — always visible
              FilledButton.icon(
                onPressed: _completing ? null : _complete,
                icon: _completing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Entrega Concluída'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ] else
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle),
                label: const Text('Concluída'),
                style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60)),
              ),

            const SizedBox(height: 8),

            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44)),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  const _Flag(this.icon, this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: fg)),
        ],
      ),
    );
  }
}

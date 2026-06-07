import 'package:controle_entregas/application/deliveries/delivery_notifier.dart';
import 'package:controle_entregas/application/wakelock/wakelock_controller.dart';
import 'package:controle_entregas/domain/entities/delivery.dart';
import 'package:controle_entregas/domain/enums/delivery_status.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom sheet panel shown when a driver taps a delivery.
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
  ConsumerState<DeliveryQuickPanel> createState() => _DeliveryQuickPanelState();
}

class _DeliveryQuickPanelState extends ConsumerState<DeliveryQuickPanel> {
  bool _completing = false;
  bool _editing = false;
  late TextEditingController _pizzaEditCtrl;
  late TextEditingController _addrEditCtrl;
  late TextEditingController _houseEditCtrl;
  late TextEditingController _locatorEditCtrl;

  String? get _locator => widget.delivery.deliveryIdentifier?.isNotEmpty == true
      ? widget.delivery.deliveryIdentifier
      : null;

  @override
  void initState() {
    super.initState();
    ref.read(wakeLockControllerProvider.notifier).acquire();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(deliveryNotifierProvider.notifier)
          .setInProgress(widget.delivery.id);
    });
    final d = widget.delivery;
    _pizzaEditCtrl = TextEditingController(text: d.pizzaNumber ?? '');
    _addrEditCtrl = TextEditingController(text: d.addressText);
    _houseEditCtrl = TextEditingController(text: d.houseNumber ?? '');
    _locatorEditCtrl = TextEditingController(
      text: d.deliveryIdentifier ?? '',
    );
  }

  @override
  void dispose() {
    ref.read(wakeLockControllerProvider.notifier).release();
    _pizzaEditCtrl.dispose();
    _addrEditCtrl.dispose();
    _houseEditCtrl.dispose();
    _locatorEditCtrl.dispose();
    super.dispose();
  }

  Future<void> _copyLocator() async {
    final code = _locator;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
    AppLogger.log(
      LogEvents.ifoodLocatorClipboardCopy,
      module: 'DeliveryQuickPanel',
      metadata: {'code': code},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código copiado: $code'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openIfood() async {
    // Step 1: copy locator
    final code = _locator;
    if (code != null) {
      await Clipboard.setData(ClipboardData(text: code));
      AppLogger.log(
        LogEvents.ifoodLocatorClipboardCopy,
        module: 'DeliveryQuickPanel',
        metadata: {'code': code, 'trigger': 'ifood-dialog'},
      );
    }
    if (!mounted) return;

    // Step 2: show "Localizador copiado." + confirm dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Localizador copiado.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abrir iFood?'),
        content: const Text(
          'Cole o localizador no campo de confirmação do iFood e volte aqui para concluir a entrega.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não agora'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Abrir iFood'),
          ),
        ],
      ),
    );
    if (open != true) return;
    if (!mounted) return;

    // Step 3: open iFood externally; bottom sheet stays open
    AppLogger.log(
      LogEvents.ifoodOpenStart,
      module: 'DeliveryQuickPanel',
      metadata: {'delivery_id': widget.delivery.id},
    );
    const ifoodUrl = 'https://confirmacao-entrega-propria.ifood.com.br/';
    final uri = Uri.parse(ifoodUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _markIfoodDone() async {
    await ref
        .read(deliveryNotifierProvider.notifier)
        .updateIfood(widget.delivery.id, success: true);
    AppLogger.log(
      LogEvents.ifoodConfirmSuccess,
      module: 'DeliveryQuickPanel',
      metadata: {'delivery_id': widget.delivery.id},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('iFood marcado como confirmado'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
  }

  Future<void> _saveEdits() async {
    final pizza = _pizzaEditCtrl.text.trim();
    final addr = _addrEditCtrl.text.trim();
    final house = _houseEditCtrl.text.trim();
    final locator = _locatorEditCtrl.text.trim();

    final hasPizzaChange = pizza != (widget.delivery.pizzaNumber ?? '');
    await ref.read(deliveryNotifierProvider.notifier).updateFields(
      id: widget.delivery.id,
      routeId: widget.routeId,
      addressText: addr.isEmpty ? null : addr,
      houseNumber: house.isEmpty ? null : house,
      pizzaNumber: pizza.isEmpty ? null : pizza,
      deliveryIdentifier: locator.isEmpty ? null : locator,
    );
    if (hasPizzaChange && pizza.isNotEmpty) {
      AppLogger.log(
        LogEvents.pizzaNumberUpdated,
        module: 'DeliveryQuickPanel',
        metadata: {'pizza': pizza, 'delivery_id': widget.delivery.id},
      );
    }
    AppLogger.log(
      LogEvents.deliveryUpdated,
      module: 'DeliveryQuickPanel',
      metadata: {'delivery_id': widget.delivery.id},
    );
    if (mounted) setState(() => _editing = false);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir entrega?'),
        content: const Text('A entrega será removida desta rota.'),
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
        .read(deliveryNotifierProvider.notifier)
        .delete(
          widget.delivery.id,
          routeId: widget.routeId,
          shiftId: widget.shiftId,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _complete() async {
    setState(() => _completing = true);
    await ref
        .read(deliveryNotifierProvider.notifier)
        .complete(widget.delivery.id);
    AppLogger.log(
      LogEvents.deliveryCompleted,
      module: 'DeliveryQuickPanel',
      metadata: {'delivery_id': widget.delivery.id},
    );
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
            const SizedBox(height: 12),

            if (!_editing) ...[
              // ── Pizza number (primary operational display) ────────────
              if (d.pizzaNumber != null && d.pizzaNumber!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '🍕',
                        style: const TextStyle(fontSize: 24),
                      ),
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
                            d.pizzaNumber!,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⚠ Número da pizza não definido — toque em Editar',
                    style: TextStyle(
                      color: colorScheme.onErrorContainer,
                      fontSize: 13,
                    ),
                  ),
                ),

              // ── Locator code ──────────────────────────────────────────
              if (_locator != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(6),
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: colorScheme.onInverseSurface,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: colorScheme.onInverseSurface,
                          size: 22,
                        ),
                        tooltip: 'Copiar código',
                        onPressed: _copyLocator,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // ── Address ───────────────────────────────────────────────
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
                      d.fullAddress,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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

              // ── Flags ─────────────────────────────────────────────────
              if (d.hasDrinks || d.needsCard || d.needsChange) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (d.hasDrinks)
                      _Flag(
                        Icons.local_drink_outlined,
                        'Bebidas',
                        colorScheme.secondaryContainer,
                        colorScheme.onSecondaryContainer,
                      ),
                    if (d.needsCard)
                      _Flag(
                        Icons.credit_card,
                        'Maquininha',
                        colorScheme.tertiaryContainer,
                        colorScheme.onTertiaryContainer,
                      ),
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
              const SizedBox(height: 16),

              // ── Actions ───────────────────────────────────────────────
              if (!isCompleted) ...[
                // iFood — simplified: copy + open external
                if (needsIfood) ...[
                  FilledButton.icon(
                    onPressed: _openIfood,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Copiar código e abrir iFood'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: colorScheme.tertiary,
                      foregroundColor: colorScheme.onTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: _markIfoodDone,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Marcar iFood como confirmado'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (ifoodDone) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'iFood confirmado',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

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
                    minimumSize: const Size(double.infinity, 60),
                  ),
                ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _editing = true),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Excluir'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        foregroundColor: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // ── Edit mode ─────────────────────────────────────────────
              Text(
                'Editar Entrega ${d.sequenceNumber}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pizzaEditCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '🍕 Número da Pizza',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _addrEditCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Endereço',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _houseEditCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nº',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locatorEditCtrl,
                decoration: const InputDecoration(
                  labelText: 'Localizador iFood',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _saveEdits,
                      child: const Text('Salvar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _editing = false),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
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

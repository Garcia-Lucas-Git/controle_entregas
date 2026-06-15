import 'package:controle_entregas/application/deliveries/delivery_notifier.dart';
import 'package:controle_entregas/application/wakelock/wakelock_controller.dart';
import 'package:controle_entregas/domain/entities/delivery.dart';
import 'package:controle_entregas/domain/enums/delivery_status.dart';
import 'package:controle_entregas/presentation/utils/currency_input.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:controle_entregas/services/ifood_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _drinkOptions = [
  'Coca 1L',
  'Coca 1,5L',
  'Coca 2L',
  'Coca Zero 1L',
  'Coca Zero 2L',
  'Fanta Laranja 1L',
  'Fanta Laranja 2L',
  'Sprite 1L',
  'Guaraná 1L',
  'Outros',
];

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
  late final WakeLockController _wakeLock;
  final ScrollController _scrollController = ScrollController();
  late TextEditingController _pizzaEditCtrl;
  late TextEditingController _addrEditCtrl;
  late TextEditingController _houseEditCtrl;
  late TextEditingController _complementEditCtrl;
  late TextEditingController _neighborhoodEditCtrl;
  late TextEditingController _locatorEditCtrl;
  late TextEditingController _cardAmountEditCtrl;
  late bool _needsCardEdit;
  late bool _hasDrinksEdit;
  String? _drinkTypeEdit;

  String? get _locator => widget.delivery.deliveryIdentifier?.isNotEmpty == true
      ? widget.delivery.deliveryIdentifier
      : null;

  @override
  void initState() {
    super.initState();
    _wakeLock = ref.read(wakeLockControllerProvider.notifier);
    _wakeLock.acquire();
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
    _complementEditCtrl = TextEditingController(text: d.complement ?? '');
    _neighborhoodEditCtrl = TextEditingController(text: d.neighborhood ?? '');
    _hasDrinksEdit = d.hasDrinks;
    _drinkTypeEdit = d.drinkType;
    _locatorEditCtrl = TextEditingController(text: d.deliveryIdentifier ?? '');
    _cardAmountEditCtrl = TextEditingController(
      text: currencyCentsForInput(d.cardAmountCents),
    );
    _needsCardEdit = d.needsCard;
  }

  @override
  void dispose() {
    _wakeLock.release();
    _scrollController.dispose();
    _pizzaEditCtrl.dispose();
    _addrEditCtrl.dispose();
    _houseEditCtrl.dispose();
    _complementEditCtrl.dispose();
    _neighborhoodEditCtrl.dispose();
    _locatorEditCtrl.dispose();
    _cardAmountEditCtrl.dispose();
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
    final code = _locator;
    if (code != null) {
      await Clipboard.setData(ClipboardData(text: code));
      AppLogger.log(
        LogEvents.ifoodLocatorClipboardCopy,
        module: 'DeliveryQuickPanel',
        metadata: {'code': code},
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    AppLogger.log(
      LogEvents.ifoodOpenStart,
      module: 'DeliveryQuickPanel',
      metadata: {'delivery_id': widget.delivery.id},
    );
    final opened = await IfoodLauncher.open();
    if (!mounted) return;
    if (!opened) {
      AppLogger.log(
        LogEvents.ifoodOpenFail,
        module: 'DeliveryQuickPanel',
        metadata: {'delivery_id': widget.delivery.id},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o iFood'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      AppLogger.log(
        LogEvents.ifoodOpenSuccess,
        module: 'DeliveryQuickPanel',
        metadata: {'delivery_id': widget.delivery.id},
      );
    }
  }

  Future<void> _saveEdits() async {
    final pizza = _pizzaEditCtrl.text.trim();
    final addr = _addrEditCtrl.text.trim();
    final house = _houseEditCtrl.text.trim();
    final complement = _complementEditCtrl.text.trim();
    final neighborhood = _neighborhoodEditCtrl.text.trim();
    final locator = _locatorEditCtrl.text.trim();
    final cardAmountCents = parseBrazilianCurrencyToCents(
      _cardAmountEditCtrl.text,
    );
    if (_needsCardEdit && cardAmountCents == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o valor da maquininha')),
      );
      return;
    }

    final hasPizzaChange = pizza != (widget.delivery.pizzaNumber ?? '');
    await ref
        .read(deliveryNotifierProvider.notifier)
        .updateFields(
          id: widget.delivery.id,
          routeId: widget.routeId,
          addressText: addr.isEmpty ? null : addr,
          houseNumber: house,
          complement: complement,
          neighborhood: neighborhood,
          pizzaNumber: pizza,
          deliveryIdentifier: locator,
          hasDrinks: _hasDrinksEdit,
          drinkType: _hasDrinksEdit ? (_drinkTypeEdit ?? '') : '',
          needsCard: _needsCardEdit,
          cardAmountCents: _needsCardEdit ? cardAmountCents : null,
          clearCardAmount: !_needsCardEdit,
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
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
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
                        Text('🍕', style: const TextStyle(fontSize: 24)),
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

                // ── Card payment (second operational priority) ───────────
                if (d.needsCard) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: d.cardAmountCents == null
                          ? colorScheme.errorContainer
                          : colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: d.cardAmountCents == null
                            ? colorScheme.error
                            : colorScheme.tertiary,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💳 COBRAR',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: d.cardAmountCents == null
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onTertiaryContainer,
                              ),
                        ),
                        const SizedBox(height: 10),
                        if (d.cardAmountCents != null) ...[
                          Text(
                            formatCurrencyCents(d.cardAmountCents!),
                            style: TextStyle(
                              fontSize: 34,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ] else
                          Text(
                            '⚠ Valor da maquininha não informado',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onErrorContainer,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],

                _OperationalInfoCard(
                  icon: '📍',
                  label: 'ENDEREÇO',
                  value: d.addressText,
                ),
                if (d.houseNumber != null && d.houseNumber!.isNotEmpty)
                  _OperationalInfoCard(
                    icon: '🏠',
                    label: 'NÚMERO',
                    value: d.houseNumber!,
                  ),
                if (d.complement != null && d.complement!.isNotEmpty)
                  _OperationalInfoCard(
                    icon: '📝',
                    label: 'COMPLEMENTO',
                    value: d.complement!,
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                    emphasized: true,
                  ),
                if (d.customerName != null && d.customerName!.trim().isNotEmpty)
                  _OperationalInfoCard(
                    icon: '👤',
                    label: 'CLIENTE',
                    value: d.customerName!,
                  ),
                if (d.drinkLabel != null)
                  _OperationalInfoCard(
                    icon: '🥤',
                    label: 'BEBIDA',
                    value: d.drinkLabel!,
                  ),

                // Locator stays available without outranking delivery details.
                if (_locator != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
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
                ],

                if (d.needsChange) ...[
                  _Flag(
                    Icons.payments_outlined,
                    d.changeAmountCents != null
                        ? 'Troco R\$ ${(d.changeAmountCents! / 100).toStringAsFixed(2)}'
                        : 'Troco',
                    colorScheme.tertiaryContainer,
                    colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 6),

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
                  controller: _complementEditCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Complemento',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _neighborhoodEditCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Bairro',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tem refrigerante'),
                  value: _hasDrinksEdit,
                  onChanged: (value) => setState(() {
                    _hasDrinksEdit = value;
                    if (!value) _drinkTypeEdit = null;
                  }),
                ),
                if (_hasDrinksEdit) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _drinkTypeEdit?.isEmpty == true
                        ? null
                        : _drinkTypeEdit,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de refrigerante',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _drinkOptions
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _drinkTypeEdit = value),
                  ),
                  const SizedBox(height: 10),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Maquininha'),
                  value: _needsCardEdit,
                  onChanged: (value) => setState(() {
                    _needsCardEdit = value;
                    if (!value) _cardAmountEditCtrl.clear();
                  }),
                ),
                if (_needsCardEdit) ...[
                  TextField(
                    controller: _cardAmountEditCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: brazilianCurrencyInputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Valor da Maquininha *',
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
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
      ),
    );
  }
}

class _OperationalInfoCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool emphasized;

  const _OperationalInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.backgroundColor,
    this.foregroundColor,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = foregroundColor ?? colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$icon $label',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: foreground.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasized ? 24 : 21,
              height: 1.15,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
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

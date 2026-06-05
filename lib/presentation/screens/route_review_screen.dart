import 'package:controle_entregas/application/deliveries/delivery_notifier.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:controle_entregas/services/maps_launcher.dart';
import 'package:controle_entregas/services/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RouteReviewScreen extends ConsumerStatefulWidget {
  final int shiftId;
  final int routeId;
  final List<OcrResult> ocrResults;

  const RouteReviewScreen({
    super.key,
    required this.shiftId,
    required this.routeId,
    required this.ocrResults,
  });

  @override
  ConsumerState<RouteReviewScreen> createState() => _RouteReviewScreenState();
}

class _RouteReviewScreenState extends ConsumerState<RouteReviewScreen> {
  late final List<_DeliveryDraft> _drafts;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _drafts = widget.ocrResults
        .asMap()
        .entries
        .map((e) => _DeliveryDraft.fromOcr(e.value, index: e.key))
        .toList();
  }

  Future<void> _approve() async {
    setState(() => _saving = true);
    try {
      for (int i = 0; i < _drafts.length; i++) {
        final d = _drafts[i];
        final locator = d.partnerCollectionCode.isNotEmpty
            ? d.partnerCollectionCode
            : d.deliveryIdentifier;
        if (locator.isNotEmpty) {
          AppLogger.log(
            LogEvents.locatorCaptured,
            module: 'RouteReviewScreen',
            metadata: {
              'value': locator,
              'length': locator.length,
              'route_id': widget.routeId,
              'sequence': i + 1,
            },
          );
        }
        await ref
            .read(deliveryNotifierProvider.notifier)
            .createFromOcr(
              routeId: widget.routeId,
              shiftId: widget.shiftId,
              sequenceNumber: i + 1,
              ocr: d.toOcrResult(),
            );
      }
      if (!mounted) return;
      context.go('/shift/${widget.shiftId}/route/${widget.routeId}/active');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openMaps() async {
    final addresses = _drafts
        .map((d) => d.addressText.trim())
        .where((a) => a.isNotEmpty)
        .toList();
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum endereço disponível para abrir no Maps.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final hasLow = _drafts.any(
      (d) => _ConfidenceLevel.fromValue(d.confidence) == _ConfidenceLevel.low,
    );
    if (hasLow && mounted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confiança Baixa'),
          content: const Text(
            'Uma ou mais entregas têm dados com baixa confiança. '
            'Verifique os endereços antes de abrir o Maps.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Abrir mesmo assim'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }
    await MapsLauncher.navigateTo(addresses);
  }

  Future<void> _copyLocator(String locator) async {
    await Clipboard.setData(ClipboardData(text: locator));
    AppLogger.log(
      LogEvents.localizerCopied,
      module: 'RouteReviewScreen',
      metadata: {'locator': locator, 'length': locator.length},
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Localizador copiado: $locator'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Revisar Rota — ${_drafts.length} entrega(s)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _drafts.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final item = _drafts.removeAt(oldIndex);
                  _drafts.insert(newIndex, item);
                });
              },
              itemBuilder: (ctx, i) => _DraftCard(
                key: ValueKey(_drafts[i].id),
                draft: _drafts[i],
                index: i,
                onChanged: (updated) => setState(() => _drafts[i] = updated),
                onRemove: _drafts.length > 1
                    ? () => setState(() => _drafts.removeAt(i))
                    : null,
                onCopyLocator: _copyLocator,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: OutlinedButton.icon(
              onPressed: _openMaps,
              icon: const Icon(Icons.map_outlined),
              label: Text('Abrir Maps com ${_drafts.length} parada(s)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: FilledButton.icon(
              onPressed: _saving ? null : _approve,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Aprovar e iniciar rota'),
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
}

// ── Confidence level ────────────────────────────────────────────────────────

enum _ConfidenceLevel {
  high,
  medium,
  low;

  static _ConfidenceLevel fromValue(double c) => c >= 0.8
      ? high
      : c >= 0.5
      ? medium
      : low;

  String get label => switch (this) {
    _ConfidenceLevel.high => 'ALTA',
    _ConfidenceLevel.medium => 'MÉDIA',
    _ConfidenceLevel.low => 'BAIXA',
  };

  Color color(ColorScheme cs) => switch (this) {
    _ConfidenceLevel.high => Colors.green.shade700,
    _ConfidenceLevel.medium => Colors.orange.shade700,
    _ConfidenceLevel.low => cs.error,
  };
}

// ── Draft model ─────────────────────────────────────────────────────────────

class _DeliveryDraft {
  final String id;
  String customerName;
  String addressText;
  String orderNumber;
  String deliveryIdentifier;
  String partnerCollectionCode;
  bool needsIfoodConfirmation;
  bool hasDrinks;
  bool needsCard;
  bool needsChange;
  String rawText;
  double confidence;

  _DeliveryDraft({
    required this.id,
    required this.customerName,
    required this.addressText,
    required this.orderNumber,
    required this.deliveryIdentifier,
    required this.partnerCollectionCode,
    required this.needsIfoodConfirmation,
    required this.hasDrinks,
    required this.needsCard,
    required this.needsChange,
    required this.rawText,
    required this.confidence,
  });

  factory _DeliveryDraft.fromOcr(OcrResult r, {required int index}) =>
      _DeliveryDraft(
        id: 'draft_$index',
        customerName: r.customerName ?? '',
        addressText: r.addressText ?? '',
        orderNumber: r.orderNumber ?? '',
        deliveryIdentifier: r.deliveryIdentifier ?? '',
        partnerCollectionCode: r.partnerCollectionCode ?? '',
        needsIfoodConfirmation: r.needsIfoodConfirmation,
        hasDrinks: r.hasDrinks,
        needsCard: r.needsCard,
        needsChange: r.needsChange,
        rawText: r.rawText,
        confidence: r.confidence,
      );

  _DeliveryDraft copyWith({
    String? customerName,
    String? addressText,
    String? orderNumber,
    String? deliveryIdentifier,
    String? partnerCollectionCode,
    bool? needsIfoodConfirmation,
    bool? hasDrinks,
    bool? needsCard,
    bool? needsChange,
  }) => _DeliveryDraft(
    id: id,
    customerName: customerName ?? this.customerName,
    addressText: addressText ?? this.addressText,
    orderNumber: orderNumber ?? this.orderNumber,
    deliveryIdentifier: deliveryIdentifier ?? this.deliveryIdentifier,
    partnerCollectionCode: partnerCollectionCode ?? this.partnerCollectionCode,
    needsIfoodConfirmation:
        needsIfoodConfirmation ?? this.needsIfoodConfirmation,
    hasDrinks: hasDrinks ?? this.hasDrinks,
    needsCard: needsCard ?? this.needsCard,
    needsChange: needsChange ?? this.needsChange,
    rawText: rawText,
    confidence: confidence,
  );

  OcrResult toOcrResult() => OcrResult(
    rawText: rawText,
    customerName: customerName.isEmpty ? null : customerName,
    addressText: addressText.isEmpty ? null : addressText,
    orderNumber: orderNumber.isEmpty ? null : orderNumber,
    deliveryIdentifier: deliveryIdentifier.isEmpty ? null : deliveryIdentifier,
    partnerCollectionCode: partnerCollectionCode.isEmpty
        ? null
        : partnerCollectionCode,
    needsIfoodConfirmation: needsIfoodConfirmation,
    hasDrinks: hasDrinks,
    needsCard: needsCard,
    needsChange: needsChange,
    confidence: confidence,
  );
}

// ── Draft card ──────────────────────────────────────────────────────────────

class _DraftCard extends StatefulWidget {
  final _DeliveryDraft draft;
  final int index;
  final ValueChanged<_DeliveryDraft> onChanged;
  final VoidCallback? onRemove;
  final ValueChanged<String> onCopyLocator;

  const _DraftCard({
    super.key,
    required this.draft,
    required this.index,
    required this.onChanged,
    this.onRemove,
    required this.onCopyLocator,
  });

  @override
  State<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends State<_DraftCard> {
  bool _expanded = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _orderCtrl;
  late final TextEditingController _idCtrl;
  late final TextEditingController _codeCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _nameCtrl = TextEditingController(text: d.customerName);
    _addrCtrl = TextEditingController(text: d.addressText);
    _orderCtrl = TextEditingController(text: d.orderNumber);
    _idCtrl = TextEditingController(text: d.deliveryIdentifier);
    _codeCtrl = TextEditingController(text: d.partnerCollectionCode);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _orderCtrl.dispose();
    _idCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(
      widget.draft.copyWith(
        customerName: _nameCtrl.text,
        addressText: _addrCtrl.text,
        orderNumber: _orderCtrl.text,
        deliveryIdentifier: _idCtrl.text,
        partnerCollectionCode: _codeCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.draft;
    final hasWarning = d.addressText.trim().isEmpty;
    final confidence = _ConfidenceLevel.fromValue(d.confidence);
    final locator = d.deliveryIdentifier.isNotEmpty
        ? d.deliveryIdentifier
        : d.partnerCollectionCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          ListTile(
            leading: CircleAvatar(
              backgroundColor: hasWarning
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '${widget.index + 1}',
                style: TextStyle(
                  color: hasWarning
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    d.orderNumber.isNotEmpty
                        ? 'Pedido #${d.orderNumber}'
                        : d.customerName.isNotEmpty
                        ? d.customerName
                        : 'Entrega ${widget.index + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                _ConfidenceBadge(level: confidence),
              ],
            ),
            subtitle: Text(
              d.addressText.isEmpty ? '⚠ Endereço obrigatório' : d.addressText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: d.addressText.isEmpty
                  ? TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    )
                  : const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.drag_handle),
                IconButton(
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.edit_outlined,
                    size: 20,
                  ),
                  tooltip: _expanded ? 'Fechar edição' : 'Editar',
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
          ),

          // ── Operational summary (always visible) ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (d.hasDrinks || d.needsCard || d.needsChange)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (d.hasDrinks)
                        _OperationalChip(
                          '⚠ Refrigerante',
                          Colors.orange.shade700,
                        ),
                      if (d.needsChange)
                        _OperationalChip(
                          '💰 Dinheiro/Troco',
                          Colors.green.shade700,
                        ),
                      if (d.needsCard)
                        _OperationalChip('💳 Cartão', Colors.blue.shade700),
                    ],
                  ),
                if (locator.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.tag,
                        size: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Localizador: $locator',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => widget.onCopyLocator(locator),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.copy_outlined,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Edit section (expanded only) ─────────────────────────────────
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _EditField(
                    label: 'Endereço *',
                    controller: _addrCtrl,
                    onChanged: (_) => _notify(),
                    isRequired: true,
                  ),
                  const SizedBox(height: 8),
                  _EditField(
                    label: 'Nome do cliente',
                    controller: _nameCtrl,
                    onChanged: (_) => _notify(),
                  ),
                  const SizedBox(height: 8),
                  _EditField(
                    label: 'Número do pedido',
                    controller: _orderCtrl,
                    onChanged: (_) => _notify(),
                  ),
                  const SizedBox(height: 8),
                  _EditField(
                    label: 'Identificador de entrega',
                    controller: _idCtrl,
                    onChanged: (_) => _notify(),
                  ),
                  const SizedBox(height: 8),
                  _EditField(
                    label: 'Código de coleta do parceiro',
                    controller: _codeCtrl,
                    onChanged: (_) => _notify(),
                  ),
                  const SizedBox(height: 12),
                  _FlagRow(
                    label: '🔐 Confirmação iFood',
                    value: d.needsIfoodConfirmation,
                    onChanged: (v) =>
                        widget.onChanged(d.copyWith(needsIfoodConfirmation: v)),
                  ),
                  _FlagRow(
                    label: '⚠ Refrigerante',
                    value: d.hasDrinks,
                    onChanged: (v) =>
                        widget.onChanged(d.copyWith(hasDrinks: v)),
                  ),
                  _FlagRow(
                    label: '💳 Cartão',
                    value: d.needsCard,
                    onChanged: (v) =>
                        widget.onChanged(d.copyWith(needsCard: v)),
                  ),
                  _FlagRow(
                    label: '💰 Troco',
                    value: d.needsChange,
                    onChanged: (v) =>
                        widget.onChanged(d.copyWith(needsChange: v)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Confidence badge ─────────────────────────────────────────────────────────

class _ConfidenceBadge extends StatelessWidget {
  final _ConfidenceLevel level;

  const _ConfidenceBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = level.color(Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        level.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// ── Operational chip ─────────────────────────────────────────────────────────

class _OperationalChip extends StatelessWidget {
  final String label;
  final Color color;

  const _OperationalChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 11, color: color)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      backgroundColor: color.withValues(alpha: 0.08),
    );
  }
}

// ── Edit field ───────────────────────────────────────────────────────────────

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isRequired;

  const _EditField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        errorText: isRequired && controller.text.trim().isEmpty
            ? 'Obrigatório'
            : null,
      ),
    );
  }
}

// ── Flag row ─────────────────────────────────────────────────────────────────

class _FlagRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FlagRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

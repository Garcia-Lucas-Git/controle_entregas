import 'package:controle_entregas/application/shifts/shift_notifier.dart';
import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class AddHistoryScreen extends ConsumerStatefulWidget {
  final Shift? entry;
  const AddHistoryScreen({super.key, this.entry});

  @override
  ConsumerState<AddHistoryScreen> createState() => _AddHistoryScreenState();
}

class _AddHistoryScreenState extends ConsumerState<AddHistoryScreen> {
  late DateTime _selectedDate;
  late final TextEditingController _deliveriesCtrl;
  late final TextEditingController _r8Ctrl;
  late final TextEditingController _r10Ctrl;
  late final TextEditingController _earningsCtrl;
  late final TextEditingController _fuelCtrl;
  late final TextEditingController _notesCtrl;
  bool _saving = false;
  bool _syncing = false;

  bool get _isEditing => widget.entry != null;

  int get _totalDeliveries => int.tryParse(_deliveriesCtrl.text.trim()) ?? 0;
  int get _r8Count => int.tryParse(_r8Ctrl.text.trim()) ?? 0;
  int get _r10Count => int.tryParse(_r10Ctrl.text.trim()) ?? 0;

  bool get _splitExceedsTotal => _r8Count + _r10Count > _totalDeliveries;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _selectedDate = e != null ? e.startedAt.toLocal() : DateTime.now();
    final deliveries = e?.deliveryCount ?? 0;
    _deliveriesCtrl = TextEditingController(
      text: e != null ? '$deliveries' : '',
    );
    _r8Ctrl = TextEditingController(text: e != null ? '$deliveries' : '');
    _r10Ctrl = TextEditingController(text: e != null ? '0' : '');
    _earningsCtrl = TextEditingController(
      text: e != null ? (e.totalEarnings.cents / 100).toStringAsFixed(2) : '',
    );
    _fuelCtrl = TextEditingController(
      text: e?.fuelExpenseCents != null
          ? (e!.fuelExpenseCents! / 100).toStringAsFixed(2)
          : '0.00',
    );
    _notesCtrl = TextEditingController(text: e?.notes ?? '');

    _deliveriesCtrl.addListener(_onTotalChanged);
    _r8Ctrl.addListener(_onR8Changed);
    _r10Ctrl.addListener(_onR10Changed);
  }

  @override
  void dispose() {
    _deliveriesCtrl.removeListener(_onTotalChanged);
    _r8Ctrl.removeListener(_onR8Changed);
    _r10Ctrl.removeListener(_onR10Changed);
    _deliveriesCtrl.dispose();
    _r8Ctrl.dispose();
    _r10Ctrl.dispose();
    _earningsCtrl.dispose();
    _fuelCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onTotalChanged() {
    if (_syncing) return;
    _syncing = true;
    final total = _totalDeliveries;
    _r8Ctrl.text = '$total';
    _r10Ctrl.text = '0';
    _recalcEarnings();
    _syncing = false;
    setState(() {});
  }

  void _onR8Changed() {
    if (_syncing) return;
    _syncing = true;
    final r8 = _r8Count;
    final total = _totalDeliveries;
    final r10 = (total - r8).clamp(0, total > 0 ? total : 9999);
    _r10Ctrl.text = '$r10';
    _recalcEarnings();
    _syncing = false;
    setState(() {});
  }

  void _onR10Changed() {
    if (_syncing) return;
    _syncing = true;
    final r10 = _r10Count;
    final total = _totalDeliveries;
    final r8 = (total - r10).clamp(0, total > 0 ? total : 9999);
    _r8Ctrl.text = '$r8';
    _recalcEarnings();
    _syncing = false;
    setState(() {});
  }

  void _recalcEarnings() {
    final r8 = _r8Count;
    final r10 = _r10Count;
    final earnings = r8 * 8 + r10 * 10;
    _earningsCtrl.text = earnings.toStringAsFixed(2);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    final deliveries = int.tryParse(_deliveriesCtrl.text.trim());
    final earningsText = _earningsCtrl.text.trim().replaceAll(',', '.');
    final earnings = double.tryParse(earningsText);

    if (deliveries == null || deliveries < 0) {
      _snack('Informe o número de entregas.');
      return;
    }
    if (earnings == null || earnings < 0) {
      _snack('Informe os ganhos estimados.');
      return;
    }

    final earningsCents = (earnings * 100).round();
    final fuelText = _fuelCtrl.text.trim().replaceAll(',', '.');
    final fuelReals = double.tryParse(fuelText) ?? 0.0;
    final fuelCents = fuelReals > 0 ? (fuelReals * 100).round() : null;
    final notes = _notesCtrl.text.trim().isEmpty
        ? null
        : _notesCtrl.text.trim();

    setState(() => _saving = true);
    try {
      final notifier = ref.read(historicalEntryNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updateEntry(
          id: widget.entry!.id,
          date: _selectedDate,
          deliveryCount: deliveries,
          earningsCents: earningsCents,
          notes: notes,
          fuelExpenseCents: fuelCents,
        );
      } else {
        await notifier.save(
          date: _selectedDate,
          deliveryCount: deliveries,
          earningsCents: earningsCents,
          notes: notes,
          fuelExpenseCents: fuelCents,
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _snack('Erro ao salvar. Tente novamente.');
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Histórico' : 'Adicionar Histórico'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data *', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(dateFmt.format(_selectedDate)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(height: 20),

            // ── Total deliveries ───────────────────────────────────────────
            TextField(
              controller: _deliveriesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total de Entregas *',
                border: OutlineInputBorder(),
                hintText: 'Ex: 18',
              ),
            ),
            const SizedBox(height: 12),

            // ── R$8 / R$10 split ───────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _r8Ctrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Entregas R\$8',
                      border: const OutlineInputBorder(),
                      hintText: '0',
                      errorText: _splitExceedsTotal ? '' : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _r10Ctrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Entregas R\$10',
                      border: const OutlineInputBorder(),
                      hintText: '0',
                      errorText: _splitExceedsTotal ? '' : null,
                    ),
                  ),
                ),
              ],
            ),
            if (_splitExceedsTotal)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'R\$8 + R\$10 (${_r8Count + _r10Count}) exceede o total ($_totalDeliveries)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // ── Estimated earnings ─────────────────────────────────────────
            TextField(
              controller: _earningsCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Ganhos Estimados *',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
                hintText: '0,00',
                helperText: 'Editável — inclua bônus ou ajustes',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _fuelCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Combustível (R\$)',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
                hintText: '0,00',
                helperText: 'Informativo — não afeta meta nem entregas',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Observações',
                border: OutlineInputBorder(),
                hintText: 'Ex: Domingo, Feriado (opcional)',
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isEditing ? 'Salvar Alterações' : 'Salvar'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

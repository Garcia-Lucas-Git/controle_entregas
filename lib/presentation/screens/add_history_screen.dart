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
  late final TextEditingController _earningsCtrl;
  late final TextEditingController _hoursCtrl;
  late final TextEditingController _notesCtrl;
  bool _saving = false;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _selectedDate =
        e != null ? e.startedAt.toLocal() : DateTime.now();
    _deliveriesCtrl =
        TextEditingController(text: e != null ? '${e.deliveryCount}' : '');
    _earningsCtrl = TextEditingController(
      text: e != null
          ? (e.totalEarnings.cents / 100).toStringAsFixed(2)
          : '',
    );
    _hoursCtrl = TextEditingController(
      text: e?.hoursWorked != null
          ? e!.hoursWorked!.toStringAsFixed(0)
          : '',
    );
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _deliveriesCtrl.dispose();
    _earningsCtrl.dispose();
    _hoursCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
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
    final earningsText =
        _earningsCtrl.text.trim().replaceAll(',', '.');
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
    final hoursText =
        _hoursCtrl.text.trim().replaceAll(',', '.');
    final hoursWorked =
        hoursText.isEmpty ? null : double.tryParse(hoursText);
    final notes = _notesCtrl.text.trim().isEmpty
        ? null
        : _notesCtrl.text.trim();

    setState(() => _saving = true);
    try {
      final notifier =
          ref.read(historicalEntryNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updateEntry(
          id: widget.entry!.id,
          date: _selectedDate,
          deliveryCount: deliveries,
          earningsCents: earningsCents,
          hoursWorked: hoursWorked,
          notes: notes,
        );
      } else {
        await notifier.save(
          date: _selectedDate,
          deliveryCount: deliveries,
          earningsCents: earningsCents,
          hoursWorked: hoursWorked,
          notes: notes,
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isEditing ? 'Editar Histórico' : 'Adicionar Histórico'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data *',
                style: Theme.of(context).textTheme.labelLarge),
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
            TextField(
              controller: _deliveriesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total de Entregas *',
                border: OutlineInputBorder(),
                hintText: 'Ex: 25',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _earningsCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              decoration: const InputDecoration(
                labelText: 'Ganhos Estimados *',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
                hintText: '0,00',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hoursCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              decoration: const InputDecoration(
                labelText: 'Horas Trabalhadas',
                border: OutlineInputBorder(),
                hintText: 'Ex: 8 (opcional)',
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
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
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

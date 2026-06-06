import 'package:controle_entregas/application/settings/settings_notifier.dart';
import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:controle_entregas/domain/entities/app_settings.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (settings) => _SettingsForm(settings: settings),
      ),
    );
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  final AppSettings settings;
  const _SettingsForm({required this.settings});

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  late final TextEditingController _driverNameCtrl;
  late final TextEditingController _pizzeriaCtrl;
  late final TextEditingController _ifoodUrlCtrl;
  late final TextEditingController _ifoodSelectorCtrl;
  late final TextEditingController _dailyGoalCtrl;
  late final TextEditingController _homeCtrl;
  late final TextEditingController _baseRateCtrl;
  late final TextEditingController _longRateCtrl;
  late bool _ocrContrast;

  @override
  void initState() {
    super.initState();
    _driverNameCtrl = TextEditingController(text: widget.settings.driverName);
    _pizzeriaCtrl = TextEditingController(
      text: widget.settings.pizzeriaAddress,
    );
    _homeCtrl = TextEditingController(text: widget.settings.homeAddress);
    _ifoodUrlCtrl = TextEditingController(text: widget.settings.ifoodUrl);
    _ifoodSelectorCtrl = TextEditingController(
      text: widget.settings.ifoodFieldSelector,
    );
    _dailyGoalCtrl = TextEditingController(
      text: (widget.settings.dailyGoalCents / 100).toStringAsFixed(0),
    );
    _baseRateCtrl = TextEditingController(
      text: (widget.settings.earningsConfig.baseRateCents / 100)
          .toStringAsFixed(2),
    );
    _longRateCtrl = TextEditingController(
      text: (widget.settings.earningsConfig.longSingleDeliveryRateCents / 100)
          .toStringAsFixed(2),
    );
    _ocrContrast = widget.settings.ocrContrastEnabled;
  }

  @override
  void dispose() {
    _driverNameCtrl.dispose();
    _pizzeriaCtrl.dispose();
    _homeCtrl.dispose();
    _ifoodUrlCtrl.dispose();
    _ifoodSelectorCtrl.dispose();
    _dailyGoalCtrl.dispose();
    _baseRateCtrl.dispose();
    _longRateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsNotifierProvider.notifier);

    await notifier.updateDriverName(_driverNameCtrl.text.trim());
    await notifier.updatePizzeriaAddress(_pizzeriaCtrl.text.trim());
    await notifier.updateHomeAddress(_homeCtrl.text.trim());
    await notifier.updateIfoodUrl(_ifoodUrlCtrl.text.trim());
    await notifier.updateIfoodFieldSelector(_ifoodSelectorCtrl.text.trim());
    await notifier.updateOcrContrast(_ocrContrast);

    final goalReals =
        double.tryParse(_dailyGoalCtrl.text.replaceAll(',', '.')) ?? 120.0;
    await notifier.updateDailyGoal((goalReals * 100).round());

    final baseRate =
        (double.tryParse(_baseRateCtrl.text.replaceAll(',', '.')) ?? 8.0) * 100;
    final longRate =
        (double.tryParse(_longRateCtrl.text.replaceAll(',', '.')) ?? 10.0) *
        100;
    await notifier.updateEarningsConfig(
      baseRateCents: baseRate.round(),
      longSingleDeliveryRateCents: longRate.round(),
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Configurações salvas.')));
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader('Motorista'),
        _Field(
          label: 'Nome do motorista',
          controller: _driverNameCtrl,
          hint: 'Lucas Garcia Rodrigues',
        ),
        const SizedBox(height: 24),

        _SectionHeader('Pizzaria'),
        _Field(
          label: 'Endereço da pizzaria',
          controller: _pizzeriaCtrl,
          hint: 'Rua Exemplo, 123 — Uberlândia',
          helperText: 'Usado como ponto de partida para cálculo de distância.',
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Endereço de casa',
          controller: _homeCtrl,
          hint: 'Rua Exemplo, 456 — Uberlândia',
          helperText: 'Opcional. Destino final de navegação ao ir para casa.',
        ),
        const SizedBox(height: 24),

        _SectionHeader('Remuneração'),
        _Field(
          label: 'Meta Diária (R\$)',
          controller: _dailyGoalCtrl,
          inputType: TextInputType.number,
          helperText: 'Padrão: R\$ 120. Exibida como barra de progresso no turno.',
          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d]'))],
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Tarifa normal (R\$)',
          controller: _baseRateCtrl,
          inputType: const TextInputType.numberWithOptions(decimal: true),
          helperText: 'Padrão: R\$ 8,00',
          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Tarifa longa distância (R\$)',
          controller: _longRateCtrl,
          inputType: const TextInputType.numberWithOptions(decimal: true),
          helperText: 'Aplicada quando: rota com 1 entrega E distância > 8 km',
          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
        ),
        const SizedBox(height: 24),

        _SectionHeader('iFood'),
        _Field(
          label: 'URL de confirmação iFood',
          controller: _ifoodUrlCtrl,
          hint: 'https://confirmacao-entrega-propria.ifood.com.br/',
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Seletor DOM do campo de código',
          controller: _ifoodSelectorCtrl,
          hint: '#confirmation-code',
          helperText:
              'CSS selector do campo de entrada no portal iFood. Atualize se o portal mudar.',
        ),
        const SizedBox(height: 24),

        _SectionHeader('OCR'),
        SwitchListTile(
          title: const Text('Contraste adaptativo (OCR)'),
          subtitle: const Text(
            'Ative apenas se OCR estiver falhando em comprovantes com desbotamento.',
          ),
          value: _ocrContrast,
          onChanged: (v) => setState(() => _ocrContrast = v),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 32),

        _SectionHeader('Exportar Dados'),
        _ExportSection(),
        const SizedBox(height: 24),

        _SectionHeader('Diagnóstico'),
        OutlinedButton.icon(
          onPressed: () => context.push('/dev/tools'),
          icon: const Icon(Icons.developer_mode),
          label: const Text('Dev Tools'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'OCR Sandbox, logs e geração de dados de teste.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 32),

        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text('Salvar configurações'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helperText;
  final TextInputType? inputType;
  final List<TextInputFormatter>? formatters;

  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.helperText,
    this.inputType,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: formatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _ExportSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ExportSection> createState() => _ExportSectionState();
}

class _ExportSectionState extends ConsumerState<_ExportSection> {
  // 0 = mês atual, 1 = mês anterior, 2 = tudo
  int _rangeIndex = 0;
  bool _exporting = false;

  static const _rangeLabels = [
    'Mês atual',
    'Mês anterior',
    'Todos os registros',
  ];

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final now = DateTime.now();
      DateTime? from;
      DateTime? to;

      if (_rangeIndex == 0) {
        from = DateTime(now.year, now.month, 1);
      } else if (_rangeIndex == 1) {
        final prev = DateTime(now.year, now.month - 1, 1);
        from = prev;
        to = DateTime(
          now.year,
          now.month,
          1,
        ).subtract(const Duration(seconds: 1));
      }

      await ref.read(exportServiceProvider).exportCsv(from: from, to: to);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao exportar: $e')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          initialValue: _rangeIndex,
          decoration: const InputDecoration(
            labelText: 'Período',
            border: OutlineInputBorder(),
          ),
          items: List.generate(
            _rangeLabels.length,
            (i) => DropdownMenuItem(value: i, child: Text(_rangeLabels[i])),
          ),
          onChanged: (v) => setState(() => _rangeIndex = v ?? 0),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: _exporting ? null : _export,
          icon: _exporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: const Text('Compartilhar CSV'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Exporta todas as entregas do período selecionado '
          'em formato CSV compatível com Google Sheets.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await AppLogger.exportLogs(lastFourHours: false);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Logs exportados com sucesso.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('Hora atual'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await AppLogger.exportLogs(lastFourHours: true);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Logs exportados com sucesso.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('5 horas'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Compartilha o arquivo de log para diagnóstico de problemas.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

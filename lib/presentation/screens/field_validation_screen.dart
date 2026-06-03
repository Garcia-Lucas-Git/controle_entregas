import 'dart:io';

import 'package:controle_entregas/core/devtools/log_reader_service.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FieldValidationScreen extends StatefulWidget {
  const FieldValidationScreen({super.key});

  @override
  State<FieldValidationScreen> createState() => _FieldValidationScreenState();
}

class _FieldValidationScreenState extends State<FieldValidationScreen> {
  late final String _runId;
  late final DateTime _startedAt;
  final List<_FieldStepState> _steps = _defaultSteps
      .map((step) => _FieldStepState(step: step))
      .toList();
  final TextEditingController _recommendationsController =
      TextEditingController();
  String? _reportPath;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _runId = 'FIELD-${DateTime.now().millisecondsSinceEpoch}';
    _startedAt = DateTime.now().toUtc();
    AppLogger.log(
      LogEvents.fieldValidationStart,
      module: 'FieldValidationScreen',
      screen: 'FieldValidationScreen',
      sessionId: _runId,
      metadata: {'run_id': _runId},
    );
  }

  @override
  void dispose() {
    _recommendationsController.dispose();
    for (final step in _steps) {
      step.notesController.dispose();
    }
    super.dispose();
  }

  int get _passCount =>
      _steps.where((s) => s.status == FieldStepStatus.pass).length;
  int get _failCount =>
      _steps.where((s) => s.status == FieldStepStatus.fail).length;
  int get _skippedCount =>
      _steps.where((s) => s.status == FieldStepStatus.skipped).length;
  int get _pendingCount =>
      _steps.where((s) => s.status == FieldStepStatus.pending).length;

  void _markStep(_FieldStepState state, FieldStepStatus status) {
    setState(() {
      state.status = status;
      state.completedAt = DateTime.now().toUtc();
    });
    final event = switch (status) {
      FieldStepStatus.pass => LogEvents.fieldValidationStepPass,
      FieldStepStatus.fail => LogEvents.fieldValidationStepFail,
      FieldStepStatus.skipped => LogEvents.fieldValidationStepSkip,
      FieldStepStatus.pending => LogEvents.fieldValidationStart,
    };
    AppLogger.log(
      event,
      module: 'FieldValidationScreen',
      screen: 'FieldValidationScreen',
      sessionId: _runId,
      metadata: {
        'run_id': _runId,
        'step': state.step.title,
        'status': status.label,
        'notes': state.notesController.text,
      },
    );
  }

  Future<void> _generateReport() async {
    setState(() => _generating = true);
    final finishedAt = DateTime.now().toUtc();
    try {
      final dir = await _reportDirectory();
      await dir.create(recursive: true);
      final report = File('${dir.path}/latest_field_validation_report.md');
      final criticalLogs = await _criticalLogs();
      await report.writeAsString(
        _buildReport(finishedAt: finishedAt, criticalLogs: criticalLogs),
      );
      AppLogger.log(
        LogEvents.fieldValidationReportGenerated,
        module: 'FieldValidationScreen',
        screen: 'FieldValidationScreen',
        sessionId: _runId,
        metadata: {'run_id': _runId, 'path': report.path},
      );
      AppLogger.log(
        LogEvents.fieldValidationComplete,
        module: 'FieldValidationScreen',
        screen: 'FieldValidationScreen',
        sessionId: _runId,
        metadata: {
          'run_id': _runId,
          'step': 'complete',
          'status': _failCount == 0 ? 'PASS' : 'FAIL',
          'notes': _recommendationsController.text,
          'pass': _passCount,
          'fail': _failCount,
          'skipped': _skippedCount,
          'pending': _pendingCount,
        },
      );
      if (!mounted) return;
      setState(() => _reportPath = report.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Relatório gerado: ${report.path}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao gerar relatório: $e')));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<Directory> _reportDirectory() async {
    final external = await getExternalStorageDirectory();
    if (external != null) {
      return Directory('${external.path}/field_validation_reports');
    }
    final fallback = await getApplicationDocumentsDirectory();
    return Directory('${fallback.path}/field_validation_reports');
  }

  Future<List<String>> _criticalLogs() async {
    final logs = await LogReaderService.readLogs();
    return logs.entries
        .where(
          (entry) =>
              entry.timestamp.isAfter(_startedAt) &&
              (entry.event == LogEvents.appFlutterError ||
                  entry.event == LogEvents.appPlatformError),
        )
        .map((entry) => '${entry.timestamp.toIso8601String()} ${entry.event}')
        .toList();
  }

  String _buildReport({
    required DateTime finishedAt,
    required List<String> criticalLogs,
  }) {
    final buffer = StringBuffer()
      ..writeln('# DeliveryFlow Field Validation Report')
      ..writeln()
      ..writeln('Run ID: $_runId')
      ..writeln('Started: ${_startedAt.toIso8601String()}')
      ..writeln('Finished: ${finishedAt.toIso8601String()}')
      ..writeln(
        'Duration: ${finishedAt.difference(_startedAt).inMilliseconds} ms',
      )
      ..writeln()
      ..writeln('## Summary')
      ..writeln()
      ..writeln('PASS: $_passCount')
      ..writeln('FAIL: $_failCount')
      ..writeln('SKIPPED: $_skippedCount')
      ..writeln('PENDING: $_pendingCount')
      ..writeln()
      ..writeln('## Checklist Results')
      ..writeln()
      ..writeln('Step | Status | Notes | Timestamp')
      ..writeln('--- | --- | --- | ---');

    for (final step in _steps) {
      buffer.writeln(
        '${step.step.title} | ${step.status.label} | '
        '${_clean(step.notesController.text)} | '
        '${step.completedAt?.toIso8601String() ?? ''}',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Critical Logs')
      ..writeln();
    if (criticalLogs.isEmpty) {
      buffer.writeln('None');
    } else {
      for (final log in criticalLogs) {
        buffer.writeln('- $log');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Recommendations')
      ..writeln()
      ..writeln(
        _recommendationsController.text.trim().isEmpty
            ? 'None'
            : _recommendationsController.text.trim(),
      );
    return buffer.toString();
  }

  String _clean(String text) => text.replaceAll('|', '/').replaceAll('\n', ' ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validação Guiada de Campo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCard(
            runId: _runId,
            pass: _passCount,
            fail: _failCount,
            skipped: _skippedCount,
            pending: _pendingCount,
          ),
          const SizedBox(height: 12),
          ..._steps.map(
            (step) => _StepCard(
              state: step,
              onPass: () => _markStep(step, FieldStepStatus.pass),
              onFail: () => _markStep(step, FieldStepStatus.fail),
              onSkip: () => _markStep(step, FieldStepStatus.skipped),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _recommendationsController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Recomendações / notas finais',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _generating ? null : _generateReport,
            icon: const Icon(Icons.description_outlined),
            label: Text(_generating ? 'Gerando...' : 'Gerar Relatório'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          if (_reportPath != null) ...[
            const SizedBox(height: 8),
            SelectableText(
              _reportPath!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String runId;
  final int pass;
  final int fail;
  final int skipped;
  final int pending;

  const _SummaryCard({
    required this.runId,
    required this.pass,
    required this.fail,
    required this.skipped,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(runId, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _Metric(label: 'PASS', value: pass),
                _Metric(label: 'FAIL', value: fail),
                _Metric(label: 'SKIP', value: skipped),
                _Metric(label: 'PEND', value: pending),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final int value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final _FieldStepState state;
  final VoidCallback onPass;
  final VoidCallback onFail;
  final VoidCallback onSkip;

  const _StepCard({
    required this.state,
    required this.onPass,
    required this.onFail,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (state.status) {
      FieldStepStatus.pass => Colors.green,
      FieldStepStatus.fail => Theme.of(context).colorScheme.error,
      FieldStepStatus.skipped => Colors.orange,
      FieldStepStatus.pending => Theme.of(context).colorScheme.outline,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.step.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  state.status.label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(state.step.instruction),
            const SizedBox(height: 8),
            Text(
              'Esperado: ${state.step.expected}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (state.step.screenshotHint != null) ...[
              const SizedBox(height: 6),
              Text(
                'Evidência: ${state.step.screenshotHint}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: state.notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onPass,
                    child: const Text('PASS'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onFail,
                    child: const Text('FAIL'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    child: const Text('SKIP'),
                  ),
                ),
              ],
            ),
            if (state.completedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                state.completedAt!.toIso8601String(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldValidationStep {
  final String title;
  final String instruction;
  final String expected;
  final String? screenshotHint;

  const _FieldValidationStep({
    required this.title,
    required this.instruction,
    required this.expected,
    this.screenshotHint,
  });
}

class _FieldStepState {
  final _FieldValidationStep step;
  final TextEditingController notesController = TextEditingController();
  FieldStepStatus status = FieldStepStatus.pending;
  DateTime? completedAt;

  _FieldStepState({required this.step});
}

enum FieldStepStatus {
  pending,
  pass,
  fail,
  skipped;

  String get label => switch (this) {
    FieldStepStatus.pending => 'PENDING',
    FieldStepStatus.pass => 'PASS',
    FieldStepStatus.fail => 'FAIL',
    FieldStepStatus.skipped => 'SKIPPED',
  };
}

const _defaultSteps = [
  _FieldValidationStep(
    title: '1. App Startup',
    instruction:
        'Open the app normally and confirm the home screen loads without crash.',
    expected: 'Home screen visible. No error dialog. No crash.',
    screenshotHint: 'Capture the home screen if possible.',
  ),
  _FieldValidationStep(
    title: '2. New Route Options',
    instruction:
        'Open New Route and confirm the three primary options are visible.',
    expected: 'Tirar Foto, Importar da Galeria, Entrada Manual.',
  ),
  _FieldValidationStep(
    title: '3. Gallery Import',
    instruction: 'Use Importar da Galeria and select a real receipt image.',
    expected:
        'OCR runs. Address or locator is extracted. Recovery appears if confidence is low.',
  ),
  _FieldValidationStep(
    title: '4. Camera OCR',
    instruction: 'Use Tirar Foto and scan a receipt or test image.',
    expected: 'OCR runs without crash. Result screen or recovery flow appears.',
  ),
  _FieldValidationStep(
    title: '5. Manual Entry',
    instruction: 'Use Entrada Manual and create a delivery manually.',
    expected:
        'Delivery is created. Validation rules work. Expected navigation occurs.',
  ),
  _FieldValidationStep(
    title: '6. Maps Flow',
    instruction: 'Open a delivery address in Google Maps.',
    expected:
        'Google Maps opens. Address is not empty. User can return to DeliveryFlow.',
  ),
  _FieldValidationStep(
    title: '7. iFood Flow',
    instruction:
        'Open the iFood confirmation flow for a delivery with locator.',
    expected:
        'Locator is preserved. Clipboard copy works. No ref-after-dispose errors.',
  ),
  _FieldValidationStep(
    title: '8. Delivery Completion',
    instruction: 'Complete at least one delivery.',
    expected: 'Delivery status changes to completed. Route progress updates.',
  ),
  _FieldValidationStep(
    title: '9. Background / Foreground',
    instruction: 'Send the app to background and return.',
    expected: 'Current route and delivery state remain available. No crash.',
    screenshotHint: 'Capture final restored route screen if possible.',
  ),
  _FieldValidationStep(
    title: '10. History',
    instruction: 'Open History.',
    expected: 'History opens. No LocaleDataException. Shift appears correctly.',
  ),
  _FieldValidationStep(
    title: '11. Shift Closure',
    instruction: 'Close the active shift.',
    expected: 'Shift closes successfully. Final report or summary is visible.',
  ),
  _FieldValidationStep(
    title: '12. DevTools Diagnostics',
    instruction:
        'Open DevTools, Diagnostics Dashboard, Log Viewer, and Session Explorer.',
    expected: 'All diagnostic screens open without crash. Logs are readable.',
  ),
  _FieldValidationStep(
    title: '13. Export Evidence',
    instruction: 'Export logs or diagnostic bundle.',
    expected: 'Export/share action opens or succeeds.',
  ),
  _FieldValidationStep(
    title: '14. Cleanup',
    instruction: 'Use cleanup actions to remove automation/test data.',
    expected:
        'Only test/automation data is removed. Real user data remains untouched.',
  ),
];

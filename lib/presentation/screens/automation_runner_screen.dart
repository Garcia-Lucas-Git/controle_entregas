import 'package:controle_entregas/core/devtools/automation_result.dart';
import 'package:controle_entregas/core/devtools/automation_runner.dart';
import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AutomationRunnerScreen extends ConsumerStatefulWidget {
  final String runToken;
  final bool launchedFromDeepLink;

  const AutomationRunnerScreen({
    super.key,
    this.runToken = '',
    this.launchedFromDeepLink = false,
  });

  @override
  ConsumerState<AutomationRunnerScreen> createState() =>
      _AutomationRunnerScreenState();
}

class _AutomationRunnerScreenState
    extends ConsumerState<AutomationRunnerScreen> {
  AutomationRunResult? _result;
  Object? _error;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    AppLogger.info(
      widget.launchedFromDeepLink
          ? LogEvents.automationDeepLinkReceived
          : LogEvents.automationScreenOpened,
      module: 'AutomationRunnerScreen',
      screen: 'AutomationRunnerScreen',
      metadata: {
        'run_token': widget.runToken,
        'launched_from_deep_link': widget.launchedFromDeepLink,
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void didUpdateWidget(covariant AutomationRunnerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.runToken.isNotEmpty && widget.runToken != oldWidget.runToken) {
      AppLogger.info(
        LogEvents.automationDeepLinkReceived,
        module: 'AutomationRunnerScreen',
        screen: 'AutomationRunnerScreen',
        metadata: {
          'run_token': widget.runToken,
          'previous_run_token': oldWidget.runToken,
          'launched_from_deep_link': widget.launchedFromDeepLink,
        },
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => _run());
    }
  }

  Future<void> _run() async {
    if (!mounted) return;
    final database = ref.read(appDatabaseProvider);
    setState(() {
      _running = true;
      _error = null;
    });
    AppLogger.info(
      LogEvents.automationRunStart,
      module: 'AutomationRunnerScreen',
      screen: 'AutomationRunnerScreen',
      metadata: {
        'run_token': widget.runToken,
        'launched_from_deep_link': widget.launchedFromDeepLink,
      },
    );
    try {
      final runner = AutomationRunner(database);
      final result = await runner.runSmoke();
      if (!mounted) return;
      setState(() {
        _result = result;
        _running = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _running = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automation Runner'),
        actions: [
          IconButton(
            onPressed: _running ? null : _run,
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Executar novamente',
          ),
        ],
      ),
      body: _running
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Executando smoke test...'),
                ],
              ),
            )
          : result == null
          ? Center(child: Text('Falha: $_error'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(
                      result.passed ? Icons.check_circle : Icons.warning_amber,
                      color: result.passed
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      result.passed ? 'PASS' : 'FAIL',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(
                      'Run ID: ${result.runId}\n'
                      'Relatório: ${result.reportPath}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _Summary(result: result),
                const SizedBox(height: 12),
                ...result.tests.map((test) => _TestTile(test: test)),
                if (result.ocrFixtures.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'OCR Fixtures',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...result.ocrFixtures.map(
                    (fixture) => _FixtureTile(fixture: fixture),
                  ),
                ],
              ],
            ),
    );
  }
}

class _Summary extends StatelessWidget {
  final AutomationRunResult result;

  const _Summary({required this.result});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Metric(label: 'PASS', value: result.passCount),
        _Metric(label: 'PART', value: result.partialCount),
        _Metric(label: 'FAIL', value: result.failCount),
        _Metric(label: 'SKIP', value: result.skippedCount),
      ],
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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text('$value', style: Theme.of(context).textTheme.titleLarge),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestTile extends StatelessWidget {
  final AutomationTestResult test;

  const _TestTile({required this.test});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        title: Text(test.name),
        subtitle: Text(test.message ?? '${test.durationMs} ms'),
        trailing: Text(test.status.label),
      ),
    );
  }
}

class _FixtureTile extends StatelessWidget {
  final AutomationOcrFixtureResult fixture;

  const _FixtureTile({required this.fixture});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        title: Text(fixture.fileName),
        subtitle: Text(
          'chars=${fixture.rawTextLength} locator=${fixture.locator ?? '-'} '
          'address=${fixture.addressFound} ${fixture.durationMs}ms',
        ),
        trailing: Text(fixture.status.label),
      ),
    );
  }
}

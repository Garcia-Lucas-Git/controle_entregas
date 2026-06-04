import 'dart:io';

import 'package:controle_entregas/core/devtools/diagnostic_bundle_service.dart';
import 'package:controle_entregas/core/devtools/log_reader_service.dart';
import 'package:controle_entregas/core/devtools/test_data_cleanup_service.dart';
import 'package:controle_entregas/core/devtools/test_data_generator_service.dart';
import 'package:controle_entregas/core/logging/log_storage.dart';
import 'package:controle_entregas/core/monitoring/build_info.dart';
import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Phase 4 — Developer Tools
/// Hub for diagnostics, log management, and test data generation.
/// Accessible from Settings screen.
class DevToolsScreen extends ConsumerStatefulWidget {
  const DevToolsScreen({super.key});

  @override
  ConsumerState<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends ConsumerState<DevToolsScreen> {
  List<DevLogFileInfo> _logFiles = [];
  bool _loadingFiles = false;
  bool _working = false;
  Map<String, dynamic> _buildMeta = {};

  TestDataGeneratorService get _generator =>
      TestDataGeneratorService(ref.read(appDatabaseProvider));

  TestDataCleanupService get _cleanup =>
      TestDataCleanupService(ref.read(appDatabaseProvider));

  @override
  void initState() {
    super.initState();
    AppLogger.info(LogEvents.devToolsOpened, module: 'DevToolsScreen');
    _loadLogFiles();
    _loadBuildInfo();
  }

  Future<void> _loadBuildInfo() async {
    final meta = await BuildInfo.collect();
    if (mounted) setState(() => _buildMeta = meta);
  }

  Future<void> _loadLogFiles() async {
    setState(() => _loadingFiles = true);
    try {
      final result = await LogReaderService.readLogs();
      if (!mounted) return;
      setState(() {
        _logFiles = result.files;
        _loadingFiles = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingFiles = false);
    }
  }

  Future<void> _exportLogs({bool lastFourHours = true}) async {
    await AppLogger.exportLogs(lastFourHours: lastFourHours);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logs exportados.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportBundle() async {
    await _runAction(
      successMessage: 'Bundle diagnóstico exportado.',
      action: () =>
          DiagnosticBundleService(ref.read(appDatabaseProvider)).export(),
    );
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar todos os logs?'),
        content: const Text(
          'Todos os arquivos de log serão deletados permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await LogStorage.close();
      final dir = await getApplicationDocumentsDirectory();
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        final isHourly = RegExp(
          r'^\d{4}-\d{2}-\d{2}_\d{2}\.log$',
        ).hasMatch(name);
        final isLegacy = {
          'deliveryflow.log',
          'deliveryflow.1.log',
          'deliveryflow.2.log',
        }.contains(name);
        if (isHourly || isLegacy) await entity.delete();
      }
      await LogStorage.init();
      await _loadLogFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logs apagados.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _confirmCleanup({
    required String title,
    required String successMessage,
    required Future<Object?> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text(
          'Somente registros marcados com [AUTOMATION], [DEVTOOLS] ou automation_run_id serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(successMessage: successMessage, action: action);
  }

  Future<void> _cleanupDeliveries() => _confirmCleanup(
    title: 'Excluir entregas de teste?',
    successMessage: 'Entregas de teste removidas.',
    action: () => _cleanup.cleanupAutomationDeliveries(),
  );

  Future<void> _cleanupRoutes() => _confirmCleanup(
    title: 'Excluir rotas de teste?',
    successMessage: 'Rotas de teste removidas.',
    action: () => _cleanup.cleanupAutomationRoutes(),
  );

  Future<void> _cleanupHistory() => _confirmCleanup(
    title: 'Excluir histórico de teste?',
    successMessage: 'Histórico de teste removido.',
    action: () => _cleanup.cleanupAutomationHistory(),
  );

  Future<void> _cleanupGenerated() => _confirmCleanup(
    title: 'Executar limpeza completa de simulação?',
    successMessage: 'Limpeza completa de simulação concluída.',
    action: () => _generator.cleanupGeneratedData(),
  );

  Future<void> _runAction({
    required String successMessage,
    required Future<void> Function() action,
  }) async {
    setState(() => _working = true);
    try {
      await action();
      AppLogger.info(
        LogEvents.testDataGenerated,
        module: 'DevToolsScreen',
        metadata: {'message': successMessage},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Erro: $e')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Build Info',
            children: _buildMeta.isEmpty
                ? const [SizedBox(height: 20, child: LinearProgressIndicator())]
                : [
                    _InfoRow(
                      'Versão',
                      '${_buildMeta['version_name']} (${_buildMeta['version_code']})',
                    ),
                    _InfoRow('Build type', '${_buildMeta['build_type']}'),
                    _InfoRow(
                      'Dispositivo',
                      '${_buildMeta['manufacturer']} ${_buildMeta['device_model']}',
                    ),
                    _InfoRow(
                      'Android',
                      '${_buildMeta['android_release']} (API ${_buildMeta['android_sdk']})',
                    ),
                  ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Observability',
            children: [
              _NavButton(
                icon: Icons.list_alt,
                label: 'Log Viewer',
                onPressed: () => context.push('/dev/logs'),
              ),
              _NavButton(
                icon: Icons.account_tree_outlined,
                label: 'Session Explorer',
                onPressed: () => context.push('/dev/sessions'),
              ),
              _NavButton(
                icon: Icons.monitor_heart_outlined,
                label: 'Diagnostics Dashboard',
                onPressed: () => context.push('/dev/diagnostics'),
              ),
              _NavButton(
                icon: Icons.play_circle_outline,
                label: 'Automation Runner',
                onPressed: () => context.push('/dev/automation-runner'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Log Files',
            children: [
              if (_loadingFiles)
                const CircularProgressIndicator()
              else if (_logFiles.isEmpty)
                const Text(
                  'Nenhum arquivo de log encontrado.',
                  style: TextStyle(fontSize: 13),
                )
              else
                ..._logFiles.map(
                  (f) => _InfoRow(
                    f.name,
                    '${(f.sizeBytes / 1024).toStringAsFixed(1)} KB',
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _exportLogs(lastFourHours: false),
                      icon: const Icon(Icons.upload),
                      label: const Text('Hora atual'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _exportLogs(lastFourHours: true),
                      icon: const Icon(Icons.history),
                      label: const Text('5 horas'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearLogs,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadLogFiles,
                    tooltip: 'Atualizar',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _working ? null : _exportBundle,
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Exportar Bundle Diagnóstico'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'OCR Sandbox',
            children: [
              const Text(
                'Teste OCR por imagem ou simule o parser com texto bruto.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => context.push('/dev/ocr-sandbox'),
                icon: const Icon(Icons.document_scanner),
                label: const Text('Abrir OCR Sandbox'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Gerar Dados de Teste',
            children: [
              if (_working) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      _ActionChip(
                        'Turno aberto',
                        () => _generator.createOpenShift(),
                      ),
                      _ActionChip(
                        'Turno fechado',
                        () => _generator.createClosedShift(),
                      ),
                      _ActionChip(
                        'Rota vazia',
                        () => _generator.createEmptyRoute(),
                      ),
                      _ActionChip(
                        'Rota ativa',
                        () => _generator.createActiveRoute(),
                      ),
                      _ActionChip(
                        'Rota concluída',
                        () => _generator.createCompletedRoute(),
                      ),
                      _ActionChip(
                        'Entrega manual',
                        () => _generator.createManualDelivery(),
                      ),
                      _ActionChip(
                        'Entrega OCR',
                        () => _generator.createOcrDelivery(),
                      ),
                      _ActionChip(
                        'Entrega iFood',
                        () => _generator.createIfoodDelivery(),
                      ),
                      _ActionChip(
                        'Rota mista',
                        () => _generator.createMixedRoute(),
                      ),
                      _ActionChip(
                        'Histórico 1d',
                        () => _generator.createHistoryDays(1),
                      ),
                      _ActionChip(
                        'Histórico 7d',
                        () => _generator.createHistoryDays(7),
                      ),
                      _ActionChip(
                        'Histórico 30d',
                        () => _generator.createHistoryDays(30),
                      ),
                    ].map((item) {
                      return ActionChip(
                        label: Text(item.label),
                        onPressed: _working
                            ? null
                            : () => _runAction(
                                successMessage: '${item.label} gerado.',
                                action: () async {
                                  await item.action();
                                },
                              ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
              _CleanupButton(
                label: 'Excluir Entregas de Teste',
                icon: Icons.local_shipping_outlined,
                working: _working,
                onPressed: _cleanupDeliveries,
              ),
              _CleanupButton(
                label: 'Excluir Rotas de Teste',
                icon: Icons.route_outlined,
                working: _working,
                onPressed: _cleanupRoutes,
              ),
              _CleanupButton(
                label: 'Excluir Histórico de Teste',
                icon: Icons.history_outlined,
                working: _working,
                onPressed: _cleanupHistory,
              ),
              _CleanupButton(
                label: 'Limpeza Completa de Simulação',
                icon: Icons.cleaning_services_outlined,
                working: _working,
                onPressed: _cleanupGenerated,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Checklist de Validação',
            children: const [
              _CheckItem('OCR com imagem boa'),
              _CheckItem('OCR com imagem ruim → popup recovery'),
              _CheckItem('Parser bruto → campos extraídos'),
              _CheckItem('Log Viewer → filtros e busca'),
              _CheckItem('Session Explorer → linha do tempo por SID'),
              _CheckItem('Diagnostics → banco, runtime e release'),
              _CheckItem('Bundle → JSON compartilhável'),
              _CheckItem('Dados gerados → marcados com [DEVTOOLS]'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }
}

class _CleanupButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool working;
  final VoidCallback onPressed;

  const _CleanupButton({
    required this.label,
    required this.icon,
    required this.working,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: working ? null : onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;

  const _CheckItem(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            Icons.check_box_outline_blank,
            size: 18,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _ActionChip {
  final String label;
  final Future<Object?> Function() action;

  const _ActionChip(this.label, this.action);
}

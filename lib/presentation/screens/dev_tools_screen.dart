import 'dart:io';

import 'package:controle_entregas/application/shifts/shift_notifier.dart';
import 'package:controle_entregas/core/logging/log_storage.dart';
import 'package:controle_entregas/core/monitoring/build_info.dart';
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
  List<_LogFileInfo> _logFiles = [];
  bool _loadingFiles = false;
  bool _generatingData = false;
  Map<String, dynamic> _buildMeta = {};

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
      final dir = await getApplicationDocumentsDirectory();
      final files = <_LogFileInfo>[];
      for (final name in [
        'deliveryflow.log',
        'deliveryflow.1.log',
        'deliveryflow.2.log',
      ]) {
        final f = File('${dir.path}/$name');
        if (await f.exists()) {
          final size = await f.length();
          files.add(_LogFileInfo(name: name, sizeBytes: size));
        }
      }
      setState(() {
        _logFiles = files;
        _loadingFiles = false;
      });
    } catch (_) {
      setState(() => _loadingFiles = false);
    }
  }

  Future<void> _exportLogs() async {
    await AppLogger.exportLogs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Logs exportados.'),
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar todos os logs?'),
        content: const Text(
            'Todos os arquivos de log serão deletados permanentemente.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Limpar')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await LogStorage.close();
      final dir = await getApplicationDocumentsDirectory();
      for (final name in [
        'deliveryflow.log',
        'deliveryflow.1.log',
        'deliveryflow.2.log',
      ]) {
        final f = File('${dir.path}/$name');
        if (await f.exists()) await f.delete();
      }
      await LogStorage.init();
      await _loadLogFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Logs apagados.'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  /// Generates 7 historical entries for the last 7 days (test data).
  Future<void> _generateTestHistory() async {
    setState(() => _generatingData = true);
    try {
      final notifier =
          ref.read(historicalEntryNotifierProvider.notifier);
      final now = DateTime.now();
      final testDays = [
        (days: 1, deliveries: 22, earnings: 17600, note: 'Teste domingo'),
        (days: 2, deliveries: 18, earnings: 14400, note: 'Teste sábado'),
        (days: 3, deliveries: 25, earnings: 20000, note: 'Teste sexta'),
        (days: 4, deliveries: 15, earnings: 12000, note: 'Teste quinta'),
        (days: 5, deliveries: 20, earnings: 16000, note: 'Teste quarta'),
        (days: 6, deliveries: 30, earnings: 24000, note: 'Teste terça'),
        (days: 7, deliveries: 28, earnings: 22400, note: 'Teste segunda'),
      ];
      for (final d in testDays) {
        await notifier.save(
          date: now.subtract(Duration(days: d.days)),
          deliveryCount: d.deliveries,
          earningsCents: d.earnings,
          hoursWorked: 8.0,
          notes: d.note,
        );
      }
      AppLogger.info(LogEvents.testDataGenerated,
          module: 'DevToolsScreen',
          metadata: {'type': 'history', 'count': testDays.length});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('7 entradas de teste criadas.'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── App info ────────────────────────────────────────────────────
          _Section(
            title: 'Build Info',
            children: _buildMeta.isEmpty
                ? const [SizedBox(height: 20, child: LinearProgressIndicator())]
                : [
                    _InfoRow('Versão',
                        '${_buildMeta['version_name']} (${_buildMeta['version_code']})'),
                    _InfoRow('Build type',
                        '${_buildMeta['build_type']}'),
                    _InfoRow('Dispositivo',
                        '${_buildMeta['manufacturer']} ${_buildMeta['device_model']}'),
                    _InfoRow('Android',
                        '${_buildMeta['android_release']} (API ${_buildMeta['android_sdk']})'),
                    _InfoRow('OS Version',
                        '${_buildMeta['os_version']}'.length > 40
                            ? '${_buildMeta['os_version']}'.substring(0, 40)
                            : '${_buildMeta['os_version']}'),
                  ],
          ),
          const SizedBox(height: 16),

          // ── Log files ────────────────────────────────────────────────────
          _Section(
            title: 'Log Files',
            children: [
              if (_loadingFiles)
                const CircularProgressIndicator()
              else if (_logFiles.isEmpty)
                const Text('Nenhum arquivo de log encontrado.',
                    style: TextStyle(fontSize: 13))
              else
                ..._logFiles.map((f) => _InfoRow(
                      f.name,
                      '${(f.sizeBytes / 1024).toStringAsFixed(1)} KB',
                    )),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _exportLogs,
                      icon: const Icon(Icons.upload),
                      label: const Text('Exportar'),
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
            ],
          ),
          const SizedBox(height: 16),

          // ── OCR Sandbox ──────────────────────────────────────────────────
          _Section(
            title: 'OCR Sandbox',
            children: [
              const Text(
                'Teste o OCR em qualquer imagem sem criar uma rota real.',
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

          // ── Test data generators ─────────────────────────────────────────
          _Section(
            title: 'Gerar Dados de Teste',
            children: [
              const Text(
                'Cria registros históricos dos últimos 7 dias para validar '
                'relatórios e totais no histórico.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _generatingData ? null : _generateTestHistory,
                icon: _generatingData
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_chart),
                label: const Text('Gerar 7 dias de histórico'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Validation checklist ─────────────────────────────────────────
          _Section(
            title: 'Checklist de Validação',
            children: [
              _CheckItem('OCR com imagem boa'),
              _CheckItem('OCR com imagem ruim → popup recovery'),
              _CheckItem('Importar da galeria → OCR pipeline'),
              _CheckItem('Entrada manual → localizador obrigatório'),
              _CheckItem('Fechar turno → dialog pré-encerramento'),
              _CheckItem('Código localizador visível na tela de entrega'),
              _CheckItem('Copiar localizador → clipboard + snackbar'),
              _CheckItem('Abrir iFood → localizador já copiado'),
              _CheckItem('Histórico → turnos abertos aparecem'),
              _CheckItem('Exportar logs → arquivo JSONL legível'),
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
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontSize: 13)),
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
          Icon(Icons.check_box_outline_blank,
              size: 18, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _LogFileInfo {
  final String name;
  final int sizeBytes;
  const _LogFileInfo({required this.name, required this.sizeBytes});
}

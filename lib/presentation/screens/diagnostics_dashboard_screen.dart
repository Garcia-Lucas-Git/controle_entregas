import 'package:controle_entregas/core/devtools/diagnostic_bundle_service.dart';
import 'package:controle_entregas/core/devtools/diagnostics_service.dart';
import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DiagnosticsDashboardScreen extends ConsumerStatefulWidget {
  const DiagnosticsDashboardScreen({super.key});

  @override
  ConsumerState<DiagnosticsDashboardScreen> createState() =>
      _DiagnosticsDashboardScreenState();
}

class _DiagnosticsDashboardScreenState
    extends ConsumerState<DiagnosticsDashboardScreen> {
  DiagnosticsSnapshot? _snapshot;
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final db = ref.read(appDatabaseProvider);
    final snapshot = await DiagnosticsService(db).collect();
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  Future<void> _exportBundle() async {
    setState(() => _exporting = true);
    try {
      await DiagnosticBundleService(ref.read(appDatabaseProvider)).export();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bundle diagnóstico exportado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _loading || snapshot == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Section(title: 'Build', data: snapshot.build),
                _Section(title: 'Logging', data: snapshot.logging),
                _Section(title: 'Database', data: snapshot.database),
                _Section(title: 'Runtime', data: snapshot.runtime),
                _Section(title: 'Release', data: snapshot.release),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _exporting ? null : _exportBundle,
                  icon: _exporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.archive_outlined),
                  label: const Text('Exportar Bundle Diagnóstico'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;

  const _Section({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...data.entries.map(
              (entry) =>
                  _InfoRow(label: entry.key, value: _format(entry.value)),
            ),
          ],
        ),
      ),
    );
  }

  String _format(Object? value) {
    if (value is List) return '${value.length} itens';
    return value?.toString() ?? 'n/a';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

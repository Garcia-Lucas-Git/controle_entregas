import 'package:controle_entregas/core/devtools/log_reader_service.dart';
import 'package:flutter/material.dart';

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  DevLogReadResult? _result;
  String _severity = 'ALL';
  String _module = 'ALL';
  String _event = 'ALL';
  String _session = 'ALL';
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await LogReaderService.readLogs();
    if (!mounted) return;
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final entries = result == null
        ? <DevLogEntry>[]
        : LogReaderService.filter(
            result.entries,
            severity: _severity,
            module: _module,
            event: _event,
            sessionId: _session,
            query: _query,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Viewer'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _Filters(
                  result: result!,
                  severity: _severity,
                  module: _module,
                  event: _event,
                  session: _session,
                  onSeverity: (v) => setState(() => _severity = v),
                  onModule: (v) => setState(() => _module = v),
                  onEvent: (v) => setState(() => _event = v),
                  onSession: (v) => setState(() => _session = v),
                  onQuery: (v) => setState(() => _query = v),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${entries.length} eventos · '
                          '${result.malformedLines} inválidos · '
                          '${result.skippedLines} protegidos',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? const Center(child: Text('Nenhum log encontrado.'))
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) =>
                              _LogTile(entry: entries[index]),
                        ),
                ),
              ],
            ),
    );
  }
}

class _Filters extends StatelessWidget {
  final DevLogReadResult result;
  final String severity;
  final String module;
  final String event;
  final String session;
  final ValueChanged<String> onSeverity;
  final ValueChanged<String> onModule;
  final ValueChanged<String> onEvent;
  final ValueChanged<String> onSession;
  final ValueChanged<String> onQuery;

  const _Filters({
    required this.result,
    required this.severity,
    required this.module,
    required this.event,
    required this.session,
    required this.onSeverity,
    required this.onModule,
    required this.onEvent,
    required this.onSession,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    final severities = _options(result.entries.map((e) => e.severity));
    final modules = _options(result.entries.map((e) => e.module));
    final events = _options(result.entries.map((e) => e.event));
    final sessions = _options(result.entries.map((e) => e.sessionId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: onQuery,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Drop(
                label: 'Sev',
                value: severity,
                values: severities,
                onChanged: onSeverity,
              ),
              _Drop(
                label: 'Módulo',
                value: module,
                values: modules,
                onChanged: onModule,
              ),
              _Drop(
                label: 'Evento',
                value: event,
                values: events,
                onChanged: onEvent,
              ),
              _Drop(
                label: 'SID',
                value: session,
                values: sessions,
                onChanged: onSession,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static List<String> _options(Iterable<String?> source) {
    final values =
        source.whereType<String>().where((v) => v.isNotEmpty).toSet().toList()
          ..sort();
    return ['ALL', ...values];
  }
}

class _Drop extends StatelessWidget {
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _Drop({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
        initialValue: values.contains(value) ? value : 'ALL',
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: values
            .map(
              (v) => DropdownMenuItem(
                value: v,
                child: Text(v, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (v) => onChanged(v ?? 'ALL'),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final DevLogEntry entry;

  const _LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = switch (entry.severity) {
      'CRITICAL' || 'ERROR' => Theme.of(context).colorScheme.error,
      'WARNING' => Colors.orange,
      _ => Theme.of(context).colorScheme.primary,
    };
    return ExpansionTile(
      leading: Icon(Icons.circle, size: 12, color: color),
      title: Text(entry.event, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        '${entry.timestamp.toLocal()} · ${entry.module}'
        '${entry.sessionId == null ? '' : ' · ${entry.sessionId}'}',
        style: const TextStyle(fontSize: 11),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SelectableText(
            entry.metadata?.toString() ?? entry.rawLine,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}

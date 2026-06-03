import 'package:controle_entregas/core/devtools/log_reader_service.dart';
import 'package:flutter/material.dart';

class SessionExplorerScreen extends StatefulWidget {
  const SessionExplorerScreen({super.key});

  @override
  State<SessionExplorerScreen> createState() => _SessionExplorerScreenState();
}

class _SessionExplorerScreenState extends State<SessionExplorerScreen> {
  List<SessionTimeline> _sessions = [];
  bool _loading = true;
  String _type = 'ALL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final logs = await LogReaderService.readLogs();
    if (!mounted) return;
    setState(() {
      _sessions = LogReaderService.groupSessions(logs.entries);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionTypes = _sessions.map((s) => s.type).toSet().toList()..sort();
    final types = ['ALL', ...sessionTypes];
    final sessions = _type == 'ALL'
        ? _sessions
        : _sessions.where((s) => s.type == _type).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Explorer'),
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de sessão',
                      border: OutlineInputBorder(),
                    ),
                    items: types
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _type = v ?? 'ALL'),
                  ),
                ),
                Expanded(
                  child: sessions.isEmpty
                      ? const Center(child: Text('Nenhuma sessão encontrada.'))
                      : ListView.builder(
                          itemCount: sessions.length,
                          itemBuilder: (context, index) =>
                              _SessionTile(session: sessions[index]),
                        ),
                ),
              ],
            ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionTimeline session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: CircleAvatar(
        radius: 18,
        child: Text(session.type.substring(0, 1)),
      ),
      title: Text(session.sessionId, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        '${session.entries.length} eventos · ${session.errorCount} erros · '
        '${session.startedAt.toLocal()}',
        style: const TextStyle(fontSize: 11),
      ),
      children: session.entries.reversed
          .map((entry) => _TimelineEvent(entry: entry))
          .toList(),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  final DevLogEntry entry;

  const _TimelineEvent({required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Text(
        entry.severity,
        style: TextStyle(
          fontSize: 10,
          color: entry.severity == 'ERROR' || entry.severity == 'CRITICAL'
              ? Theme.of(context).colorScheme.error
              : null,
        ),
      ),
      title: Text(entry.event, style: const TextStyle(fontSize: 13)),
      subtitle: SelectableText(
        '${entry.timestamp.toLocal()} · ${entry.module}\n'
        '${entry.metadata ?? {}}',
        style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
      ),
    );
  }
}

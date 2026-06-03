import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DevLogEntry {
  final DateTime timestamp;
  final String severity;
  final String module;
  final String event;
  final String? screen;
  final String? className;
  final String? method;
  final String? sessionId;
  final Map<String, dynamic>? metadata;
  final String sourceFile;
  final String rawLine;

  const DevLogEntry({
    required this.timestamp,
    required this.severity,
    required this.module,
    required this.event,
    required this.sourceFile,
    required this.rawLine,
    this.screen,
    this.className,
    this.method,
    this.sessionId,
    this.metadata,
  });

  String get searchableText => [
    severity,
    module,
    event,
    screen,
    className,
    method,
    sessionId,
    metadata?.toString(),
    rawLine,
  ].whereType<String>().join(' ').toLowerCase();

  static DevLogEntry? tryParse(String line, String sourceFile) {
    try {
      final decoded = jsonDecode(line);
      if (decoded is! Map<String, dynamic>) return null;
      final ts = DateTime.tryParse('${decoded['ts']}');
      if (ts == null) return null;
      final meta = decoded['meta'];
      return DevLogEntry(
        timestamp: ts,
        severity: '${decoded['sev'] ?? 'INFO'}',
        module: '${decoded['module'] ?? 'unknown'}',
        event: '${decoded['event'] ?? 'unknown'}',
        screen: decoded['screen'] as String?,
        className: decoded['class'] as String?,
        method: decoded['method'] as String?,
        sessionId: decoded['sid'] as String?,
        metadata: meta is Map<String, dynamic> ? meta : null,
        sourceFile: sourceFile,
        rawLine: line,
      );
    } catch (_) {
      return null;
    }
  }
}

class DevLogFileInfo {
  final String name;
  final int sizeBytes;

  const DevLogFileInfo({required this.name, required this.sizeBytes});
}

class DevLogReadResult {
  final List<DevLogEntry> entries;
  final List<DevLogFileInfo> files;
  final int malformedLines;
  final int skippedLines;

  const DevLogReadResult({
    required this.entries,
    required this.files,
    required this.malformedLines,
    required this.skippedLines,
  });
}

class SessionTimeline {
  final String sessionId;
  final String type;
  final List<DevLogEntry> entries;

  const SessionTimeline({
    required this.sessionId,
    required this.type,
    required this.entries,
  });

  DateTime get startedAt => entries.last.timestamp;
  DateTime get endedAt => entries.first.timestamp;
  int get errorCount => entries
      .where((e) => e.severity == 'ERROR' || e.severity == 'CRITICAL')
      .length;
}

abstract final class LogReaderService {
  static const _logNames = [
    'deliveryflow.log',
    'deliveryflow.1.log',
    'deliveryflow.2.log',
  ];
  static const int maxBytesPerFile = 1024 * 1024;
  static const int maxLinesPerFile = 5000;

  static Future<DevLogReadResult> readLogs() async {
    final dir = await getApplicationDocumentsDirectory();
    final entries = <DevLogEntry>[];
    final files = <DevLogFileInfo>[];
    var malformed = 0;
    var skipped = 0;

    for (final name in _logNames) {
      final file = File('${dir.path}/$name');
      if (!await file.exists()) continue;
      final size = await file.length();
      files.add(DevLogFileInfo(name: name, sizeBytes: size));

      final lines = await _readProtectedLines(file, size);
      skipped += lines.skipped;
      for (final line in lines.lines) {
        if (line.trim().isEmpty) continue;
        final parsed = DevLogEntry.tryParse(line, name);
        if (parsed == null) {
          malformed++;
        } else {
          entries.add(parsed);
        }
      }
    }

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return DevLogReadResult(
      entries: entries,
      files: files,
      malformedLines: malformed,
      skippedLines: skipped,
    );
  }

  static List<DevLogEntry> filter(
    List<DevLogEntry> entries, {
    String? severity,
    String? module,
    String? event,
    String? sessionId,
    String? query,
  }) {
    final q = query?.trim().toLowerCase();
    return entries.where((entry) {
      if (severity != null && severity != 'ALL' && entry.severity != severity) {
        return false;
      }
      if (module != null && module != 'ALL' && entry.module != module) {
        return false;
      }
      if (event != null && event != 'ALL' && entry.event != event) {
        return false;
      }
      if (sessionId != null &&
          sessionId != 'ALL' &&
          entry.sessionId != sessionId) {
        return false;
      }
      if (q != null && q.isNotEmpty && !entry.searchableText.contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  static List<SessionTimeline> groupSessions(List<DevLogEntry> entries) {
    final grouped = <String, List<DevLogEntry>>{};
    for (final entry in entries) {
      final sid = entry.sessionId;
      if (sid == null || sid.isEmpty) continue;
      grouped.putIfAbsent(sid, () => []).add(entry);
    }

    final timelines = grouped.entries.map((item) {
      final sessionEntries = item.value
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return SessionTimeline(
        sessionId: item.key,
        type: _sessionType(item.key),
        entries: sessionEntries,
      );
    }).toList();
    timelines.sort((a, b) => b.endedAt.compareTo(a.endedAt));
    return timelines;
  }

  static Future<_ProtectedLines> _readProtectedLines(
    File file,
    int size,
  ) async {
    final skippedBySize = size > maxBytesPerFile ? size - maxBytesPerFile : 0;
    final raf = await file.open();
    try {
      if (skippedBySize > 0) {
        await raf.setPosition(skippedBySize);
      }
      final bytes = await raf.read(maxBytesPerFile);
      final text = utf8.decode(bytes, allowMalformed: true);
      final lines = text.split('\n');
      if (skippedBySize > 0 && lines.isNotEmpty) {
        lines.removeAt(0);
      }
      final overflow = lines.length > maxLinesPerFile
          ? lines.length - maxLinesPerFile
          : 0;
      return _ProtectedLines(
        lines: lines.length > maxLinesPerFile
            ? lines.sublist(lines.length - maxLinesPerFile)
            : lines,
        skipped: (skippedBySize > 0 ? 1 : 0) + overflow,
      );
    } finally {
      await raf.close();
    }
  }

  static String _sessionType(String sid) {
    final idx = sid.indexOf('-');
    return idx == -1 ? 'OTHER' : sid.substring(0, idx);
  }
}

class _ProtectedLines {
  final List<String> lines;
  final int skipped;

  const _ProtectedLines({required this.lines, required this.skipped});
}

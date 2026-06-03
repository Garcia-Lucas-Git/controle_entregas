import 'dart:convert';

enum LogSeverity { verbose, info, warning, error, critical }

class LogEntry {
  final DateTime timestamp;
  final LogSeverity severity;
  final String module;
  final String event;
  final String? screen;
  final String? className;
  final String? method;
  final String? sessionId;
  final Map<String, dynamic>? metadata;

  const LogEntry({
    required this.timestamp,
    required this.severity,
    required this.module,
    required this.event,
    this.screen,
    this.className,
    this.method,
    this.sessionId,
    this.metadata,
  });

  String toJsonLine() {
    final map = <String, dynamic>{
      'ts': timestamp.toIso8601String(),
      'sev': severity.name.toUpperCase(),
      'module': module,
      'event': event,
    };
    if (screen != null) map['screen'] = screen;
    if (className != null) map['class'] = className;
    if (method != null) map['method'] = method;
    if (sessionId != null) map['sid'] = sessionId;
    if (metadata != null && metadata!.isNotEmpty) map['meta'] = metadata;
    return jsonEncode(map);
  }
}

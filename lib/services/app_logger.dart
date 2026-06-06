import 'dart:developer' as dev;

import 'package:controle_entregas/core/logging/log_entry.dart';
import 'package:controle_entregas/core/logging/log_storage.dart';

export 'package:controle_entregas/core/logging/log_entry.dart' show LogSeverity;
export 'package:controle_entregas/core/logging/log_events.dart';
export 'package:controle_entregas/core/logging/session_manager.dart';

/// Public logging API.
///
/// All writes are async (queued via [LogStorage]).
/// Never throws. Never blocks UI.
/// Output: JSONL files at `<documents>/YYYY-MM-DD_HH.log`.
abstract final class AppLogger {
  static Future<void> init() => LogStorage.init();

  static Future<void> exportLogs({bool lastFourHours = true}) =>
      LogStorage.export(lastFourHours: lastFourHours);

  // ── Primary write method ──────────────────────────────────────────────────

  static void log(
    String event, {
    LogSeverity severity = LogSeverity.info,
    required String module,
    String? screen,
    String? className,
    String? method,
    String? sessionId,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    try {
      final enriched = <String, dynamic>{
        ...?metadata,
        if (error != null) 'error': error.toString(),
        if (stackTrace != null)
          'stack_trace': stackTrace.toString().split('\n').take(12).join('\n'),
      };
      final entry = LogEntry(
        timestamp: DateTime.now().toUtc(),
        severity: severity,
        module: module,
        event: event,
        screen: screen,
        className: className,
        method: method,
        sessionId: sessionId,
        metadata: enriched.isEmpty ? null : enriched,
      );
      final line = entry.toJsonLine();
      LogStorage.enqueue(line);
      dev.log(line, name: 'DeliveryFlow');
    } catch (_) {}
  }

  // ── Convenience wrappers ──────────────────────────────────────────────────

  static void verbose(
    String event, {
    required String module,
    String? screen,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) => log(
    event,
    severity: LogSeverity.verbose,
    module: module,
    screen: screen,
    sessionId: sessionId,
    metadata: metadata,
  );

  static void info(
    String event, {
    required String module,
    String? screen,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) => log(
    event,
    severity: LogSeverity.info,
    module: module,
    screen: screen,
    sessionId: sessionId,
    metadata: metadata,
  );

  static void warn(
    String event, {
    required String module,
    String? screen,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) => log(
    event,
    severity: LogSeverity.warning,
    module: module,
    screen: screen,
    sessionId: sessionId,
    metadata: metadata,
  );

  static void error(
    String event, {
    required String module,
    String? screen,
    String? className,
    String? method,
    String? sessionId,
    Map<String, dynamic>? metadata,
    Object? exception,
    StackTrace? stackTrace,
  }) => log(
    event,
    severity: LogSeverity.error,
    module: module,
    screen: screen,
    className: className,
    method: method,
    sessionId: sessionId,
    metadata: metadata,
    error: exception,
    stackTrace: stackTrace,
  );

  static void critical(
    String event, {
    required String module,
    String? screen,
    String? sessionId,
    Map<String, dynamic>? metadata,
    Object? exception,
    StackTrace? stackTrace,
  }) => log(
    event,
    severity: LogSeverity.critical,
    module: module,
    screen: screen,
    sessionId: sessionId,
    metadata: metadata,
    error: exception,
    stackTrace: stackTrace,
  );
}

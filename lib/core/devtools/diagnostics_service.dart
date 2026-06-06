import 'package:controle_entregas/core/devtools/log_reader_service.dart';
import 'package:controle_entregas/core/monitoring/build_info.dart';
import 'package:controle_entregas/core/monitoring/network_monitor.dart';
import 'package:controle_entregas/data/database/app_database.dart';

class DiagnosticsSnapshot {
  final Map<String, dynamic> build;
  final Map<String, dynamic> logging;
  final Map<String, dynamic> database;
  final Map<String, dynamic> runtime;
  final Map<String, dynamic> release;

  const DiagnosticsSnapshot({
    required this.build,
    required this.logging,
    required this.database,
    required this.runtime,
    required this.release,
  });

  Map<String, dynamic> toJson() => {
    'build': build,
    'logging': logging,
    'database': database,
    'runtime': runtime,
    'release': release,
  };
}

class DiagnosticsService {
  final AppDatabase _db;

  const DiagnosticsService(this._db);

  Future<DiagnosticsSnapshot> collect() async {
    final build = await BuildInfo.collect();
    final logs = await LogReaderService.readLogs();
    final network = NetworkMonitor.snapshot();
    final dbSummary = await _databaseSummary();
    final release = await ReleaseDiagnostics.checkBuildArtifacts('.');

    final lastOcr = logs.entries
        .where((e) => e.event.startsWith('OCR_'))
        .map((e) => e.timestamp)
        .firstOrNull;
    final lastCrash = logs.entries
        .where(
          (e) =>
              e.event == 'APP_UNCAUGHT_FLUTTER_ERROR' ||
              e.event == 'APP_UNCAUGHT_PLATFORM_ERROR' ||
              e.severity == 'CRITICAL',
        )
        .map((e) => e.timestamp)
        .firstOrNull;

    return DiagnosticsSnapshot(
      build: build,
      logging: {
        'files': logs.files
            .map((f) => {'name': f.name, 'size_bytes': f.sizeBytes})
            .toList(),
        'current_file_size': logs.files.isEmpty
            ? null
            : logs.files.first.sizeBytes,
        'hourly_count': logs.files
            .where(
              (f) => RegExp(r'^\d{4}-\d{2}-\d{2}_\d{2}\.log$').hasMatch(f.name),
            )
            .length,
        'entry_count': logs.entries.length,
        'malformed_lines': logs.malformedLines,
        'skipped_lines': logs.skippedLines,
        'healthy': logs.malformedLines == 0,
      },
      database: dbSummary,
      runtime: {
        'network_started': network.started,
        'network_online': network.online,
        'last_latency_ms': network.latencyMs,
        'network_checked_at': network.checkedAt?.toIso8601String(),
        'last_ocr_execution': lastOcr?.toIso8601String(),
        'last_crash_timestamp': lastCrash?.toIso8601String(),
      },
      release: release,
    );
  }

  Future<Map<String, dynamic>> _databaseSummary() async {
    return {
      'schema_version': _db.schemaVersion,
      'shift_count': await _count('shifts'),
      'route_count': await _count('routes'),
      'delivery_count': await _count('deliveries'),
      'receipt_count': await _count('receipts'),
      'earnings_entry_count': await _count('earnings_entries'),
    };
  }

  Future<int> _count(String table) async {
    final row = await _db
        .customSelect('select count(*) as c from $table')
        .getSingle();
    return row.data['c'] as int? ?? 0;
  }
}

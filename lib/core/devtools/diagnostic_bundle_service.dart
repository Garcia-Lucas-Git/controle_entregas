import 'dart:convert';
import 'dart:typed_data';

import 'package:controle_entregas/core/devtools/diagnostics_service.dart';
import 'package:controle_entregas/core/devtools/log_reader_service.dart';
import 'package:controle_entregas/data/database/app_database.dart';
import 'package:share_plus/share_plus.dart';

class DiagnosticBundleService {
  final AppDatabase _db;

  const DiagnosticBundleService(this._db);

  Future<void> export() async {
    final diagnostics = await DiagnosticsService(_db).collect();
    final logs = await LogReaderService.readLogs();
    final payload = const JsonEncoder.withIndent('  ').convert({
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'diagnostics': diagnostics.toJson(),
      'logs': logs.entries
          .map(
            (e) => {
              'ts': e.timestamp.toIso8601String(),
              'sev': e.severity,
              'module': e.module,
              'event': e.event,
              if (e.screen != null) 'screen': e.screen,
              if (e.className != null) 'class': e.className,
              if (e.method != null) 'method': e.method,
              if (e.sessionId != null) 'sid': e.sessionId,
              if (e.metadata != null) 'meta': e.metadata,
              'source': e.sourceFile,
            },
          )
          .toList(),
    });

    await Share.shareXFiles([
      XFile.fromData(
        Uint8List.fromList(utf8.encode(payload)),
        name: 'deliveryflow_diagnostic_bundle.json',
        mimeType: 'application/json',
      ),
    ], subject: 'DeliveryFlow - Diagnostic Bundle');
  }
}

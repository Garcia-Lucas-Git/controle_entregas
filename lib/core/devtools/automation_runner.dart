import 'dart:io';

import 'package:controle_entregas/core/devtools/automation_fixture_service.dart';
import 'package:controle_entregas/core/devtools/automation_result.dart';
import 'package:controle_entregas/core/devtools/diagnostics_service.dart';
import 'package:controle_entregas/core/devtools/log_reader_service.dart';
import 'package:controle_entregas/core/logging/log_storage.dart';
import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:controle_entregas/services/ocr_service.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class AutomationRunner {
  static const suite = 'smoke';
  static const marker = '[DEVTOOLS_AUTOMATION]';

  final AppDatabase _db;
  final AutomationFixtureService _fixtures;
  String _activeRunId = '';

  AutomationRunner(this._db, {AutomationFixtureService? fixtures})
    : _fixtures = fixtures ?? AutomationFixtureService();

  Future<AutomationRunResult> runSmoke() async {
    final runId = 'AUTO-${DateTime.now().millisecondsSinceEpoch}';
    final startedAt = DateTime.now().toUtc();
    _activeRunId = runId;
    final tests = <AutomationTestResult>[];
    final ocrFixtures = <AutomationOcrFixtureResult>[];
    var reportPath = '';

    _log(
      LogEvents.automationRunStart,
      runId: runId,
      test: 'run',
      durationMs: 0,
    );

    try {
      tests.add(await _runTest(runId, 'app_health', _appHealth));
      tests.add(await _runTest(runId, 'database_health', _databaseHealth));
      tests.add(await _runTest(runId, 'fixture_discovery', _fixtureDiscovery));
      final ocrResult = await _runOcrFixtureProcessing(runId);
      tests.add(ocrResult.test);
      ocrFixtures.addAll(ocrResult.fixtures);
      tests.add(await _runTest(runId, 'parser_fixture_health', _parserHealth));
      tests.add(
        await _runTest(runId, 'delivery_lifecycle', _deliveryLifecycle),
      );
      tests.add(await _runTest(runId, 'history_health', _historyHealth));
      tests.add(await _runTest(runId, 'log_health', _logHealth));

      await LogStorage.flush();
      final criticalErrors = await _criticalErrorsSince(startedAt);
      final finishedAt = DateTime.now().toUtc();
      final result = AutomationRunResult(
        runId: runId,
        startedAt: startedAt,
        finishedAt: finishedAt,
        tests: tests,
        ocrFixtures: ocrFixtures,
        criticalErrors: criticalErrors,
        reportPath: '',
      );
      reportPath = await _writeReport(result);
      final finalResult = AutomationRunResult(
        runId: runId,
        startedAt: startedAt,
        finishedAt: finishedAt,
        tests: tests,
        ocrFixtures: ocrFixtures,
        criticalErrors: criticalErrors,
        reportPath: reportPath,
      );

      _log(
        LogEvents.automationReportGenerated,
        runId: runId,
        test: 'report',
        durationMs: finalResult.duration.inMilliseconds,
        metadata: {'path': reportPath},
      );
      _log(
        finalResult.passed
            ? LogEvents.automationRunComplete
            : LogEvents.automationRunFail,
        runId: runId,
        test: 'run',
        durationMs: finalResult.duration.inMilliseconds,
        severity: finalResult.passed ? LogSeverity.info : LogSeverity.warning,
        metadata: {
          'pass': finalResult.passCount,
          'partial': finalResult.partialCount,
          'fail': finalResult.failCount,
          'skipped': finalResult.skippedCount,
        },
      );
      return finalResult;
    } catch (e, st) {
      final finishedAt = DateTime.now().toUtc();
      _log(
        LogEvents.automationRunFail,
        runId: runId,
        test: 'run',
        durationMs: finishedAt.difference(startedAt).inMilliseconds,
        severity: LogSeverity.error,
        metadata: {'error': e.toString(), 'stack': st.toString()},
      );
      rethrow;
    }
  }

  Future<AutomationTestResult> _runTest(
    String runId,
    String name,
    Future<Map<String, dynamic>> Function() body,
  ) async {
    final start = DateTime.now();
    _log(
      LogEvents.automationTestStart,
      runId: runId,
      test: name,
      durationMs: 0,
    );
    try {
      final metadata = await body();
      final durationMs = DateTime.now().difference(start).inMilliseconds;
      _log(
        LogEvents.automationTestPass,
        runId: runId,
        test: name,
        durationMs: durationMs,
        metadata: metadata,
      );
      return AutomationTestResult(
        name: name,
        status: AutomationStatus.pass,
        durationMs: durationMs,
        metadata: metadata,
      );
    } catch (e) {
      final durationMs = DateTime.now().difference(start).inMilliseconds;
      _log(
        LogEvents.automationTestFail,
        runId: runId,
        test: name,
        durationMs: durationMs,
        severity: LogSeverity.error,
        metadata: {'error': e.toString()},
      );
      return AutomationTestResult(
        name: name,
        status: AutomationStatus.fail,
        durationMs: durationMs,
        message: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> _appHealth() async {
    await DiagnosticsService(_db).collect();
    await LogStorage.flush();
    final logs = await LogReaderService.readLogs();
    final latest = logs.entries.take(80);
    final startupErrors = latest
        .where(
          (e) =>
              e.event == LogEvents.appFlutterError ||
              e.event == LogEvents.appPlatformError,
        )
        .toList();
    if (startupErrors.isNotEmpty) {
      throw StateError('Startup exception found in latest logs.');
    }
    return {'latest_log_entries_checked': latest.length};
  }

  Future<Map<String, dynamic>> _databaseHealth() async {
    final counts = await _tableCounts();
    return {'schema_version': _db.schemaVersion, ...counts};
  }

  Future<Map<String, dynamic>> _fixtureDiscovery() async {
    final dir = await _fixtures.fixtureDirectory();
    final start = DateTime.now();
    _log(
      LogEvents.automationFixtureDirCheck,
      runId: _activeRunId,
      test: 'fixture_discovery',
      durationMs: 0,
      metadata: {'path': dir.path},
    );
    final files = await _fixtures.discoverImages();
    final durationMs = DateTime.now().difference(start).inMilliseconds;
    if (files.isEmpty) {
      _log(
        LogEvents.automationFixtureMissing,
        runId: _activeRunId,
        test: 'fixture_discovery',
        durationMs: durationMs,
        severity: LogSeverity.warning,
        metadata: {'path': dir.path, 'count': 0},
      );
      throw StateError('No image fixtures found at ${dir.path}');
    }
    _log(
      LogEvents.automationFixtureFound,
      runId: _activeRunId,
      test: 'fixture_discovery',
      durationMs: durationMs,
      metadata: {'path': dir.path, 'count': files.length},
    );
    return {'path': dir.path, 'count': files.length};
  }

  Future<_OcrFixtureSuiteResult> _runOcrFixtureProcessing(String runId) async {
    final start = DateTime.now();
    final fixtureResults = <AutomationOcrFixtureResult>[];
    final files = await _fixtures.discoverImages();
    if (files.isEmpty) {
      _log(
        LogEvents.automationTestFail,
        runId: runId,
        test: 'ocr_fixture_processing',
        durationMs: 0,
        severity: LogSeverity.error,
        metadata: {'error': 'No fixtures found.'},
      );
      return _OcrFixtureSuiteResult(
        test: AutomationTestResult(
          name: 'ocr_fixture_processing',
          status: AutomationStatus.fail,
          durationMs: 0,
          message: 'No fixtures found.',
        ),
        fixtures: fixtureResults,
      );
    }

    final service = OcrService();
    var rawTextSuccess = 0;
    var locatorSuccess = 0;
    try {
      for (final file in files) {
        final itemStart = DateTime.now();
        _log(
          LogEvents.automationOcrFixtureStart,
          runId: runId,
          test: 'ocr_fixture_processing',
          durationMs: 0,
          metadata: {'file': file.path},
        );
        try {
          final result = await service.processImage(file.path);
          final durationMs = DateTime.now()
              .difference(itemStart)
              .inMilliseconds;
          final locator =
              result.partnerCollectionCode ?? result.deliveryIdentifier;
          final missing = <String>[];
          if (!result.hasRequiredFields) missing.add('address');
          if (locator == null || locator.isEmpty) missing.add('locator');
          if (result.rawText.isNotEmpty) rawTextSuccess++;
          if (locator != null && locator.isNotEmpty) locatorSuccess++;
          final fixtureResult = AutomationOcrFixtureResult(
            fileName: file.uri.pathSegments.last,
            status: AutomationStatus.pass,
            rawTextLength: result.rawText.length,
            locator: locator,
            addressFound: result.hasRequiredFields,
            durationMs: durationMs,
            missingFields: missing,
          );
          fixtureResults.add(fixtureResult);
          _log(
            LogEvents.automationOcrFixturePass,
            runId: runId,
            test: 'ocr_fixture_processing',
            durationMs: durationMs,
            metadata: _ocrMetadata(file, fixtureResult),
          );
        } catch (e) {
          final durationMs = DateTime.now()
              .difference(itemStart)
              .inMilliseconds;
          final fixtureResult = AutomationOcrFixtureResult(
            fileName: file.uri.pathSegments.last,
            status: AutomationStatus.fail,
            rawTextLength: 0,
            locator: null,
            addressFound: false,
            durationMs: durationMs,
            missingFields: const ['raw_text', 'locator'],
            message: e.toString(),
          );
          fixtureResults.add(fixtureResult);
          _log(
            LogEvents.automationOcrFixtureFail,
            runId: runId,
            test: 'ocr_fixture_processing',
            durationMs: durationMs,
            severity: LogSeverity.error,
            metadata: _ocrMetadata(file, fixtureResult),
          );
        }
      }
    } finally {
      await service.dispose();
    }

    final durationMs = DateTime.now().difference(start).inMilliseconds;
    final status = rawTextSuccess > 0 && locatorSuccess > 0
        ? AutomationStatus.pass
        : rawTextSuccess > 0
        ? AutomationStatus.partial
        : AutomationStatus.fail;
    _log(
      status == AutomationStatus.fail
          ? LogEvents.automationTestFail
          : LogEvents.automationTestPass,
      runId: runId,
      test: 'ocr_fixture_processing',
      durationMs: durationMs,
      severity: status == AutomationStatus.fail
          ? LogSeverity.error
          : status == AutomationStatus.partial
          ? LogSeverity.warning
          : LogSeverity.info,
      metadata: {
        'fixture_count': files.length,
        'raw_text_success': rawTextSuccess,
        'locator_success': locatorSuccess,
        'status': status.label,
      },
    );
    return _OcrFixtureSuiteResult(
      test: AutomationTestResult(
        name: 'ocr_fixture_processing',
        status: status,
        durationMs: durationMs,
        metadata: {
          'fixture_count': files.length,
          'raw_text_success': rawTextSuccess,
          'locator_success': locatorSuccess,
        },
      ),
      fixtures: fixtureResults,
    );
  }

  Future<Map<String, dynamic>> _parserHealth() async {
    final fixtures = [
      'CLIENTE: Ana\nENDERECO: Rua Um, 123\nCOD: ABC1234',
      'Pedido 98765\nLocalizador:\nZXCV9876\nEndereco: Avenida Dois, 45',
      'COD #AA9988\nTROCO R\$ 20,00',
    ];
    var locatorCount = 0;
    var addressCount = 0;
    for (final text in fixtures) {
      final result = OcrService.parseRawText(text);
      final locator = result.partnerCollectionCode ?? result.deliveryIdentifier;
      if (locator != null && locator.isNotEmpty) locatorCount++;
      if (result.hasRequiredFields) addressCount++;
    }
    if (locatorCount < 2 || addressCount < 2) {
      throw StateError(
        'Parser fixtures failed: locator=$locatorCount address=$addressCount',
      );
    }
    return {
      'fixture_count': fixtures.length,
      'locator_count': locatorCount,
      'address_count': addressCount,
    };
  }

  Future<Map<String, dynamic>> _deliveryLifecycle() async {
    await _cleanupAutomationData();
    final now = DateTime.now().toUtc().toIso8601String();
    final shiftId = await _db.shiftsDao.insertShift(
      ShiftsTableCompanion(
        driverName: Value('$marker Runner'),
        startedAt: Value(now),
        status: const Value('open'),
        notes: Value('$marker smoke lifecycle'),
        source: const Value('automation'),
        createdAt: Value(now),
      ),
    );
    final routeId = await _db.routesDao.insertRoute(
      RoutesTableCompanion(
        shiftId: Value(shiftId),
        routeNumber: const Value(1),
        status: const Value('open'),
        startedAt: Value(now),
        createdAt: Value(now),
      ),
    );
    final deliveryId = await _db.deliveriesDao.insertDelivery(
      DeliveriesTableCompanion(
        routeId: Value(routeId),
        shiftId: Value(shiftId),
        sequenceNumber: const Value(1),
        addressText: Value('$marker Rua Smoke, 123'),
        customerName: Value('$marker Cliente'),
        partnerCollectionCode: const Value('AUTO1234'),
        createdAt: Value(now),
      ),
    );
    await _db.deliveriesDao.completeDelivery(
      id: deliveryId,
      completedAt: DateTime.now().toUtc().toIso8601String(),
      distanceKm: 1.2,
    );
    final readBack = await _db.deliveriesDao.getDeliveryById(deliveryId);
    if (readBack == null || readBack.status != 'completed') {
      throw StateError('Completed automation delivery was not readable.');
    }
    return {
      'shift_id': shiftId,
      'route_id': routeId,
      'delivery_id': deliveryId,
      'status': readBack.status,
    };
  }

  Future<Map<String, dynamic>> _historyHealth() async {
    final shifts = await _db.shiftsDao.watchAllShifts().first;
    final open = shifts.where((s) => s.status == 'open').length;
    final closed = shifts.where((s) => s.status == 'closed').length;
    final month = DateFormat('MMMM yyyy', 'pt_BR').format(DateTime.now());
    return {
      'shift_count': shifts.length,
      'open_count': open,
      'closed_count': closed,
      'locale_sample': month,
    };
  }

  Future<Map<String, dynamic>> _logHealth() async {
    _log(
      LogEvents.automationTestStart,
      runId: _activeRunId,
      test: 'log_health_marker',
      durationMs: 0,
    );
    await LogStorage.flush();
    final logs = await LogReaderService.readLogs();
    final automationEntries = logs.entries
        .where((e) => e.event.startsWith('AUTOMATION_'))
        .length;
    if (logs.entries.isEmpty || automationEntries == 0) {
      throw StateError('Automation logs were not readable.');
    }
    return {
      'log_entries': logs.entries.length,
      'automation_entries': automationEntries,
      'log_files': logs.files.length,
    };
  }

  Future<Map<String, int>> _tableCounts() async {
    return {
      'shifts': await _count('shifts'),
      'routes': await _count('routes'),
      'deliveries': await _count('deliveries'),
    };
  }

  Future<int> _count(String table) async {
    final row = await _db
        .customSelect('select count(*) as c from $table')
        .getSingle();
    return row.data['c'] as int? ?? 0;
  }

  Future<void> _cleanupAutomationData() async {
    await _db.customUpdate(
      "delete from shifts where driver_name like ? or coalesce(notes, '') like ?",
      variables: [Variable<String>('$marker%'), Variable<String>('%$marker%')],
    );
  }

  Future<List<String>> _criticalErrorsSince(DateTime startedAt) async {
    await LogStorage.flush();
    final logs = await LogReaderService.readLogs();
    return logs.entries
        .where(
          (e) =>
              e.timestamp.isAfter(startedAt) &&
              (e.event == LogEvents.appFlutterError ||
                  e.event == LogEvents.appPlatformError),
        )
        .map((e) => '${e.timestamp.toIso8601String()} ${e.event}')
        .toList();
  }

  Future<String> _writeReport(AutomationRunResult result) async {
    final dir = await _reportDirectory();
    await dir.create(recursive: true);
    final file = File('${dir.path}/latest_smoke_report.md');
    await file.writeAsString(_buildReport(result));
    return file.path;
  }

  Future<Directory> _reportDirectory() async {
    final external = await getExternalStorageDirectory();
    if (external != null) {
      return Directory('${external.path}/automation_reports');
    }
    final fallback = await getApplicationDocumentsDirectory();
    return Directory('${fallback.path}/automation_reports');
  }

  String _buildReport(AutomationRunResult result) {
    final buffer = StringBuffer()
      ..writeln('# DeliveryFlow Device Smoke Test')
      ..writeln()
      ..writeln('Run ID: ${result.runId}')
      ..writeln('Started: ${result.startedAt.toIso8601String()}')
      ..writeln('Finished: ${result.finishedAt.toIso8601String()}')
      ..writeln('Duration: ${result.duration.inMilliseconds} ms')
      ..writeln()
      ..writeln('## Summary')
      ..writeln()
      ..writeln('PASS: ${result.passCount}')
      ..writeln('PARTIAL: ${result.partialCount}')
      ..writeln('FAIL: ${result.failCount}')
      ..writeln('SKIPPED: ${result.skippedCount}')
      ..writeln()
      ..writeln('## Test Results')
      ..writeln();

    for (final test in result.tests) {
      buffer.writeln('- ${test.name}: ${test.status.label}');
    }

    buffer
      ..writeln()
      ..writeln('## OCR Fixture Results')
      ..writeln()
      ..writeln(
        'file | result | raw_text_length | locator | address_found | duration_ms',
      )
      ..writeln('--- | --- | ---: | --- | --- | ---:');
    for (final item in result.ocrFixtures) {
      buffer.writeln(
        '${item.fileName} | ${item.status.label} | ${item.rawTextLength} | '
        '${item.locator ?? ''} | ${item.addressFound} | ${item.durationMs}',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Critical Errors')
      ..writeln();
    if (result.criticalErrors.isEmpty) {
      buffer.writeln('None');
    } else {
      for (final error in result.criticalErrors) {
        buffer.writeln('- $error');
      }
    }
    return buffer.toString();
  }

  Map<String, dynamic> _ocrMetadata(
    File file,
    AutomationOcrFixtureResult result,
  ) {
    return {
      'file': file.path,
      'file_name': result.fileName,
      'result': result.status.label,
      'raw_text_length': result.rawTextLength,
      'locator': result.locator,
      'address_found': result.addressFound,
      'missing_fields': result.missingFields,
      'message': result.message,
    };
  }

  void _log(
    String event, {
    required String runId,
    required String test,
    required int durationMs,
    LogSeverity severity = LogSeverity.info,
    Map<String, dynamic>? metadata,
  }) {
    AppLogger.log(
      event,
      severity: severity,
      module: 'AutomationRunner',
      sessionId: runId,
      metadata: {
        'suite': suite,
        'test': test,
        'run_id': runId,
        'duration_ms': durationMs,
        ...?metadata,
      },
    );
  }
}

class _OcrFixtureSuiteResult {
  final AutomationTestResult test;
  final List<AutomationOcrFixtureResult> fixtures;

  const _OcrFixtureSuiteResult({required this.test, required this.fixtures});
}

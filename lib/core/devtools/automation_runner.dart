import 'dart:io';

import 'package:controle_entregas/core/devtools/automation_fixture_service.dart';
import 'package:controle_entregas/core/devtools/automation_result.dart';
import 'package:controle_entregas/core/devtools/test_data_cleanup_service.dart';
import 'package:controle_entregas/core/devtools/diagnostics_service.dart';
import 'package:controle_entregas/core/devtools/log_reader_service.dart';
import 'package:controle_entregas/core/logging/log_storage.dart';
import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:controle_entregas/services/maps_launcher.dart';
import 'package:controle_entregas/services/ocr_service.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class AutomationRunner {
  static const suite = 'smoke';
  static const workflowProfile = 'FULL_SHIFT_SIMULATION';
  static const marker = '[AUTOMATION]';

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
      final workflowStages = await _runFullShiftSimulation(runId);

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
        workflowStages: workflowStages,
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
        workflowStages: workflowStages,
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
          'workflow_stages': finalResult.workflowStages.length,
          'workflow_passed': finalResult.workflowPassed,
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

  Future<List<AutomationWorkflowStageResult>> _runFullShiftSimulation(
    String runId,
  ) async {
    final cleanup = TestDataCleanupService(_db);
    await cleanup.cleanupAll();
    final ctx = _FullShiftContext(runId: runId);
    final stages = <AutomationWorkflowStageResult>[];

    stages.add(
      await _runWorkflowStage(
        runId,
        'Shift Creation',
        AutomationFailureCategory.shift,
        () => _workflowShiftCreation(ctx),
      ),
    );
    stages.add(
      await _runWorkflowStage(
        runId,
        'OCR Route Creation',
        AutomationFailureCategory.ocr,
        () => _workflowOcrRouteCreation(ctx),
      ),
    );
    stages.add(
      await _runWorkflowStage(
        runId,
        'Delivery Creation',
        AutomationFailureCategory.database,
        () => _workflowMultipleDeliveries(ctx),
      ),
    );
    stages.add(
      await _runWorkflowStage(
        runId,
        'Maps Integration',
        AutomationFailureCategory.maps,
        () => _workflowMapsIntegration(ctx),
      ),
    );
    stages.add(
      await _runWorkflowStage(
        runId,
        'Background Recovery',
        AutomationFailureCategory.infrastructure,
        () => _workflowBackgroundRecovery(ctx),
      ),
    );
    stages.add(
      await _runWorkflowStage(
        runId,
        'iFood Workflow',
        AutomationFailureCategory.ifood,
        () => _workflowIfood(ctx),
      ),
    );
    stages.add(
      await _runWorkflowStage(
        runId,
        'Manual Entry',
        AutomationFailureCategory.automation,
        () => _workflowManualEntry(ctx),
      ),
    );
    stages.add(
      await _runWorkflowStage(
        runId,
        'History Validation',
        AutomationFailureCategory.history,
        () => _workflowHistoryValidation(ctx),
      ),
    );
    stages.add(
      await _runWorkflowStage(
        runId,
        'Shift Closure',
        AutomationFailureCategory.shift,
        () => _workflowShiftClosure(ctx),
      ),
    );
    stages.add(
      await _runWorkflowStage(
        runId,
        'Cleanup',
        AutomationFailureCategory.automation,
        () => _workflowCleanup(cleanup),
      ),
    );

    await _writeWorkflowReport(runId, stages);
    return stages;
  }

  Future<AutomationWorkflowStageResult> _runWorkflowStage(
    String runId,
    String name,
    AutomationFailureCategory category,
    Future<Map<String, dynamic>> Function() body,
  ) async {
    final start = DateTime.now();
    _log(
      LogEvents.automationTestStart,
      runId: runId,
      test: name,
      durationMs: 0,
      metadata: {'profile': workflowProfile, 'category': category.label},
    );
    try {
      final metadata = await body();
      final durationMs = DateTime.now().difference(start).inMilliseconds;
      _log(
        LogEvents.automationTestPass,
        runId: runId,
        test: name,
        durationMs: durationMs,
        metadata: {
          'profile': workflowProfile,
          'category': category.label,
          ...metadata,
        },
      );
      return AutomationWorkflowStageResult(
        name: name,
        status: AutomationStatus.pass,
        category: category,
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
        metadata: {
          'profile': workflowProfile,
          'category': category.label,
          'error': e.toString(),
        },
      );
      return AutomationWorkflowStageResult(
        name: name,
        status: AutomationStatus.fail,
        category: category,
        durationMs: durationMs,
        message: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> _workflowShiftCreation(
    _FullShiftContext ctx,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final shiftId = await _db.shiftsDao.insertShift(
      ShiftsTableCompanion(
        driverName: Value('$marker Driver ${ctx.runId}'),
        startedAt: Value(now),
        status: const Value('open'),
        notes: Value('$marker automation_run_id=${ctx.runId} full shift'),
        source: Value('automation:${ctx.runId}'),
        createdAt: Value(now),
      ),
    );
    final shift = await _db.shiftsDao.getShiftById(shiftId);
    if (shift == null || shift.status != 'open') {
      throw StateError('Shift was not persisted as open.');
    }
    ctx.shiftId = shiftId;
    return {'shift_id': shiftId, 'status': shift.status};
  }

  Future<Map<String, dynamic>> _workflowOcrRouteCreation(
    _FullShiftContext ctx,
  ) async {
    final shiftId = ctx.requireShiftId();
    final files = await _fixtures.discoverImages();
    if (files.isEmpty) throw StateError('No OCR fixtures available.');
    final service = OcrService();
    OcrResult result;
    try {
      result = await service.processImage(files.first.path);
    } finally {
      await service.dispose();
    }
    final locator = result.partnerCollectionCode ?? result.deliveryIdentifier;
    if (!result.hasRequiredFields) throw StateError('OCR address missing.');
    if (locator == null || locator.isEmpty) {
      throw StateError('OCR locator missing.');
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final routeId = await _db.routesDao.insertRoute(
      RoutesTableCompanion(
        shiftId: Value(shiftId),
        routeNumber: const Value(1),
        status: const Value('open'),
        startedAt: Value(now),
        createdAt: Value(now),
      ),
    );
    final deliveryId = await _insertAutomationDelivery(
      ctx: ctx,
      routeId: routeId,
      sequenceNumber: 1,
      customerName: '$marker OCR Cliente',
      addressText: result.addressText ?? '$marker Rua OCR, 100',
      partnerCollectionCode: locator,
      ocrRawText: '${result.rawText}\nautomation_run_id=${ctx.runId}',
    );
    ctx.routeId = routeId;
    ctx.deliveryIds.add(deliveryId);
    ctx.locator = locator;
    return {
      'route_id': routeId,
      'delivery_id': deliveryId,
      'address_present': true,
      'locator': locator,
    };
  }

  Future<Map<String, dynamic>> _workflowMultipleDeliveries(
    _FullShiftContext ctx,
  ) async {
    final routeId = ctx.requireRouteId();
    var deliveries = await _db.deliveriesDao.getDeliveriesForRoute(routeId);
    if (deliveries.length != 1) throw StateError('Expected 1 delivery.');
    for (var i = 2; i <= 5; i++) {
      ctx.deliveryIds.add(
        await _insertAutomationDelivery(
          ctx: ctx,
          routeId: routeId,
          sequenceNumber: i,
          customerName: '$marker Cliente $i',
          addressText: '$marker Rua Sequencial, $i',
          partnerCollectionCode: 'AUTO${ctx.runId.hashCode.abs()}$i',
        ),
      );
    }
    deliveries = await _db.deliveriesDao.getDeliveriesForRoute(routeId);
    if (deliveries.length != 5) throw StateError('Expected 5 deliveries.');
    for (var i = 6; i <= 10; i++) {
      ctx.deliveryIds.add(
        await _insertAutomationDelivery(
          ctx: ctx,
          routeId: routeId,
          sequenceNumber: i,
          customerName: '$marker Cliente $i',
          addressText: '$marker Rua Sequencial, $i',
          partnerCollectionCode: 'AUTO${ctx.runId.hashCode.abs()}$i',
        ),
      );
    }
    deliveries = await _db.deliveriesDao.getDeliveriesForRoute(routeId);
    final sequences = deliveries.map((d) => d.sequenceNumber).toSet();
    if (deliveries.length != 10 || sequences.length != 10) {
      throw StateError('Expected 10 unique delivery sequences.');
    }
    return {
      'delivery_count': deliveries.length,
      'sequence_count': sequences.length,
    };
  }

  Future<Map<String, dynamic>> _workflowMapsIntegration(
    _FullShiftContext ctx,
  ) async {
    final deliveries = await _db.deliveriesDao.getDeliveriesForRoute(
      ctx.requireRouteId(),
    );
    final addresses = deliveries
        .map((d) => d.addressText)
        .where((a) => a.trim().isNotEmpty)
        .toList();
    if (addresses.isEmpty) throw StateError('No addresses available for maps.');
    final request = MapsLauncher.buildNavigationRequest(addresses);
    if (request == null || request.primary.isEmpty) {
      throw StateError('Maps request was not generated.');
    }
    return {
      'address_count': addresses.length,
      'primary': request.primary,
      'fallback': request.fallback,
      'coordinates_required': false,
    };
  }

  Future<Map<String, dynamic>> _workflowBackgroundRecovery(
    _FullShiftContext ctx,
  ) async {
    for (var i = 0; i < 3; i++) {
      final shift = await _db.shiftsDao.getShiftById(ctx.requireShiftId());
      final route = await _db.routesDao.getRouteById(ctx.requireRouteId());
      final delivery = await _db.deliveriesDao.getDeliveryById(
        ctx.deliveryIds.first,
      );
      if (shift == null || route == null || delivery == null) {
        throw StateError('State was not preserved during simulated lifecycle.');
      }
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }
    return {'cycles': 3, 'state_preserved': true};
  }

  Future<Map<String, dynamic>> _workflowIfood(_FullShiftContext ctx) async {
    final delivery = await _db.deliveriesDao.getDeliveryById(
      ctx.deliveryIds.first,
    );
    final locator =
        delivery?.partnerCollectionCode ?? delivery?.deliveryIdentifier;
    if (locator == null || locator != ctx.locator) {
      throw StateError('Locator was not preserved end-to-end.');
    }
    await _db.deliveriesDao.updateIfoodConfirmation(
      id: delivery!.id,
      success: false,
      confirmedAt: DateTime.now().toUtc().toIso8601String(),
    );
    final updated = await _db.deliveriesDao.getDeliveryById(delivery.id);
    if (updated?.partnerCollectionCode != locator) {
      throw StateError('Locator changed after iFood helper update.');
    }
    final helperUrl = Uri.https('portal.ifood.com.br', '/delivery', {
      'code': locator,
    });
    return {
      'locator': locator,
      'length': locator.length,
      'helper_url': helperUrl.toString(),
    };
  }

  Future<Map<String, dynamic>> _workflowManualEntry(
    _FullShiftContext ctx,
  ) async {
    final shiftId = ctx.requireShiftId();
    final now = DateTime.now().toUtc().toIso8601String();
    final routeNumber = await _db.routesDao.getNextRouteNumber(shiftId);
    final routeId = await _db.routesDao.insertRoute(
      RoutesTableCompanion(
        shiftId: Value(shiftId),
        routeNumber: Value(routeNumber),
        status: const Value('open'),
        startedAt: Value(now),
        createdAt: Value(now),
      ),
    );
    final deliveryId = await _insertAutomationDelivery(
      ctx: ctx,
      routeId: routeId,
      sequenceNumber: 1,
      customerName: '$marker Manual Cliente',
      addressText: '$marker Rua Manual, 200',
      partnerCollectionCode: 'MANUAL${ctx.runId.hashCode.abs()}',
    );
    ctx.manualRouteId = routeId;
    ctx.deliveryIds.add(deliveryId);
    final delivery = await _db.deliveriesDao.getDeliveryById(deliveryId);
    if (delivery == null || delivery.partnerCollectionCode == null) {
      throw StateError('Manual delivery was not persisted.');
    }
    return {'manual_route_id': routeId, 'manual_delivery_id': deliveryId};
  }

  Future<Map<String, dynamic>> _workflowHistoryValidation(
    _FullShiftContext ctx,
  ) async {
    final completedAt = DateTime.now().toUtc().toIso8601String();
    for (final id in ctx.deliveryIds) {
      await _db.deliveriesDao.completeDelivery(
        id: id,
        completedAt: completedAt,
        distanceKm: 1.0,
      );
    }
    final completed = await _db.deliveriesDao.getDeliveriesForShift(
      ctx.requireShiftId(),
    );
    if (completed.length != ctx.deliveryIds.length) {
      throw StateError('History completed delivery count mismatch.');
    }
    final totalDistance = completed.fold<double>(
      0,
      (sum, item) => sum + (item.distanceKm ?? 0),
    );
    return {
      'completed_deliveries': completed.length,
      'total_distance': totalDistance,
    };
  }

  Future<Map<String, dynamic>> _workflowShiftClosure(
    _FullShiftContext ctx,
  ) async {
    final closedAt = DateTime.now().toUtc().toIso8601String();
    await _db.routesDao.closeRoute(
      id: ctx.requireRouteId(),
      closedAt: closedAt,
      deliveryCountAtClose: 10,
    );
    if (ctx.manualRouteId != null) {
      await _db.routesDao.closeRoute(
        id: ctx.manualRouteId!,
        closedAt: closedAt,
        deliveryCountAtClose: 1,
      );
    }
    await _db.shiftsDao.closeShift(
      id: ctx.requireShiftId(),
      endedAt: closedAt,
      totalEarningsCents: ctx.deliveryIds.length * 800,
      deliveryCount: ctx.deliveryIds.length,
    );
    final shift = await _db.shiftsDao.getShiftById(ctx.requireShiftId());
    if (shift == null || shift.status != 'closed') {
      throw StateError('Shift was not closed.');
    }
    return {
      'shift_id': shift.id,
      'status': shift.status,
      'delivery_count': shift.deliveryCount,
    };
  }

  Future<Map<String, dynamic>> _workflowCleanup(
    TestDataCleanupService cleanup,
  ) async {
    final before = await cleanup.countAutomationRecords();
    final summary = await cleanup.cleanupAll();
    final after = await cleanup.countAutomationRecords();
    if ((after['deliveries'] ?? 0) != 0 ||
        (after['routes'] ?? 0) != 0 ||
        (after['shifts'] ?? 0) != 0) {
      throw StateError('Automation records remain after cleanup: $after');
    }
    return {
      'before': before,
      'deliveries_deleted': summary.deliveriesDeleted,
      'routes_deleted': summary.routesDeleted,
      'shifts_deleted': summary.shiftsDeleted,
      'after': after,
    };
  }

  Future<int> _insertAutomationDelivery({
    required _FullShiftContext ctx,
    required int routeId,
    required int sequenceNumber,
    required String customerName,
    required String addressText,
    String? partnerCollectionCode,
    String? ocrRawText,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return _db.deliveriesDao.insertDelivery(
      DeliveriesTableCompanion(
        routeId: Value(routeId),
        shiftId: Value(ctx.requireShiftId()),
        sequenceNumber: Value(sequenceNumber),
        customerName: Value(customerName),
        addressText: Value('$addressText automation_run_id=${ctx.runId}'),
        partnerCollectionCode: Value(partnerCollectionCode),
        ocrRawText: Value(
          ocrRawText ?? '$marker automation_run_id=${ctx.runId}',
        ),
        createdAt: Value(now),
        needsIfoodConfirmation: Value(partnerCollectionCode != null),
      ),
    );
  }

  Future<String> _writeWorkflowReport(
    String runId,
    List<AutomationWorkflowStageResult> stages,
  ) async {
    final dir = await _reportDirectory();
    await dir.create(recursive: true);
    final file = File('${dir.path}/workflow_report.md');
    final buffer = StringBuffer()
      ..writeln('# DeliveryFlow Workflow Validation')
      ..writeln()
      ..writeln('Run ID: $runId')
      ..writeln('Profile: $workflowProfile')
      ..writeln()
      ..writeln('## Business Workflow Validation')
      ..writeln();
    for (final stage in stages) {
      final dots = '.' * (28 - stage.name.length).clamp(1, 28);
      buffer.writeln('${stage.name} $dots ${stage.status.label}');
      if (stage.message != null) buffer.writeln('  - ${stage.message}');
    }
    buffer
      ..writeln()
      ..writeln('## Failure Classification')
      ..writeln();
    final failures = stages.where(
      (stage) => stage.status == AutomationStatus.fail,
    );
    if (failures.isEmpty) {
      buffer.writeln('None');
    } else {
      for (final stage in failures) {
        buffer.writeln('- ${stage.category.label}: ${stage.name}');
      }
    }
    await file.writeAsString(buffer.toString());
    return file.path;
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
    await TestDataCleanupService(_db).cleanupAll();
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
      ..writeln('## Business Workflow Validation')
      ..writeln();
    if (result.workflowStages.isEmpty) {
      buffer.writeln('Not executed');
    } else {
      for (final stage in result.workflowStages) {
        final dots = '.' * (28 - stage.name.length).clamp(1, 28);
        buffer.writeln(
          '${stage.name} $dots ${stage.status.label} (${stage.category.label})',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Failure Classification')
      ..writeln();
    final failedByCategory = <AutomationFailureCategory, int>{};
    for (final stage in result.workflowStages) {
      if (stage.status == AutomationStatus.fail) {
        failedByCategory.update(
          stage.category,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
    if (failedByCategory.isEmpty) {
      buffer.writeln('None');
    } else {
      for (final entry in failedByCategory.entries) {
        buffer.writeln('- ${entry.key.label}: ${entry.value}');
      }
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

class _FullShiftContext {
  final String runId;
  int? shiftId;
  int? routeId;
  int? manualRouteId;
  String? locator;
  final List<int> deliveryIds = [];

  _FullShiftContext({required this.runId});

  int requireShiftId() {
    final value = shiftId;
    if (value == null) throw StateError('Shift ID is not available.');
    return value;
  }

  int requireRouteId() {
    final value = routeId;
    if (value == null) throw StateError('Route ID is not available.');
    return value;
  }
}

import 'package:controle_entregas/core/monitoring/build_info.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Logger must initialize before anything else.
  await AppLogger.init();
  AppLogger.log(LogEvents.appStart, module: 'Main', className: 'main');

  // ── Flutter uncaught error handler ──────────────────────────────────────
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.log(
      LogEvents.appFlutterError,
      severity: LogSeverity.critical,
      module: 'FlutterError',
      className: 'FlutterError',
      method: 'onError',
      metadata: {
        'exception': details.exception.toString(),
        'library': details.library ?? 'unknown',
        'context': details.context?.toString() ?? 'none',
      },
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  // ── Platform (Dart isolate) uncaught error handler ───────────────────────
  PlatformDispatcher.instance.onError = (Object err, StackTrace stack) {
    AppLogger.log(
      LogEvents.appPlatformError,
      severity: LogSeverity.critical,
      module: 'PlatformDispatcher',
      metadata: {'error_type': err.runtimeType.toString()},
      error: err,
      stackTrace: stack,
    );
    return false;
  };

  // ── Build + device metadata (async, non-blocking) ────────────────────────
  BuildInfo.collect().then((meta) {
    AppLogger.log(
      LogEvents.appBuildMetadata,
      module: 'Main',
      className: 'main',
      method: '_logBuildMetadata',
      metadata: meta,
    );
  }).catchError((_) {});

  runApp(
    const ProviderScope(
      child: DeliveryFlowApp(),
    ),
  );
}

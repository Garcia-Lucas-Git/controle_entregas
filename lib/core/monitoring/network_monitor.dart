import 'dart:async';
import 'dart:io';

import 'package:controle_entregas/services/app_logger.dart';

/// Polls network reachability every 30 seconds and logs state changes.
/// Measures DNS lookup latency as a proxy for network responsiveness.
/// No external package required — uses [InternetAddress.lookup].
abstract final class NetworkMonitor {
  static Timer? _timer;
  static bool _lastOnline = true;
  static bool _started = false;

  static void start() {
    if (_started) return;
    _started = true;
    _check(); // immediate first check on startup
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _check());
  }

  static void stop() {
    _timer?.cancel();
    _started = false;
  }

  static Future<void> _check() async {
    final t0 = DateTime.now();
    bool isOnline;
    int? latencyMs;

    try {
      final result = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 5));
      isOnline = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      latencyMs = DateTime.now().difference(t0).inMilliseconds;
    } catch (_) {
      isOnline = false;
      latencyMs = null;
    }

    // Log latency for every check (verbose — not just on state change)
    AppLogger.log(
      LogEvents.networkStateChange,
      severity: LogSeverity.verbose,
      module: 'NetworkMonitor',
      metadata: {
        'online': isOnline,
        'latency_ms': latencyMs,
      },
    );

    if (isOnline == _lastOnline) return;

    // State changed — log at INFO/WARNING level
    _lastOnline = isOnline;
    AppLogger.log(
      isOnline ? LogEvents.networkOnline : LogEvents.networkOffline,
      severity: isOnline ? LogSeverity.info : LogSeverity.warning,
      module: 'NetworkMonitor',
      metadata: {
        'online': isOnline,
        'latency_ms': latencyMs,
        'note': isOnline
            ? 'connectivity restored'
            : 'dns lookup failed or timed out',
      },
    );
  }
}

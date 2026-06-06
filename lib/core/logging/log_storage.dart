import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Async log storage split by hour with simple recent-file retention.
///
/// Write queue: [enqueue] adds to a [StreamController]; the stream listener
/// writes to [IOSink] on a separate event-loop slot, never blocking the UI.
///
/// Files: `YYYY-MM-DD_HH.log` in the app documents directory.
abstract final class LogStorage {
  static IOSink? _sink;
  static String? _currentFileName;
  static const int _retentionHours = 48;
  static late String _dir;

  static final _queue = StreamController<String>();
  static StreamSubscription<String>? _sub;
  static bool _ready = false;

  static Future<void> init() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _dir = appDir.path;
      await _openCurrentFile();
      _sub = _queue.stream.listen(
        _handleWrite,
        onError: (_) {},
        cancelOnError: false,
      );
      _ready = true;
    } catch (_) {}
  }

  /// Enqueues a JSONL line for async write. Never throws.
  static void enqueue(String jsonLine) {
    try {
      if (_ready && !_queue.isClosed) _queue.add(jsonLine);
    } catch (_) {}
  }

  static Future<void> flush() async {
    try {
      await _sink?.flush();
    } catch (_) {}
  }

  static Future<void> close() async {
    try {
      await _sub?.cancel();
      await flush();
      await _sink?.close();
    } catch (_) {}
  }

  /// Exports current hour plus the previous four hours by default.
  static Future<void> export({bool lastFourHours = true}) async {
    try {
      await flush();
      final files = await _getFiles(
        hours: lastFourHours ? _lastHours(DateTime.now(), 5) : [DateTime.now()],
      );
      if (files.isEmpty) return;
      await Share.shareXFiles(
        files
            .map(
              (f) => XFile(
                f.path,
                name: f.uri.pathSegments.last,
                mimeType: 'application/x-ndjson',
              ),
            )
            .toList(),
        subject: 'DeliveryFlow - Logs de diagnostico',
      );
    } catch (_) {}
  }

  // ── Private ───────────────────────────────────────────────────────────────

  static Future<void> _handleWrite(String line) async {
    try {
      final expectedName = _hourlyName(DateTime.now());
      if (_currentFileName != expectedName) await _openCurrentFile();
      _sink?.writeln(line);
    } catch (_) {}
  }

  static Future<void> _openCurrentFile() async {
    await _sink?.flush();
    await _sink?.close();
    await _cleanupOldFiles();
    _currentFileName = _hourlyName(DateTime.now());
    _sink = File('$_dir/$_currentFileName').openWrite(mode: FileMode.append);
  }

  static Future<List<File>> _getFiles({required List<DateTime> hours}) async {
    final result = <File>[];
    final seen = <String>{};
    for (final hour in hours) {
      final name = _hourlyName(hour);
      if (!seen.add(name)) continue;
      final f = File('$_dir/$name');
      if (await f.exists()) result.add(f);
    }
    return result;
  }

  static Future<void> _cleanupOldFiles() async {
    try {
      final cutoff = DateTime.now().subtract(
        const Duration(hours: _retentionHours),
      );
      final dir = Directory(_dir);
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        final hour = _parseHourlyName(name);
        if (hour != null && hour.isBefore(cutoff)) await entity.delete();
      }
    } catch (_) {}
  }

  static List<DateTime> _lastHours(DateTime now, int count) => List.generate(
    count,
    (i) => DateTime(now.year, now.month, now.day, now.hour - i),
  );

  static String _hourlyName(DateTime dt) {
    final local = dt.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}_${two(local.hour)}.log';
  }

  static DateTime? _parseHourlyName(String name) {
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})_(\d{2})\.log$',
    ).firstMatch(name);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
    );
  }
}

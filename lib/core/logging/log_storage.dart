import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Async log storage with 2 MB rotation and 3-file retention.
///
/// Write queue: [enqueue] adds to a [StreamController]; the stream listener
/// writes to [IOSink] on a separate event-loop slot, never blocking the UI.
///
/// Files:
///   deliveryflow.log      ← current
///   deliveryflow.1.log    ← previous
///   deliveryflow.2.log    ← oldest kept
abstract final class LogStorage {
  static IOSink? _sink;
  static int _currentBytes = 0;
  static const int _maxBytes = 2 * 1024 * 1024; // 2 MB
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

  /// Exports all log files via the platform share dialog.
  static Future<void> export() async {
    try {
      await flush();
      final files = await _getFiles();
      if (files.isEmpty) return;
      await Share.shareXFiles(
        files
            .map((f) => XFile(
                  f.path,
                  name: f.uri.pathSegments.last,
                  mimeType: 'application/x-ndjson',
                ))
            .toList(),
        subject: 'DeliveryFlow — Logs de diagnóstico',
      );
    } catch (_) {}
  }

  // ── Private ───────────────────────────────────────────────────────────────

  static Future<void> _handleWrite(String line) async {
    try {
      final bytes = line.length + 1;
      if (_currentBytes + bytes > _maxBytes) await _rotate();
      _sink?.writeln(line);
      _currentBytes += bytes;
    } catch (_) {}
  }

  static Future<void> _openCurrentFile() async {
    final file = File('$_dir/deliveryflow.log');
    _currentBytes = await file.exists() ? await file.length() : 0;
    _sink = file.openWrite(mode: FileMode.append);
  }

  static Future<void> _rotate() async {
    try {
      await _sink?.flush();
      await _sink?.close();

      final f2 = File('$_dir/deliveryflow.2.log');
      final f1 = File('$_dir/deliveryflow.1.log');
      final f0 = File('$_dir/deliveryflow.log');

      if (await f2.exists()) await f2.delete();
      if (await f1.exists()) await f1.rename('$_dir/deliveryflow.2.log');
      if (await f0.exists()) await f0.rename('$_dir/deliveryflow.1.log');

      await _openCurrentFile();
      _currentBytes = 0;
    } catch (_) {}
  }

  static Future<List<File>> _getFiles() async {
    final names = [
      'deliveryflow.log',
      'deliveryflow.1.log',
      'deliveryflow.2.log',
    ];
    final result = <File>[];
    for (final name in names) {
      final f = File('$_dir/$name');
      if (await f.exists()) result.add(f);
    }
    return result;
  }
}

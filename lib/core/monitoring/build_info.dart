import 'dart:io';

import 'package:flutter/foundation.dart';

/// Collects build and device metadata at app startup.
/// Reads Android `/system/build.prop` for device model and manufacturer
/// — no external plugin required, world-readable on all Android versions.
abstract final class BuildInfo {
  static Map<String, dynamic>? _cached;

  static Future<Map<String, dynamic>> collect() async {
    if (_cached != null) return _cached!;

    final meta = <String, dynamic>{
      'version_name': '1.0.0',
      'version_code': 2002,
      'build_type': kReleaseMode
          ? 'release'
          : kProfileMode
          ? 'profile'
          : 'debug',
      'is_release': kReleaseMode,
      'os': Platform.operatingSystem,
      'os_version': Platform.operatingSystemVersion,
      'dart_version': Platform.version.split(' ').first,
    };

    // Parse Android API level from os_version string
    // e.g. "Android 13 (API 33) Build/TPP2.220218.023"
    final apiMatch = RegExp(
      r'API\s+(\d+)',
    ).firstMatch(Platform.operatingSystemVersion);
    if (apiMatch != null) {
      meta['android_sdk'] = int.tryParse(apiMatch.group(1) ?? '0');
    }

    // Read device model and manufacturer from Android build.prop
    final props = await _readBuildProps();
    meta['device_model'] = props['ro.product.model'] ?? 'unknown';
    meta['manufacturer'] = props['ro.product.manufacturer'] ?? 'unknown';
    meta['android_release'] = props['ro.build.version.release'] ?? 'unknown';
    meta['build_fingerprint'] = _truncate(
      props['ro.build.fingerprint'] ?? '',
      60,
    );

    _cached = meta;
    return meta;
  }

  /// Reads only the specific keys needed from build.prop to avoid memory waste.
  static Future<Map<String, String>> _readBuildProps() async {
    const needed = {
      'ro.product.model',
      'ro.product.manufacturer',
      'ro.build.version.release',
      'ro.build.fingerprint',
    };
    try {
      final file = File('/system/build.prop');
      if (!await file.exists()) return {};

      final result = <String, String>{};
      final lines = await file.readAsLines();
      for (final line in lines) {
        if (line.startsWith('#') || !line.contains('=')) continue;
        final idx = line.indexOf('=');
        final key = line.substring(0, idx).trim();
        if (!needed.contains(key)) continue;
        result[key] = line.substring(idx + 1).trim();
        if (result.length == needed.length) break;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  static String _truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max)}…' : s;
}

/// Utilities for diagnosing release build artifacts.
abstract final class ReleaseDiagnostics {
  /// Checks if the R8 mapping/missing_rules.txt exists after a build.
  /// Only relevant when running on a development machine, not on device.
  static Future<Map<String, dynamic>> checkBuildArtifacts(
    String projectRoot,
  ) async {
    final result = <String, dynamic>{
      'is_release': kReleaseMode,
      'project_root': projectRoot,
    };

    try {
      final mappingDir = Directory(
        '$projectRoot/build/app/outputs/mapping/release',
      );
      result['mapping_dir_exists'] = await mappingDir.exists();

      if (result['mapping_dir_exists'] == true) {
        final missingRules = File('${mappingDir.path}/missing_rules.txt');
        result['missing_rules_exists'] = await missingRules.exists();

        if (result['missing_rules_exists'] == true) {
          final content = await missingRules.readAsString();
          final lines = content
              .split('\n')
              .where((l) => l.isNotEmpty && !l.startsWith('#'))
              .toList();
          result['missing_rules_count'] = lines.length;
          result['missing_rules_preview'] = lines.take(5).toList();
        }
      }
    } catch (e) {
      result['error'] = e.toString();
    }

    return result;
  }
}

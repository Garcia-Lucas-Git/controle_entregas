import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AutomationFixtureService {
  static const defaultFixturePath =
      '/sdcard/Android/data/com.example.controle_entregas/files/test_fixtures/pedidos';

  static const _imageExtensions = {'.jpg', '.jpeg', '.png'};

  Future<Directory> fixtureDirectory() async {
    final defaultDir = Directory(defaultFixturePath);
    if (await defaultDir.exists()) return defaultDir;

    final external = await getExternalStorageDirectory();
    if (external == null) return defaultDir;
    return Directory('${external.path}/test_fixtures/pedidos');
  }

  Future<List<File>> discoverImages() async {
    final dir = await fixtureDirectory();
    if (!await dir.exists()) return const [];

    final files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final lower = entity.path.toLowerCase();
      if (_imageExtensions.any(lower.endsWith)) {
        files.add(entity);
      }
    }
    files.sort((a, b) => a.path.compareTo(b.path));
    return files;
  }
}

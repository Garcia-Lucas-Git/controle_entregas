import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'wakelock_controller.g.dart';

@Riverpod(keepAlive: true)
class WakeLockController extends _$WakeLockController {
  int _holdCount = 0;

  @override
  bool build() => false; // isHeld

  Future<void> acquire() async {
    _holdCount++;
    if (_holdCount == 1) {
      await WakelockPlus.enable();
      state = true;
    }
  }

  Future<void> release() async {
    if (_holdCount > 0) _holdCount--;
    if (_holdCount == 0) {
      await WakelockPlus.disable();
      state = false;
    }
  }

  Future<void> releaseAll() async {
    _holdCount = 0;
    await WakelockPlus.disable();
    state = false;
  }
}

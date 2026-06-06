import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:controle_entregas/domain/entities/app_settings.dart';
import 'package:controle_entregas/domain/value_objects/earnings_rules.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_notifier.g.dart';

@riverpod
Stream<AppSettings> settingsStream(SettingsStreamRef ref) =>
    ref.watch(settingsRepositoryProvider).watchSettings();

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<AppSettings> build() =>
      ref.watch(settingsRepositoryProvider).getSettings();

  Future<void> updateDriverName(String name) async {
    final current = await future;
    await ref
        .read(settingsRepositoryProvider)
        .saveSettings(current.copyWith(driverName: name));
    ref.invalidateSelf();
  }

  Future<void> updatePizzeriaAddress(String address) async {
    final current = await future;
    await ref
        .read(settingsRepositoryProvider)
        .saveSettings(current.copyWith(pizzeriaAddress: address));
    ref.invalidateSelf();
  }

  Future<void> updateIfoodUrl(String url) async {
    final current = await future;
    await ref
        .read(settingsRepositoryProvider)
        .saveSettings(current.copyWith(ifoodUrl: url));
    ref.invalidateSelf();
  }

  Future<void> updateIfoodFieldSelector(String selector) async {
    final current = await future;
    await ref
        .read(settingsRepositoryProvider)
        .saveSettings(current.copyWith(ifoodFieldSelector: selector));
    ref.invalidateSelf();
  }

  Future<void> updateOcrContrast(bool enabled) async {
    final current = await future;
    await ref
        .read(settingsRepositoryProvider)
        .saveSettings(current.copyWith(ocrContrastEnabled: enabled));
    ref.invalidateSelf();
  }

  Future<void> updateDailyGoal(int cents) async {
    final current = await future;
    await ref
        .read(settingsRepositoryProvider)
        .saveSettings(current.copyWith(dailyGoalCents: cents));
    AppLogger.info(
      LogEvents.dailyGoal,
      module: 'SettingsNotifier',
      metadata: {'value_cents': cents, 'value_reals': cents / 100},
    );
    ref.invalidateSelf();
  }

  Future<void> updateEarningsConfig({
    required int baseRateCents,
    required int longSingleDeliveryRateCents,
  }) async {
    await ref
        .read(earningsRepositoryProvider)
        .updateConfig(
          baseRateCents: baseRateCents,
          longSingleDeliveryRateCents: longSingleDeliveryRateCents,
        );
    final current = await future;
    await ref
        .read(settingsRepositoryProvider)
        .saveSettings(
          current.copyWith(
            earningsConfig: EarningsConfig(
              baseRateCents: baseRateCents,
              longSingleDeliveryRateCents: longSingleDeliveryRateCents,
            ),
          ),
        );
    ref.invalidateSelf();
  }
}

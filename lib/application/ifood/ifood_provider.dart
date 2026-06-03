import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ifood_provider.g.dart';

enum IFoodState {
  loading,
  webviewActive,
  success,
  failed,
  manualFallback,
  manualConfirmed,
}

class IFoodStatus {
  final IFoodState state;
  final String? errorMessage;

  const IFoodStatus({required this.state, this.errorMessage});

  bool get isTerminal =>
      state == IFoodState.success || state == IFoodState.manualConfirmed;
}

@riverpod
class IFoodNotifier extends _$IFoodNotifier {
  @override
  IFoodStatus build() => const IFoodStatus(state: IFoodState.loading);

  void onWebViewReady() =>
      state = const IFoodStatus(state: IFoodState.webviewActive);

  void onWebViewSuccess() =>
      state = const IFoodStatus(state: IFoodState.success);

  void onWebViewFailed(String? reason) {
    state = IFoodStatus(
      state: IFoodState.failed,
      errorMessage: reason,
    );
    // Auto-transition to manual fallback
    Future.microtask(() {
      state = const IFoodStatus(state: IFoodState.manualFallback);
    });
  }

  void onManualConfirmed() =>
      state = const IFoodStatus(state: IFoodState.manualConfirmed);

  void reset() => state = const IFoodStatus(state: IFoodState.loading);
}

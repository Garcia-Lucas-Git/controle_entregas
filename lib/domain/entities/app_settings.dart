import 'package:controle_entregas/domain/value_objects/earnings_rules.dart';

class AppSettings {
  final String driverName;
  final String pizzeriaAddress;
  final String ifoodUrl;
  final String ifoodFieldSelector;
  final bool ocrContrastEnabled;
  final EarningsConfig earningsConfig;

  // Crash recovery
  final int? activeRouteId;
  final int? activeDeliveryIndex;

  // Daily revenue goal in cents. Default R$120.
  final int dailyGoalCents;

  // Home address for navigation return destination (optional).
  final String homeAddress;

  const AppSettings({
    required this.driverName,
    required this.pizzeriaAddress,
    required this.ifoodUrl,
    required this.ifoodFieldSelector,
    required this.ocrContrastEnabled,
    required this.earningsConfig,
    this.activeRouteId,
    this.activeDeliveryIndex,
    this.dailyGoalCents = 12000,
    this.homeAddress = '',
  });

  static AppSettings get defaults => const AppSettings(
    driverName: '',
    pizzeriaAddress: '',
    ifoodUrl: 'https://confirmacao-entrega-propria.ifood.com.br/',
    ifoodFieldSelector: '',
    ocrContrastEnabled: false,
    earningsConfig: EarningsConfig.defaults(),
    dailyGoalCents: 12000,
    homeAddress: '',
  );

  bool get isSetupComplete =>
      driverName.isNotEmpty && pizzeriaAddress.isNotEmpty;

  AppSettings copyWith({
    String? driverName,
    String? pizzeriaAddress,
    String? ifoodUrl,
    String? ifoodFieldSelector,
    bool? ocrContrastEnabled,
    EarningsConfig? earningsConfig,
    int? activeRouteId,
    int? activeDeliveryIndex,
    int? dailyGoalCents,
    String? homeAddress,
  }) => AppSettings(
    driverName: driverName ?? this.driverName,
    pizzeriaAddress: pizzeriaAddress ?? this.pizzeriaAddress,
    ifoodUrl: ifoodUrl ?? this.ifoodUrl,
    ifoodFieldSelector: ifoodFieldSelector ?? this.ifoodFieldSelector,
    ocrContrastEnabled: ocrContrastEnabled ?? this.ocrContrastEnabled,
    earningsConfig: earningsConfig ?? this.earningsConfig,
    activeRouteId: activeRouteId ?? this.activeRouteId,
    activeDeliveryIndex: activeDeliveryIndex ?? this.activeDeliveryIndex,
    dailyGoalCents: dailyGoalCents ?? this.dailyGoalCents,
    homeAddress: homeAddress ?? this.homeAddress,
  );
}

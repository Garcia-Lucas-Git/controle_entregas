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

  const AppSettings({
    required this.driverName,
    required this.pizzeriaAddress,
    required this.ifoodUrl,
    required this.ifoodFieldSelector,
    required this.ocrContrastEnabled,
    required this.earningsConfig,
    this.activeRouteId,
    this.activeDeliveryIndex,
  });

  static AppSettings get defaults => const AppSettings(
    driverName: '',
    pizzeriaAddress: '',
    ifoodUrl: 'https://confirmacao-entrega-propria.ifood.com.br/',
    ifoodFieldSelector: '',
    ocrContrastEnabled: false,
    earningsConfig: EarningsConfig.defaults(),
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
  }) => AppSettings(
    driverName: driverName ?? this.driverName,
    pizzeriaAddress: pizzeriaAddress ?? this.pizzeriaAddress,
    ifoodUrl: ifoodUrl ?? this.ifoodUrl,
    ifoodFieldSelector: ifoodFieldSelector ?? this.ifoodFieldSelector,
    ocrContrastEnabled: ocrContrastEnabled ?? this.ocrContrastEnabled,
    earningsConfig: earningsConfig ?? this.earningsConfig,
    activeRouteId: activeRouteId ?? this.activeRouteId,
    activeDeliveryIndex: activeDeliveryIndex ?? this.activeDeliveryIndex,
  );
}

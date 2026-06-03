import 'package:controle_entregas/domain/enums/earnings_type.dart';
import 'package:controle_entregas/domain/value_objects/money.dart';

abstract final class EarningsRules {
  // Hardcoded domain constant — not configurable by user
  static const double kLongSingleDeliveryThresholdKm = 8.0;

  static EarningsType classify({
    required int deliveryCountAtClose,
    required double? distanceKm,
  }) {
    if (deliveryCountAtClose == 1 &&
        distanceKm != null &&
        distanceKm > kLongSingleDeliveryThresholdKm) {
      return EarningsType.longSingleDelivery;
    }
    return EarningsType.normal;
  }

  static Money rateFor(EarningsType type, EarningsConfig config) =>
      switch (type) {
        EarningsType.longSingleDelivery =>
          Money(config.longSingleDeliveryRateCents),
        EarningsType.normal => Money(config.baseRateCents),
      };
}

class EarningsConfig {
  final int baseRateCents;
  final int longSingleDeliveryRateCents;

  const EarningsConfig({
    required this.baseRateCents,
    required this.longSingleDeliveryRateCents,
  });

  const EarningsConfig.defaults()
      : baseRateCents = 800,
        longSingleDeliveryRateCents = 1000;

  Map<String, dynamic> toJson() => {
        'base_rate_cents': baseRateCents,
        'long_single_delivery_rate_cents': longSingleDeliveryRateCents,
        'earnings_config_version': 1,
      };
}

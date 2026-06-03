enum EarningsType {
  normal,
  longSingleDelivery;

  String toJson() => switch (this) {
        EarningsType.longSingleDelivery => 'long_single_delivery',
        _ => name,
      };

  static EarningsType fromJson(String value) => switch (value) {
        'long_single_delivery' => EarningsType.longSingleDelivery,
        'normal' => EarningsType.normal,
        _ => throw ArgumentError('Unknown EarningsType: $value'),
      };
}

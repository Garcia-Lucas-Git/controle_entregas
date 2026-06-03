enum DeliveryStatus {
  pending,
  inProgress,
  completed;

  String toJson() => switch (this) {
    DeliveryStatus.inProgress => 'in_progress',
    _ => name,
  };

  static DeliveryStatus fromJson(String value) => switch (value) {
    'in_progress' => DeliveryStatus.inProgress,
    'pending' => DeliveryStatus.pending,
    'completed' => DeliveryStatus.completed,
    _ => throw ArgumentError('Unknown DeliveryStatus: $value'),
  };
}

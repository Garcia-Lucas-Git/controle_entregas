enum RouteStatus {
  open,
  closed;

  String toJson() => name;
  static RouteStatus fromJson(String value) => RouteStatus.values.byName(value);
}

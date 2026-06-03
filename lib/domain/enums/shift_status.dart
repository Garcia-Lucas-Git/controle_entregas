enum ShiftStatus {
  open,
  closed;

  String toJson() => name;
  static ShiftStatus fromJson(String value) => ShiftStatus.values.byName(value);
}

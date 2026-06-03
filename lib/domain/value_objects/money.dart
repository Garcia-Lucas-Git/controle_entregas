import 'package:intl/intl.dart';

class Money {
  final int cents;

  const Money(this.cents);

  static const Money zero = Money(0);

  factory Money.fromReais(double reais) => Money((reais * 100).round());

  double get reais => cents / 100.0;

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator *(int factor) => Money(cents * factor);

  bool operator >(Money other) => cents > other.cents;
  bool operator >=(Money other) => cents >= other.cents;

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  String format() {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(reais);
  }

  @override
  String toString() => format();
}

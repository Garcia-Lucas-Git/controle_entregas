import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final brazilianCurrencyInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
];

int? parseBrazilianCurrencyToCents(String value) {
  final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
  final reais = double.tryParse(normalized);
  if (reais == null || reais <= 0) return null;
  return (reais * 100).round();
}

String formatCurrencyCents(int cents) {
  return NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  ).format(cents / 100);
}

String currencyCentsForInput(int? cents) {
  if (cents == null) return '';
  return (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
}

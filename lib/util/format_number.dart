import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String formatNumberBR(num value) {
  final formatter = NumberFormat("#,##0.00", "pt_BR");
  return formatter.format(value);
}

class RealInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String value = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (value.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double number = double.parse(value) / 100;

    final formatted = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
    ).format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
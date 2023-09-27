import 'package:intl/intl.dart';

mixin FormatCurrencyMixin {
  String formatCurrencyEuro(double valor) {
    final formatoMoeda =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
    return formatoMoeda.format(valor);
  }
}

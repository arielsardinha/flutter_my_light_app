import 'package:flutter_test/flutter_test.dart';
import 'package:my_light_app/utils/mixins/convert_currency.dart';

class _TestFormatCurrencyMixin with FormatCurrencyMixin {}

void main() {
  test('Deve converter o valor em moeda corretamente', () {
    final currencyMixin = _TestFormatCurrencyMixin();

    var valor = 1234.56;
    var valorFormatado = currencyMixin.formatCurrencyEuro(valor);

    // Verifique se o valor formatado está correto
    expect(valorFormatado, 'R\$ 1.234,56');
  });
}

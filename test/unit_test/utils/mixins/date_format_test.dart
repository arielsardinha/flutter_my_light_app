import 'package:flutter_test/flutter_test.dart';
import 'package:my_light_app/utils/mixins/date_formate.dart';

class _TestDateFormatMixin with DateFormatMixin {}

void main() {
  test('Deve formatar a data MM-DD-YYY - HH:MM:SS', () {
    final dateFormatMixin = _TestDateFormatMixin();

    final dataMockada = DateTime(2023, 1, 30, 14, 50, 30);
    final dataFormatada =
        dateFormatMixin.dateFormatDateTimeInStringFullTime(dataMockada);

    expect(dataFormatada, '30-01-2023 - 14:50:30');
  });
}

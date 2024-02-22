import 'package:flutter_test/flutter_test.dart';
import 'package:my_light_app/enterprise/entities/leitura_entity.dart';

void main() {
  test('deve instanciar corretamente', () {
    final dataInMilisegundos = DateTime.now().millisecondsSinceEpoch;
    final leitura = LeituraEntity(
      id: '',
      contador: 100,
      dataInMilisegundos: dataInMilisegundos,
      photo: 'photo',
    );

    expect(leitura.contador, '123');
    expect(leitura.dataInMilisegundos, dataInMilisegundos);
    expect(leitura.photo, 'photo');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:my_light_app/application/usecases/remote_get_leituras.dart';
import 'package:my_light_app/enterprise/usecases/get_leituras_usecase.dart';
import 'package:my_light_app/infra/storage/storage.dart';
import 'package:my_light_app/models/leitura_model.dart';

import '../../../mocs/mocs.mocks.dart';

void main() {
  late Storage storage;
  late GetLeiturasUseCase getLeiturasUseCase;

  setUpAll(() {
    storage = MockStorage();
  });

  setUp(() {
    getLeiturasUseCase = RemoteGetLeituras(storage: storage);
  });

  test('Deve buscar dados com sucesso', () {
    expect(getLeiturasUseCase.exec(), completes);
  });

  test('Deve retornar uma lista de leituras', () async {
    final leituras = await getLeiturasUseCase.exec();

    expect(leituras.leituras, []);
  });

  test('Deve retornar uma leitura dentro da lista', () async {
    when(storage.get(StorageEnum.data)).thenAnswer((realInvocation) async {
      final leituras = [
        LeituraModel(
                contador: '100',
                dataInMilisegundos: DateTime.now().millisecondsSinceEpoch,
                photo: '')
            .toJson(),
      ];

      return leituras;
    });
    final leituras = await getLeiturasUseCase.exec();

    expect(leituras.leituras.length, 1);
  });

  test(
      'Deve retornar uma lista de leituras vazia quando não tiver leitura nos storages',
      () async {
    when(storage.get(StorageEnum.data)).thenAnswer((realInvocation) async {
      return null;
    });
    final leituras = await getLeiturasUseCase.exec();

    expect(leituras.leituras.length, 0);
  });
}

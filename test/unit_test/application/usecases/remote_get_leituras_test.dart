import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:my_light_app/application/usecases/remote_get_leituras.dart';
import 'package:my_light_app/enterprise/usecases/get_leituras_usecase.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_model.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_repository.dart';
import 'package:my_light_app/infra/storage/storage.dart';

import '../../../mocs/mocs.mocks.dart';

void main() {
  late Storage storage;
  late GetLeiturasUseCase getLeiturasUseCase;
  late LeituraRepository leituraRepository;

  setUpAll(() {
    storage = MockStorage();
    leituraRepository = MockLeituraRepository();
  });

  setUp(() {
    getLeiturasUseCase = RemoteGetLeituras(
      storage: storage,
      leituraRepository: leituraRepository,
    );
  });

  test('Deve buscar dados com sucesso', () {
    provideDummy<ProprietarioResponseModel>(
      const ProprietarioResponseModel(
          id: '0', nomeProprietario: 'nomeProprietario'),
    );

    when(storage.get(StorageEnum.proprietario))
        .thenAnswer((realInvocation) async {
      return {"id": 2, "nome_proprietario": "ADRIANA"};
    });

    when(leituraRepository.getAll(
            proprietario:
                const ProprietarioResponseModel(id: '0', nomeProprietario: '')))
        .thenAnswer((realInvocation) async {
      return LeiturasModel(
        leituras: [],
        totalContador: 0,
        totalContadorPorDaCasa: 0,
        casaId: '1',
      );
    });
    expect(getLeiturasUseCase.exec(), completes);
  });

  test('Deve retornar uma lista de leituras', () async {
    final leituras = await getLeiturasUseCase.exec();

    expect(leituras.leituras, []);
  }, skip: 'completar teste');

  test('Deve retornar uma leitura dentro da lista', () async {
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

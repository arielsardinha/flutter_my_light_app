import 'package:flutter_test/flutter_test.dart';
import 'package:my_light_app/application/usecases/remote_delete_leitura.dart';
import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';
import 'package:my_light_app/enterprise/usecases/delete_leitura_usecase.dart';
import 'package:my_light_app/infra/storage/storage.dart';

import '../../../mocs/mocs.mocks.dart';

void main() {
  late DeleteLeituraUseCase deleteLeituraUseCase;
  late Storage storage;
  setUpAll(() {
    storage = MockStorage();
    deleteLeituraUseCase = RemoteDeleteLeitura(storage: storage);
  });

  test('Deve deletar uma leitura com sucesso', () {
    expect(
      deleteLeituraUseCase.exec(
        leituras: LeiturasEntity(leituras: []),
        leitura: LeituraEntity(
          contador: '100',
          dataInMilisegundos: DateTime.now().millisecondsSinceEpoch,
          photo: '',
        ),
      ),
      completes,
    );
  });

  test(
      'Deve deletar uma leitura com sucesso quando tiver passando uma lista de leituras',
      () {
    expect(
      deleteLeituraUseCase.exec(
        leituras: LeiturasEntity(
          leituras: [
            LeituraEntity(
              contador: '100',
              dataInMilisegundos: DateTime.now().millisecondsSinceEpoch,
              photo: '',
            )
          ],
        ),
        leitura: LeituraEntity(
          contador: '100',
          dataInMilisegundos: DateTime.now().millisecondsSinceEpoch,
          photo: '',
        ),
      ),
      completes,
    );
  });
}

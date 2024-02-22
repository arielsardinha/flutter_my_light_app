import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_light_app/application/usecases/remote_create_leitura.dart';
import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';
import 'package:my_light_app/enterprise/usecases/create_leitura_usecase.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_repository.dart';
import 'package:my_light_app/infra/storage/storage.dart';

import '../../../mocs/mocs.mocks.dart';

void main() {
  late CreateLeituraUseCase createLeituraUseCase;
  late final LeituraRepository leituraRepository;
  late Storage storage;
  late File tempFile;
  late IOSink ioSink;
  setUpAll(() {
    leituraRepository = MockLeituraRepository();
    tempFile = File('test_image.png');
    ioSink = tempFile.openWrite();
    storage = MockStorage();
  });

  setUp(() async {
    createLeituraUseCase = RemoteCreateLeitura(
      storage: storage,
      leituraRepository: leituraRepository,
    );
  });

  tearDownAll(() async {
    await ioSink.close();
    tempFile.deleteSync();
  });

  test('Deve criar uma leitura com sucesso', () async {
    expect(
      createLeituraUseCase.exec(
        leituras: LeiturasEntity(leituras: []),
        photo: tempFile,
        contador: 100,
      ),
      completes,
    );
  });
  test('Deve executar um erro quando o arquivo não for encontrado', () async {
    expect(
      () async => await createLeituraUseCase.exec(
        leituras: LeiturasEntity(leituras: []),
        photo: File(''),
        contador: 100,
      ),
      throwsException,
    );
  });

  test('Deve executar um erro quando o contador não for encontrado', () async {
    expect(
      () async => await createLeituraUseCase.exec(
        leituras: LeiturasEntity(leituras: []),
        photo: tempFile,
        contador: 0,
      ),
      throwsException,
    );
  });

  test('Deve executar um erro quando o arquivo tiver a extensão inválida',
      () async {
    final tempFile = File('imagem');

    expect(
      () => createLeituraUseCase.exec(
        leituras: LeiturasEntity(leituras: []),
        photo: tempFile,
        contador: 100,
      ),
      throwsException,
    );
  });

  test(
      'Deve criar uma leitura com sucesso quando tiver sendo passado uma lista de leituras',
      () {
    expect(
      createLeituraUseCase.exec(
        leituras: LeiturasEntity(leituras: [
          LeituraEntity(
            id: '',
            contador: 100,
            dataInMilisegundos: DateTime.now().millisecondsSinceEpoch,
            photo: '',
          ),
        ]),
        photo: tempFile,
        contador: 100,
      ),
      completes,
    );
  });
}

import 'dart:io';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';
import 'package:my_light_app/enterprise/usecases/create_leitura_usecase.dart';
import 'package:my_light_app/infra/storage/storage.dart';
import 'package:my_light_app/models/leitura_model.dart';
import 'package:my_light_app/utils/mixins/convert_file.dart';

class RemoteCreateLeitura with FormatFileMixin implements CreateLeituraUseCase {
  final Storage _storage;
  RemoteCreateLeitura({required Storage storage}) : _storage = storage;
  @override
  Future<void> exec({
    required LeiturasEntity leituras,
    required File photo,
    required String contador,
  }) async {
    await _storage.delete(StorageEnum.data);

    final leitura = LeituraModel(
      contador: contador,
      dataInMilisegundos: DateTime.now().millisecondsSinceEpoch,
      photo: convertImageFileToBase64String(photo),
    );

    final leiturasModel = leituras.leituras.map((leitura) {
      return LeituraModel(
        contador: leitura.contador,
        dataInMilisegundos: leitura.dataInMilisegundos,
        photo: leitura.photo,
      ).toJson();
    }).toList();

    final newLeituras = [
      ...leiturasModel,
      leitura.toJson(),
    ];

    await _storage.save<List>(
      key: StorageEnum.data,
      value: newLeituras,
    );
  }
}

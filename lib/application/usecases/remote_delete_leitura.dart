import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';
import 'package:my_light_app/enterprise/usecases/delete_leitura_usecase.dart';
import 'package:my_light_app/infra/storage/storage.dart';
import 'package:my_light_app/models/leitura_model.dart';

class RemoteDeleteLeitura implements DeleteLeituraUseCase {
  final Storage _storage;

  RemoteDeleteLeitura({required Storage storage}) : _storage = storage;
  @override
  Future<void> exec(
      {required LeiturasEntity leituras,
      required LeituraEntity leitura}) async {
    leituras.leituras.remove(leitura);

    final leiturasModel = leituras.leituras.map((leitura) {
      return LeituraModel(
        contador: leitura.contador,
        dataInMilisegundos: leitura.dataInMilisegundos,
        photo: leitura.photo,
      ).toJson();
    }).toList();
    await _storage.delete(StorageEnum.data);
    await _storage.save(key: StorageEnum.data, value: leiturasModel);
  }
}

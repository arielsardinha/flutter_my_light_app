import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';
import 'package:my_light_app/enterprise/usecases/get_leituras_usecase.dart';
import 'package:my_light_app/infra/storage/storage.dart';
import 'package:my_light_app/models/leitura_model.dart';

final class RemoteGetLeituras implements GetLeiturasUseCase {
  final Storage _storage;

  RemoteGetLeituras({required Storage storage}) : _storage = storage;
  @override
  Future<LeiturasEntity> exec() async {
    final data = await _storage.get<List>(StorageEnum.data);

    if (data == null || data.isEmpty) {
      return LeiturasEntity(leituras: []);
    }
    final leiturasModel = data.map((e) => LeituraModel.fromJson(e)).toList();

    return LeiturasEntity(
        leituras: leiturasModel.map((leitura) {
      return LeituraEntity(
        contador: leitura.contador,
        dataInMilisegundos: leitura.dataInMilisegundos,
        photo: leitura.photo,
      );
    }).toList());
  }
}

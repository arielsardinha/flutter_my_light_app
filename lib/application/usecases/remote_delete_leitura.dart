import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';
import 'package:my_light_app/enterprise/usecases/delete_leitura_usecase.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_model.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_repository.dart';
import 'package:my_light_app/infra/storage/storage.dart';

class RemoteDeleteLeitura implements DeleteLeituraUseCase {
  final Storage _storage;
  final LeituraRepository _leituraRepository;

  RemoteDeleteLeitura({
    required Storage storage,
    required LeituraRepository leituraRepository,
  })  : _storage = storage,
        _leituraRepository = leituraRepository;
  @override
  Future<void> exec({
    required LeiturasEntity leituras,
    required LeituraEntity leitura,
  }) async {
    final data =
        await _storage.get<Map<String, dynamic>>(StorageEnum.proprietario);

    final proprietarioModel = ProprietarioResponseModel.fromJson(data!);

    final leituraModel = LeituraModel(
        createAt: DateTime(leitura.dataInMilisegundos),
        id: leitura.id,
        contador: leitura.contador,
        photo: leitura.photo);
    await _leituraRepository.delete(
      leitura: leituraModel,
      proprietario: proprietarioModel,
    );
  }
}

import 'package:my_light_app/enterprise/entities/casa_entity.dart';
import 'package:my_light_app/enterprise/usecases/get_casa_use_case.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_repository.dart';
import 'package:my_light_app/infra/storage/storage.dart';

final class RemoteGetCasa implements GetCasaUseCase {
  final CasaRepository _casaRepository;
  final Storage _storage;

  RemoteGetCasa(
      {required CasaRepository casaRepository, required Storage storage})
      : _casaRepository = casaRepository,
        _storage = storage;
  @override
  Future<CasaEntity> exec({required String nomeProprietario}) async {
    final responseModel = await _casaRepository
        .getCasa(ProprietarioModel(nomeProprietario: nomeProprietario));
    await _storage.save(
        key: StorageEnum.proprietario, value: responseModel.toJson());
    return CasaEntity(
      nivelDeAcesso: CasaNivelDeAcessoEnum.fromJson(responseModel.nivelAcesso),
      id: responseModel.id,
      proprietario: responseModel.nomeProprietario,
    );
  }
}

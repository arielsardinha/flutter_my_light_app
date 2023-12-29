import 'package:my_light_app/enterprise/entities/leitura_resumo_entity.dart';
import 'package:my_light_app/enterprise/usecases/get_leitura_resumo_usecase.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_repository.dart';
import 'package:my_light_app/infra/storage/storage.dart';

final class RemoteGetLeituraResumo implements GetLeituraResumoUseCase {
  final LeituraRepository _leituraRepository;
  final Storage _storage;

  RemoteGetLeituraResumo(
      {required LeituraRepository leituraRepository, required Storage storage})
      : _leituraRepository = leituraRepository,
        _storage = storage;
  @override
  Future<List<LeiturasResumoEntity>> exec() async {
    final data =
        await _storage.get<Map<String, dynamic>>(StorageEnum.proprietario);
    final proprietarioModel = ProprietarioResponseModel.fromJson(data!);
    final resumo =
        await _leituraRepository.getResumo(proprietario: proprietarioModel);

    return resumo
        .map((e) => LeiturasResumoEntity(
            totalLeitura: e.totalLeitura,
            consumo: e.consumo,
            dataLeitura: e.dataLeitura))
        .toList();
  }
}

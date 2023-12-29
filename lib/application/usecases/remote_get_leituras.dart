import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';
import 'package:my_light_app/enterprise/usecases/get_leituras_usecase.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_repository.dart';
import 'package:my_light_app/infra/storage/storage.dart';

final class RemoteGetLeituras implements GetLeiturasUseCase {
  final Storage _storage;
  final LeituraRepository _leituraRepository;
  RemoteGetLeituras(
      {required Storage storage, required LeituraRepository leituraRepository})
      : _storage = storage,
        _leituraRepository = leituraRepository;
  @override
  Future<LeiturasEntity> exec({DateTime? endDate, DateTime? startDate}) async {
    final proprietario =
        await _storage.get<Map<String, dynamic>>(StorageEnum.proprietario);
    final proprietarioModel = ProprietarioResponseModel.fromJson(proprietario!);

    final leiturasModel = await _leituraRepository.getAll(
      proprietario: proprietarioModel,
      endDate: endDate,
      startDate: startDate,
    );

    return LeiturasEntity(
      totalLeitura: leiturasModel.totalContadorPorDaCasa,
      leituras: leiturasModel.leituras
          .map(
            (e) => LeituraEntity(
              contador: e.contador,
              dataInMilisegundos: e.createAt.millisecondsSinceEpoch,
              id: e.id,
              photo: e.photo ?? '',
            ),
          )
          .toList(),
    );
  }
}

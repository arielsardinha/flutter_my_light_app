import 'dart:developer';

import 'package:my_light_app/enterprise/entities/casa_entity.dart';
import 'package:my_light_app/enterprise/usecases/get_casas_usecase.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_repository.dart';

final class RemoteGetCasas implements GetCasasUseCase {
  final CasaRepository _casaRepository;

  RemoteGetCasas({required CasaRepository casaRepository})
      : _casaRepository = casaRepository;
  @override
  Future<List<CasaEntity>> exec() async {
    try {
      final model = await _casaRepository.getCasas();
      log(model.length.toString());
      final casa = model
          .map((e) => CasaEntity(
              nivelDeAcesso: CasaNivelDeAcessoEnum.fromJson(e.nivelAcesso),
              id: e.id,
              proprietario: e.nomeProprietario))
          .toList();

      return casa;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

import 'dart:io';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';
import 'package:my_light_app/enterprise/usecases/create_leitura_usecase.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_model.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_repository.dart';
import 'package:my_light_app/infra/storage/storage.dart';
import 'package:my_light_app/utils/mixins/convert_file.dart';

class RemoteCreateLeitura with FormatFileMixin implements CreateLeituraUseCase {
  final Storage _storage;
  final LeituraRepository _leituraRepository;
  RemoteCreateLeitura(
      {required Storage storage, required LeituraRepository leituraRepository})
      : _storage = storage,
        _leituraRepository = leituraRepository;
  @override
  Future<void> exec({
    required LeiturasEntity leituras,
    required File? photo,
    required int contador,
  }) async {
    final data =
        await _storage.get<Map<String, dynamic>>(StorageEnum.proprietario);

    final proprietarioModel = ProprietarioResponseModel.fromJson(data!);

    final newLeitura = LeituraCreateParamns(
      casaId: proprietarioModel.id,
      contador: contador,
      photo: photo,
    );
    await _leituraRepository.create(newLeitura: newLeitura);
  }
}

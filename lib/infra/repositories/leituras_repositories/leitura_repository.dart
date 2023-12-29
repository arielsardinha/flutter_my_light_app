import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_model.dart';

abstract interface class LeituraRepository {
  Future<LeiturasModel> getAll({
    required ProprietarioResponseModel proprietario,
  });

  Future<void> delete({
    required LeituraModel leitura,
    required ProprietarioResponseModel proprietario,
  });

  Future<LeituraModel> create({
    required LeituraCreateParamns newLeitura,
  });
}

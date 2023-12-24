import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';

abstract interface class CasaRepository {
  Future<ProprietarioResponseModel> getCasa(ProprietarioModel casaModel);
  Future<List<ProprietarioResponseModel>> getCasas();
}

import 'package:my_light_app/infra/adapter/http_erro.dart';
import 'package:my_light_app/infra/adapter/request_adapter.dart';
import 'package:my_light_app/infra/client_http/client_http.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_repository.dart';

final class CasaRepositoryImpl implements CasaRepository {
  final ClientHttp _clientHttp;

  CasaRepositoryImpl({required ClientHttp clientHttp})
      : _clientHttp = clientHttp;

  @override
  Future<CasaResponseModel> getCasa(CasaModel casaModel) async {
    try {
      final request = Request('/casa', body: casaModel.toJson());
      final response = await _clientHttp.get(request);
      if (response.data == null) {
        throw HttpError(request: request, response: response);
      }
      return CasaResponseModel.fromJson(response.data!);
    } on HttpError catch (_) {
      rethrow;
    }
  }
}

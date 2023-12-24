import 'package:my_light_app/infra/adapter/http_erro.dart';
import 'package:my_light_app/infra/adapter/request_adapter.dart';
import 'package:my_light_app/infra/client_http/client_http.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_model.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_repository.dart';

final class LeituraRepositoryImpl implements LeituraRepository {
  final ClientHttp _clientHttp;

  LeituraRepositoryImpl({required ClientHttp clientHttp})
      : _clientHttp = clientHttp;

  @override
  Future<LeiturasModel> getAll(
      {required ProprietarioResponseModel casa}) async {
    try {
      final response = await _clientHttp.get(Request(
        '/leituras',
        body: casa.toJson(),
      ));

      return LeiturasModel.fromJson(response.data);
    } on HttpError catch (_) {
      rethrow;
    }
  }
}

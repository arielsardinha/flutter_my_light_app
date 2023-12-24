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
      {required ProprietarioResponseModel proprietario}) async {
    try {
      final request = Request(
        '/leituras',
        body: proprietario.toJson(),
      );
      final response = await _clientHttp.get<Map<String, dynamic>>(request);
      if (response.data == null) {
        throw HttpError(request: request, response: response);
      }
      return LeiturasModel.fromJson(response.data!);
    } on HttpError catch (_) {
      rethrow;
    }
  }
}

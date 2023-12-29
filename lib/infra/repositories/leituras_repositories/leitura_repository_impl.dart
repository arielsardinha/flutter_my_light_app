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
  Future<LeiturasModel> getAll({
    required ProprietarioResponseModel proprietario,
    DateTime? endDate,
    DateTime? startDate,
  }) async {
    try {
      final request = Request(
        '/leituras',
        body: {
          ...proprietario.toJson(),
          "initialDate":
              startDate?.subtract(const Duration(days: 1)).toIso8601String(),
          "finalDate": endDate?.toIso8601String(),
        },
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

  @override
  Future<void> delete({
    required LeituraModel leitura,
    required ProprietarioResponseModel proprietario,
  }) async {
    try {
      await _clientHttp.delete(Request('/leitura',
          body: {...leitura.toJson(), "casaId": proprietario.id}));
    } on HttpError catch (_) {
      rethrow;
    }
  }

  @override
  Future<LeituraModel> create(
      {required LeituraCreateParamns newLeitura}) async {
    try {
      final response = await _clientHttp.post<Map<String, dynamic>>(Request(
        '/leitura',
        body: await newLeitura.getFormData(),
      ));
      return LeituraModel.fromJson(response.data!['leitura']);
    } on HttpError catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<LeiturasResumoModel>> getResumo(
      {required ProprietarioResponseModel proprietario}) async {
    try {
      final resumo = await _clientHttp.get<List<dynamic>>(Request(
        '/leituras/resumo',
        body: proprietario.toJson(),
      ));

      return resumo.data!.map((e) => LeiturasResumoModel.fromJson(e)).toList();
    } on HttpError catch (_) {
      rethrow;
    }
  }
}

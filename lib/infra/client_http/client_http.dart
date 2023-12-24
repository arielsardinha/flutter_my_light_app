import 'package:my_light_app/infra/adapter/request_adapter.dart';
import 'package:my_light_app/infra/adapter/response_adapter.dart';

abstract interface class ClientHttp {
  Future<Response<T>> get<T>(Request request);
  Future<Response<T>> post<T>(Request request);
  Future<Response<T>> delete<T>(Request request);
}

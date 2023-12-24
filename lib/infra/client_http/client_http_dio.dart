import 'dart:developer';

import 'package:my_light_app/infra/adapter/http_erro.dart';
import 'package:my_light_app/infra/adapter/request_adapter.dart';
import 'package:my_light_app/infra/adapter/response_adapter.dart';
import 'package:my_light_app/infra/client_http/client_http.dart';
import 'package:dio/dio.dart' as dio_import;
import 'package:my_light_app/infra/storage/storage.dart';

final dio = dio_import.Dio();

class ClientHttpDio implements ClientHttp {
  final Storage storage = StorageSharedPreferences();
  ClientHttpDio() {
    storage.get<String>(StorageEnum.host).then((value) {
      dio.options.baseUrl = value ?? '';
      log("client $value");
      // 'http://10.0.2.2:3000'
    });
  }

  @override
  Future<Response<T>> delete<T>(Request request) async {
    try {
      final response = await dio.delete(
        request.url,
        data: request.body,
        queryParameters: request.queryParamns,
      );

      return Response<T>(
        data: response.data,
        status: response.statusCode,
      );
    } on dio_import.DioException catch (e, s) {
      throw HttpError(
        error: e,
        stackTrace: s,
        request: Request(
          e.requestOptions.path,
          body: e.requestOptions.data,
          queryParamns: e.requestOptions.queryParameters,
        ),
        response: Response(
          data: e.response?.data,
          status: e.response?.statusCode,
        ),
      );
    }
  }

  @override
  Future<Response<T>> get<T>(Request request) async {
    try {
      final response = await dio.get(
        request.url,
        data: request.body,
        queryParameters: request.queryParamns,
      );

      return Response<T>(
        data: response.data,
        status: response.statusCode,
      );
    } on dio_import.DioException catch (e, s) {
      throw HttpError(
        error: e,
        stackTrace: s,
        request: Request(
          e.requestOptions.path,
          body: e.requestOptions.data,
          queryParamns: e.requestOptions.queryParameters,
        ),
        response: Response(
          data: e.response?.data,
          status: e.response?.statusCode,
        ),
      );
    }
  }

  @override
  Future<Response<T>> post<T>(Request request) async {
    try {
      final response = await dio.post(
        request.url,
        data: request.body,
        queryParameters: request.queryParamns,
      );

      return Response<T>(
        data: response.data,
        status: response.statusCode,
      );
    } on dio_import.DioException catch (e, s) {
      throw HttpError(
        error: e,
        stackTrace: s,
        request: Request(
          e.requestOptions.path,
          body: e.requestOptions.data,
          queryParamns: e.requestOptions.queryParameters,
        ),
        response: Response(
          data: e.response?.data,
          status: e.response?.statusCode,
        ),
      );
    }
  }
}

import 'package:my_light_app/infra/adapter/request_adapter.dart';
import 'package:my_light_app/infra/adapter/response_adapter.dart';

final class HttpError implements Error {
  @override
  final StackTrace? stackTrace;
  final Request request;
  final Response response;
  final dynamic error;

  HttpError({
    this.error,
    this.stackTrace,
    required this.request,
    required this.response,
  });
}

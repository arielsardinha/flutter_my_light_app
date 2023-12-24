final class Request {
  final String url;
  final dynamic body;
  final Map<String, dynamic>? queryParamns;

  Request(this.url, {this.body, this.queryParamns});
}

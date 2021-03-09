
import 'package:http/http.dart';
import 'package:ingrow_client_flutter/const.dart';
import 'package:meta/meta.dart';

import '../util/nothing.dart';
import '../util/request_type.dart';
import '../util/request_type_exception.dart';

class RestClient {
  //Base url
  static const String _baseUrl = "https://event.ingrow.co/v1";
  final Client _client;

  RestClient(this._client);

  Future<Response> request(
      {@required RequestType requestType,
        @required String apiKey,
        dynamic parameter = Nothing}) async {
    switch (requestType) {
      case RequestType.GET:
        return _client.get("$_baseUrl");
      case RequestType.POST:
        return _client.post("$_baseUrl",
            headers: {
              "Content-Type": "application/json",
              "Cache-Control": "no-cache",
              Const.API_KEY: apiKey
            },
            body: parameter.toString());

      default:
        return throw RequestTypeNotFoundException(
            "The HTTP request mentioned is not found");
    }
  }
}

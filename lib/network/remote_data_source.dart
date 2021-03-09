import 'dart:async';

import 'dart:developer' as developer;
import 'package:http/http.dart';
import 'package:ingrow_client_flutter/model/result.dart';
import 'package:ingrow_client_flutter/util/request_type.dart';
import 'package:ingrow_client_flutter/network/rest_client.dart';

class RemoteDataSource {
  RemoteDataSource._privateConstructor();

  static final RemoteDataSource _apiResponse =
  RemoteDataSource._privateConstructor();

  factory RemoteDataSource() => _apiResponse;

  RestClient client = RestClient(Client());

  StreamController<Result> _sendEventStream;

  Stream<Result> hasEventsSent() => _sendEventStream.stream;

  void init() => _sendEventStream = StreamController();

  void sendEvents(String main, String apiKey) async {
    _sendEventStream.sink.add(Result<String>.loading("Loading"));
    try {
      final response = await client.request(
          requestType: RequestType.POST, parameter: main, apiKey: apiKey);
      if (response.statusCode == 201) {
        _sendEventStream.sink.add(Result.success("Success"));
        developer.log("Send events succeeded", name: "SUCCESS");
      } else {
        developer.log(
            response.body != null ? response.body : "Unknown error occurred",
            name: "ERROR");
        _sendEventStream.sink.add(Result.error("Something went wrong"));
      }
    } catch (error) {
      _sendEventStream.sink.add(Result.error("Something went wrong!"));
      developer.log("Response is not 201", name: "ERROR");
    }
  }
}

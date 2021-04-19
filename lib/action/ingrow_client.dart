import 'package:ingrow_client_flutter/action/client_builder.dart';
import 'package:ingrow_client_flutter/const.dart';
import 'package:ingrow_client_flutter/model/custom_exception.dart';
import 'dart:developer' as developer;
import 'dart:convert';

import 'package:ingrow_client_flutter/network/remote_data_source.dart';
import 'package:connectivity/connectivity.dart';

class InGrowClient {
  String _apiKey;
  String _project;
  String _stream;
  bool _isDebugMode;
  bool _isLoggingEnabled;
  String _anonymousId;
  String _userId;
  static InGrowClient _inGrowClientSingleton;
  RemoteDataSource _apiResponse = RemoteDataSource();

  InGrowClient(ClientBuilder builder) {
    _apiKey = builder.apiKey;
    _project = builder.project;
    _stream = builder.stream;
    _isDebugMode = builder.isDebugMode;
    _isLoggingEnabled = builder.isLoggingEnabled;
    if (builder.anonymousId != null) {
      _anonymousId = builder.anonymousId;
      _userId = builder.userId != null ? builder.userId : "";
    }
    _apiResponse.init();
  }

  static void enrichmentBySession(String userId) {
    if (_inGrowClientSingleton == null) {
      throw new CustomException(
          "Please call InGrowClient.initialize() before requesting the enrichmentBySession.");
    }
    if (_inGrowClientSingleton._anonymousId == null) {
      throw new CustomException(
          "You had to set Anonymous ID while you were initializing InGrow.");
    }
    if (userId == null) {
      throw new CustomException("userId must not be null.");
    }
    _inGrowClientSingleton._userId = userId;
  }

  static void initialize(InGrowClient client) {
    if (client == null) {
      throw new CustomException("Client must not be null");
    }
    if (_inGrowClientSingleton != null) {
      return;
    }
    _inGrowClientSingleton = client;
  }

  static InGrowClient client() {
    if (_inGrowClientSingleton == null) {
      throw new CustomException(
          "Please call InGrowClient.initialize() before requesting the client.");
    }
    return _inGrowClientSingleton;
  }

  void logEvents(Map<String, dynamic> events) {
    if (events.isEmpty) {
      _handleFailure(new CustomException("Events must not be null."));
      return;
    }

/*    var eventsJSON = jsonEncode(events);
    var inGrowJSON =
        json.encode({Const.PROJECT: _project, Const.STREAM: _stream});
    var inputIPJSON = json.encode({Const.IP: Const.AUTO_FILL});
    var enrichmentIPJSON =
        json.encode({Const.NAME: Const.IP, Const.INPUT: jsonEncode({Const.IP: Const.AUTO_FILL})});*/

    var enrichmentSessionJSON;
    if (_anonymousId != null) {
      var inputJSON = {
        Const.ANONYMOUS_ID: _anonymousId,
        Const.USER_ID: _userId != null ? _userId : ""
      };
      enrichmentSessionJSON = {
        Const.NAME: Const.SESSION,
        Const.INPUT: {
          Const.ANONYMOUS_ID: _anonymousId,
          Const.USER_ID: _userId != null ? _userId : ""
        }
      };
    }

    var mainJSON = jsonEncode({
      Const.ENRICHMENT: enrichmentSessionJSON != null
          ? [
        {
          Const.NAME: Const.IP,
          Const.INPUT: {Const.IP: Const.AUTO_FILL}
        },
        enrichmentSessionJSON
      ]
          : [
        {
          Const.NAME: Const.IP,
          Const.INPUT: {Const.IP: Const.AUTO_FILL}
        }
      ],
      Const.INGROW: {Const.PROJECT: _project, Const.STREAM: _stream},
      Const.EVENT: events
    });

    _checkNetworkAndSendEvents(mainJSON);
  }

  void _sendRequest(var mainJSON) {
    RemoteDataSource().sendEvents(mainJSON, _apiKey);
  }

  void _handleFailure(CustomException e) {
    if (_isDebugMode) {
      throw e;
    } else {
      developer.log(e.cause, name: "Encountered error");
    }
  }

  void _checkNetworkAndSendEvents(var mainJSON) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      _sendRequest(mainJSON);
    } else {
      if (_isLoggingEnabled)
        developer.log("Couldn't send events because of no network connection.",
            name: "Network failure");
      _handleFailure(new CustomException("Network's not connected."));
    }
  }
}

import 'package:ingrow_client_flutter/action/ingrow_client.dart';

class ClientBuilder {
  String _apiKey;
  String _project;
  String _stream;
  bool _isDebugMode;
  bool _isLoggingEnabled;
  String _anonymousId;
  String _userId;

  ClientBuilder(this._apiKey, this._project, this._stream,  this._isDebugMode,
      this._isLoggingEnabled,
      [this._anonymousId, this._userId]);

  bool get isLoggingEnabled => _isLoggingEnabled;

  bool get isDebugMode => _isDebugMode;

  String get userId => _userId;

  String get anonymousId => _anonymousId;

  String get apiKey => _apiKey;

  String get stream => _stream;

  String get project => _project;

  InGrowClient build() {
    return InGrowClient(this);
  }
}

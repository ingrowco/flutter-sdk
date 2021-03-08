import 'dart:convert';

class NetworkResponse {
  final String message;

  NetworkResponse({this.message});

  factory NetworkResponse.fromRawJson(String str) =>
      NetworkResponse.fromJson(json.decode(str));

  factory NetworkResponse.fromJson(Map<String, dynamic> json) =>
      NetworkResponse(message: json["message"]);

  Map<String, dynamic> toJson() => {"message": message};
}

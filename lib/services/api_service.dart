import 'dart:convert';
import 'dart:developer';

import 'package:ft_chat/models/User.dart';
import 'package:http/http.dart' as http;

class Constant {
  static const String server = "172.17.0.1:3000";
  static const String login = "/api/login";
  static const String register = "/api/registeration";
}

class ApiService {
  static ApiService instance = ApiService();

  Future login(String email, String password) async {
    Map<String, String?> parameters;
    var params = {
      'email': email,
      'password': password,
    };
    parameters = params;
    var uri = Uri.http(Constant.server, Constant.login);
    log('request: ${uri.toString()}');

    var response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    // log('response: ${response.body}');
    // log('response: ${response.statusCode}');
    log('response: 21312 3${response.statusCode}');

    if (response.statusCode == 200) {
      return AuthData.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      return Future.error('Не коректные данные');
    } else {
      return Future.error('Error response');
    }
  }

  Future registeration(String email, String password, name) async {
    Map<String, String?> parameters;
    var params = {
      'email': email,
      'password': password,
    };
    parameters = params;
    var uri = Uri.http(Constant.server, Constant.register);
    log('request: ${uri.toString()}');

    var response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'name': name,
      }),
    );
    log('response: ${response.body}');
    log('response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return AuthData.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      return Future.error('Не коректные данные');
    } else {
      return Future.error('Error response');
    }
  }
}

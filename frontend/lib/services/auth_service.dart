import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/services/prefs_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class AuthService {
  AuthService._instantiate();
  static final AuthService instance = AuthService._instantiate();

  StreamController<int> _userStreamControllerNotifier =
      StreamController<int>.broadcast();

  Stream<int> get userStreamNotifier => _userStreamControllerNotifier.stream;

  Users _currentUser;
  Users get currentUser => _currentUser;

  setUser(Users user) {
    _currentUser = user;
    PrefsService.instance.saveUser(user);
    _userStreamControllerNotifier.sink.add(0);
  }

  clearUser() {
    Users clear;
    _currentUser = clear;
    _userStreamControllerNotifier.sink.add(0);
  }

  Future<AuthenticateResponse> authenticateUser([Users user]) async {
    Uri uri = Uri.http(APIService.instance.baseUrl, '/api/authenticate');

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      HttpHeaders.acceptHeader: 'application/json',
    };

    String userData = "username=${user.name}&password=${user.password}";
    print(userData);
    var response = await http.post(uri, headers: headers, body: userData);
    print(response.body);
    if (response.statusCode == 200) {
      try {
        AuthenticateResponse auth;
        final data = json.decode(response.body) as Map;
        auth = AuthenticateResponse.fromMap(data);
        if (auth.success) {
          user.token = auth.token;
          setUser(user);
        }
        return auth;
      } catch (e) {
        print(e);
      }
    } else {
      print(response.statusCode);
      print('get apps failed');
    }
  }
}

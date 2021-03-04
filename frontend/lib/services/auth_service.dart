import 'dart:async';
import 'dart:io';
import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/services/prefs_service.dart';
import 'package:dio/dio.dart';

import 'api_service.dart';

class AuthService {
  AuthService._instantiate();
  static final AuthService instance = AuthService._instantiate();

  StreamController<int> _userStreamControllerNotifier =
      StreamController<int>.broadcast();

  Stream<int> get userStreamNotifier => _userStreamControllerNotifier.stream;

  StreamController<bool> _tokenStreamControllerNotifier =
      StreamController<bool>.broadcast();

  Stream<bool> get tokenStreamControllerNotifier =>
      _tokenStreamControllerNotifier.stream;

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

  Future<AuthenticateResponse> authenticateUser(
      Users user, bool keepLogedIn) async {
    Uri uri = Uri.http(APIService.instance.baseUrl, '/api/authenticate');

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      HttpHeaders.acceptHeader: 'application/json',
    };

    String userData =
        "username=${user.name}&password=${user.password}&keep_logged_in=${keepLogedIn}";
    Response response = await Dio().postUri(uri,
        options: Options(
            contentType: Headers.formUrlEncodedContentType, headers: headers),
        data: userData);
    if (response.statusCode == 200) {
      try {
        AuthenticateResponse auth;
        final data = response.data as Map;
        auth = AuthenticateResponse.fromMap(data);
        if (auth.success) {
          user.token = auth.token;
          user.password = "";
          setUser(user);
        }
        return auth;
      } catch (e) {
        print(e);
      }
    } else {
      print(response.statusCode);
      print('Failed to send auth request');
    }
  }

  Stream<int> checkUserStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      if (_currentUser != null) {
        int respCode = await APIService.instance.testFetch(_currentUser.token);
        yield respCode;
      }
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:dashi/models/dashi_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class APIService {
  APIService._instantiate();
  static final APIService instance = APIService._instantiate();

  String _baseUrl = '';
  String get baseUrl => _baseUrl;

  StreamController<int> _urlStreamControllerNotifier =
      StreamController<int>.broadcast();

  Stream<int> get urlStreamNotifier => _urlStreamControllerNotifier.stream;

  setBaseUrl([url]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedBaseUrl = prefs.getString('baseUrl');
    if (url == null) {
      if (savedBaseUrl == null) {
        if (kIsWeb) {
          const dashiBaseUrl = String.fromEnvironment('DASHI_API_BASE_URL');
          _baseUrl = dashiBaseUrl;
        }
      } else {
        _baseUrl = savedBaseUrl;
      }
    } else {
      _baseUrl = url;
      await prefs.setString('baseUrl', _baseUrl);
    }
    _urlStreamControllerNotifier.sink.add(0);
    print("Dashi API Base URL being set to: ");
    print(_baseUrl);
  }

  Future<List<Apps>> fetchApps([String authToken]) async {
    Uri uri = Uri.http(_baseUrl, '/api/apps');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    if (authToken != null) {
      headers["Authorization"] = "Bearer ${authToken}";
    }
    var response = await http.get(uri, headers: headers);
    print(response.body);
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body) as Map;
        List<Apps> apps = [];
        for (final appName in data.keys) {
          var newApp = Apps.fromMap(data[appName]);
          newApp.name = appName;
          apps.add(newApp);
        }
        return apps;
      } catch (e) {
        print(e);
      }
    } else {
      print(response.statusCode);
      print('get apps failed');
    }
  }

  Future<Dashboard> fetchDashboardConfig() async {
    Uri uri = Uri.http(_baseUrl, '/api/dashboard');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    var response = await http.get(uri, headers: headers);
    print(response.body);
    if (response.statusCode == 200) {
      try {
        Dashboard dash;
        final data = json.decode(response.body) as Map;
        dash = Dashboard.fromMap(data);
        return dash;
      } catch (e) {
        print(e);
      }
    } else {
      print(response.statusCode);
      print('get apps failed');
    }
  }

  Future<AuthenticateResponse> authenticateUser(Users user) async {
    Uri uri = Uri.http(_baseUrl, '/api/authenticate');

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
        return auth;
      } catch (e) {
        print(e);
      }
    } else {
      print(response.statusCode);
      print('get apps failed');
    }
  }

  Future<GeneratePasswordResponse> genPassword(String password) async {
    Uri uri = Uri.http(_baseUrl, '/api/generate-password');

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      HttpHeaders.acceptHeader: 'application/json',
    };

    String userData = "password=${password}";
    print(userData);
    var response = await http.post(uri, headers: headers, body: userData);
    print(response.body);
    if (response.statusCode == 200) {
      try {
        GeneratePasswordResponse hash;
        final data = json.decode(response.body) as Map;
        hash = GeneratePasswordResponse.fromMap(data);
        return hash;
      } catch (e) {
        print(e);
      }
    } else {
      print(response.statusCode);
      print('get apps failed');
    }
  }
}

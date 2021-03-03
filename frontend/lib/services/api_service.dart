import 'dart:async';
import 'dart:io';
import 'package:dashi/models/dashi_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
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

    Response response = await Dio().getUri(
      uri,
      options: Options(headers: headers),
    );
    if (response.statusCode == 200) {
      try {
        final data = response.data as Map;
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
    } else if (response.statusCode == 401) {
      headers.remove("Authorization");
      Response response = await Dio().getUri(
        uri,
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        try {
          final data = response.data as Map;
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
      }
    } else {
      print(response.statusCode);
      print('Failed to retrive apps');
    }
  }

  Future<int> testFetch(String authToken) async {
    Uri uri = Uri.http(_baseUrl, '/api/apps');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    if (authToken != null) {
      headers["Authorization"] = "Bearer ${authToken}";
    }
    Response response = await Dio().getUri(
      uri,
      options: Options(headers: headers),
    );
    return response.statusCode;
  }

  Future<Dashboard> fetchDashboardConfig() async {
    Uri uri = Uri.http(_baseUrl, '/api/dashboard');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    Response response = await Dio().getUri(
      uri,
      options: Options(headers: headers),
    );
    print(response.data);
    if (response.statusCode == 200) {
      try {
        Dashboard dash;
        final data = response.data as Map;
        dash = Dashboard.fromMap(data);
        return dash;
      } catch (e) {
        print(e);
      }
    } else {
      print(response.statusCode);
      print('Failed to retrive dashboard config');
    }
  }

  Future<GeneratePasswordResponse> genPassword(String password) async {
    Uri uri = Uri.http(_baseUrl, '/api/generate-password');

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      HttpHeaders.acceptHeader: 'application/json',
    };

    String userData = "password=${password}";
    Response response = await Dio().postUri(uri,
        options: Options(
            contentType: Headers.formUrlEncodedContentType, headers: headers),
        data: userData);
    if (response.statusCode == 200) {
      try {
        GeneratePasswordResponse hash;
        final data = response.data as Map;
        hash = GeneratePasswordResponse.fromMap(data);
        return hash;
      } catch (e) {
        print(e);
      }
    } else {
      print(response.statusCode);
      print('Failed to generate password');
    }
  }
}

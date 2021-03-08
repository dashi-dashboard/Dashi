import 'dart:async';
import 'dart:io';
import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/services/auth_service.dart';
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
          const dashiBaseUrl =
              String.fromEnvironment('DASHI_API_BASE_URL', defaultValue: "");
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
    List<Apps> apps = [];
    Uri uri = Uri.http(_baseUrl, '/api/apps');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    if (authToken != null) {
      headers["Authorization"] = "Bearer ${authToken}";
    }

    _handleDioResponse(dynamic response) {
      final data = response.data as Map;
      for (final appName in data.keys) {
        var newApp = Apps.fromMap(data[appName]);
        newApp.name = appName;
        apps.add(newApp);
      }
    }

    _handleDioError(dynamic error) async {
      headers.remove("Authorization");
      await Dio()
          .getUri(
            uri,
            options: Options(
              headers: headers,
              validateStatus: (status) {
                return status <= 500;
              },
            ),
          )
          .then(_handleDioResponse)
          .catchError((error) => print(error));
    }

    try {
      await Dio()
          .getUri(
            uri,
            options: Options(headers: headers),
          )
          .then(_handleDioResponse)
          .catchError(
        (error) async {
          await _handleDioError(error);
        },
      );
    } catch (e) {
      print(e);
    }

    if (apps.isNotEmpty) {
      return apps;
    }
  }

  Future<int> testFetch(String authToken) async {
    Uri uri = Uri.http(_baseUrl, '/api/dashboard');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    if (authToken != null) {
      headers["Authorization"] = "Bearer ${authToken}";
    }
    Response response = await Dio().getUri(
      uri,
      options: Options(
        headers: headers,
        validateStatus: (status) {
          return status <= 500;
        },
      ),
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

  Future<bool> preRunCheck() async {
    bool returnVal = false;
    Uri uri = Uri.http(_baseUrl, '/api/dashboard');

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    _handleDioResponse(dynamic response) {
      if (response.statusCode == 200) {
        if (response.data.toString().contains("<!DOCTYPE html>")) {
          returnVal = false;
        } else {
          returnVal = true;
        }
      } else {
        returnVal = false;
      }
    }

    _handleDioError(dynamic error) {
      returnVal = false;
    }

    try {
      await Dio()
          .getUri(
            uri,
            options: Options(
              headers: headers,
              validateStatus: (status) {
                return status <= 500;
              },
            ),
          )
          .then(_handleDioResponse)
          .catchError(_handleDioError);
    } catch (e) {
      print(e);
    }
    return returnVal;
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

  Future<bool> appLongPole() async {
    Uri uri = Uri.http(_baseUrl, '/api/apps/poll');
    bool reload = false;
    Map<String, String> headers = {
      HttpHeaders.acceptHeader: 'application/json',
    };

    _handleDioResponse(dynamic response) {
      if (response.data.toString().isNotEmpty) {
        print("Reloading dashboard");
        reload = true;
      }
    }

    await Dio()
        .getUri(
          uri,
          options: Options(headers: headers, receiveTimeout: 30000),
        )
        .then(_handleDioResponse)
        .catchError((error) => print(error));
    return reload;
  }

  Stream checkAppsStream() async* {
    while (true) {
      bool reload = await APIService.instance.appLongPole();
      if (reload) {
        yield true;
      } else {
        yield false;
      }
    }
  }
}

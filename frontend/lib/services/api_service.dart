import 'dart:convert';
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
    print("Dashi API Base URL being set to: ");
    print(_baseUrl);
  }

  Future<List<Apps>> fetchApps() async {
    Uri uri = Uri.http(_baseUrl, '/api/apps');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    var response = await http.get(uri, headers: headers);
    print(response.body);
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body) as Map;
        print(data);
        List<Apps> apps = [];
        for (final appName in data.keys) {
          var newApp = Apps.fromMap(data[appName]);
          newApp.name = appName;
          apps.add(newApp);
          print(newApp.icon);
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
}

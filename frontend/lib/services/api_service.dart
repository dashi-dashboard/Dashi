import 'dart:convert';
import 'dart:io';
import 'package:dashi/models/dashi_model.dart';
import 'package:http/http.dart' as http;

class APIService {
  APIService._instantiate();
  static final APIService instance = APIService._instantiate();

  // final String _baseUrl = '192.168.68.91:8443';
  String _baseUrl = '';

  Future<List<Apps>> fetchApps() async {
    const dashiBaseUrl = String.fromEnvironment('DASHI_API_BASE_URL');
    print("Dashi API Base URL being set to: ");
    print(dashiBaseUrl);
    _baseUrl = dashiBaseUrl;

    Uri uri = Uri.http(_baseUrl, '/api/apps');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    var response = await http.get(uri, headers: headers);
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map;
      print(data);
      List<Apps> apps = [];
      for (final appName in data.keys) {
        print(data[appName]);
        var newApp = Apps.fromMap(data[appName]);
        newApp.name = appName;
        apps.add(newApp);
      }

      return apps;
    } else {
      print(response.statusCode);
      print('get apps failed');
    }
  }
}

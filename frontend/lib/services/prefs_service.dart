import 'dart:async';
import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  PrefsService._instantiate();
  static final PrefsService instance = PrefsService._instantiate();

  StreamController<String> _viewStreamControllerNotifier =
      StreamController<String>.broadcast();

  Stream<String> get viewStreamControllerNotifier =>
      _viewStreamControllerNotifier.stream;

  setPref(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String savedPref = prefs.getString(key);
      if (savedPref == null) {
        await prefs.setString(key, value);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  getPref(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String savedPref = prefs.getString(key);
      return savedPref;
    } catch (e) {
      return null;
    }
  }

  deletePref(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool removedPref = await prefs.remove(key);
    return removedPref;
  }

  saveUser(Users user) async {
    await setPref("username", user.name);
    await setPref("password", user.password);
    await setPref("token", user.token);
    await setPref("role", user.role);
  }

  getSavedUser() async {
    String username = await getPref("username");
    String password = await getPref("password");
    String token = await getPref("token");
    String role = await getPref("role");
    Users toReturn =
        Users(name: username, password: password, role: role, token: token);
    return toReturn;
  }

  removeUser(Users user) async {
    await deletePref("username");
    await deletePref("password");
    await deletePref("token");
    await deletePref("role");
    AuthService.instance.clearUser();
  }

  setView(String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString("viewType", type);
      _viewStreamControllerNotifier.sink.add(type);
      return true;
    } catch (e) {
      return false;
    }
  }
}

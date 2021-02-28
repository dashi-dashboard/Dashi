import 'dart:async';

import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/services/api_service.dart';
import 'package:dashi/services/auth_service.dart';
import 'package:dashi/services/prefs_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'base_page_viewmodel.dart';

class SettingsViewModel extends BaseViewModel {
  // ignore: close_sinks

  bool _ready = false;
  bool get ready => _ready;

  Users _currentUser;
  Users get currentUser => _currentUser;

  getInfo() async {
    _ready = false;
    getCurrentUser();
    _ready = true;
    notifyListeners();
    APIService.instance.urlStreamNotifier.listen((value) async {
      await getCurrentUser();
    });
  }

  getCurrentUser() {
    _currentUser = AuthService.instance.currentUser;
    notifyListeners();
  }

  setBaseUrl(String url) async {
    await APIService.instance.setBaseUrl(url);
  }

  signOut() async {
    await PrefsService.instance.removeUser(AuthService.instance.currentUser);
    getInfo();
  }
}

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

  String _viewType = "grid";
  String get viewType => _viewType;

  getInfo() async {
    _ready = false;
    getCurrentUser();
    getViewType();
    _ready = true;
    notifyListeners();
    APIService.instance.urlStreamNotifier.listen(
      (value) async {
        await getCurrentUser();
      },
    );
    PrefsService.instance.viewStreamControllerNotifier.listen(
      (event) async {
        await getViewType();
      },
    );
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

  setViewType(String type) async {
    await PrefsService.instance.setView(type);
  }

  getViewType() async {
    var newViewType = await PrefsService.instance.getPref("viewType");
    if (newViewType != null) {
      _viewType = newViewType;
      notifyListeners();
    }
  }
}

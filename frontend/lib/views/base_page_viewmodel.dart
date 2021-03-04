import 'dart:async';

import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/services/api_service.dart';
import 'package:dashi/services/auth_service.dart';
import 'package:dashi/services/prefs_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class BasePageViewModel extends BaseViewModel {
  // ignore: close_sinks

  bool _ready = false;
  bool get ready => _ready;

  Dashboard _background;
  Dashboard get background => _background;

  List<Apps> _apps = [];
  List<Apps> get apps => _apps;

  double _currentPage = 0;
  double get currentPage => _currentPage;

  bool _validToken = false;
  bool get validToken => _validToken;

  List _tags = [];
  List get tags => _tags;

  String _viewType = "grid";
  String get viewType => _viewType;

  getInfo() async {
    _ready = false;
    await APIService.instance.setBaseUrl();
    await updateUser();
    await fetchDashboardConfig();
    await fetchApps();
    getTagList();
    await getViewType();
    _ready = true;
    notifyListeners();
    tokenValidCheck();
    AuthService.instance.userStreamNotifier.listen(
      (value) async {
        await fetchApps();
      },
    );
    PrefsService.instance.viewStreamControllerNotifier.listen(
      (event) async {
        await getViewType();
      },
    );
  }

  fetchApps() async {
    String _authToken;
    if (AuthService.instance.currentUser != null) {
      _authToken = AuthService.instance.currentUser.token;
    }
    _apps = await APIService.instance.fetchApps(_authToken);
    notifyListeners();
  }

  updateUser() async {
    Users user = await PrefsService.instance.getSavedUser();
    if (user.name != null) {
      AuthService.instance.setUser(user);
    }
  }

  fetchDashboardConfig() async {
    _background = await APIService.instance.fetchDashboardConfig();
    notifyListeners();
  }

  updateCurrentPage(double pageNum) {
    _currentPage = pageNum;
    notifyListeners();
  }

  tokenValidCheck() async {
    AuthService.instance.checkUserStream().listen(
      (event) async {
        if (event == 401) {
          _validToken = false;
          await PrefsService.instance
              .removeUser(AuthService.instance.currentUser);
          await AuthService.instance.clearUser();
          print("Token Expired. Logging out");
        } else if (event == 200) {
          _validToken = true;
        } else {
          _validToken = false;
        }
      },
    );
  }

  getTagList() {
    List tags = [];
    for (var i = 0; i < _apps.length; i++) {
      String currentAppTag = _apps[i].tag;
      if (!tags.contains(currentAppTag)) {
        tags.add(currentAppTag);
      }
    }
    _tags = tags;
    notifyListeners();
  }

  getViewType() async {
    var newViewType = await PrefsService.instance.getPref("viewType");
    if (newViewType != null) {
      _viewType = newViewType;
      notifyListeners();
    }
  }
}

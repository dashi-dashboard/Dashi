import 'dart:async';

import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/services/api_service.dart';
import 'package:dashi/services/auth_service.dart';
import 'package:dashi/services/prefs_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SignInViewModel extends BaseViewModel {
  // ignore: close_sinks

  bool _ready = false;
  bool get ready => _ready;

  bool _loginError = false;
  bool get loginError => _loginError;

  signIn(String username, String password) async {
    Users user = Users(name: username, password: password, role: "");
    AuthenticateResponse auth =
        await AuthService.instance.authenticateUser(user);
    return auth;
  }

  setLoginError(value) {
    _loginError = value;
    notifyListeners();
  }
}

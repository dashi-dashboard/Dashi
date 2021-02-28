import 'dart:async';

import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/services/api_service.dart';
import 'package:dashi/services/auth_service.dart';
import 'package:dashi/services/prefs_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class RegisterViewModel extends BaseViewModel {
  // ignore: close_sinks

  bool _ready = false;
  bool get ready => _ready;

  String _passwordHash = "";
  String get passwordHash => _passwordHash;

  generatePassword(String password) async {
    GeneratePasswordResponse hash =
        await APIService.instance.genPassword(password);
    _passwordHash = hash.hash;
    notifyListeners();
  }
}

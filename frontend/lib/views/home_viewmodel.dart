import 'dart:async';

import 'package:dashi/models/dashi_model.dart';
import 'package:dashi/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

DateTime today = new DateTime.now();
String date =
    "${today.year.toString()}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

class HomeViewModel extends BaseViewModel {
  // ignore: close_sinks

  bool _ready = false;
  bool get ready => _ready;

  List<Apps> _apps = [];
  List<Apps> get apps => _apps;

  getInfo() async {
    _ready = false;
    await APIService.instance.setBaseUrl();
    await fetchApps();
    _ready = true;
    notifyListeners();
  }

  fetchApps() async {
    _apps = await APIService.instance.fetchApps();
    notifyListeners();
  }
}

import 'package:dashi/app/theme_data.dart';
import 'package:dashi/views/base_page_view.dart';
import 'package:dashi/views/home_view.dart';
import 'package:dashi/views/settings_view.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dashi',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: BasePageView());
  }
}
